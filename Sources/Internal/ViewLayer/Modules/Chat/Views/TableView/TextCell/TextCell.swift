//
//  TextCell.swift
//  OneMillionBot
//
//  Created by Adrián Rubio on 30/01/2021.
//

import Foundation
import UIKit
import Atributika

@objc(SPMXibTextCell)
final class TextCell: UITableViewCell, BubbleCell {
    static let id = "\(TextCell.self)"
    
    private var id: UUID = UUID()
    private var retry: (UUID) -> Void = { _ in }

    @IBOutlet var spacerFromTrailing: NSLayoutConstraint!
    @IBOutlet weak var top: NSLayoutConstraint!
    @IBOutlet var trailing: NSLayoutConstraint!
    @IBOutlet var spacerFromLeading: NSLayoutConstraint!
    @IBOutlet var leading: NSLayoutConstraint!
    @IBOutlet var bubble: UIView!
    @IBOutlet var textLb: AttributedLabel!
    @IBOutlet var retryButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        flip()
        
        textLb.numberOfLines = 0
    }
        
    func update(
        messageId: UUID,
        fromUser: Bool,
        text: String,
        over: Bool,
        color: String,
        status: TextMessageStatus,
        retry: @escaping (UUID) -> Void
    ) {
        self.id = messageId
        self.retry = retry
        
        styleLb(text)
        textLb.onClick = pressedOnAttributedLabel
        
        retryButton.tintColor = UIColor(hexString: color)
        
        switch status {
        case .success:
            retryButton.isHidden = true
            bubble.alpha = 1
        case .failure:
            retryButton.isHidden = false
            bubble.alpha = 0.5
        case .pending:
            retryButton.isHidden = true
            bubble.alpha = 0.5
        }
        
        updateBubbleStyle(fromUser, over: over)
    }
    
    @IBAction func retryPressed(_ sender: Any) {
        retry(id)
    }
    
    private func pressedOnAttributedLabel(
        _ label: AttributedLabel,
        _ detection: Detection
    ) {
        switch detection.type {
        case let .phoneNumber(phone):
            break
        case let .link(url):
            UIApplication.shared.open(url, options: [:])
        case let .tag(tag):
            if tag.name == "a",
               let href = tag.attributes["href"],
               let url = URL(string: href) {
                UIApplication.shared.open(url, options: [:])
            }
            
        default: return
        }
    }
    
    private func styleLb(_ htmlText: String) {
        let all = Style.font(.roboto(.subheadline))
        let link = Style("a")
            .foregroundColor(.cardButton, .highlighted)
            .foregroundColor(.cardButton, .normal)
        
        
        let b = Style("b").font(.robotoMedium(.subheadline))
        let u = Style("u").underlineStyle(.single)
        let i = Style("i").font(.robotoItalic(.subheadline))
        let strong = Style("strong").font(.robotoMedium(.subheadline))
        let transformers = [TagTransformer(tagName: "br", tagType: .start, replaceValue: "\n")]
        
        textLb.attributedText = htmlText
            .style(tags: [link, b, u, i, strong], transformers: transformers)
            .styleLinks(link)
            .styleAll(all)
    }
}
