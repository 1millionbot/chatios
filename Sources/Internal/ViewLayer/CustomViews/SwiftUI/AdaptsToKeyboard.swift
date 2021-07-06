//
//  AdaptsToKeyboard.swift
//  OneMillionBot
//
//  Created by Adrián Rubio on 27/01/2021.
//

import Foundation
import SwiftUI
import Combine

struct AdaptsToKeyboard: ViewModifier {
    @State var currentHeight: CGFloat = 0
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .padding(.bottom, currentHeight)
                .onAppear {
                    let keyboardWillChange = NotificationCenter.Publisher(
                        center: .default,
                        name: UIResponder.keyboardWillChangeFrameNotification
                    )
                    
                    let keyBoardWillShow = NotificationCenter.Publisher(
                        center: .default,
                        name: UIResponder.keyboardWillShowNotification
                    )
                    
                    keyBoardWillShow.merge(with: keyboardWillChange)
                        .compactMap { notification in
                            notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
                        }
                        .map { rect in
                            rect.height - geometry.safeAreaInsets.bottom
                        }
                        .subscribe(Subscribers.Assign(object: self, keyPath: \.currentHeight))
                    
                    NotificationCenter.Publisher(
                        center: .default,
                        name: UIResponder.keyboardWillHideNotification
                    )
                    .compactMap { _ in CGFloat.zero }
                    .subscribe(Subscribers.Assign(object: self, keyPath: \.currentHeight))
            }
        }
    }
}

extension View {
    func adaptsToKeyboard() -> some View {
        if #available(iOS 14, *) {
            return AnyView(self)
        } else {
            return AnyView(modifier(AdaptsToKeyboard()))
        }
    }
}
