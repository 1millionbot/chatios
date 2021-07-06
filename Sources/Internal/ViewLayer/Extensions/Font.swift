//
//  Font.swift
//  OneMillionBot
//
//  Created by Adrián Rubio on 13/03/2021.
//

import Foundation
import SwiftUI
import UIKit

extension UIFont {
    static func roboto(_ style: UIFont.TextStyle) -> UIFont {
        return scaledFont(
            name: "Roboto",
            textStyle: style
        )
    }

    static func robotoItalic(_ style: UIFont.TextStyle) -> UIFont {
        return scaledFont(
            name: "Roboto-Italic",
            textStyle: style
        )
    }
    
    static func robotoMedium(_ style: UIFont.TextStyle) -> UIFont {
        return scaledFont(
            name: "Roboto-Medium",
            textStyle: style
        )
    }
    
    fileprivate static func scaledFont(
        name: String,
        textStyle: UIFont.TextStyle
    ) -> UIFont {
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: textStyle)
        
        guard let customFont = UIFont(name: name, size: fontDescriptor.pointSize) else {
            fatalError("Failed to load the \(name) font.")
        }
        
        return UIFontMetrics.default.scaledFont(for: customFont)
    }
}

extension Font {
    static func roboto(_ style: UIFont.TextStyle) -> Font {
        return Font(UIFont.roboto(style))
    }
}
//Font Family Name = [Roboto]
//Font Names = [["Roboto-Regular", "Roboto-Italic", "Roboto-Thin", "Roboto-ThinItalic", "Roboto-Light", "Roboto-LightItalic", "Roboto-Medium", "Roboto-MediumItalic", "Roboto-Bold", "Roboto-BoldItalic", "Roboto-Black", "Roboto-BlackItalic"]]
