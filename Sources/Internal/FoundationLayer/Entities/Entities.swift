//
//  DTOs.swift
//  OneMillionBotAPI
//
//  Created by Adrián Rubio on 21/01/2021.
//

import Foundation
import UIKit

let nothing = Nothing(dontLook: "")

struct Nothing: Decodable {
    let dontLook: String
}

struct BotConfig {
    let botId: String
    let aliasId: String
    let colorHex: String
    let languages: [Language] // SessionRepo
    let avatarUrl: URL?
    let name: String
    let initialMessage: [String: [BotMessage]?]
    let privacyPolicy: [String: String?]
    let privacyPolicyURL: [String: URL?]
    let callToAction: String
}

struct Language: Codable, Identifiable {
    public let id: String
    public let languageName: String
}

struct BotCard: Equatable, Identifiable {
    let id: UUID = UUID()
    let imageUrl: URL?
    let options: [BotOption]
    let description: String?
    let title: String?
}

struct FloatingOptions {
    var options: [BotOption]
    var completed: Bool = false
}

enum BotOption: Equatable {
    case text(UUID, String, String)
    case link(UUID, String, URL)
}

enum Message {
    case user(UserMessageAndStatus, firstOfMany: Bool)
    case bot(BotMessage, firstOfMany: Bool)
}

enum TextMessageStatus {
    case success
    case failure
    case pending
}

struct UserMessage: Equatable, Hashable {
    let text: String
    let id = UUID()
    let optionValue: String?
    
    init(text: String, optionValue: String? = nil) {
        self.text = text
        self.optionValue = optionValue
    }
}

struct UserMessageAndStatus: Hashable {
    let message: UserMessage
    var status: TextMessageStatus = .pending
}

enum BotMessage {
    case text(id: UUID, text: String)
    case image(id: UUID, url: URL, size: CGSize = .zero)
    case cards(id: UUID, cards: [BotCard])
    case video(id: UUID, thumbnail: URL?, videoUrl: URL)
    case writing
}

struct RealPerson: Equatable {
    let image: String?
    let name: String
    let employee: String?
    let department: String?
}
