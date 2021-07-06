//
//  APIEnvironment.swift
//  OneMillionBotAPI
//
//  Created by Adrián R on 18/5/21.
//

import Foundation

public struct APIEnv {
    public let url: URL
    public let urlSocket: URL
}

extension APIEnv {
    public static var staging: APIEnv {
        return APIEnv(
            url: safe("https://staging-api.1millionbot.com/api/public"),
            urlSocket: safe("https://socket-staging.1millionbot.com")
        )
    }
    
    public static var production: APIEnv {
        return APIEnv(
            url: safe("https://api.1millionbot.com/api/public"),
            urlSocket: safe("https://socket.1millionbot.com")
        )
    }
}
