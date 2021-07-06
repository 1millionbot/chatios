//
//  Chat.swift
//  OneMillionBot
//
//  Created by Adrián Rubio on 21/01/2021.
//

import Foundation
import SwiftUI
 
struct Chat: View {
    @ObservedObject var viewModel: ViewModel<ChatViewModel>
    
    @State private var currentMessage: String = ""
    @State private var displaySend: Bool = false
    @State private var showMoreCards: Bool = false
    @State private var moreCards: [BotCard] = []
    @State private var showScrollToBottom: Bool = false
    @State private var botIsWriting: Bool = false
    @State private var showError: Bool = false
    
    @Binding private var policyAccepted: Bool
    @Binding private var showLanguageSelector: Bool
    @Binding private var openMenu: Bool
    @Binding private var showMenuButton: Bool
    
    var localizables: LocalizableValues
    var color: String
    
    init(
        botConfig: BotConfig,
        openMenu: Binding<Bool>,
        showMenuButton: Binding<Bool>,
        showLanguageSelector: Binding<Bool>,
        policyAccepted: Binding<Bool>,
        localizables: LocalizableValues,
        language: Language?
    ) {
        self._showMenuButton = showMenuButton
        self._openMenu = openMenu
        self._showLanguageSelector = showLanguageSelector
        self._policyAccepted = policyAccepted
        self.localizables = localizables
        self.color = botConfig.colorHex
        
        self.viewModel = ViewModel {
            ChatViewModel(
                config: botConfig,
                language: language
            )
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                ChatMessages(
                    messages: $viewModel.messages,
                    showScrollToBottom: $showScrollToBottom,
                    shouldScroll: viewModel.scrollAction,
                    color: color,
                    responseSelected: { [unowned viewModel] (resp) in
                        viewModel.selected(resp)
                    },
                    showMoreCards: { cards in
                        moreCards = cards
                        showMoreCards = true
                    },
                    videoSelected: { viewModel.open($0) },
                    retryMessage: { viewModel.retryMessage($0) },
                    showPhoto: { viewModel.showPhoto($0) },
                    writingMessage: localizables.writing
                )
                
                ScrollToBottom(
                    shouldShowButton: showScrollToBottom,
                    color: color,
                    scrollAction: viewModel.scrollToBottom
                )
            }
                        
            VStack(spacing: 0) {
                FloatingOptionsView(
                    options: $viewModel.floatingOptions,
                    selection: viewModel.selected
                )
                
                ChatInput(
                    color: color,
                    isRecording: viewModel.isRecording,
                    inputText: $currentMessage,
                    inputHint: localizables.typingBarPlaceholder,
                    displaySend: $displaySend,
                    sendAction: viewModel.value.send,
                    beginRecording: viewModel.beginSpeechToText,
                    stopRecording: viewModel.stopSpeechToText,
                    status: viewModel.status
                )
                
                By1MillionBot(by1millionText: localizables.byOneMBot)
            }.background(Color.white)
        }
        .showMenu(
            if: $openMenu,
            showLanguageSelector: $showLanguageSelector,
            policyAccepted: _policyAccepted,
            showPrivacy: viewModel.openPrivacyPolicy,
            deleteData: viewModel.deleteData,
            localizable: localizables
        )
        .sheet(isPresented: $showMoreCards) {
            MoreCards(
                color: color,
                cards: $moreCards,
                sendAction: {
                    showMoreCards = false
                    viewModel.selected($0)
                },
                showPhoto: viewModel.showPhoto
            )
        }
        .alert(
            isPresent: $showError,
            options: [(localizables.ok, ())],
            selected: { showError = false },
            title: localizables.error,
            message: viewModel.error?.localizedDescription.localized(for: localizables.current)
        )
        .onReceive(viewModel.$error) { error in
            showError = error != nil
        }
        .onAppear {
            viewModel.value.attach()
            showMenuButton = true
        }
        .onDisappear {
            viewModel.status(.chatClosed)
        }
    }
}
