//
//  ActionsCell.swift
//  Heartbeat Messenger
//
//  Created by Pushpsen on 30/04/20.
//  Copyright © 2022 pushpsen airekar. All rights reserved.
//

import UIKit

class CometChatActionItem: UITableViewCell {
    
    private let backView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints()
        return view
    }()
    
    private let actionImage: UIImageView = {
        let imageView = UIImageView().withoutAutoresizingMaskConstraints()
        imageView.pin(anchors: [.width, .height], to: 24)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints()
        return label
    }()
    
    private let mainStackView: UIStackView = {
        let stackView = UIStackView().withoutAutoresizingMaskConstraints()
        stackView.axis = .horizontal
        stackView.spacing = CometChatSpacing.Padding.p2
        stackView.alignment = .center
        return stackView
    }()
    
    var actionItem: ActionItem? {
        didSet {
            guard let actionItem = actionItem else { return }
            nameLabel.text = actionItem.text
            
            if let titleColor = actionItem.style?.textColor {
                nameLabel.textColor = titleColor
            }
            
            if let titleFont = actionItem.style?.textFont {
                nameLabel.font = titleFont
            }
            
            if let leadingIcon = actionItem.leadingIcon {
                actionImage.isHidden = false
                actionImage.image = leadingIcon.withRenderingMode(.alwaysTemplate)
            } else {
                actionImage.isHidden = true
            }
            
            if let leadingIconTint = actionItem.style?.imageTintColor {
                actionImage.tintColor = leadingIconTint
            }
        }
    }
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell(){
        self.backgroundColor = .clear
        
        contentView.embed(backView)
        mainStackView.addArrangedSubview(actionImage)
        mainStackView.addArrangedSubview(nameLabel)
        
        backView.embed(mainStackView, insets: .init(
            top: CometChatSpacing.Padding.p3,
            leading: CometChatSpacing.Padding.p4,
            bottom: CometChatSpacing.Padding.p3,
            trailing: CometChatSpacing.Padding.p4
        )
        )
    }
    
    @discardableResult
    public func set(actionItem: ActionItem) -> CometChatActionItem {
        self.actionItem = actionItem
        return self
    }
}
