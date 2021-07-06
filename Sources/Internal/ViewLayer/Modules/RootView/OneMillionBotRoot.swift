//
//  OneMillionBotRoot.swift
//  OneMillionBot
//
//  Created by Adrián Rubio on 21/01/2021.
//

 
import Foundation
import SwiftUI

struct OneMillionBotRoot: View {
    @ObservedObject private var viewModel: ViewModel<RootViewModel>
    
    @State var realPerson: RealPerson? = nil
    @State var openMenu: Bool = false
    @State var showMenuButton: Bool = false
    @State var showLanguageSelector: Bool = false
    
    private let config: BotConfig
    
    init(config: BotConfig) {
        self.viewModel = .init {
            .init(
                botConfig: config
            )
        }
        
        self.config = config
    }
    
    var showChat: Bool {
        return viewModel.languageSelected != nil && viewModel.policyAccepted
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                if showChat {
                    Chat(
                        botConfig: config,
                        openMenu: $openMenu,
                        showMenuButton: $showMenuButton,
                        showLanguageSelector: $showLanguageSelector,
                        policyAccepted: $viewModel.policyAccepted,
                        localizables: viewModel.localization,
                        language: viewModel.languageSelected
                    )
                    .transition(.chat)
                } else {
                    PrivacyPolicy(
                        config: config,
                        privacyAccepted: $viewModel.policyAccepted,
                        showLanguageSelector: .init(
                            get: {
                                viewModel
                                    .languageSelected
                                    .map { _ in false }
                                ?? showLanguageSelector
                            },
                            set: {
                                if viewModel.languageSelected == nil {
                                    showLanguageSelector = $0
                                }
                            }
                        ),
                        showMenuButton: $showMenuButton,
                        localizables: viewModel.localization
                    )
                    .transition(.privacy)
                }
            }
            .alert(
                isPresent: $showLanguageSelector,
                options: config.languages.map { ($0.languageName, $0) },
                selected: { [unowned viewModel] in viewModel.languageSelected = $0 },
                title: viewModel.localization.selectLanguage,
                message: viewModel.localization.selectLanguageText
            )
            .navigation(
                with: viewModel.state,
                close: { [unowned viewModel] in
                    viewModel.close()
                },
                shouldShowMenuButton: showMenuButton,
                openMenu: $openMenu,
                realPerson: realPerson
            )
            .onReceive(Env.noteCenter.publisher(for: .realPerson), perform: { note in
                realPerson = note.object as? RealPerson
            })
            .background(Color(.mainBubbleBackground))
            .background(
                Color(
                    showChat ? .white : .mainBubbleBackground
                ).edgesIgnoringSafeArea(.all)
            )
            .adaptsToKeyboard()
        }
    }
}
