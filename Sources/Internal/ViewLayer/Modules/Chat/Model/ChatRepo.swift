//
//  ChatRepo.swift
//  OneMillionBot
//
//  Created by Adrián R on 18/5/21.
//

import Foundation
import Combine
import SocketIO

final class ChatRepo {
    private var manager: SocketManager?
    private var previous: Message?
    private var cancellables = [String: AnyCancellable]()
    private let config: BotConfig
    private let language: Language
    
    private let messageSubject: PassthroughSubject<[Message], Never> = .init()
    private let errorSubject: PassthroughSubject<Error, Never> = .init()
    private let initialized = CurrentValueSubject<Bool, Never>(false)
    private let floatingOptions: PassthroughSubject<[BotOption], Never> = .init()
    private let status: CurrentValueSubject<StatusDTO, Never> = .init(.new(with: ""))
    
    private var conversation: ConversationDTO? {
        Env.diskStorage.read(CONVERSATION)
    }
    
    private var user: UserDTO? {
        Env.diskStorage.read(USER)
    }
    
    // MARK: Output
    
    var messagePipeline: AnyPublisher<[Message], Never> {
        messageSubject
            .doOnNext { [unowned self] in
                // if its a confirmation of success or if the new msg
                // is the previous, dont set a new previous
                
                if $0.last?.status == .success { return }
                if let lastId = $0.last?.id, lastId == previous?.id { return }
                
                previous = $0.last
            }
            .eraseToAnyPublisher()
    }
    
    var errorPipeline: AnyPublisher<Error, Never> {
        errorSubject.eraseToAnyPublisher()
    }
    
    var floatingOptionsPipeline: AnyPublisher<[BotOption], Never> {
        floatingOptions.eraseToAnyPublisher()
    }
    
    init(botConfig: BotConfig, language: Language?) {
        self.config = botConfig
        self.language = language ?? .init(id: "es", languageName: "languages_es")
        
        status
            .map(\.attended)
            .map(RealPerson.init)
            .receive(on: DispatchQueue.main)
            .sink {
                Env.noteCenter.post(
                    Notification(
                        name: .realPerson,
                        object: $0
                    )
                )
            }
            .store(id: UUID().uuidString, in: &cancellables)
    }
    
    // MARK: Input
    
    func initialize() {
        if let user = user {
            getOrCreateConversation(user: user)
                .flatMap { [unowned self] _ in getStatus() }
                .doOnNext { [unowned self] _ in sendStatus(.chatOpened) }
                .flatMap { [unowned self] _ in getMessages(conversation!) }
                .pipe(to: messageSubject, e: errorSubject)
                .store(id: "init", in: &cancellables)
            
        } else {
            if let botMessages = config.initialMessage[language.id] ?? nil {
                let messages = botMessages.enumerated().map { offset, el in
                    Message.bot(el, firstOfMany: offset == 0)
                }
                
                messageSubject.send(messages)
            }
        }
    }
    
    func sendMessage(
        _ message: UserMessage,
        retrying: Bool,
        firstOfMany: Bool? = nil
    ) {
        lazyInitialize()
        
        let pendingMessage = Message.user(
            .init(message: message, status: .pending),
            firstOfMany: firstOfMany ?? previous.map {
                !$0.fromUser
            } ?? true
        )
        
        if !retrying {
            messageSubject.send([pendingMessage])
        }
        
        initialized.sink { [unowned self] ready in
            if ready,
               let conv = conversation,
               let user = user {
                let dto = MessagePostDTO(
                    conversation: conv._id,
                    bot: config.botId,
                    sender: user._id,
                    language: language.id,
                    message: .init(
                        text: message.optionValue ?? message.text
                    )
                )
                
                connectToSocketIfNecessary()
                
                Env.net.request(endpoint: .sendMessage(dto))
                    .doOnError { [unowned self] _ in
                        messageSubject.send([
                            Message.user(
                                .init(
                                    message: message,
                                    status: .failure
                                ),
                                firstOfMany: pendingMessage.firstOfMany
                            )
                        ])
                    }
                    .map {
                        [
                            Message.user(
                                .init(
                                    message: message,
                                    status: .success
                                ),
                                firstOfMany: pendingMessage.firstOfMany
                            )
                        ]
                    }
                    .pipe(to: messageSubject, e: errorSubject)
                    .store(id: "sendMessage", in: &cancellables)
            }
        }
        .store(id: "alreadyInit", in: &cancellables)
    }
    
    func sendStatus(_ event: StatusEvent) {
        initialized.sink { [unowned self] inited in
            guard inited else { return }
            
            if status.value.attended == nil, event == .typing {
                return
            }
            
            event.mutate(&status.value)
            
            Env.net.request(
                endpoint: .sendStatus(
                    RequestStatusDTO(
                        status: status.value,
                        bot: config.botId,
                        conversation: conversation!._id
                    )
                )
            )
            .pipe(error: errorSubject)
            .store(id: event.rawValue, in: &cancellables)
        }
        .store(id: "alreadyInitStatus", in: &cancellables)
    }
    
    // MARK: Private
    
    private func getStatus() -> AnyPublisher<StatusDTO, Error> {
        if let conv = conversation,
           let user = user {
            return Env.net.request(
                endpoint: .getStatus(
                    botId: config.botId,
                    convId: conv._id
                )
            )
            .replaceError(
                with: StatusDTO(
                    online: true,
                    typing: false,
                    userName: user.name,
                    deleted: false,
                    attended: nil,
                    origin: nil
                )
            )
            .doOnNext { [unowned self] in status.value = $0 }
            .eraseToAnyError()
        } else {
            return Fail(error: StatusDecodingFailed())
                .eraseToAnyPublisher()
        }
    }
    
    /// lazy initialization only used the first time the user initiates a conversation
    
    private func lazyInitialize() {
        if initialized.value { return }
        
        getOrCreateUser()
            .flatMap { [unowned self] user in
                getOrCreateConversation(user: user)
            }
            .pipe(error: errorSubject) { [unowned self] _ in
                initialized.send(true)
            }
            .store(id: "lazyInit", in: &cancellables)
    }
    
    private func connectToSocketIfNecessary() {
        if manager == nil, let conv = conversation {
            manager = SocketManager(
                socketURL: OneMillionBot.instance.apiEnv.urlSocket,
                config: [
                    .version(.two),
                    .connectParams([
                        "bot": config.botId,
                        "conversation": conv._id
                    ]),
                    .forceWebsockets(true)
                ]
            )
            
            let socket = manager!.defaultSocket
            
            socket.on("\(conv._id)_@_status") { [unowned self] data, ack in
                return Result {
                    try JSONSerialization.data(withJSONObject: data[0])
                }
                .flatMap { data in
                    Result {
                        try JSONDecoder().decode(StatusDTO.self, from: data)
                    }
                }
                .publisher
                .pipe(to: status, e: errorSubject)
                .store(id: "socketStatus", in: &cancellables)
            }
            
            socket.on(conv._id) { [unowned self] data, ack in
                return Result {
                    try JSONSerialization.data(withJSONObject: data[0])
                }
                .flatMap { data in
                    Result {
                        try JSONDecoder().decode(WebSocketMessageDTO.self, from: data)
                    }
                }
                .publisher
                .filter { $0.type == .bot || $0.type == .employee }
                .map(\.message)
                .doOnNext { [unowned self] in
                    floatingOptions.send(
                        BotOption.multiple(from: $0) ?? []
                    )
                }
                .map(BotMessage.multiple)
                .map { [unowned self] botMessages -> [Message] in
                    botMessages.enumerated().map { offset, message in
                        let firstOfMany = previous?.fromUser == true && offset == 0
                        return .bot(message, firstOfMany: firstOfMany)
                    }
                }
                .pipe(to: messageSubject, e: errorSubject)
                .store(id: "socketReceive", in: &cancellables)
            }
            
            socket.on(clientEvent: .error) { a, b in
                Env.log("\(a)")
            }
            
            socket.connect()
        }
    }
    
    private func getOrCreateConversation(user: UserDTO) -> AnyPublisher<ConversationDTO, Error> {
        if let conversation = conversation {
            return Just(conversation).eraseToAnyError()
        }
        
        let request = ConversationPostDTO(
            alias: config.aliasId,
            bot: config.botId,
            user: user._id,
            language: language.id,
            company: user.company,
            integration: "app"
        )
        
        return Env.net
            .request(endpoint: .createConversation(request))
            .map(\.conversation)
            .doOnNext { Env.diskStorage.write($0, for: CONVERSATION) }
            .eraseToAnyPublisher()
    }
    
    private func getOrCreateUser() -> AnyPublisher<UserDTO, Error> {
        if let user = user {
            return Just(user).eraseToAnyError()
        }
        
        let request = UserPostDTO(
            bot: config.botId,
            country: Locale.current.regionCode ?? "ES",
            ip: "0.0.0.0",
            language: language.id,
            platform: "iOS",
            timezone: TimeZone.current.identifier
        )
        
        return Env.net
            .request(endpoint: .createUser(request))
            .map(\.user)
            .doOnNext { Env.diskStorage.write($0, for: USER) }
            .eraseToAnyPublisher()
    }
    
    private func getMessages(_ conversation: ConversationDTO) -> AnyPublisher<[Message], Error> {
        return Env.net.request(endpoint: .getConversation(conversation._id))
            .map(\.conversation)
            .map(Message.multiple)
            .doOnNext { [unowned self] _ in
                initialized.send(true)
            }
            .eraseToAnyPublisher()
    }
    
    deinit {
        manager?.disconnect()
    }
}

extension AnyCancellable {
    fileprivate func store(id: String, in dict: inout [String: AnyCancellable]) {
        dict[id] = self
    }
}
