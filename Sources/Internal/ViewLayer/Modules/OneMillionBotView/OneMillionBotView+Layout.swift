//
//  OneMillionBotView+Layout.swift
//  OneMillionBot
//
//  Created by Adrián Rubio on 23/01/2021.
//

import Foundation
import UIKit

private let avatarSide: CGFloat = 80
private let margin: CGFloat = 20
private let closeButtonSide: CGFloat = 30

extension OneMillionBotView {
    func layoutSuviews(in position: OneMillionBotView.Position) {
        switch position {
        case .bottomRight:
            avatar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
            
            speechBubble.trailingAnchor.constraint(equalTo: avatar.leadingAnchor, constant: -5).isActive = true
            speechBubble.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
            speechBubble.roundCorners(
                corners: [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner],
                radius: kCR
            )
        }
        
        avatar.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        avatar.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        avatar.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        avatar.widthAnchor.constraint(equalToConstant: avatarSide).isActive = true
        avatar.heightAnchor.constraint(equalToConstant: avatarSide).isActive = true
        
        closeButton.topAnchor.constraint(equalTo: avatar.topAnchor, constant: -closeButtonSide*0.33).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: closeButtonSide*0.33).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: closeButtonSide).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: closeButtonSide).isActive = true
        
        speechBubble.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        speechBubble.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
    }
    
    func createAvatar() -> UIImageView {
        let v = UIImageView()
        v.clipsToBounds = true
        v.backgroundColor = .white
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = avatarSide/2
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.lightGray.cgColor
        return v
    }
    
    func createSpeechBubble() -> SpeechBubble {
        let v = SpeechBubble(padding: .init(top: 0, left: 10, bottom: 0, right: 10))
        v.backgroundColor = .mainBubbleBackground
        v.font = .preferredFont(forTextStyle: .footnote)
        v.numberOfLines = 3
        v.textColor = .black
        return v
    }
    
    func createCloseButton() -> UIButton {
        let xMark = UIImage(systemName: "xmark.circle.fill")
        let v = UIButton()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.clipsToBounds = true
        v.tintColor = .gray
        v.setImage(xMark, for: .normal)
        v.addTarget(self, action: #selector(close), for: .touchUpInside)
        return v
    }
}
