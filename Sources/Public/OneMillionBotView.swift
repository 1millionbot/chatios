//
//  EntryPoint.swift
//  OneMillionBot
//
//  Created by Adrián Rubio on 22/01/2021.
//

import Foundation
import UIKit
 
import Combine
import SwiftUI
import Kingfisher

@available(iOS 13.0, *)
public final class OneMillionBotView: UIView {
    private var cancellables = Set<AnyCancellable>()
    private let navApperarance = UINavigationBar
        .appearance(whenContainedInInstancesOf:
            [UIHostingController<OneMillionBotRoot>.self]
        )
    
    lazy private var viewModel: EntryPointViewModel = {
        return .init(
            apiKey: OneMillionBot.instance.apiKey
        )
    }()
    
    let position: Position
    public enum Position {
        case bottomRight
    }
    
    // MARK: Subviews
    
    lazy private(set) var avatar: UIImageView = createAvatar()
    lazy private(set) var speechBubble: SpeechBubble = createSpeechBubble()
    lazy private(set) var closeButton: UIButton = createCloseButton()
    
    // MARK: Initialization
    
    public init(_ position: Position = .bottomRight) {
        self.position = position
        super.init(frame: .zero)
        
        sharedInit()
    }
    
    public required init?(coder: NSCoder) {
        self.position = .bottomRight
        super.init(coder: coder)
        
        sharedInit()
    }
    
    // MARK: Layout
        
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        setUpViewModelEvents()
    }
    
    // MARK: Action
    
    @objc func onTap() {
        viewModel.openChatBot()
    }
    
    @objc func close() {
        // TODO: deallocate views and related
        makeVisible(false)
    }
    
    // MARK: Private methods
    
    private func sharedInit() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(avatar)
        addSubview(speechBubble)
        addSubview(closeButton)

        layoutSuviews(in: position)
                
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTap)))
        
        alpha = 0
    }

    private func setUpViewModelEvents() {
        viewModel.configRecieved.sink { [unowned self] config in
            configViews(config)
        }.store(in: &cancellables)
        
        viewModel.hideBubble.sink { [unowned self] in
            self.speechBubble.alpha = 0
        }.store(in: &cancellables)
    }

    private func configViews(_ config: BotConfig) {
        navApperarance.barTintColor = .init(hexString: config.colorHex)
        navApperarance.tintColor = .white
        navApperarance.isTranslucent = false
        navApperarance.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        
        speechBubble.text = config.callToAction
        avatar.kf.setImage(
            with: config.avatarUrl,
            completionHandler: { _ in
                self.makeVisible(true)
            }
        )
    }
    
    private func makeVisible(_ bool: Bool) {
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                self.alpha = bool ? 1 : 0
            })
    }
}
