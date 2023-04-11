//
//  ActionSheetConfiguration.swift
//  
//
//  Created by Abdullah Ansari on 23/08/22.
//

import UIKit

public final class ActionSheetConfiguration {
    
    private(set) var layoutModeIcon: String?
    private(set) var cancelButtonIcon: String?
    private(set) var layoutMode: LayoutMode?
    private(set) var messageTypes: [CometChatMessageTemplate]?
    private(set) var hideLayoutMode: Bool?
    private(set) var style: ActionSheetStyle?
    
    @discardableResult
    public func set(layoutModeIcon: String) -> Self {
        self.layoutModeIcon = layoutModeIcon
        return self
    }
    
    @discardableResult
    public func set(cancelButtonIcon: String) -> Self {
        self.cancelButtonIcon = cancelButtonIcon
        return self
    }
    
    @discardableResult
    public func set(layoutMode: LayoutMode) -> Self {
        self.layoutMode = layoutMode
        return self
    }
    
    @discardableResult
    func set(messageTypes: [CometChatMessageTemplate]) -> Self {
        self.messageTypes = messageTypes
        return self
    }
    
    @discardableResult
    func hide(layoutMode: Bool) -> Self {
        self.hideLayoutMode = layoutMode
        return self
    }
    
    @discardableResult
    public func set(style: ActionSheetStyle) -> Self {
        self.style = style
        return self
    }

}
