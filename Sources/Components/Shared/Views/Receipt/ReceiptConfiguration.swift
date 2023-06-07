//
//  MessageReceiptConfiguration.swift
 
//
//  Created by Pushpsen Airekar on 10/01/22.
//

import Foundation
import UIKit

public class ReceiptConfiguration: CometChatConfiguration  {
    
    private(set) var messageWaitIcon = UIImage(named: "messages-wait", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    private(set) var messageReadIcon = UIImage(named: "messages-read", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    private(set) var messageDeliveredIcon = UIImage(named: "messages-delivered", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    private(set) var messageSentIcon = UIImage(named: "messages-sent", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    private(set) var messageErrorIcon = UIImage(named: "messages-wait", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    
    @discardableResult
    public func setProgressIcon(icon: UIImage) -> Self {
        self.messageWaitIcon = icon
        return self
    }
    
    @discardableResult
    public func setSentIcon(icon: UIImage) -> Self {
        self.messageSentIcon = icon
        return self
    }
    
    @discardableResult
    public func setDeliveredIcon(icon: UIImage) -> Self {
        self.messageSentIcon = icon
        return self
    }
    
    @discardableResult
    public func setReadIcon(icon: UIImage) -> Self {
        self.messageReadIcon = icon
        return self
    }
    
    @discardableResult
    public func setFailureIcon(icon: UIImage) -> Self {
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
