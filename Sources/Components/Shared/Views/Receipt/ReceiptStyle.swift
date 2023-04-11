//
//  File.swift
//  
//
//  Created by Ajay Verma on 13/01/23.
//

import UIKit

public final class ReceiptStyle {
    
    private(set) var sentIconTint = CometChatTheme.palatte.accent500
    private(set) var deliveredIconTint = CometChatTheme.palatte.accent500
    private(set) var readIconTint = CometChatTheme.palatte.primary
    
    public init() {}
    
    @discardableResult
    public func set(sentIconTint: UIColor) -> Self {
        self.sentIconTint = sentIconTint
        return self
    }
    
    @discardableResult
    public func set(deliveredIconTint: UIColor) -> Self {
        self.deliveredIconTint = deliveredIconTint
        return self
    }
    
    @discardableResult
    public func set(readIconTint: UIColor) -> Self {
        self.readIconTint = readIconTint
        return self
    }


}
