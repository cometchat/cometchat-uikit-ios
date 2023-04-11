//
//  EmojiKeyboardConfiguration.swift
//  
//
//  Created by Abdullah Ansari on 19/08/22.
//

import UIKit

public class EmojiKeyboardConfiguration {
    
    private(set) var hideSearch: Bool?
    private(set) var onClick: (() -> ())?
    private(set) var emojiKeyboardStyle: EmojiKeyboardStyle?
    
    @discardableResult
    public func hide(search: Bool) -> Self {
        self.hideSearch = search
        return self
    }
    
    @discardableResult
    public func set(onClick: (() -> ())?) -> Self {
        self.onClick = onClick
        return self
    }
    
    @discardableResult
    public func set(emojiKeyboardStyle: EmojiKeyboardStyle) -> Self {
        self.emojiKeyboardStyle = emojiKeyboardStyle
        return self
    }
    
}
