//
//  HeaderView.swift
//  CometChatUIKitSwift
//
//  Created by SuryanshBisen on 22/01/24.
//

import Foundation
import UIKit

class SchedulerHeaderView {
    
    @MainActor static func getHeaderView(message: SchedulerMessage, style: SchedulerBubbleStyle?, onBackButtonClicked: Selector, target: Any?) -> UIView {
        
        let headingView = UIView()
        headingView.translatesAutoresizingMaskIntoConstraints = false
        headingView.heightAnchor.constraint(equalToConstant: 85).isActive = true
        
        let listItem = CometChatListItem()
        listItem.translatesAutoresizingMaskIntoConstraints = false
        listItem.layoutIfNeeded()
        listItem.awakeFromNib()
        listItem.set(avatarURL: message.avatarURL ?? message.sender?.avatar ?? "")
        
        if let title =  message.title {
            listItem.set(title: title)
        } else {
            listItem.set(title: message.sender?.name ?? "")
        }

        listItem.containerView.backgroundColor = .clear
        
        let subtitleView = UIStackView()
        subtitleView.axis = .horizontal
        subtitleView.distribution = .fillProportionally
        subtitleView.spacing = 3
        subtitleView.translatesAutoresizingMaskIntoConstraints = false
        
        let timeIcon = UIImage(named: "time-clock", in: CometChatUIKit.bundle, with: nil)?.withRenderingMode(.alwaysTemplate)
        let timeImageView = UIImageView(image: timeIcon)
        timeImageView.tintColor = CometChatTheme_v4.palatte.accent500
        timeImageView.translatesAutoresizingMaskIntoConstraints = false
        timeImageView.contentMode = .scaleAspectFit
        timeImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        timeImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        subtitleView.addArrangedSubview(timeImageView)

        let subtitleLabel = UILabel()
        subtitleLabel.text = "\(message.duration) min"
        subtitleLabel.font = CometChatTheme_v4.typography.text2
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.textColor = CometChatTheme_v4.palatte.accent500
        subtitleView.addArrangedSubview(subtitleLabel)
        subtitleView.addArrangedSubview(UIView())
        
        listItem.set(subtitle: subtitleView)
        listItem.background.backgroundColor = .clear
        
        if let lisItemStyle = style?.lisItemStyle {
            listItem.style = lisItemStyle
        }
    
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(named: "cometchatlistbase-back", in: CometChatUIKit.bundle, with: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        backButton.tintColor = CometChatTheme_v4.palatte.primary
        backButton.imageView?.contentMode = .scaleAspectFit
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.widthAnchor.constraint(equalToConstant: 17).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 17).isActive = true
        backButton.addTarget(target, action: onBackButtonClicked, for: .primaryActionTriggered)
        
        headingView.addSubview(backButton)
        backButton.leadingAnchor.constraint(equalTo: headingView.leadingAnchor, constant: 10).isActive = true
        
        headingView.addSubview(listItem)
        listItem.topAnchor.constraint(equalTo: headingView.topAnchor, constant: 5).isActive = true
        listItem.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 10).isActive = true
        listItem.trailingAnchor.constraint(equalTo: headingView.trailingAnchor, constant: 20).isActive = true
        backButton.centerYAnchor.constraint(equalTo: listItem.avatar.centerYAnchor).isActive = true
        
        let dividerView = UIView()
        headingView.addSubview(dividerView)
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        dividerView.backgroundColor = style?.dividerTint ?? CometChatTheme_v4.palatte.accent800
        dividerView.heightAnchor.constraint(equalToConstant: 0.3).isActive = true
        dividerView.topAnchor.constraint(equalTo: listItem.bottomAnchor).isActive = true
        dividerView.bottomAnchor.constraint(equalTo: headingView.bottomAnchor, constant: -10).isActive = true
        dividerView.leadingAnchor.constraint(equalTo: headingView.leadingAnchor, constant: 0).isActive = true
        dividerView.trailingAnchor.constraint(equalTo: headingView.trailingAnchor, constant: 0).isActive = true
        
        return headingView

    }

    
}
