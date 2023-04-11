//
//  VideoBubbleConfiguration.swift
//  
//
//  Created by Abdullah Ansari on 19/08/22.
//

import UIKit

public class VideoBubbleConfiguration {
    
    private(set) var style: VideoBubbleStyle?
    
    @discardableResult
    public func set(style: VideoBubbleStyle) -> VideoBubbleConfiguration {
        self.style = style
        return self
    }
    
}
