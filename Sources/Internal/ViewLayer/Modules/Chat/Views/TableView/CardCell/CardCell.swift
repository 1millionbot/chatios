//
//  CardCell.swift
//  OneMillionBot
//
//  Created by Adrián Rubio on 02/02/2021.
//

import Foundation
 
import UIKit
import Combine

@objc(SPMXibCardCell)
final class CardCell: UITableViewCell, BubbleCell {
    var moreCardsTapped: ([BotCard]) -> Void = { _ in }
        
    static let id = "\(CardCell.self)"
            
    @IBOutlet var buttonContainer: UIView!
    @IBOutlet var spacerFromTrailing: NSLayoutConstraint!
    @IBOutlet var trailing: NSLayoutConstraint!
    @IBOutlet var spacerFromLeading: NSLayoutConstraint!
    @IBOutlet var leading: NSLayoutConstraint!
    @IBOutlet var bubble: UIView!
    @IBOutlet var cardView: CardView!
    @IBOutlet weak var moreCards: UIButton!
    @IBOutlet weak var top: NSLayoutConstraint!

    private var cards: [BotCard] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        
        moreCards.imageView?.contentMode = .scaleAspectFit
        moreCards.isHidden = true
        buttonContainer.isHidden = true
        
        cardView.layer.cornerRadius = kCR
        
        buttonContainer.layer.cornerRadius = 20
        buttonContainer.layer.shadowColor = UIColor.black.withAlphaComponent(0.15).cgColor
        buttonContainer.layer.shadowRadius = 1
        buttonContainer.layer.shadowOffset = .init(width: 0, height: 1)
        buttonContainer.layer.shadowOpacity = 1
            
        flip()
    }

    func update(
        with cards: [BotCard],
        color: String,
        over: Bool,
        _ selection: @escaping (BotOption) -> Void,
        _ moreCardsTapped: @escaping ([BotCard]) -> Void,
        _ showPhoto: @escaping (UIImage) -> Void
    ) {
        guard let first = cards.first else {
            return
        }
        
        let reformButtons = first != self.cards.first
                
        self.cards = cards
        self.moreCardsTapped = moreCardsTapped
        
        moreCards.isHidden = cards.count == 1
        buttonContainer.isHidden = cards.count == 1
        moreCards.tintColor = UIColor(hexString: color)
        
        cardView.update(
            with: first,
            reformButtons: reformButtons,
            selectedOption: selection,
            showPhoto: showPhoto
        )
                        
        updateBubbleStyle(false, over: over)
    }
    
    @IBAction func moreCardsTapped(_ sender: Any) {
        moreCardsTapped(cards)
    }
}
