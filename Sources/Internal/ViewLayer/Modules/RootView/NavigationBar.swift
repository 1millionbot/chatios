//
//  NavigationBar.swift
//  OneMillionBot
//
//  Created by Adrián Rubio on 25/01/2021.
//

import Foundation
import SwiftUI

struct NavigationState {
    var botName: String
    var color: String
    var botAvatarUrl: URL?
}

extension Notification.Name {
    static let realPerson = Self("_1mbRealPersonNotification")
}

fileprivate func imageUrl(_ person: RealPerson?, current: URL?) -> URL? {
    return person.flatMap { $0.image }
        .flatMap(URL.init(string:))
        ?? current
}

fileprivate func name(_ person: RealPerson?, current: String) -> String {
    return person?.name ?? current
}

extension View {
    func navigation(
        with state: NavigationState,
        close: @escaping () -> Void,
        shouldShowMenuButton: Bool,
        openMenu: Binding<Bool>,
        realPerson: RealPerson?
    ) -> some View {
        navigationBarTitle("", displayMode: .inline)
            .navigationBarItems(
                leading:
                    HStack {
                        Button(action: close, label: {
                            Image(systemName: "xmark")
                                .imageScale(.medium)
                                .padding()
                        })
                        
                        Avatar(
                            imageUrl(realPerson, current: state.botAvatarUrl)
                        )
                        .scaledToFill()
                        .frame(width: 32, height: 32)
                        
                        Text(
                            name(realPerson, current: state.botName)
                        )
                        .font(.roboto(.body))
                        .bold()
                        .foregroundColor(.white)
                    }
                ,
                trailing:
                    ZStack {
                        if shouldShowMenuButton {
                            Button(action: {
                                withAnimation {
                                    openMenu.wrappedValue.toggle()
                                }
                            }, label: {
                                Image(systemName: "ellipsis")
                                    .imageScale(.medium)
                            })
                            .rotationEffect(.init(degrees: 90))
                            .contentShape(
                                Rectangle()
                            ).frame(width: 40, height: 40, alignment: .trailing)
                        }
                    }
            )
    }
}

