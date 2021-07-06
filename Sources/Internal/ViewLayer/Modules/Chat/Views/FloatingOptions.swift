//
//  FloatingOptions.swift
//  OneMillionBot
//
//  Created by Adrián Rubio on 13/02/2021.
//

import SwiftUI
import Introspect

struct FloatingOptionsView: View {
    @Binding var options: FloatingOptions
    
    var selection: (BotOption) -> Void
    
    var body: some View {
        ZStack {
            if !options.completed && !options.options.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        Spacer(minLength: 10)
                        ForEach(options.options) { op in
                            Button(op.title) {
                                withAnimation {
                                    options.completed = true
                                }
                                selection(op)
                            }
                            .font(.roboto(.footnote))
                            .padding([.top, .bottom], 6)
                            .padding([.leading, .trailing], 10)
                            .foregroundColor(
                                op.isLink ?
                                    Color(.cardButton) :
                                    .black
                            )
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white)
                                    .shadow(radius: 1, x: 0, y: 1)
                            )
                            .padding(2)
                        }
                        Spacer(minLength: 10)
                    }
                    .frame(height: 44)
                }
                .background(Color(UIColor.white))
                .introspectScrollView(customize: { scroll in
                    // simulates a little animation to let the user know that
                    // there can be more buttons if they scroll
                    
                    if options.options.count > 2{
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            scroll.setContentOffset(.init(x: 40, y: 0), animated: true)
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            scroll.setContentOffset(.init(x: 0, y: 0), animated: true)
                        }
                    }
                })
                .transition(.floatingOptions)
            }
        }
    }
}
