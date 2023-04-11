//
//  MessageReactionsConfiguration.swift
//  
//
//  Created by Abdullah Ansari on 19/08/22.
//

import UIKit

public final class MessageReactionsConfiguration {
    
    private(set) var style: MessageReactionStyle?
    
    @discardableResult
    public func set(style: MessageReactionStyle) -> Self {
        self.style = style
        return self
    }
}
