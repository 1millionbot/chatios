//
//  ScrollToBottom.swift
//  OneMillionBot
//
//  Created by Adrián Rubio on 17/02/2021.
//

import SwiftUI

struct ScrollToBottom: View {
    var shouldShowButton: Bool
    var color: String
    var scrollAction: () -> Void
    
    var body: some View {
        if shouldShowButton {
            GeometryReader { proxy in
                Button(action: {
                    scrollAction()
                }) {
                    Image(systemName: "chevron.down")
                }
                .frame(width: 30, height: 30)
                .foregroundColor(Color(.init(hexString: color)))
                .background(Color.white)
                .cornerRadius(15)
                .shadow(radius: 1)
                .position(
                    x: proxy.size.width - 30,
                    y: proxy.size.height - 30
                )
            }
        }

    }
}
