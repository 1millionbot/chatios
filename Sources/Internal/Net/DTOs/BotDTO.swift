//
//  BotDTO.swift
//  OneMillionBotAPI
//
//  Created by Adrián R on 18/5/21.
//

import Foundation

struct BotStyleDTO: Codable {
    let primary_color: String
}

struct BotResultDTO: Codable {
    let bot: BotDTO
}

struct GdprDTO: Codable {
    let url: GdprUrlDTO
    let message: GdprMessageDTO
}

struct GdprMessageDTO: Codable {
    let es: String?
    let en: String?
    let va: String?
    let ca: String?
}

struct GdprUrlDTO: Codable {
    let es: URL?
    let en: URL?
    let va: URL?
    let ca: URL?
}

struct BotDTO: Codable {
    let _id: String
    let aliases: [BotAliasDTO]
    let gdpr: GdprDTO
}

struct BotAliasDTO: Codable {
    let _id: String
    let name: String
    let image: URL
    let call_to_action: String
    let styles: BotStyleDTO
    let welcome_message: WelcomeMessageDTO
    let languages: [String]
}

struct WelcomeMessageDTO: Codable {
    let web: WebDTO
}

struct WebDTO: Codable {
    let es: [WrapperMessage]?
    let en: [WrapperMessage]?
    let ca: [WrapperMessage]?
    let va: [WrapperMessage]?
}

