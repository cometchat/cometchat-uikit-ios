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
    @objc func setProgressIcon(icon: UIImage) -> MessageReceiptConfiguration {
        self.messageWaitIcon = icon
        return self
    }
    
    @discardableResult
    @objc func setSentIcon(icon: UIImage) -> MessageReceiptConfiguration {
        self.messageSentIcon = icon
        return self
    }
    
    @discardableResult
    @objc func setDeliveredIcon(icon: UIImage) -> MessageReceiptConfiguration {
        self.messageSentIcon = icon
        return self
    }
    
    @discardableResult
    @objc func setReadIcon(icon: UIImage) -> MessageReceiptConfiguration {
        self.messageReadIcon = icon
        return self
    }
    
    @discardableResult
    @objc func setFailureIcon(icon: UIImage) -> MessageReceiptConfiguration {
        self.messageErrorIcon = icon
        return self
    }
    
    public func getProgressIcon() -> UIImage{
        return messageWaitIcon ?? UIImage()
    }
    
    public func getDeliveredIcon() -> UIImage {
        return messageDeliveredIcon ?? UIImage()
    }
    
    public func getReadIcon() -> UIImage {
        return messageReadIcon ?? UIImage()
    }
    
    public func getFailureIcon() -> UIImage {
        return messageErrorIcon ?? UIImage()
    }
    
    public func getSentIcon() -> UIImage {
        return messageSentIcon ?? UIImage()
    }
    
    
    
    
}
