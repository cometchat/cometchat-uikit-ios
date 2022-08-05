//  CometChatAvatar.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2022 CometChat Inc. All rights reserved.

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
 CometChatAvatar: This component will be the class of UIImageView which is customizable to display CometChatMessageReceipt.
 
 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  */


// MARK: - Importing Frameworks.

import Foundation
import  UIKit
import  CometChatPro


/*  ----------------------------------------------------------------------------------------- */

@IBDesignable
@objc public final class CometChatMessageReceipt: UIImageView {
    
    // MARK: - Initialization of required Methods
    
    override init(image: UIImage?) { super.init(image: image) }
    override init(frame: CGRect) { super.init(frame: frame) }
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    var messageWaitIcon = UIImage(named: "messages-wait", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    var messageSentIcon = UIImage(named: "messages-sent", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)  ?? UIImage()
    var messageDeliveredIcon = UIImage(named: "messages-delivered", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    var messageReadIcon = UIImage(named: "messages-read", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)  ?? UIImage()
    var messageErrorIcon = UIImage(named: "messages-error", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)  ?? UIImage()
    
    public override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    // MARK: - instance methods
    @discardableResult
    @objc public func set(messageInProgressIcon: UIImage) -> CometChatMessageReceipt {
        self.messageWaitIcon = messageInProgressIcon
        return self
    }
    
    @discardableResult
    @objc public func set(messageSentIcon: UIImage) -> CometChatMessageReceipt {
        self.messageSentIcon = messageWaitIcon
        return self
    }
    
    @discardableResult
    @objc public func set(messageDeliveredIcon: UIImage) -> CometChatMessageReceipt {
        self.messageDeliveredIcon = messageDeliveredIcon
        return self
    }
    
    @discardableResult
    @objc public func set(messageReadIcon: UIImage) -> CometChatMessageReceipt {
        self.messageReadIcon = messageReadIcon
        return self
    }
    
    @discardableResult
    @objc public func set(messageErrorIcon: UIImage) -> CometChatMessageReceipt {
        self.messageErrorIcon = messageErrorIcon
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
    @objc public func set(receipt forMessage: BaseMessage) -> CometChatMessageReceipt {
        if let metaData = forMessage.metaData, let isError = metaData["error"] as? Bool, isError {
            self.isHidden = false
            self.image = messageErrorIcon
            self.tintColor = CometChatTheme.palatte?.error
            return self
        }
        self.isHidden = false
        if forMessage.readAt > 0 {
            self.image = messageReadIcon
            self.tintColor = CometChatTheme.palatte?.primary
        }else if forMessage.deliveredAt > 0 {
            self.image = messageDeliveredIcon
            self.tintColor = CometChatTheme.palatte?.accent500
        }else if forMessage.sentAt > 0 {
            self.image = messageSentIcon
            self.tintColor = CometChatTheme.palatte?.accent500
        }else if forMessage.sentAt == 0 {
            self.image = messageWaitIcon
            self.tintColor = CometChatTheme.palatte?.accent500
        }
        return self
    }
    
    @discardableResult
    public func set(configuration: MessageReceiptConfiguration)  -> CometChatMessageReceipt {
        self.set(messageInProgressIcon: configuration.messageWaitIcon  ?? UIImage())
        self.set(messageSentIcon: configuration.messageSentIcon  ?? UIImage())
        self.set(messageReadIcon: configuration.messageReadIcon  ?? UIImage())
        self.set(messageDeliveredIcon: configuration.messageDeliveredIcon  ?? UIImage())
        self.set(messageErrorIcon: configuration.messageErrorIcon  ?? UIImage()) 
        return self
    }
}

/*  ----------------------------------------------------------------------------------------- */


