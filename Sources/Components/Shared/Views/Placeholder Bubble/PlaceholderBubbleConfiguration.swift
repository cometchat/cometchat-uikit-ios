//
//  PlaceholderBubbleConfiguration.swift
//  
//
//  Created by Abdullah Ansari on 19/08/22.
//

import UIKit

public class PlaceholderBubbleConfiguration {

    private(set) var style: PlaceholderBubbleStyle?
    
    @discardableResult
    public func set(style: PlaceholderBubbleStyle) -> PlaceholderBubbleConfiguration {
        self.style = style
        return self
    }
    
}
