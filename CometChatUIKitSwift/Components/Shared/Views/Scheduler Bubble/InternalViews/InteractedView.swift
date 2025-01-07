//
//  IntractedView.swift
//  CometChatUIKitSwift
//
//  Created by SuryanshBisen on 03/01/24.
//

import Foundation
import UIKit

class InteractedView: UIView {
    
    private var titleText: String?
    private var subtitleText: String?
    private var bodyText: String?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buildUI() {
        
        let containerView = UIStackView()
        containerView.axis = .vertical
        containerView.spacing = 7
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .clear
        containerView.alignment = .top
        containerView.distribution = .fill
        
        let subContainerView = UIView()
        subContainerView.translatesAutoresizingMaskIntoConstraints = false
        subContainerView.backgroundColor = CometChatTheme_v4.palatte.accent50
        subContainerView.roundViewCorners(corner: CometChatCornerStyle(cornerRadius: 7))
        subContainerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        subContainerView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        
        let leftBorder = UIView()
        leftBorder.translatesAutoresizingMaskIntoConstraints = false
        leftBorder.widthAnchor.constraint(equalToConstant: 5).isActive = true
        leftBorder.backgroundColor = CometChatTheme_v4.palatte.primary
        subContainerView.addSubview(leftBorder)
        leftBorder.topAnchor.constraint(equalTo: subContainerView.topAnchor).isActive = true
        leftBorder.bottomAnchor.constraint(equalTo: subContainerView.bottomAnchor).isActive = true
        leftBorder.leadingAnchor.constraint(equalTo: subContainerView.leadingAnchor).isActive = true

        let headingLabel = UILabel()
        headingLabel.translatesAutoresizingMaskIntoConstraints = false
        headingLabel.textColor = CometChatTheme_v4.palatte.accent900
        headingLabel.font = CometChatTheme_v4.typography.heading
        headingLabel.text = titleText
        subContainerView.addSubview(headingLabel)
        headingLabel.topAnchor.constraint(equalTo: subContainerView.topAnchor, constant: 5).isActive = true
        headingLabel.leadingAnchor.constraint(equalTo: leftBorder.trailingAnchor, constant: 10).isActive = true
        headingLabel.trailingAnchor.constraint(equalTo: subContainerView.trailingAnchor).isActive = true
        
        let subheadingLabel = UILabel()
        subheadingLabel.translatesAutoresizingMaskIntoConstraints = false
        subheadingLabel.textColor = CometChatTheme_v4.palatte.accent700
        subheadingLabel.font = CometChatTheme_v4.typography.text2
        subheadingLabel.text = subtitleText
        subheadingLabel.textAlignment = .justified
        subContainerView.addSubview(subheadingLabel)
        subheadingLabel.topAnchor.constraint(equalTo: headingLabel.bottomAnchor).isActive = true
        subheadingLabel.leadingAnchor.constraint(equalTo: leftBorder.trailingAnchor, constant: 10).isActive = true
        subheadingLabel.trailingAnchor.constraint(equalTo: subContainerView.trailingAnchor).isActive = true
        subheadingLabel.bottomAnchor.constraint(equalTo: subContainerView.bottomAnchor, constant: -8).isActive = true
        
        containerView.addArrangedSubview(subContainerView)
        
        let bodyLabel = UILabel()
        bodyLabel.textColor = CometChatTheme_v4.palatte.accent
        bodyLabel.font = CometChatTheme_v4.typography.text1
        bodyLabel.text = bodyText
        
        containerView.addArrangedSubview(bodyLabel)
        containerView.addArrangedSubview(UIView())
        containerView.addArrangedSubview(UIView())
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(containerView)
        containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true
        containerView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
        containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true

    }
    
    @discardableResult
    public func set(titleText: String?) -> Self {
        self.titleText = titleText
        return self
    }
    
    @discardableResult
    public func set(subtitleText: String?) -> Self {
        self.subtitleText = subtitleText
        return self
    }
    
    @discardableResult
    public func set(bodyText: String?) -> Self {
        self.bodyText = bodyText
        return self
    }
    
    @discardableResult
    public func build() -> Self {
        self.buildUI()
        return self
    }
    
}
