//
//  WhiteboardBubbleConfiguration.swift
//  
//
//  Created by Abdullah Ansari on 19/08/22.
//

import UIKit

public final class CollaborativeWhiteboardBubbleConfiguration {

    private(set) var iconURL: String?
    private(set) var style: CollaborativeBubbleStyle?
    
    @discardableResult
    public func set(style: CollaborativeBubbleStyle) -> Self {
        self.style = style
        return self
    }
    
    @discardableResult
    public func set(iconURL: String) -> Self {
        self.iconURL = iconURL
        return self
    }
    
}
