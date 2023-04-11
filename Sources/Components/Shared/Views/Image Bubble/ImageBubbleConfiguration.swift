//
//  ImageBubbleConfiguration.swift
//  
//
//  Created by Abdullah Ansari on 19/08/22.
//

import UIKit

public class ImageBubbleConfiguration {
    
    private(set) var style: ImageBubbleStyle?
    private(set) var overlayImageURL: String? // This property should be change in notion.
    
    @discardableResult
    public func set(style: ImageBubbleStyle) -> ImageBubbleConfiguration {
        self.style =  style
        return self
    }
    
    @discardableResult
    public func set(overlayImageURL: String) -> ImageBubbleConfiguration {
        self.overlayImageURL =  overlayImageURL
        return self
    }
    
}
