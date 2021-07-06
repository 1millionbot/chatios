//
//  ImageAvatar.swift
//  OneMillionBot
//
//  Created by Adrián Rubio on 25/01/2021.
//

import Foundation
import SwiftUI

struct Avatar: View, Equatable {
    var url: URL?
    
    init(_ url: URL?) {
        self.url = url
    }
    
    var body: some View {
        URLImage(url)
            .clipShape(Circle())
    }
    
    static func == (lhs: Avatar, rhs: Avatar) -> Bool {
        lhs.url == rhs.url
    }
}
