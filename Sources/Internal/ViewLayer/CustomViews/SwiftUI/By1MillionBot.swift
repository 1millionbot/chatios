//
//  By1MillionBot.swift
//  OneMillionBot
//
//  Created by Adrián Rubio on 12/02/2021.
//

import SwiftUI

struct By1MillionBot: View {
    var by1millionText: String
    
    var body: some View {
            Text(by1millionText)
                .font(.roboto(.footnote))
                .foregroundColor(Color(.lightGray))
                .bold()
                .frame(maxWidth: .infinity)
                .padding(.bottom, 4)
                .onTapGesture {
                    UIApplication.shared.open(
                        URL(string: "https://1millionbot.com")!,
                        options: [:]
                    )
                }
    }
}
