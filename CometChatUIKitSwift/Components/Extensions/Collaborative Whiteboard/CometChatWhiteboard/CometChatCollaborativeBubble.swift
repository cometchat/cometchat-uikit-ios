//
//  CometChatWhiteboardBubble.swift
 
//
//  Created by Abdullah Ansari on 16/05/22.
//

import UIKit
import CometChatSDK

public class CometChatCollaborativeBubble: UIStackView {

    // MARK: - Properties
    public lazy var topImageView: UIImageView = {
        let imageView = UIImageView().withoutAutoresizingMaskConstraints()
        imageView.pin(anchors: [.height], to: 140)
        imageView.roundViewCorners(corner: .init(cornerRadius: CometChatSpacing.Radius.r2))
        imageView.image = topImage
        return imageView
    }()
    
    // Title label
    public lazy var title: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints()
        label.textAlignment = .left
        return label
    }()

    // Icon image view
    public lazy var icon: UIImageView = {
        let imageView = UIImageView().withoutAutoresizingMaskConstraints()
        imageView.image = collaborativeIconImage
        imageView.pin(anchors: [.width, .height], to: 32)
        return imageView
    }()

    // Subtitle label
    public lazy var subTitle: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints()
        label.textAlignment = .left
        return label
    }()

    // Whiteboard button
    public lazy var openButton: UIButton = {
        let button = UIButton(type: .system).withoutAutoresizingMaskConstraints()
        button.pin(anchors: [.height], to: 25)
        return button
    }()
    
    // divider button
    public lazy var dividerView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints()
        view.backgroundColor = .black.withAlphaComponent(0.4)
        view.pin(anchors: [.height], to: 0.3)
        return view
    }()
    
    // Line view
    public lazy var middleContainerView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints()
        view.addSubview(icon)
        view.addSubview(title)
        view.addSubview(subTitle)
        
        icon.pin(anchors: [.top, .bottom], to: view)
        title.pin(anchors: [.top, .trailing], to: view)
        subTitle.pin(anchors: [.bottom, .trailing], to: view)
        NSLayoutConstraint.activate([
            icon.leadingAnchor.pin(equalTo: view.leadingAnchor, constant: CometChatSpacing.Padding.p1),
            icon.trailingAnchor.pin(equalTo: title.leadingAnchor, constant: -CometChatSpacing.Padding.p1),
            title.bottomAnchor.pin(equalTo: icon.centerYAnchor, constant: CometChatSpacing.Padding.p),
            subTitle.leadingAnchor.pin(equalTo: title.leadingAnchor),
            subTitle.topAnchor.pin(equalTo: title.bottomAnchor)
        ])
        
        return view
    }()
    
    // MARK: - Initializers
    private var customMessage: CustomMessage?
    public var style = CollaborativeBubbleStyle()
    public var onOpenButtonClicked: (() -> ())?
    public var collaborativeIconImage: UIImage? = UIImage(named: "collaborative-message-icon", in: CometChatUIKit.bundle, with: nil)?.withRenderingMode(.alwaysTemplate) {
        didSet {
            self.icon.image = collaborativeIconImage
        }
    }
    public var topImage: UIImage? = UIImage(named: "collaborative-document-image", in: CometChatUIKit.bundle, with: nil)?.withRenderingMode(.alwaysOriginal) {
        didSet {
            self.topImageView.image = topImage
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
    }
    
    convenience init(frame: CGRect, message: CustomMessage) {
        self.init(frame: frame)
        self.customMessage = message
        buildUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func willMove(toWindow newWindow: UIWindow?) {
        if newWindow != nil {
            setupStyle()
        }
    }
    
    public func buildUI() {
        withoutAutoresizingMaskConstraints()
        axis = .vertical
        distribution = .fillProportionally
        spacing = CometChatSpacing.Padding.p2
        isLayoutMarginsRelativeArrangement = true
        layoutMargins = UIEdgeInsets(
            top: CometChatSpacing.Padding.p1,
            left: CometChatSpacing.Padding.p1,
            bottom: 0,
            right: CometChatSpacing.Padding.p1
        )
        
        addArrangedSubview(topImageView)
        addArrangedSubview(middleContainerView)
        setCustomSpacing(CometChatSpacing.Padding.p3, after: middleContainerView)
        addArrangedSubview(dividerView)
        setCustomSpacing(CometChatSpacing.Padding.p1, after: dividerView)

        addArrangedSubview(openButton)
        
        openButton.addTarget(self, action: #selector(onOpenWhiteboardClick), for: .primaryActionTriggered)
    }
    
    
    
    public func setupStyle() {
        title.font = style.titleFont
        title.textColor = style.titleColor
        subTitle.font = style.subTitleFont
        subTitle.textColor = style.subTitleColor
        icon.tintColor = style.iconTint
        openButton.tintColor = style.buttonTextColor
        openButton.titleLabel?.font = style.buttonTextFont
    }
    
    @discardableResult
    public func set(title: String) -> Self {
        self.title.text = title
        return self
    }
    
    @discardableResult
    public func set(subTitle: String) -> Self {
        self.subTitle.text = subTitle
        return self
    }
    
    @discardableResult
    public func set(buttonText: String) -> Self {
        self.openButton.setTitle(buttonText, for: .normal)
        return self
    }
    
    @discardableResult
    public func set(onOpenButtonClicked: @escaping (() -> ())) -> Self {
        self.onOpenButtonClicked = onOpenButtonClicked
        return self
    }
    
    @objc func onOpenWhiteboardClick() {
        onOpenButtonClicked?()
    }
}
