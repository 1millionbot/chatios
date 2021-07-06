//
//  VideoCell.swift
//  OneMillionBot
//
//  Created by Adrián Rubio on 09/02/2021.
//

import Foundation
import Kingfisher
import UIKit

@objc(SPMXibVideoCell)
final class VideoCell: UITableViewCell, BubbleCell {
    static let id = "\(VideoCell.self)"
    private var pressedPlay: () -> Void = {}

    @IBOutlet var spacerFromTrailing: NSLayoutConstraint!
    @IBOutlet var trailing: NSLayoutConstraint!
    @IBOutlet var spacerFromLeading: NSLayoutConstraint!
    @IBOutlet var leading: NSLayoutConstraint!
    @IBOutlet var bubble: UIView!
    @IBOutlet var playIcon: UIButton!
    @IBOutlet var thumbnail: UIImageView!
    @IBOutlet weak var top: NSLayoutConstraint!
            
    override func awakeFromNib() {
        super.awakeFromNib()
        
        flip()
    }
    
    func update(with imageUrl: URL?, color: String, over: Bool, pressedPlay: @escaping () -> Void) {
        
        self.pressedPlay = pressedPlay
        playIcon.tintColor = UIColor(hexString: color)
        
        if let url = imageUrl {
            KF.url(url)
                .roundCorner(radius: .point(kCR))
                .set(to: thumbnail)
        }
        
        thumbnail.layer.cornerRadius = kCR
        thumbnail.clipsToBounds = true
        
        updateBubbleStyle(false, over: over)
    }
    
    @IBAction func didPressPlay(_ sender: Any) {
        pressedPlay()
    }
}
