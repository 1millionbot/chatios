//
//  EntryPointViewModel.swift
//  OneMillionBot
//
//  Created by Adrián Rubio on 22/01/2021.
//

import Foundation
import Combine
 
import UIKit

final class EntryPointViewModel {
    private var cancellables = Set<AnyCancellable>()
    private let apiKey: String
    private let configSubject: CurrentValueSubject<BotConfig?, Never> = .init(nil)
    private let _hideBubble: PassthroughSubject<Void, Never> = .init()
    private var currentStack: UIViewController? // TODO: maybe abstract this
    
    var hideBubble: AnyPublisher<Void, Never> {
        return _hideBubble.eraseToAnyPublisher()
    }
    
    init(apiKey: String) {
        self.apiKey = apiKey
        
        initialize()
    }
    
    // MARK: Input
    
    func openChatBot() {
        configSubject
            .compactMap { $0 }
            .sink { [unowned self, nav = Env.nav] config in
                if let current = currentStack {
                    nav.presentScreen(current)
                } else {
                    currentStack = nav.presentRoot(config) {
                        _hideBubble.send()
                    }
                }
            }.store(in: &cancellables)
    }
    
    // MARK: Output
    
    var configRecieved: AnyPublisher<BotConfig, Never> {
        configSubject
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }

    // MARK: Private methods
    
    private func initialize() {
        Env
            .net
            .request(endpoint: .getAnyBot)
            .map(BotConfig.init)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { event in
                    if case let .failure(error) = event {
                        Env.log(error.localizedDescription)
                    }
                },
                receiveValue: { [unowned self] config in
                    configSubject.send(config)
                }
            ).store(in: &cancellables)
    }
    
    deinit {
        SwiftUIViewModelProvider.shared.release()
    }
}
