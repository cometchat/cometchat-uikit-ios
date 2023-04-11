//
//  CometChatFileBubble.swift
//
//
//  Created by Abdullah Ansari on 21/12/22.
//

import Foundation
import UIKit
import QuickLook

class CometChatCallBubble: UIStackView {
    
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var joinButtonView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var downloadIcon: UIImageView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentStackView: UIStackView!
   
    lazy var previewController = QLPreviewController()
    private var controller: UIViewController?
    private var onClick: (() -> Void)?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit(width: frame.width, height: frame.height)
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        customInit(width: 0, height: 0)
        fatalError("init(coder:) has not been implemented")
    }
    
    private func customInit(width: CGFloat, height: CGFloat) {
        CometChatUIKit.bundle.loadNibNamed("CometChatCallBubble", owner: self, options:  nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        translatesAutoresizingMaskIntoConstraints = false
        contentStackView.isLayoutMarginsRelativeArrangement = true
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: width),
            heightAnchor.constraint(equalToConstant: height)
        ])
        set(style: CallBubbleStyle())
    }

    @discardableResult
    public func set(title: String) -> Self {
        self.title.text = title
        return self
    }
    
    @discardableResult
    public func set(titleColor: UIColor)  -> Self {
        title.textColor = titleColor
        return self
    }
    
    @discardableResult
    public func set(titleFont: UIFont)  -> Self {
        title.font = titleFont
        return self
    }
    
    @discardableResult
    public func set(subTitle: String)  -> Self {
        self.subTitle.text = subTitle
        return self
    }
    
    @discardableResult
    public func set(subTitleFont: UIFont)  -> Self {
        subTitle.font = subTitleFont
        return self
    }
    
    @discardableResult
    public func set(subTitleColor: UIColor)  -> Self {
        subTitle.textColor = subTitleColor
        return self
    }
    
    @discardableResult
    public func set(icon: UIImage)  -> Self {
        self.downloadIcon.image = icon
        return self
    }
    
    @discardableResult
    public func set(iconTint: UIColor)  -> Self {
        downloadIcon.tintColor = iconTint
        return self
    }
    
    @discardableResult
    public func set(backgroundColor: UIColor)  -> Self {
        contentView.backgroundColor(color: backgroundColor)
        return self
    }
    
    @discardableResult
    public func set(cornerRadius: CometChatCornerStyle)  -> Self {
        contentView.roundViewCorners(corner: cornerRadius)
        return self
    }
    
    @discardableResult
    public func set(borderWidth: CGFloat)  -> Self {
        contentView.borderWith(width: borderWidth)
        return self
    }
    
    @discardableResult
    public func set(borderColor: UIColor)  -> Self {
        contentView.borderColor(color: borderColor)
        return self
    }
    
    @discardableResult
    public func set(controller: UIViewController)  -> Self {
        self.controller = controller
        return self
    }
    
    @discardableResult
    public func set(joinButtonText: String)  -> Self {
        if !joinButtonText.isEmpty {
            self.joinButton.setTitle(joinButtonText, for: .normal)
            self.joinButtonView.isHidden = false
        } else {
            self.joinButtonView.isHidden = true
        }
        return self
    }
    
    
    @discardableResult
    public func set(joinButtonBackground: UIColor)  -> Self {
        joinButton.backgroundColor = joinButtonBackground
        return self
    }
    
    @discardableResult
    public func set(joinButtonCornerRadius: CGFloat)  -> Self {
        joinButton.layer.cornerRadius = joinButtonCornerRadius
        joinButton.clipsToBounds = true
        return self
    }
    
    @discardableResult
    public func setOnClick(onClick: @escaping (() -> Void)) -> Self {
        self.onClick = onClick
        return self
    }
    
    @discardableResult
    public func set(style: CallBubbleStyle)  -> Self {
        set(iconTint: style.iconTint)
        set(titleColor: style.titleColor)
        set(titleFont: style.titleFont)
        set(subTitleFont: style.subtitleFont)
        set(subTitleColor: style.subtitleColor)
        set(cornerRadius: style.cornerRadius)
        set(borderWidth: style.borderWidth)
        set(borderColor: style.borderColor)
        set(joinButtonBackground: style.buttonBackground)
        set(joinButtonCornerRadius: style.buttonCornerRadius)
        return self
    }
    
    
    @IBAction func onClick(_ sender: Any) {
        self.onClick?()
    }


}
