//
//  SpeechBubble.swift
//  OneMillionBot
//
//  Created by Adrián Rubio on 23/01/2021.
//

import Foundation
import UIKit

final class SpeechBubble: UIView {
    let label: UILabel = .init()
    let padding: UIEdgeInsets
    
    var text: String? {
        get { label.text }
        set { label.text = newValue }
    }
    
    var font: UIFont {
        get { label.font }
        set { label.font = newValue }
    }
    
    var textColor: UIColor {
        get { label.textColor }
        set { label.textColor = newValue }
    }
    
    var numberOfLines: Int {
        get { label.numberOfLines }
        set { label.numberOfLines = newValue }
    }
    
    init(
        padding: UIEdgeInsets = .zero
    ) {
        self.padding = padding
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .left
        
        addSubview(label)
        
        label.pinEdges(to: self, margin: padding)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
