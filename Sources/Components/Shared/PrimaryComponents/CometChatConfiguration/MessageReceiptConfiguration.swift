//
//  MessageReceiptConfiguration.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 10/01/22.
//

import Foundation
import UIKit

public class MessageReceiptConfiguration: CometChatConfiguration  {
    
    var messageWaitIcon = UIImage(named: "messages-wait", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    var messageSentIcon = UIImage(named: "messages-sent", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    var messageDeliveredIcon = UIImage(named: "messages-delivered", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    var messageReadIcon = UIImage(named: "messages-read", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    var messageErrorIcon = UIImage(named: "messages-wait", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    
    @discardableResult
    @objc public func setProgressIcon(icon: UIImage) -> MessageReceiptConfiguration {
        self.messageWaitIcon = icon
        return self
    }
    
    @discardableResult
    @objc public func setSentIcon(icon: UIImage) -> MessageReceiptConfiguration {
        self.messageSentIcon = icon
        return self
    }
    
    @discardableResult
    @objc public func setDeliveredIcon(icon: UIImage) -> MessageReceiptConfiguration {
        self.messageSentIcon = icon
        return self
    }
    
    @discardableResult
    @objc public func setReadIcon(icon: UIImage) -> MessageReceiptConfiguration {
        self.messageReadIcon = icon
        return self
    }
    
    @discardableResult
    @objc public func setFailureIcon(icon: UIImage) -> MessageReceiptConfiguration {
        self.messageErrorIcon = icon
        return self
    }
    
    @discardableResult
    public func getProgressIcon() -> UIImage{
        return messageWaitIcon ?? UIImage()
    }
    
    @discardableResult
    public func getDeliveredIcon() -> UIImage {
        return messageDeliveredIcon ?? UIImage()
    }
    
    @discardableResult
    public func getReadIcon() -> UIImage {
        return messageReadIcon ?? UIImage()
    }
    
    @discardableResult
    public func getFailureIcon() -> UIImage {
        return messageErrorIcon ?? UIImage()
    }
    
    @discardableResult
    public func getSentIcon() -> UIImage {
        return messageSentIcon ?? UIImage()
    }
    
    
    
    
}
