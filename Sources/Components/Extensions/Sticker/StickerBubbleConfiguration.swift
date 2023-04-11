//
//  StickerBubbleConfiguration.swift
//  
//
//  Created by Abdullah Ansari on 19/08/22.
//

import UIKit

public class StickerBubbleConfiguration {

    private(set) var style: StickerBubbleStyle?
    
    @discardableResult
    public func set(style: StickerBubbleStyle) -> StickerBubbleConfiguration {
        self.style = style
        return self
    }
}
