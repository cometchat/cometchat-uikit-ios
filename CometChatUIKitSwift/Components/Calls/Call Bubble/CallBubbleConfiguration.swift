//
//  CollaborativeDocumentBubbleConfiguration.swift
//  
//
//  Created by Abdullah Ansari on 19/08/22.
//

import UIKit

public class CallBubbleConfiguration {
    
    private(set) var icon: UIImage?
    private(set) var style: CallBubbleStyle?
    private(set) var onClick: (() -> Void)?
    
    @discardableResult
    public func set(style: CallBubbleStyle) -> Self {
        self.style = style
        return self
    }
    
    @discardableResult
    public func set(icon: UIImage) -> Self {
        self.icon = icon
        return self
    }
    
    @discardableResult
    public func setOnClick(onClick: @escaping (() -> Void)) -> Self {
        self.onClick = onClick
        return self
    }
}
