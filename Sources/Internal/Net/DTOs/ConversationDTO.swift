//
//  ConversationDTO.swift
//  OneMillionBotAPI
//
//  Created by Adrián R on 18/5/21.
//

import Foundation

struct ConversationDTO: Codable {
    let _id: String
}

struct ConversationPostDTO: Codable {
    /// id
    let alias: String
    /// id
    let bot: String
    /// id
    let user: String
    
    let language: String
    let company: String
    let integration: String
}

struct ConversationResultDTO: Codable {
    let conversation: ConversationDTO
}
