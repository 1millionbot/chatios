//
//  Menu.swift
//  OneMillionBot
//
//  Created by Adrián Rubio on 12/02/2021.
//

import SwiftUI
 

enum RemoveData {
    case yes
    case no
}

struct Menu<Content: View>: View {
    @State var showDeleteData: Bool = false
    @State var dragOffset: CGSize = .zero
    
    @Binding var isPresent: Bool
    @Binding var showLanguageSelector: Bool
    @Binding var policyAccepted: Bool

    var deleteData: () -> Void
    var showPrivacyPolicy: () -> Void
    var content: Content
    
    var yes, no, forgetData, forgetDataText, selectLanguage, privacyPolicy: String
    
    var body: some View {
        GeometryReader() { proxy in
            ZStack(alignment: .topTrailing) {
                content
                    .zIndex(1)
                    .alert(
                        isPresent: $showDeleteData,
                        options: [
                            (yes, RemoveData.yes),
                            (no, .no)
                        ],
                        selected: {
                            if case .yes = $0 {
                                deleteData()
                                policyAccepted = false
                            }
                        },
                        title: forgetData,
                        message: forgetDataText
                    )
                
                if isPresent {
                    Color.white.opacity(0.001)
                        .onTapGesture { isPresent = false }
                    
                    VStack(spacing: 0) {
                        Button(selectLanguage) {
                            isPresent = false
                            showLanguageSelector = true
                        }
                        .buttonStyle(MenuButton())
                        
                        Divider()
                        
                        Button(privacyPolicy) {
                            isPresent = false
                            showPrivacyPolicy()
                        }
                        .buttonStyle(MenuButton())
                        
                        Divider()
                        
                        Button(forgetData) {
                            isPresent = false
                            showDeleteData = true
                        }
                        .buttonStyle(MenuButton())
                    }
                    .frame(
                        maxWidth: proxy.size.width * 0.6
                    )
                    .background(Color(UIColor.alertColor))
                    .cornerRadius(kCR, corners: [.bottomLeft, .bottomRight, .topLeft])
                    .shadow(radius: 1)
                    .padding()
                    .offset(dragOffset)
                    .highPriorityGesture(
                        DragGesture()
                            .onChanged { value in
                                let tH = value.translation.height
                                
                                dragOffset.height = tH < 0 ?
                                    tH :
                                    dragOffset.height
                            }
                            .onEnded { value in
                                let oH = dragOffset.height
                                
                                if abs(oH) > 50 {
                                    isPresent = false
                                    dragOffset = .zero
                                } else {
                                    dragOffset = .zero
                                }
                            }
                    )
                    .zIndex(2)
                    .animation(.interactiveSpring())
                    .transition(.menu)
                }
            }
        }
    }
}

struct MenuButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .font(.roboto(.body))
            .padding([.leading, .trailing], 10)
            .frame(maxWidth: .infinity, minHeight: 60)
            .background(
                configuration.isPressed ?
                    Color(UIColor.alertColor) :
                    Color.white
            )
            .foregroundColor(
                configuration.isPressed ?
                    Color(UIColor.cardButton) :
                    Color.black
            )
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(
            RoundedCorner(radius: radius, corners: corners)
        )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func showMenu(
        if condition: Binding<Bool>,
        showLanguageSelector: Binding<Bool>,
        policyAccepted: Binding<Bool>,
        showPrivacy: @escaping () -> Void,
        deleteData: @escaping () -> Void,
        localizable: LocalizableValues
    ) -> some View {
        Menu(
            isPresent: condition,
            showLanguageSelector: showLanguageSelector,
            policyAccepted: policyAccepted,
            deleteData: deleteData,
            showPrivacyPolicy: showPrivacy,
            content: self,
            yes: localizable.yes,
            no: localizable.no,
            forgetData: localizable.forgetData,
            forgetDataText: localizable.forgetDataText,
            selectLanguage: localizable.selectLanguage,
            privacyPolicy: localizable.privacyPolicy
        )
    }
}
