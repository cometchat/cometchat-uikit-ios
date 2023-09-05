//
//  CometChatCustomBubble.swift
 
//
//  Created by Abdullah Ansari on 22/05/22.
//

import UIKit
import CometChatSDK

protocol CustomDelegate: NSObject {
    func onClick(forMessage: CustomMessage, cell: UITableViewCell)
    func onLongPress(message: CustomMessage,cell: UITableViewCell)
}

public class CometChatCustomBubble: UIView {

    @IBOutlet weak var containerView: UIView!
    var controller: UIViewController?
    var customMessage: CustomMessage?
    
    var placeholderBubbleConfiguration: PlaceholderBubbleConfiguration?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect, message: CustomMessage, placeholderBubbleConfiguration: PlaceholderBubbleConfiguration?) {
        self.init(frame: frame)
        self.placeholderBubbleConfiguration = placeholderBubbleConfiguration
        if let placeholderBubbleConfiguration = placeholderBubbleConfiguration, let placeholderBubbleStyle = placeholderBubbleConfiguration.style {
            set(style: placeholderBubbleStyle)
        } else {
            set(style: PlaceholderBubbleStyle())
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func customInit() {
        CometChatUIKit.bundle.loadNibNamed("CometChatCustomBubble", owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    @discardableResult
    public func set(style: PlaceholderBubbleStyle) -> Self {
        set(textColor: style.textColor)
        set(textFont: style.textFont)
        set(background: style.background)
        set(borderColor: style.borderColor)
        set(borderWidth: style.borderWidth)
        set(corner: style.cornerRadius)
        return self
    }
    
    @discardableResult
    public func set(background: UIColor) -> Self {
        self.backgroundColor = background
        return self
    }
    
    @discardableResult
    public func set(corner: CometChatCornerStyle) -> Self {
        self.roundViewCorners(corner: corner)
        return self
    }
    
    @discardableResult
    public func set(borderWidth: CGFloat) -> Self {
        self.layer.borderWidth = borderWidth
        return self
    }
    
    @discardableResult
    public func set(borderColor: UIColor) -> Self {
        self.layer.borderColor = borderColor.cgColor
        return self
    }
    
    @discardableResult
    public func set(textColor: UIColor) -> Self {
        // Set the text color here.
        return self
    }
    
    @discardableResult
    public func set(textFont: UIFont) -> Self {
        // Set the text Font here.
        return self
    }
    
    @discardableResult
    public func set(message: CustomMessage) -> Self {
        self.customMessage = message
        return self
    }
    
    
    @discardableResult
    public func set(controller: UIViewController) -> Self {
        self.controller = controller
        return self
    }

    
}
