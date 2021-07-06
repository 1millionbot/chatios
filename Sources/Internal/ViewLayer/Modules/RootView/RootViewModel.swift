//
//  RootViewModel.swift
//  OneMillionBot
//
//  Created by Adrián Rubio on 25/01/2021.
//

import Foundation
import Combine

final class RootViewModel: ObservableObject {
    @Published var state: NavigationState
    @Published var policyAccepted: Bool
    @Published var languageSelected: Language?
    @Published var localization: LocalizableValues = .init()
    
    private var cancellables = Set<AnyCancellable>()
    private let config: BotConfig
    
    init(
        botConfig: BotConfig
    ) {
        self._policyAccepted = .init(initialValue: Env.diskStorage.read(POLICY_ACCEPTED) ?? false)
        self._languageSelected = .init(initialValue: Env.diskStorage.read(LANGUAGE))
        self.config = botConfig
        self.state = .init(
            botName: config.name,
            color: config.colorHex,
            botAvatarUrl: config.avatarUrl
        )
        
        $policyAccepted.sink(receiveValue: {
            Env.diskStorage.write($0, for: POLICY_ACCEPTED)
        }).store(in: &cancellables)
        
        $languageSelected.sink(receiveValue: { [unowned self] in
            if let lan = $0 {
                localization.setLanguage(lan)

                if languageSelected?.id == $0?.id { return }

                Env.diskStorage.write(lan, for: LANGUAGE)
                
                SwiftUIViewModelProvider.shared.refresh {
                    ChatViewModel(
                        config: botConfig,
                        language: lan
                    )
                }?.attach()
            }
        }).store(in: &cancellables)
    }
    
    // MARK: Input
    
    let close: () -> Void = {
        Env.nav.closeChat()
    }
}
