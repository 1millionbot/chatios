//
//  ChatInput.swift
//  OneMillionBot
//
//  Created by Adrián Rubio on 28/01/2021.
//

import Foundation
import SwiftUI

struct ChatInput: View {
    @Binding var inputText: String
    @Binding var displaySend: Bool
    
    var isRecording: Bool
    var inputHint: String
    var color: String
    
    let sendAction: (String) -> Void
    let beginRecording: () -> Void
    let status: (StatusEvent) -> Void
    
    private let discardRecording: () -> Void
    private let commitRecording: () -> Void
    
    init(
        color: String,
        isRecording: Bool,
        inputText: Binding<String>,
        inputHint: String,
        displaySend: Binding<Bool>,
        sendAction: @escaping (String) -> Void,
        beginRecording: @escaping () -> Void,
        stopRecording: @escaping (Bool) -> Void,
        status: @escaping (StatusEvent) -> Void
    ) {
        self.isRecording = isRecording
        self.sendAction = sendAction
        self.color = color
        self.inputHint = inputHint
        self._inputText = .init(
            get: { inputText.wrappedValue },
            set: {
                if $0.isEmpty { status(.notTyping) }
                else { status(.typing) }
                
                inputText.wrappedValue = $0
            }
        )
        self._displaySend = displaySend
        self.beginRecording = beginRecording
        
        self.status = status
        self.discardRecording = { stopRecording(true) }
        self.commitRecording = { stopRecording(false) }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            if isRecording {
                DictationInput(
                    discardRecording: discardRecording,
                    color: color
                )
            } else {
                VStack {
                    TextField(
                        "",
                        text: $inputText,
                        onEditingChanged: { editing in
                            displaySend = editing
                        })
                        .font(.roboto(.body))
                        .background(
                            Color.white
                            .overlay(
                                ZStack(alignment: .leading) {
                                    if inputText.isEmpty {
                                        Text(inputHint)
                                            .font(.roboto(.body))
                                            .foregroundColor(
                                                Color(.mainBubbleBackground)
                                            )
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                            )
                        )
                        .foregroundColor(.black)
                        .padding(.all, 10)
                }
                .background(
                    RoundedRectangle(cornerRadius: kCR)
                        .fill(Color.white)
                )
                .padding([.leading], 10)
            }
            
            VStack {
                ZStack {
                    if displaySend || isRecording {
                        Button(action: {
                            if isRecording {
                                commitRecording()
                            } else {
                                sendAction(inputText)
                                inputText = ""
                            }
                        }) {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(.white)
                        }
                    } else {
                        Button(action: beginRecording) {
                            Image(systemName: "mic.fill")
                                .foregroundColor(.white)
                        }
                    }
                }.padding(.trailing, 10)
            }
            .frame(width: 65, height: 50, alignment: .trailing)
            .background(
                Image(
                    "send_button",
                    bundle: Bundle.current
                )
                .resizable()
                .renderingMode(.template)
                .foregroundColor(Color(UIColor(hexString: color)))
            )
        }
        .frame(height: 50)
        .background(
            Color.white
        )
    }
}
