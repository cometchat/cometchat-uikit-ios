//
//  CometChatFileBubble.swift
//
//
//  Created by Abdullah Ansari on 21/12/22.
//

import Foundation
import UIKit
import QuickLook
import CometChatSDK


class CometChatCallBubble: UIView {
    
    public var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    public var iconBackgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    public var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    public var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    public var separatorView: UIView = {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    public var joinButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Join", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    public let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = CometChatSpacing.Padding.p2
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    public weak var controller: UIViewController?
    public var callType: CometChatSDK.CallType = .audio
    public var audioCallTitleText = "Audio"
    public var videoCallTitleText = "Video"
    public var onClick: ((_ callType: CometChatSDK.CallType) -> Void)?
    public static var style = CallBubbleStyle()
    public lazy var style = CometChatCallBubble.style
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        if newWindow != nil{
            setupStyle()
        }
    }
    
    public func buildUI() {
        iconBackgroundView.addSubview(iconImageView)
        mainStackView.addArrangedSubview(iconBackgroundView)
        
        let textStackView = UIStackView(arrangedSubviews: [titleLabel, dateLabel])
        textStackView.axis = .vertical
        textStackView.spacing = CometChatSpacing.Padding.p1
        textStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let upperStackView = UIStackView(arrangedSubviews: [iconBackgroundView, textStackView])
        upperStackView.axis = .horizontal
        upperStackView.spacing = CometChatSpacing.Padding.p2
        upperStackView.alignment = .center
        upperStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.addArrangedSubview(upperStackView)
        
        mainStackView.addArrangedSubview(separatorView)
        mainStackView.addArrangedSubview(joinButton)
        
        addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            iconBackgroundView.widthAnchor.constraint(equalToConstant: 40),
            iconBackgroundView.heightAnchor.constraint(equalToConstant: 40),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconBackgroundView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconBackgroundView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),
            
            upperStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: CometChatSpacing.Padding.p2),
            upperStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -CometChatSpacing.Padding.p2),
            
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: CometChatSpacing.Padding.p1),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -CometChatSpacing.Padding.p1),
            
            mainStackView.topAnchor.constraint(equalTo: topAnchor, constant: CometChatSpacing.Padding.p3),
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: CometChatSpacing.Padding.p1),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -CometChatSpacing.Padding.p1),
            mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -CometChatSpacing.Padding.p2)
        ])
        joinButton.addTarget(self, action: #selector(onJoinClicked), for: .touchUpInside)
    }
    
    public func setupStyle(){
        titleLabel.textColor = style.titleTextColor
        titleLabel.font = style.titleTextFont
        dateLabel.textColor = style.subtitleTextColor
        dateLabel.font = style.subtitleTextFont
        joinButton.setTitleColor(style.joinButtonTextColor, for: .normal)
        joinButton.titleLabel?.font = style.joinButtonTextFont
        iconImageView.image = callType == .audio ? style.audioCallImage : style.videoCallImage
        titleLabel.text = callType == .audio ? audioCallTitleText : videoCallTitleText
        iconImageView.tintColor = style.callImageTintColor
        iconBackgroundView.backgroundColor = style.callImageBackgroundColor
        iconBackgroundView.borderWith(width: style.callImageBorderWidth)
        iconBackgroundView.borderColor(color: style.callImageBorderColor)
        iconBackgroundView.roundViewCorners(corner: style.callImageCornerRadius ?? .init(cornerRadius: CometChatSpacing.Radius.r5))
        separatorView.backgroundColor = style.separatorBackgroundColor
    }
    
    @objc func onJoinClicked(){
        self.onClick?(callType)
    }
    
    @discardableResult
    public func set(controller: UIViewController)  -> Self {
        self.controller = controller
        return self
    }
    
    @discardableResult
    public func setOnClick(onClick: @escaping ((_ callType: CometChatSDK.CallType) -> Void)) -> Self {
        self.onClick = onClick
        return self
    }
}
