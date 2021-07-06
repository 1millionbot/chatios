//
//  URLImage.swift
//  OneMillionBot
//
//  Created by Adrián Rubio on 25/01/2021.
//

import Foundation
import UIKit
import SwiftUI
import Kingfisher

let imagePlaceholder = UIImage(systemName: "person.crop.circle")!

struct URLImage: View, Equatable {
    let url: URL?
    
    init(_ url: URL?) {
        self.url = url
    }
    
    var body: some View {
        KFImage
            .url(url)
            .resizable()
            .scaledToFill()
            .aspectRatio(contentMode: .fit)
            .clipped()
    }
    
    static func == (lhs: URLImage, rhs: URLImage) -> Bool {
        lhs.url == rhs.url
    }
}
