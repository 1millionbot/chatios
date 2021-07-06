//
//  WritingCell.swift
//  OneMillionBot
//
//  Created by Adrián Rubio on 20/02/2021.
//

import Foundation
import UIKit

@objc(SPMXibWritingCell)
final class WritingCell: UITableViewCell, IdableCell {
    static let id = "\(WritingCell.self)"
    @IBOutlet var caption: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        caption.textColor = .black
        
        flip()
    }
    
    func touch(writingMessage: String) {
        caption.text = writingMessage
    }
}
