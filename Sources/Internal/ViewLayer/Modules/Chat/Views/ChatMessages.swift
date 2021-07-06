//
//  ChatMessages.swift
//  OneMillionBot
//
//  Created by Adrián Rubio on 13/02/2021.
//

import Foundation
import SwiftUI
import Combine

struct ChatMessages: View {
    @Binding var messages: [Message]
    @Binding var showScrollToBottom: Bool
    
    var shouldScroll: AnyPublisher<Void, Never>
    
    var color: String
    let responseSelected: (BotOption) -> Void
    let showMoreCards: ([BotCard]) -> Void
    let videoSelected: (URL) -> Void
    let retryMessage: (UUID) -> Void
    let showPhoto: (UIImage) -> Void
    let writingMessage: String
    
    var body: some View {
        TableView(
            messages: _messages,
            showScrollToBottom: _showScrollToBottom,
            shouldScrollObservable: shouldScroll,
            color: color,
            writingMessage: writingMessage,
            responseSelected: responseSelected,
            showMoreCards: showMoreCards,
            videoSelected: videoSelected,
            retryMessage: retryMessage,
            showPhoto: showPhoto
        )
        .flip()
        .background(
            Image(
                "back_pattern",
                bundle: Bundle.current
            )
            .resizable()
            .renderingMode(.template)
            .foregroundColor(Color.black.opacity(0.02))
            .background(Color.white)
        )
    }
}

extension View {
    public func flip() -> some View {
        return self
            .rotationEffect(.radians(.pi))
            .scaleEffect(x: -1, y: 1, anchor: .center)
    }
}

