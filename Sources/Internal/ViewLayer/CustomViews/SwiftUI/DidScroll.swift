//
//  DidScroll.swift
//  OneMillionBot
//
//  Created by Adrián Rubio on 08/02/2021.
//

import Foundation
import SwiftUI
import UIKit

struct DidScroll<Content: View>: View {
    final class ScrollDelegate: NSObject, UIScrollViewDelegate {
        var didScroll: ((CGPoint) -> Void)?
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            didScroll?(scrollView.contentOffset)
        }
    }
    
    let content: Content
    let didScroll: (CGPoint) -> Void
    
    @State var delegate: ScrollDelegate? = ScrollDelegate()
    
    init(
        didScroll: @escaping (CGPoint) -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.didScroll = didScroll
    }
    var body: some View {
        content.introspectScrollView { [unowned delegate] in
            delegate?.didScroll = { [didScroll] point in
                didScroll(point)
            }
            
            $0.delegate = delegate
        }
    }
}

extension View {
    func didScroll(_ didScroll: @escaping (CGPoint) -> Void) -> some View {
        return DidScroll(didScroll: didScroll) {
            self
        }
    }
}
