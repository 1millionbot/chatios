//
//  BotEndpoints.swift
//  OneMillionBotAPI
//
//  Created by Adrián R on 18/5/21.
//

import Foundation

extension APIEndpoint where Input == Void, Output ==  BotResultDTO {
    static var getAnyBot: Self {
        return .init(
            path: "/bots",
            method: .GET
        )
    }
}
