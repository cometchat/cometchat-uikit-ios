//
//  DeleteBubbleConfiguration.swift
//  
//
//  Created by Abdullah Ansari on 19/08/22.
//

import UIKit


public class DeletedBubbleConfiguration {
    
    private(set) var style: DeleteBubbleStyle?
    
    @discardableResult
    public func set(style: DeleteBubbleStyle) -> DeletedBubbleConfiguration {
        self.style = style
        return self
    }
    
}
