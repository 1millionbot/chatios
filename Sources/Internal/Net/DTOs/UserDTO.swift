//
//  UserDTO.swift
//  OneMillionBotAPI
//
//  Created by Adrián R on 18/5/21.
//

import Foundation

struct UserDTO: Codable {
    let _id: String
    let name: String
    
    /// id
    let bot: String
    
    let country: String
    let ip: String
    let language: String
    let platform: String
    let timezone: String
    let company: String
}

struct UserPostDTO: Codable {
    /// id
    let bot: String
    
    let country: String
    let ip: String
    let language: String
    let platform: String
    let timezone: String
}

struct UserResultDTO: Codable {
    let user: UserDTO
}
