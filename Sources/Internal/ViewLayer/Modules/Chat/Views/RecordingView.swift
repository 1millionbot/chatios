//
//  RecordingView.swift
//  OneMillionBot
//
//  Created by Adrián Rubio on 18/02/2021.
//

import SwiftUI
import Combine

struct DictationInput: View {
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "mm:ss"
        return formatter
    }()

    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    let timer2 = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var initialDate = Date()
    @State private var currentDate = Date()
    @State private var recordingLight: Color = .red
    
    let discardRecording: () -> Void
    var color: String
    
    var body: some View {
        HStack {
            Button(action: {
                discardRecording()
            }) {
                Image(systemName: "trash.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(
                        Color(
                            .init(hexString: color)
                        )
                    )
                    .padding([.leading, .trailing])
            }
            
            Circle()
                .frame(width: 16, height: 16)
                .foregroundColor(recordingLight)
                .onReceive(timer2) { _ in
                    withAnimation(.easeInOut(duration: 1)) {
                    recordingLight = recordingLight == .red ? Color(.init(hexString: "BF0000")) : .red
                    }
                }
            
            Text(
                "\(dateFormatter.string(from: currentDate))"
            )
            .foregroundColor(.black)
            .onReceive(timer) { input in
                currentDate = Date(
                    timeIntervalSince1970: input.timeIntervalSince(initialDate)
                )
            }
        }
        .onAppear {
            initialDate = Date()
        }
        
        Spacer()
    }
}
