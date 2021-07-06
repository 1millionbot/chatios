//
//  StatusUtilities.swift
//  OneMillionBot
//
//  Created by Adrián R on 24/5/21.
//

import Foundation

extension StatusDTO {
    static func new(with username: String) -> StatusDTO {
        return StatusDTO(
            online: true,
            typing: false,
            userName: username,
            deleted: false,
            attended: nil,
            origin: nil
        )
    }
    
    mutating func eraseData() {
        self = StatusDTO(
            online: false,
            typing: false,
            userName: nil,
            deleted: true,
            attended: nil,
            origin: nil
        )
    }
    
    mutating func userIsNotTyping() {
        typing = false
        online = true
    }
    
    mutating func userIsTyping() {
        typing = true
        online = true
    }
    
    mutating func chatClosed() {
        typing = false
        online = false
    }
    
    mutating func chatOpened() {
        typing = false
        online = true
    }
}

enum StatusEvent: String {
    case typing
    case notTyping
    case chatOpened
    case chatClosed
    case deleteData
}

extension StatusEvent {
    func mutate(_ status: inout StatusDTO) {
        switch self {
        case .typing:
            status.userIsTyping()
        case .notTyping:
            status.userIsNotTyping()
        case .chatOpened:
            status.chatOpened()
        case .chatClosed:
            status.chatClosed()
        case .deleteData:
            status.eraseData()
        }
    }
}
