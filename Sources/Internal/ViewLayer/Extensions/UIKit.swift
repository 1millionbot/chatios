//
//  ViewExtensions.swift
//  OneMillionBot
//
//  Created by Adrián Rubio on 23/01/2021.
//

import Foundation
import UIKit
import Atributika

extension UIView {
    func roundCorners(corners: CACornerMask, radius: CGFloat) {
        layer.cornerRadius = radius
        layer.maskedCorners = corners
    }
    
    func pinEdges(
        to view: UIView,
        margin: UIEdgeInsets = .zero,
        priority: Float = 1000,
        only: NSDirectionalRectEdge = .all
    ) {
        if only.contains(.bottom) {
            let bottom = bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -margin.bottom)
            bottom.isActive = true
            bottom.priority = .init(priority)
        }
        
        if only.contains(.top) {
            let top = topAnchor.constraint(equalTo: view.topAnchor, constant: margin.top)
            top.isActive = true
            top.priority = .init(priority)
        }
        
        if only.contains(.leading) {
            let leading = leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin.left)
            leading.isActive = true
            leading.priority = .init(priority)
        }
        
        if only.contains(.trailing) {
            let trailing = trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin.right)
            trailing.isActive = true
            trailing.priority = .init(priority)
        }
    }
}

extension UIWindow {
    func topViewController() -> UIViewController? {
        var top = self.rootViewController
        while true {
            if let presented = top?.presentedViewController {
                top = presented
            } else if let nav = top as? UINavigationController {
                top = nav.visibleViewController
            } else if let tab = top as? UITabBarController {
                top = tab.selectedViewController
            } else {
                break
            }
        }
        return top
    }
}

extension UILabel {
    func html(text: String, style: UIFont.TextStyle) {
        let b = Style("b").font(.robotoMedium(style))
        let u = Style("u").underlineStyle(.single)
        let i = Style("i").font(.robotoItalic(style))
        let strong = Style("strong").font(.robotoMedium(style))
        let transformers = [TagTransformer(tagName: "br", tagType: .start, replaceValue: "\n")]
        
        self.attributedText = text
            .style(tags: [u, b, i, strong], transformers: transformers)
            .styleAll(.font(.roboto(style)))
            .attributedString
    }
}
