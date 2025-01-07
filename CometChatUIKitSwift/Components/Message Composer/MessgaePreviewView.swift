//
//  MessgaePreviewView.swift
//  CometChatUIKitSwift
//
//  Created by Suryansh on 19/10/24.
//

import UIKit
import Foundation

class MessagePreviewView: UIView {
    
    var title: String
    var subTitle: NSAttributedString
    var style: MessageComposerStyle
    var onCrossIconClicked: (() -> ())?
    
    init(title: String, subTitle: NSAttributedString, style: MessageComposerStyle) {
        self.title = title
        self.subTitle = subTitle
        self.style = style
        super.init(frame: .null)
        buildUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buildUI() {
        
        backgroundColor = style.editPreviewBackgroundColor
        borderWith(width: style.editPreviewBorderWidth)
        roundViewCorners(corner: style.editPreviewCornerRadius)
        borderColor(color: style.borderColor)
        
        var constrainsToActivate = [NSLayoutConstraint]()
        
        let titleLabel = UILabel().withoutAutoresizingMaskConstraints()
        titleLabel.text = title
        titleLabel.textColor = style.editPreviewTitleTextColor
        titleLabel.font = style.editPreviewTitleTextFont
        addSubview(titleLabel)
        constrainsToActivate += [
            titleLabel.topAnchor.pin(equalTo: topAnchor, constant: CometChatSpacing.Padding.p2),
            titleLabel.leadingAnchor.pin(equalTo: leadingAnchor, constant: CometChatSpacing.Padding.p2)
        ]
        
        let closeButton = UIButton().withoutAutoresizingMaskConstraints()
        closeButton.tintColor = style.editPreviewCloseIconTint
        closeButton.setImage(style.editPreviewCloseIcon, for: .normal)
        closeButton.pin(anchors: [.height, .width], to: 20)
        closeButton.addTarget(self, action: #selector(onCrossIconTapped), for: .primaryActionTriggered)
        addSubview(closeButton)
        constrainsToActivate += [
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -CometChatSpacing.Padding.p2),
            closeButton.topAnchor.constraint(equalTo: topAnchor, constant: CometChatSpacing.Padding.p2)
        ]
        
        let subtitleLabel = UILabel().withoutAutoresizingMaskConstraints()
        subtitleLabel.attributedText = subTitle
        subtitleLabel.numberOfLines = 2
        subtitleLabel.textColor = style.editPreviewMessageTextColor
        subtitleLabel.font = style.editPreviewMessageTextFont
        addSubview(subtitleLabel)
        constrainsToActivate += [
            subtitleLabel.topAnchor.pin(equalTo: titleLabel.bottomAnchor, constant: CometChatSpacing.Padding.p1),
            subtitleLabel.leadingAnchor.pin(equalTo: titleLabel.leadingAnchor, constant: 0),
            subtitleLabel.bottomAnchor.pin(equalTo: bottomAnchor, constant: -CometChatSpacing.Padding.p2),
            subtitleLabel.trailingAnchor.pin(equalTo: closeButton.leadingAnchor)
        ]
        
        NSLayoutConstraint.activate(constrainsToActivate)
    }
    
    @objc func onCrossIconTapped() {
        onCrossIconClicked?()
    }
}
