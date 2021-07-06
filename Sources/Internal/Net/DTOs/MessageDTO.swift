//
//  MessageDTO.swift
//  OneMillionBotAPI
//
//  Created by Adrián R on 18/5/21.
//

import Foundation

struct MessageButtonDTO: Codable {
    let type: MessageButtonTypeDTO
    let text: String
    let value: String
}

enum MessageButtonTypeDTO: String, Codable {
    case url = "url"
    case text = "text"
    case event = "event"
}

struct MessageCardDTO: Codable {
    let imageUrl: String?
    let title: String?
    let subtitle: String?
    let buttons: [MessageButtonDTO]?
}

struct MessageImageDTO: Codable {
    let imageUrl: URL
}

struct MessagePostDTO: Codable {
    /// id
    let conversation: String

    /// id
    let bot: String
    
    /// userId
    let sender: String
    
    let language: String
    let sender_type: String = "User"
    let message: MessageTextPostDTO
}

struct MessageResultDTO: Codable {
    let conversation: MessagesWrapper
}

struct MessagesWrapper: Codable {
    let messages: [RootMessageDTO]
}

struct MessageTextDTO: Codable {
    let text: String
}

struct MessageTextPostDTO: Codable {
    let text: String
}

struct MessageVideoDTO: Codable {
    let videoUrl: URL
    let imageUrl: URL?
}

struct PayloadMessageDTO: Codable {
    let images: [MessageImageDTO]?
    let videos: [MessageVideoDTO]?
    let buttons: [MessageButtonDTO]?
    let cards: [MessageCardDTO]?
}

struct RequestStatusDTO: Codable {
    let status: StatusDTO
    
    /// id
    let bot: String
    
    /// id
    let conversation: String
}

struct RootMessageDTO: Codable {
    let _id: String
    let message: WrapperMessage
    let sender_type: SenderTypeDTO
}

enum SenderTypeDTO: String, Codable {
    case bot = "Bot"
    case user = "User"
    case employee = "Employee"
}

struct StatusDTO: Codable {
    var online: Bool
    var typing: Bool
    var userName: String?
    var deleted: Bool
    var attended: AttendedDTO?
    var origin: String?
}

struct AttendedDTO: Codable {
    let image: String?
    let name: String?
    let employee: String?
    let department: String?
}

struct StatusWrapperDTO: Codable {
    // ??
    let data: String
}

struct WebSocketMessageDTO: Codable {
    let message: WrapperMessage
    let type: SenderTypeDTO
}

struct WrapperMessage: Codable {
    let text: String?
    let payload: PayloadMessageDTO?
}
