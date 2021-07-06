//
//  ImageCell.swift
//  OneMillionBot
//
//  Created by Adrián Rubio on 01/02/2021.
//

import Foundation
import UIKit
import Kingfisher
import Combine

@objc(SPMXibImageCell)
final class ImageCell: UITableViewCell, BubbleCell {
    static let id = "\(ImageCell.self)"
    
    private var showPhoto: (UIImage) -> Void = { _ in }

    @IBOutlet weak var top: NSLayoutConstraint!
    @IBOutlet var spacerFromTrailing: NSLayoutConstraint!
    @IBOutlet var trailing: NSLayoutConstraint!
    @IBOutlet var spacerFromLeading: NSLayoutConstraint!
    @IBOutlet var leading: NSLayoutConstraint!
    @IBOutlet var bubble: UIView!
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet weak var height: NSLayoutConstraint!
    @IBOutlet weak var width: NSLayoutConstraint!
            
    override func awakeFromNib() {
        super.awakeFromNib()
        
        flip()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(showPhotoPressed(_:)))
        cellImage.isUserInteractionEnabled = true
        cellImage.addGestureRecognizer(tap)
    }
        
    func update(
        url: URL,
        over: Bool,
        completion: @escaping (CGSize) -> Void,
        showPhoto: @escaping (UIImage) -> Void
    ) {
        self.showPhoto = showPhoto
        
        KF.url(url).onSuccess { [self] (result: RetrieveImageResult) in
            var computedWidth = result.image.size.width/result.image.scale
            var computedHeight = result.image.size.height/result.image.scale
            let aspectRatio = computedWidth/computedHeight
            
            computedHeight = computedHeight.clamped(to: 100...250)
            computedWidth = computedHeight * aspectRatio
            
            self.width.constant = computedWidth
            self.height.constant = computedHeight
            
            completion(.init(width: Int(computedWidth), height: Int(computedHeight)))
        }
        .set(to: cellImage)
        
        updateBubbleStyle(false, over: over)
    }
    
    @objc func showPhotoPressed(_ sender: Any) {
        cellImage.image.map(showPhoto)
    }
}
