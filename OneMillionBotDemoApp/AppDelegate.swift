//
//  AppDelegate.swift
//  OneMillionBotDemoApp
//
//  Created by Adrián Rubio on 22/01/2021.
//

import UIKit
import OneMillionBot

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        OneMillionBot.initialize(
            apiKey: "60553d58c41f5dfa095b34b9",
            apiEnv: .staging,
            logger: { print($0) }
        )

        return true
    }
}

