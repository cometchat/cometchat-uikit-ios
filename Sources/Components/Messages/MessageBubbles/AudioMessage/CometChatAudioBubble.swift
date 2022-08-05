//
//  CometChatAudioBubble.swift
//  CometChatUIKit
//
//  Created by Abdullah Ansari on 16/05/22.
//

import UIKit
import CometChatPro

class CometChatAudioBubble: UIView {

    // MARK: - Properties
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var thumbnail: UIImageView!
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    convenience init(frame: CGRect, message: MediaMessage) {
        self.init(frame: frame)
        self.set(title: message.attachment?.fileName.capitalized ?? "")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Helper Methods
    
    private func customInit() {
        CometChatUIKit.bundle.loadNibNamed("CometChatAudioBubble", owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    @discardableResult
    @objc public func set(title: String) -> Self {
        self.title.text = title
        return self
    }
    
    @discardableResult
    @objc public func set(titleFont: UIFont) -> Self {
        self.title.font = titleFont
        return self
    }
    
    
    @discardableResult
    @objc public func set(titleColor: UIColor) -> Self {
        self.title.textColor = titleColor
        return self
    }
    
    @discardableResult
    @objc public func set(subTitle: String) -> Self {
        self.subTitle.text = subTitle
        return self
    }
    
    @discardableResult
    @objc public func set(subTitleFont: UIFont) -> Self {
        self.subTitle.font = subTitleFont
        return self
    }
    
    
    @discardableResult
    @objc public func set(subTitleColor: UIColor) -> Self {
        self.subTitle.textColor = subTitleColor
        return self
    }
    
    @discardableResult
    @objc public func set(iconTintColor: UIColor) -> Self {
        self.thumbnail.image = UIImage(named: "messages-audio-file.png", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
        self.thumbnail.tintColor = iconTintColor
        return self
    }
    
}
