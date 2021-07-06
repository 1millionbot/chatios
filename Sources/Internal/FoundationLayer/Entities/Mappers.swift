//
//  Mappers.swift
//  OneMillionBot
//
//  Created by Adrián R on 19/5/21.
//

import Foundation

extension BotConfig {
    init(_ dto: BotResultDTO) {
        guard let alias = dto.bot.aliases.first else {
            Env.log("Invalid API response, no aliases found for bot with id \(dto.bot._id)")
            
            fatalError("Invalid API response, no aliases found")
        }
        
        self.botId = dto.bot._id
        self.aliasId = alias._id
        self.colorHex = alias.styles.primary_color
        self.languages = alias.languages.map {
            Language(id: $0, languageName: "languages_\($0)".localized)
        }
        
        self.avatarUrl = alias.image
        self.name = alias.name
        self.privacyPolicy = [
            "ca": dto.bot.gdpr.message.ca,
            "es": dto.bot.gdpr.message.es,
            "va": dto.bot.gdpr.message.va,
            "en": dto.bot.gdpr.message.en
        ]
        
        self.privacyPolicyURL = [
            "ca": dto.bot.gdpr.url.ca,
            "es": dto.bot.gdpr.url.es,
            "va": dto.bot.gdpr.url.va,
            "en": dto.bot.gdpr.url.en
        ]
        
        self.callToAction = alias.call_to_action
                
        self.initialMessage = [
            "ca": alias.welcome_message.web.ca?.flatMap(BotMessage.multiple),
            "es": alias.welcome_message.web.es?.flatMap(BotMessage.multiple),
            "va": alias.welcome_message.web.va?.flatMap(BotMessage.multiple),
            "en": alias.welcome_message.web.en?.flatMap(BotMessage.multiple)
        ]
    }
}

extension UserMessage {
    init?(_ dto: WrapperMessage) {
        guard let text = dto.text else {
            return nil
        }
        
        self.init(text: text)
    }
}

extension BotMessage {
    static func multiple(from dto: WrapperMessage) -> [BotMessage] {
        var messages = [BotMessage]()
        
        dto.payload?.videos?.forEach { video in
            messages.append(
                .video(
                    id: .init(),
                    thumbnail: video.imageUrl,
                    videoUrl: video.videoUrl
                )
            )
        }
        
        dto.payload?.images?.forEach { imageMessage in
            messages.append(
                BotMessage.image(
                    id: .init(),
                    url: imageMessage.imageUrl,
                    size: .zero
                )
            )
        }
        
        dto.text.map { text in
            messages.append(
                .text(id: .init(), text: text)
            )
        }
        
        dto.payload?.cards.map { cards in
            messages.append(
                .cards(
                    id: .init(),
                    cards: cards.map(BotCard.init)
                )
            )
        }
        
        return messages
    }
}

extension BotCard {
    init(_ dto: MessageCardDTO) {
        self.init(
            imageUrl: dto.imageUrl.flatMap(URL.init(string:)),
            options: dto.buttons?.map(BotOption.init) ?? [],
            description: dto.subtitle.flatMap {
                if $0.isEmpty { return nil }
                else { return $0 }
            },
            title: dto.title.flatMap {
                if $0.isEmpty { return nil }
                else { return $0 }
            }
        )
    }
}

extension BotOption {
    init(_ dto: MessageButtonDTO) {
        if dto.type == .url, let url = URL(string: dto.value) {
            self = .link(.init(), dto.text, url)
        } else {
            self = .text(.init(), dto.text, dto.value)
        }
    }
    
    static func multiple(from dto: WrapperMessage) -> [BotOption]? {
        return dto.payload?.buttons?.map(BotOption.init)
    }
}

extension RealPerson {
    init?(_ dto: AttendedDTO?) {
        guard let dto = dto else { return nil }
        guard let name = dto.name else { return nil }
        
        self = .init(
            image: dto.image,
            name: name, employee:
                dto.employee,
            department: dto.department
        )
    }
}

extension Message {
    static func multiple(from dto: MessagesWrapper) -> [Message] {
        var messages = [Message]()
        
        dto.messages.enumerated().forEach { offset, msg in
            switch msg.sender_type {
            case .bot, .employee:
                let previous = offset - 1 >= 0 ?
                    dto.messages[offset - 1] : nil
                let firstOfMany = previous.map { $0.sender_type == .user } ?? true

                let botMessages = BotMessage
                    .multiple(from: msg.message)
                    .enumerated()
                    .map {
                        Message.bot(
                            $0.element,
                            firstOfMany: firstOfMany
                        )
                    }
                
                messages.append(contentsOf: botMessages)
                 
            case .user:
                if let text = msg.message.text {
                    let previous = offset - 1 >= 0 ?
                        dto.messages[offset - 1] : nil
                    let firstOfMany = previous.map { $0.sender_type == .bot } ?? true
                    
                    messages.append(
                        .user(
                            .init(
                                message: .init(text: text),
                                status: .success
                            ),
                            firstOfMany: firstOfMany
                        )
                    )
                }
            }
        }
        
        return messages
    }
}

extension StatusDTO {
    init(_ jsonString: String) throws {
        guard let data = jsonString.data(using: .utf8) else {
            throw StatusDecodingFailed()
        }
        
        self = try JSONDecoder().decode(Self.self, from: data)
    }
}
