//
//  OneMillionBot.swift
//  OneMillionBot
//
//  Created by Adrián Rubio on 20/01/2021.
//

import Foundation
import UIKit

// library wide corner radius
let kCR: CGFloat = 16

internal let Env = Environment.live

@available(iOS 13.0, *)
public final class OneMillionBot {
    private(set) var apiKey: String!
    private(set) var apiEnv: APIEnv!
    private(set) var log: (String) -> Void = {
        #if DEBUG
            print($0)
        #endif
    }
    
    private init() {}
    
    static let instance: OneMillionBot = .init()
    
    public static func initialize(
        apiKey: String ,
        apiEnv: APIEnv? = nil,
        logger: ((String) -> Void)? = nil
    ) {
        instance.apiEnv = apiEnv ?? .production
        registerFontsIfNeeded()
        instance.apiKey = apiKey
        instance.log = logger ?? instance.log
        
        Env.diskStorage.cleanPreviousSetupIfNeeded()
    }
}

private var fontsRegistered: Bool = false
private func registerFontsIfNeeded() {
    guard
        !fontsRegistered,
        let fontURLs = Bundle.current.urls(
            forResourcesWithExtension: "ttf",
            subdirectory: nil
        )
    else { return }
    
    fontURLs.forEach {
        CTFontManagerRegisterFontsForURL(
            $0 as CFURL,
            .process,
            nil
        )
    }
    
    fontsRegistered = true
}
