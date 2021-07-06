//
//  UserEndpoints.swift
//  OneMillionBot
//
//  Created by Adrián R on 19/5/21.
//

import Foundation

extension APIEndpoint where Input == UserPostDTO, Output == UserResultDTO {
    static func createUser(_ dto: Input) -> Self {
        return .init(
            path: "/users",
            input: dto,
            method: .POST
        )
    }
}
