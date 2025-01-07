//
//  CometChatImageBubble.swift
//
//
//  Created by Abdullah Ansari on 19/12/22.
//

import UIKit
import QuickLook

public class CometChatButton: VerticalButton {
    
    private(set) weak var controller: UIViewController?
    private(set) var onClick: (() -> Void)?
    
    public init() {
        super.init(frame: .zero)
        addTarget(self, action: #selector(onClicked), for: .primaryActionTriggered)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc open func onClicked() {
        onClick?()
    }
    
    @discardableResult
    public func set(text: String) -> Self {
        if !text.isEmpty {
            makeTextVerticallyAligned = true
            self.setTitle(text, for: .normal)
        } 
        return self
    }
    
    @discardableResult
    public func set(icon: UIImage) -> Self {
        setImage(icon, for: .normal)
        return self
    }
    
    @discardableResult
    public func setOnClick(onClick: @escaping (() -> Void)) -> Self {
        self.onClick = onClick
        return self
    }
    
    @discardableResult
    public func set(backgroundColor: UIColor) -> Self {
        self.backgroundColor = backgroundColor
        return self
    }
    
    @discardableResult
    public func set(cornerRadius: CometChatCornerStyle) -> Self {
        self.roundViewCorners(corner: cornerRadius)
        return self
    }
    
    @discardableResult
    private func set(borderWidth: CGFloat) -> Self {
        self.borderWith(width: borderWidth)
        return self
    }
    
    @discardableResult
    private func set(borderColor: UIColor) -> Self {
        self.borderColor(color: borderColor)
        return self
    }
    
    @discardableResult
    public func set(controller: UIViewController?) -> Self {
        self.controller = controller
        return self
    }
    
    @discardableResult
    public func disable(button: Bool) -> Self {
        self.isEnabled = !button
        return self
    }
    
    @objc func onButtonClick() {
        onClick?()
    }
    
    
}

public class VerticalButton: UIButton {
    
    public var makeTextVerticallyAligned = false
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.contentHorizontalAlignment = .left
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if makeTextVerticallyAligned == true {
            centerButtonImageAndTitle()
        }
    }
    
    private func centerButtonImageAndTitle() {
        let titleSize = self.titleLabel?.frame.size ?? .zero
        let imageSize = self.imageView?.frame.size  ?? .zero
        let spacing: CGFloat = 6.0
        self.imageEdgeInsets = UIEdgeInsets(top: -(titleSize.height + spacing),left: 0, bottom: 0, right:  -titleSize.width)
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: -imageSize.width, bottom: -(imageSize.height + spacing), right: 0)
    }
}
