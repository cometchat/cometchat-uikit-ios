//
//  GroupActionBubbleConfiguration.swift
//  
//
//  Created by Abdullah Ansari on 19/08/22.
//

import UIKit

public class GroupActionBubbleConfiguration {

    private(set) var style: GroupActionBubbleStyle?
    
    @discardableResult
    public func set(style: GroupActionBubbleStyle) -> GroupActionBubbleConfiguration {
        self.style = style
        return self
    }
}
