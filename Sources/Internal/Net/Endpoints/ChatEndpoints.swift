//
//  ChatEndpoints.swift
//  OneMillionBot
//
//  Created by Adrián R on 19/5/21.
//

import Foundation

extension APIEndpoint where Input == ConversationPostDTO, Output == ConversationResultDTO {
    static func createConversation(_ dto: Input) -> Self {
        return .init(
            path: "/conversations",
            input: dto,
            method: .POST
        )
    }
}

extension APIEndpoint where Input == MessagePostDTO, Output == Void {
    static func sendMessage(_ dto: Input) -> Self {
        return .init(
            path: "/messages",
            input: dto,
            method: .POST
        )
    }
}

extension APIEndpoint where Input == Void, Output == MessageResultDTO {
    static func getConversation(_ id: String) -> Self {
        return .init(
            path: "/conversations/\(id)",
            method: .GET
        )
    }
}
