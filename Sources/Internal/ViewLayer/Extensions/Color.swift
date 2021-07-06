//
//  Color.swift
//  OneMillionBot
//
//  Created by Adrián Rubio on 23/01/2021.
//

import Foundation
import UIKit

extension UIColor {
    static let mainBubbleBackground: UIColor = .init(red: 0.89, green: 0.89, blue: 0.89, alpha: 1)
    static let userBubble = UIColor(red: 0.95, green: 0.95, blue: 0.99, alpha: 1.00)
    static let cardButton = UIColor(red: 0.16, green: 0.34, blue: 0.73, alpha: 1)
    static let alertColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(
            in: CharacterSet.alphanumerics.inverted
        )
        
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
