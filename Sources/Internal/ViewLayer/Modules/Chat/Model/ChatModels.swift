//
//  ChatModels.swift
//  OneMillionBot
//
//  Created by Adrián Rubio on 28/01/2021.
//

import Foundation
import UIKit

extension BotOption: Identifiable {
    var isLink: Bool {
        switch self {
        case .link(_, _, _):
            return true
        case .text(_, _, _):
            return false
        }
    }
    
    var title: String {
        switch self {
        case let .link(_, text, _):
            return text
        case let .text(_, text, _):
            return text
        }
    }
    
    var id: UUID {
        switch self {
        case let .link(id, _, _):
            return id
        case let .text(id, _, _):
            return id
        }
    }
    
    var value: String? {
        if case let .text(_, _, value) = self {
            return value
        } else {
            return nil
        }
    }
}

extension FloatingOptions {
    init(_ options: [BotOption]) {
        self = .init(options: options)
    }
}

private let writingId = UUID()
extension BotMessage {
    var id: UUID {
        switch self {
        case let .cards(id: id, _):
            return id
        case let .image(id: id, _, _):
            return id
        case let .text(id: id, _):
            return id
        case let .video(id: id, _, _):
            return id
        case .writing:
            return writingId
        }
    }
}

extension Message: Hashable, Equatable {
    static func == (lhs: Message, rhs: Message) -> Bool {
        return
            lhs.id == rhs.id &&
            lhs.size == rhs.size &&
            lhs.userMessage == rhs.userMessage
    }
    
    func hash(into hasher: inout Hasher) {
        size.map {
            hasher.combine($0.width)
            hasher.combine($0.height)
        }
        
        userMessage.map {
            hasher.combine($0)
        }
        
        hasher.combine(id)
    }
}

extension Message: Identifiable {
    var firstOfMany: Bool {
        switch self {
        case let .bot(_, firstOfMany: over):
            return over
        case let .user(_, firstOfMany: over):
            return over
        }
    }
    
    var fromUser: Bool {
        switch self {
        case .user: return true
        case .bot: return false
        }
    }
    
    var status: TextMessageStatus? {
        switch self {
        case let .user(message, firstOfMany: _):
            return message.status
        default:
            return nil
        }
    }
    
    public var id: UUID {
        switch self {
        case let .user(msg, _):
            return msg.message.id
        case let .bot(msg, _):
            return msg.id
        }
    }
        
    var text: String? {
        switch self {
        case let .user(msg, _):
            return msg.message.text
        case let .bot(.text(_, text: text), _):
            return text
        default: return nil
        }
    }
    
    var size: CGSize? {
        if case let Message.bot(.image(_, _, size), _) = self {
            return size
        } else {
            return nil
        }
    }
    
    func withSize(_ size: CGSize) -> Message {
        if case let Message.bot(.image(a, b, _), over) = self {
            return .bot(.image(id: a, url: b, size: size), firstOfMany: over)
        } else {
            fatalError()
        }
    }
    
    var userMessage: UserMessageAndStatus? {
        if case let .user(m, _) = self {
            return m
        } else { return nil }
    }
}
