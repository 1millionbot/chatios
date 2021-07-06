//
//  TableViewExtensions.swift
//  OneMillionBot
//
//  Created by Adrián Rubio on 01/02/2021.
//

import Foundation

import UIKit
import Combine

protocol IdableCell: AnyObject {
    static var id: String { get }
}

protocol BubbleCell: IdableCell {
    var top: NSLayoutConstraint! { get }
    var spacerFromTrailing: NSLayoutConstraint! { get }
    var trailing: NSLayoutConstraint! { get }
    var spacerFromLeading: NSLayoutConstraint! { get }
    var leading: NSLayoutConstraint! { get }
    var bubble: UIView! { get }
}

extension BubbleCell where Self: UITableViewCell {
    func updateBubbleStyle(_ fromUser: Bool, over: Bool) {
        var corners: CACornerMask = fromUser ? [.layerMaxXMaxYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner] :
            [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
        
        corners = over ? corners : [.layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner]

        bubble.backgroundColor = fromUser ? .userBubble : .white

        top.constant = over ? 10 : 4
        
        leading.isActive = !fromUser
        spacerFromTrailing.isActive = !fromUser
        
        spacerFromLeading.isActive = fromUser
        trailing.isActive = fromUser
        
        bubble.layer.cornerRadius = kCR
        bubble.layer.maskedCorners = corners
    }
}

extension IdableCell where Self: UITableViewCell {
    func flip() {
        contentView.transform = CGAffineTransform(rotationAngle: .pi)
            .scaledBy(x: -1, y: 1)
    }
}

extension UITableView {
    func register<Cell: IdableCell>(_ type: Cell.Type) {
        register(
            .init(
                nibName: "\(Cell.id)",
                bundle: .current
            ),
            forCellReuseIdentifier: "\(Cell.id)"
        )
    }
    
    func dequeueing<Cell: IdableCell>(
        _ type: Cell.Type
    ) -> Cell? {
        let cell = dequeueReusableCell(
            withIdentifier: Cell.id
        ) as? Cell
        
        return cell
    }
    
    func dequeueing<Cell: IdableCell>(
        _ type: Cell.Type,
        _ apply: (Cell) -> Void
    ) -> Cell? {
        let cell = dequeueing(Cell.self)
        
        cell.map(apply)
        
        return cell
    }
    
    func textCell(_ text: String, fromUser: Bool, over: Bool, color: String, status: TextMessageStatus, id: UUID, retry: @escaping (UUID) -> Void) -> TextCell? {
        return dequeueing(TextCell.self) { (cell: TextCell) in
            cell.update(
                messageId: id,
                fromUser: fromUser,
                text: text,
                over: over,
                color: color,
                status: status,
                retry: retry
            )
        }
    }
}
