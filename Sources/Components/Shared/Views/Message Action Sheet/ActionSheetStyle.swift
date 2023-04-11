//
//  ActionSheetStyle.swift
//  
//
//  Created by Abdullah Ansari on 27/09/22.
//

import UIKit

public final class ActionSheetStyle: BaseStyle {

    private(set) var titleColor = CometChatTheme.palatte.accent900
    private(set) var titleFont = CometChatTheme.typography.title2
    private(set) var layoutModeIconTint = CometChatTheme.palatte.primary
    private(set) var cancelButtonIconTint = CometChatTheme.palatte.primary
    private(set) var cancelButtonIconFont = CometChatTheme.typography.text1
    private(set) var listItemIconTint = CometChatTheme.palatte.accent700
    private(set) var listItemTitleFont = CometChatTheme.typography.text1
    private(set) var listItemTitleColor = CometChatTheme.palatte.accent900
    private(set) var listItemIconBackground = CometChatTheme.palatte.background
    private(set) var listItemIconBorderRadius: CGFloat = 0.0

    override var cornerRadius: CometChatCornerStyle {
        get {
            return CometChatCornerStyle(cornerRadius: 10.0)
        }
        set {}
    }
    
    @discardableResult
    public func set(titleColor: UIColor) -> Self {
        self.titleColor = titleColor
        return self
    }
    
    @discardableResult
    public func set(titleFont: UIFont) -> Self {
        self.titleFont = titleFont
        return self
    }
    
    @discardableResult
    public func set(layoutModeIconTint: UIColor) -> Self {
        self.layoutModeIconTint = layoutModeIconTint
        return self
    }
    
    
    @discardableResult
    public func set(cancelButtonIconTint: UIColor) -> Self {
        self.cancelButtonIconTint = cancelButtonIconTint
        return self
    }
    
    @discardableResult
    public func set(listItemIconTint: UIColor) -> Self {
        self.listItemIconTint = listItemIconTint
        return self
    }
    
    @discardableResult
    public func set(listItemTitleFont: UIFont) -> Self {
        self.listItemTitleFont = listItemTitleFont
        return self
    }
    
    @discardableResult
    public func set(listItemTitleColor: UIColor) -> Self {
        self.listItemTitleColor = listItemTitleColor
        return self
    }
    
    @discardableResult
    public func set(listItemIconBackground: UIColor) -> Self {
        self.listItemIconBackground = listItemIconBackground
        return self
    }
    
    @discardableResult
    public func set(listItemIconBorderRadius: CGFloat) -> Self {
        self.listItemIconBorderRadius = listItemIconBorderRadius
        return self
    }
   
}
