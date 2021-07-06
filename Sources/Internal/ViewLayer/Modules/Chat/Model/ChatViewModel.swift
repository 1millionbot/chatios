//
//  ChatViewModel.swift
//  OneMillionBot
//
//  Created by Adrián Rubio on 27/01/2021.
//

import Foundation
import Combine
import UIKit

final class ChatViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    private var messageCancellable: AnyCancellable?
    
    private let privacyUrl: [String: URL?]
    private let repo: ChatRepo
    
    @Published var isRecording: Bool = false
    @Published var floatingOptions = FloatingOptions(options: [])
    @Published var messages: [Message] = []
    @Published var error: Error? = nil
        
    private let _scrollAction: PassthroughSubject<Void, Never> = .init()
    var scrollAction: AnyPublisher<Void, Never> {
        return _scrollAction.eraseToAnyPublisher()
    }
    
    init(
        config: BotConfig,
        language: Language?
    ) {
        self.privacyUrl = config.privacyPolicyURL
        self.repo = ChatRepo(botConfig: config, language: language)
    }
    
    // MARK: Output
    
    func attach() {
        status(.chatOpened)
        
        if messageCancellable == nil {
            setUpRepoPipeline()
            repo.initialize()
        }
    }
    
    // MARK: Input
    
    lazy private(set) var status = { [unowned self] status in
        repo.sendStatus(status)
    }
    
    lazy private(set) var deleteData = { [unowned self] in
        status(.chatClosed)
        status(.deleteData)

        Env.nav.closeChat()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            SwiftUIViewModelProvider.shared.release(Self.self)
            
            Env.diskStorage.delete(POLICY_ACCEPTED)
            Env.diskStorage.delete(USER)
            Env.diskStorage.delete(CONVERSATION)
        }
    }
    
    lazy private(set) var openPrivacyPolicy = { [unowned self] in
        if let url = self.privacyUrl[Env.lanCode] ?? nil {
            self.open(url)
        }
    }
    
    let open: (_ url: URL) -> Void = { url in
        Env.nav.openInBrowser(url)
    }
    
    lazy private(set) var scrollToBottom: () -> Void = { [unowned self] in
        self._scrollAction.send()
    }
    
    lazy private(set) var selected: (_ option: BotOption) -> Void = { [unowned self] option in
        switch option {
        case let .link(_, _, url):
            self.open(url)
        case let .text(_, text, _):
            self.sendBotOption(option)
        }
    }
    
    lazy private(set) var send: (_ message: String) -> Void = { [unowned self] message in
        guard !message.isEmpty else { return }
        
        self.send(
            UserMessageAndStatus(message: .init(text: message)),
            retrying: false
        )
    }
    
    lazy private(set) var beginSpeechToText = { [unowned self] in
        self.isRecording = true
        
        Env.speech.begin().sink(receiveCompletion: { [unowned self] event in
            if case let .failure(error) = event {
                self.error = error
                self.stopSpeechToText(true)
            }
        }, receiveValue: { [unowned self] in
            self.send($0)
        }).store(in: &self.cancellables)
    }

    lazy private(set) var stopSpeechToText = { [unowned self] (discard: Bool) in
        self.isRecording = false
        
        Env.speech.end(discard)
    }
    
    lazy private(set) var retryMessage = { [weak self] (id: UUID) in
        guard let sf = self, let message = sf.messages.first(where: { $0.id == id }),
             let userMessage = message.userMessage
        else {
            return
        }
        
        sf.send(
            sf.mark(userMessage, with: .pending),
            retrying: true,
            firstOfMany: message.firstOfMany
        )
    }
    
    lazy private(set) var showPhoto = { [unowned self] (image: UIImage) in
        Env.nav.showPhoto(image)
    }
    
    // MARK: Private
    
    private func sendBotOption(_ botOption: BotOption) {
        let userMessage = UserMessageAndStatus(
            message: .init(text: botOption.title, optionValue: botOption.value),
            status: .pending
        )
        
        send(userMessage, retrying: false)
    }
    
    private func setUpRepoPipeline() {
        messageCancellable = repo.messagePipeline
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] msgs in
                msgs.forEach { msg in
                    if case .user(_, firstOfMany: _) = msg,
                       let index = messages.firstIndex(where: { $0.id == msg.id }) {
                        messages[index] = msg
                    } else {
                        messages.insert(msg, at: 0)
                    }
                }
            }
        
        repo.errorPipeline
            .receive(on: DispatchQueue.main)
            .sink { error in
                Env.log(error.dumped)
            }.store(in: &cancellables)
        
        repo.floatingOptionsPipeline
            .receive(on: DispatchQueue.main)
            .map { FloatingOptions($0) }
            .sink(receiveValue: { [unowned self] in
                floatingOptions = $0
            })
            .store(in: &cancellables)
    }
    
    private func send(
        _ userMessage: UserMessageAndStatus,
        retrying: Bool,
        firstOfMany: Bool? = nil
    ) {
        scrollToBottom()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.repo.sendMessage(userMessage.message, retrying: retrying, firstOfMany: firstOfMany)
        }
    }
    
    private func writingMessage(show: Bool) {
        let message = Message.bot(.writing, firstOfMany: true)

        if show {
            messages.insert(message, at: 0)
        } else {
            messages.removeAll { message.id == $0.id }
        }
    }
    
    @discardableResult
    private func mark(_ message: UserMessageAndStatus, with status: TextMessageStatus) -> UserMessageAndStatus {
        
        guard let index = messages.firstIndex(where: {
            $0.userMessage == message
        }) else { return message }
        
        var copy = message
        copy.status = status
        
        messages[index] = .user(copy, firstOfMany: messages[index].firstOfMany)
        
        return copy
    }
}
