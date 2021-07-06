//
//  Error.swift
//  OneMillionBot
//
//  Created by Adrián Rubio on 20/01/2021.
//

import Foundation

struct StatusDecodingFailed: Error {}

enum OneMillionBotError: Error {
    case inssuficientPermissions
}

extension OneMillionBotError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .inssuficientPermissions:
            return "speech_permission_error"
        }
    }
}

extension Error {
    var dumped: String {
        var string: String = ""
        dump(self, to: &string)
        
        return string
    }
}
