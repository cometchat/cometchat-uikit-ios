//
//  SmartRepliesConfiguration.swift
//  
//
//  Created by Abdullah Ansari on 19/08/22.
//

import UIKit

public class SmartRepliesConfiguration {
        
    private(set) var customOutgoingMessageSound: String?
    private(set) var enableSoundForMessages: Bool?
    private(set) var closeIcon: UIImage?
    private(set) var onClose: (() -> ())?
    private(set) var onClick: (() -> ())?
    private(set) var style: SmartRepliesStyle?
    
    @discardableResult
    public func set(customOutgoingMessageSound: String) -> Self {
        self.customOutgoingMessageSound = customOutgoingMessageSound
        return self
    }
    
    @discardableResult
    public func enable(soundForMessagesonClick: Bool) -> Self {
        self.enableSoundForMessages = soundForMessagesonClick
        return self
    }
    
    @discardableResult
    public func set(closeIcon: UIImage) -> Self {
        self.closeIcon = closeIcon
        return self
    }
    
    @discardableResult
    public func setOnClose(onClose: @escaping (() -> ())) -> Self {
        self.onClose = onClose
        return self
    }
    
    @discardableResult
    public func setOnClick(onClick: @escaping (() -> ())) -> Self {
        self.onClick = onClick
        return self
    }
    
    @discardableResult
    public func set(style: SmartRepliesStyle) -> Self {
        self.style = style
        return self
    }

}
