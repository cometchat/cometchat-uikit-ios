//
//  CollaborativeDocumentBubbleConfiguration.swift
//  
//
//  Created by Abdullah Ansari on 19/08/22.
//

import UIKit

public class CollaborativeDocumentBubbleConfiguration {
    
    private(set) var iconURL: String?
    private(set) var style: CollaborativeDocumentStyle?
    
    @discardableResult
    public func set(style: CollaborativeDocumentStyle) -> Self {
        self.style = style
        return self
    }
    
    @discardableResult
    public func set(iconURL: String) -> Self {
        self.iconURL = iconURL
        return self
    }
    
}
