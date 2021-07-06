//
//  AlertController.swift
//  OneMillionBot
//
//  Created by Adrián Rubio on 11/02/2021.
//

import Foundation
import UIKit
import SwiftUI

struct AlertSelector<A, Content: View>: UIViewControllerRepresentable {
    
    @Binding var shouldPresent: Bool

    let title: String?
    let message: String?
    let options: [(String, A)]
    let selected: (A) -> Void
    let content: Content
    
    internal init(
        shouldPresent: Binding<Bool>,
        title: String?,
        message: String?,
        options: [(String, A)],
        selected: @escaping (A) -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._shouldPresent = shouldPresent
        self.title = title
        self.message = message
        self.options = options
        self.selected = selected
        self.content = content()
    }
        
    func makeUIViewController(context: Context) -> UIHostingController<Content> {
        let vc = UIHostingController(rootView: content)
        vc.view.backgroundColor = .clear

        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIHostingController<Content>, context: Context) {
        
        uiViewController.rootView = content
        
        if shouldPresent && uiViewController.presentedViewController == nil {
            let vc = createAlert()
            uiViewController.present(vc, animated: true)
        }
    }
    
    func createAlert() -> UIAlertController {
        let vc = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        vc.overrideUserInterfaceStyle = .light
        
        options.forEach { title, object in
            vc.addAction(
                .init(
                    title: title,
                    style: .default,
                    handler: { _ in
                        shouldPresent = false
                        selected(object)
                    }
                )
            )
        }
        
        return vc
    }
}

extension View {
    func alert<A>(
        isPresent: Binding<Bool>,
        options: [(String, A)],
        selected: @escaping (A) -> Void,
        title: String? = nil,
        message: String? = nil
    ) -> some View {
        return AlertSelector(
            shouldPresent: isPresent,
            title: title,
            message: message,
            options: options,
            selected: selected,
            content: { AnyView(self) }
        )
    }
}
