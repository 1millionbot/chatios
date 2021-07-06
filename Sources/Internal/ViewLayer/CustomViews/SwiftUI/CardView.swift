//
//  CardView.swift
//  OneMillionBot
//
//  Created by Adrián Rubio on 02/02/2021.
//

import Foundation
import UIKit
 
import Kingfisher

final class CardView: UIView {
    private var userSelected: ((BotOption) -> Void) = { _ in }
    private var showPhoto: (UIImage) -> Void = { _ in }
    private var buttons = [(UIView, UIView?)]()
    private var card: BotCard?
    
    func showingThis(card: BotCard) -> Bool{
        return card == self.card
    }
    
    private var stackBottomSeparation: NSLayoutConstraint!
    private var stackTopSeparation: NSLayoutConstraint!
    
    lazy private var spacer: UIView = {
        return UIView()
    }()
    
    lazy private var descriptionLb: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .black
        label.font = .roboto(.subheadline)
        return label
    }()
    
    lazy private var titleLb: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .left
        label.numberOfLines = 0
        label.textColor = .black
        label.font = .robotoMedium(.headline)
        return label
    }()

    
    lazy private var headStackView: UIStackView = {
        let stack = UIStackView()
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = .init(top: 0, left: 15, bottom: 0, right: 15)
        stack.axis = .vertical
        stack.spacing = 14
        
        return stack
    }()
    
    lazy private var buttonStackView: UIStackView = {
        let stack = UIStackView()
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 0
        
        return stack
    }()

    
    lazy private var imageView: UIImageView = {
        let imageView = UIImageView()
        let uitapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedOnPhoto(_:)))
        
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(systemName: "photo.fill")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(uitapGesture)
        
        return imageView
    }()
    
    lazy var imageHeightConstraint: NSLayoutConstraint = { [unowned imageView] in
        let height = imageView
            .heightAnchor
            .constraint(equalToConstant: 200)
        height.priority = .init(999)
        return height
    }()
    
    init() {
        super.init(frame: .zero)
        sharedInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
    
    private func sharedInit() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        clipsToBounds = true
        
        addSubview(headStackView)
        addSubview(buttonStackView)
        addSubview(imageView)

        headStackView.addArrangedSubview(titleLb)
        headStackView.addArrangedSubview(descriptionLb)
        
        imageHeightConstraint.isActive = true
        
        headStackView.pinEdges(
            to: self,
            only: [.top, .leading, .trailing]
        )
        
        stackTopSeparation = headStackView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10)
        stackTopSeparation.isActive = true
        
        headStackView.pinEdges(
            to: self,
            priority: 999,
            only: [.leading, .trailing]
        )
        
        buttonStackView.pinEdges(
            to: self,
            priority: 999,
            only: [.bottom, .leading, .trailing]
        )
        
        stackBottomSeparation = buttonStackView.topAnchor.constraint(equalTo: headStackView.bottomAnchor, constant: 15)
        stackBottomSeparation.isActive = true
    }
    
    func update(
        with card: BotCard,
        reformButtons: Bool = true,
        selectedOption: @escaping (BotOption) -> Void,
        showPhoto: @escaping (UIImage) -> Void
    ) {
        self.showPhoto = showPhoto
        self.userSelected = selectedOption
        self.card = card
        
        if let imageUrl = card.imageUrl {
            imageView.kf.setImage(
                with: imageUrl
            )
            
            imageView.isHidden = false
        } else {
            imageView.isHidden = true
        }
        
        card.description.map { descriptionLb.html(text: $0, style: .subheadline) }
        titleLb.text = card.title
                
        titleLb.isHidden = card.title.map { _ in false } ?? true
        descriptionLb.isHidden = card.description.map { _ in false } ?? true
                    
        if imageView.isHidden && !(titleLb.isHidden && descriptionLb.isHidden) {
            headStackView.insertArrangedSubview(spacer, at: 0)
        } else {
            spacer.removeFromSuperview()
        }
        
        stackBottomSeparation.constant =
            (imageView.isHidden &&
            titleLb.isHidden &&
            descriptionLb.isHidden) ? 0 : 15
                
        if reformButtons || buttons.isEmpty {
            buttons.forEach {
                $0.0.removeFromSuperview()
                $0.1?.removeFromSuperview()
            }
            
            buttons = card
                .options
                .enumerated()
                .map { offset, option in
                    let addSeparator = !(titleLb.isHidden && descriptionLb.isHidden) || !imageView.isHidden || offset != 0
                    return createButton(from: option, addSeparator: addSeparator)
                }
            
            buttons.forEach { button, separator in
                separator.map(self.buttonStackView.addArrangedSubview)
                self.buttonStackView.addArrangedSubview(button)
            }
            
            buttonStackView.setNeedsLayout()
        }
    }
    
    private func createButton(from: BotOption, addSeparator: Bool) -> (UIView, UIView?) {
        let wrapper = UIView()
        let button = UILabel()
        let uitapGesture = UITapGestureRecognizer(target: self, action: #selector(selectedOption(_:)))
        
        wrapper.isUserInteractionEnabled = true
        wrapper.addGestureRecognizer(uitapGesture)
        button.setContentHuggingPriority(.defaultHigh, for: .vertical)
        button.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.textAlignment = .center
        button.html(text: from.title, style: .subheadline)
        button.lineBreakMode = .byWordWrapping
        button.numberOfLines = 0
        button.textColor = from.isLink ? .cardButton : .black
        wrapper.addSubview(button)
        button.pinEdges(to: wrapper, margin: .init(top: 20, left: 10, bottom: 20, right: 10), priority: 999)

        return (wrapper, addSeparator ? createSeparator() : nil)
    }
    
    @objc func tappedOnPhoto(_ sender: Any) {
        imageView
            .image
            .map(showPhoto)
    }
    
    @objc func selectedOption(_ sender: Any) {
        let option = (sender as? UITapGestureRecognizer)?
            .view?
            .subviews.first.flatMap { $0 as? UILabel }?
            .text
        
        guard let text = option else { return }
        
        card?.options.first {
            $0.title == text
        }.map(userSelected)
    }
}

func createSeparator() -> UIView {
    let view = UIView()
    view.backgroundColor = .lightGray
    let height = view.heightAnchor.constraint(equalToConstant: 1)
    height.priority = .init(999)
    height.isActive = true
    return view
}
