//  CometChatAvatar.swift
 
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2022 CometChat Inc. All rights reserved.

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
 CometChatAvatar: This component will be the class of UIImageView which is customizable to display CometChatReceipt.
 
 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  */


// MARK: - Importing Frameworks.

import Foundation
import  UIKit

/*  ----------------------------------------------------------------------------------------- */

@IBDesignable
@objc public final class CometChatReceipt: UIImageView {
    
    // MARK: - Initialization of required Methods
    
    override public init(image: UIImage?) { super.init(image: image) }
    override init(frame: CGRect) { super.init(frame: frame) }
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    var messageWaitIcon = UIImage(named: "messages-wait", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    var messageReadIcon = UIImage(named: "messages-read", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)  ?? UIImage()
    var messageDeliveredIcon = UIImage(named: "messages-delivered", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    var messageSentIcon = UIImage(named: "messages-sent", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)  ?? UIImage()
    var messageErrorIcon = UIImage(named: "messages-error", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)  ?? UIImage()
    var style = ReceiptStyle()
    var disableReceipt: Bool = false
    
    public override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    // MARK: - instance methods
    @discardableResult
    public func set(messageInProgressIcon: UIImage?) -> Self {
        if let messageInProgressIcon = messageInProgressIcon {
            self.messageWaitIcon = messageInProgressIcon
        }
        return self
    }
    
    @discardableResult
    public func set(messageSentIcon: UIImage?) -> Self {
        if let messageSentIcon = messageSentIcon {
            self.messageSentIcon = messageSentIcon
        }
        return self
    }
    
    @discardableResult
    public func set(messageDeliveredIcon: UIImage?) -> Self {
        if let messageDeliveredIcon = messageDeliveredIcon {
            self.messageDeliveredIcon = messageDeliveredIcon
        }
        return self
    }
    
    @discardableResult
    public func set(messageReadIcon: UIImage?) -> Self {
        if let messageReadIcon = messageReadIcon {
            self.messageReadIcon = messageReadIcon
        }
        return self
    }
    
    @discardableResult
    public func set(messageErrorIcon: UIImage?) -> Self {
        if let messageErrorIcon = messageErrorIcon {
            self.messageErrorIcon = messageErrorIcon
        }
        return self
    }
    
    @discardableResult
    public func set(style: ReceiptStyle) -> Self {
        self.style = style
        return self
    }
    
    @discardableResult
    public func disable(receipt: Bool) -> Self {
        disableReceipt = receipt
        return self
    }
    /**
     This method used to set the cornerRadius for CometChatAvatar class
     - Parameter cornerRadius: This specifies a float value  which sets corner radius.
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     - See Also:
     [CometChatAvatar Documentation](https://prodocs.cometchat.com/docs/ios-ui-components#section-1-avatar)
     */
    @discardableResult
    public func set(receipt status: ReceiptStatus, tintColor: UIColor? = nil) -> Self {
        if !disableReceipt {
            self.isHidden = false
            switch status {
            case .failed:
                self.image = messageErrorIcon
                self.tintColor = CometChatTheme.palatte.error
            case .delivered:
                self.image = messageDeliveredIcon
                self.tintColor = style.deliveredIconTint
            case .inProgress:
                self.image = messageWaitIcon
                self.tintColor = CometChatTheme.palatte.accent500
            case .read:
                self.image = messageReadIcon
                self.tintColor = style.readIconTint
            case .sent:
                self.image = messageSentIcon
                self.tintColor = style.sentIconTint
            }
        } else {
            self.isHidden = true
        }
        return self
    }
    
    @discardableResult
    public func set(receiptConfiguration: ReceiptConfiguration)  -> CometChatReceipt {
        self.set(messageInProgressIcon: receiptConfiguration.messageWaitIcon  ?? UIImage())
        self.set(messageSentIcon: receiptConfiguration.messageSentIcon  ?? UIImage())
        self.set(messageReadIcon: receiptConfiguration.messageReadIcon  ?? UIImage())
        self.set(messageDeliveredIcon: receiptConfiguration.messageDeliveredIcon  ?? UIImage())
        self.set(messageErrorIcon: receiptConfiguration.messageErrorIcon  ?? UIImage())
        return self
    }
}
