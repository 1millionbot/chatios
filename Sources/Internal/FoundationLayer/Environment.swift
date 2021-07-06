//
//  Environment.swift
//  OneMillionBot
//
//  Created by Adrián Rubio on 21/01/2021.
//

import Foundation

struct Environment {
    var net: APIClient
    var log: (String) -> Void
    var diskStorage: DiskStorage
    var nav: NavigationCoordinator
    var speech:  SpeechToText
    let noteCenter: NotificationCenter
}

extension Environment {
    var lanCode: String {
        let language: Language? = diskStorage.read(LANGUAGE)
        
        return language?.id ?? Locale.current.languageCode ?? "es"
    }
    
    var speechLang: String {
        lanCode.lowercased().hasPrefix("va") ?
            "ca" : lanCode
    }
}

extension Environment {
    static var live: Environment {
        Environment(
            net: .live,
            log: OneMillionBot.instance.log,
            diskStorage: .live,
            nav: .live,
            speech: .live,
            noteCenter: .default
        )
    }
    
    static var test: Environment {
        Environment(
            net: .test,
            log: OneMillionBot.instance.log,
            diskStorage: .live,
            nav: .live,
            speech: .live,
            noteCenter: .default
        )
    }
}

