//
//  ViewController.swift
//  OneMillionBotDemoApp
//
//  Created by Adrián Rubio on 22/01/2021.
//

import UIKit
import OneMillionBot

class ViewController: UIViewController {
    let bot = OneMillionBotView(.bottomRight)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(bot)
        NSLayoutConstraint.activate([
            bot.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            bot.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            bot.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
    }
}

