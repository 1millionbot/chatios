//
//  PrivacyPolicyView.swift
//  OneMillionBot
//
//  Created by Adrián Rubio on 20/01/2021.
//

import Foundation
import SwiftUI
 
struct ScrollViewHeight: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

struct PrivacyPolicy: View {
    private let privacyPolicyText: [String: String?]
    
    private var policyHtml: String? {
        return privacyPolicyText[Env.lanCode] ?? nil
    }
    
    @ObservedObject private var viewModel: ViewModel<PrivacyPolicyViewModel>
    
    @Binding private var showMenuButton: Bool
    @Binding private var privacyPolicyAccepted: Bool
    @Binding private var showLanguageSelector: Bool
    
    @State private var svHeight: CGFloat = 0
    
    let languages: [Language]
    let localizables: LocalizableValues
        
    init(
        config: BotConfig,
        privacyAccepted: Binding<Bool>,
        showLanguageSelector: Binding<Bool>,
        showMenuButton: Binding<Bool>,
        localizables: LocalizableValues
    ) {
        self._privacyPolicyAccepted = privacyAccepted
        self._showLanguageSelector = showLanguageSelector
        self._showMenuButton = showMenuButton
        self.localizables = localizables
        self.privacyPolicyText = config.privacyPolicy
        self.viewModel = .init {
            .init(
                policyLink: config.privacyPolicyURL
            )
        }
        self.languages = config.languages
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(spacing: 0) {
                VStack {
                    ScrollView(.vertical, showsIndicators: false) {
                        if let policyText = policyHtml {
                            Text(policyText)
                                .foregroundColor(Color.black)
                                .font(.roboto(.body))
                                .padding(4)
                                .overlay(GeometryReader {
                                    Color.clear.preference(
                                        key: ScrollViewHeight.self,
                                        value: $0.size.height
                                    )
                                })
                        }
                    }
                    .frame(maxHeight: svHeight)
                    .onPreferenceChange(ScrollViewHeight.self) { height in
                        svHeight = max(height, 40)
                    }
                    
                    Button(action: viewModel.value.navigateToTOSUrl, label: {
                        Text(localizables.gdprLink)
                            .font(.roboto(.footnote))
                    })
                    .padding(.top, 10)
                }
                .padding()
                
                Divider()
                
                HStack(spacing: 0) {
                    Button(
                        action: {
                            privacyPolicyAccepted = true
                            showLanguageSelector = true
                        },
                        label: {
                            Text(localizables.yes)
                            .font(.roboto(.body))
                            .frame(maxWidth: .infinity, maxHeight: 60)
                            .contentShape(Rectangle())
                        }
                    )
                    .buttonStyle(PrivacyButton())
                    
                    Divider()
                        .frame(maxHeight: 60)
                    
                    Button(
                        action: { viewModel.policyDenied() },
                        label: {
                            Text(localizables.no)
                            .font(.roboto(.body))
                            .frame(maxWidth: .infinity, maxHeight: 60)
                            .contentShape(Rectangle())
                        }
                    )
                    .buttonStyle(PrivacyButton())
                }
            }
            .background(Color.white)
            .cornerRadius(kCR)
            .shadow(radius: 1)
            .padding()
            
            Spacer()
            
            By1MillionBot(by1millionText: localizables.byOneMBot)
        }
        .background(Color(.mainBubbleBackground))
        .onAppear {
            showMenuButton = false
        }
    }
}

struct PrivacyButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .frame(maxWidth: .infinity, minHeight: 60)
            .background(
                configuration.isPressed ?
                    Color(UIColor.alertColor) :
                    Color.white
            )
            .foregroundColor(
                configuration.isPressed ?
                    Color(UIColor.systemBlue).opacity(0.8) :
                    Color(UIColor.systemBlue)
            )
    }
}
