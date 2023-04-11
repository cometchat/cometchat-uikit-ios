//
//  NewMessageIndicatorConfiguration.swift
//  
//
//  Created by Abdullah Ansari on 19/08/22.
//

import UIKit

public class NewMessageIndicatorConfiguration {
    
    private(set) var icon: UIImage = UIImage()
    private(set) var onClick: (() -> ())?
    private(set) var style: NewMessageIndicatorStyle?
    
    public init() {}
    
    @discardableResult
    public func set(icon: UIImage) -> Self {
        self.icon = icon
        return self
    }
    
    @discardableResult
    public func setOnClick(onClick: @escaping () -> ()) -> Self {
        self.onClick = onClick
        return self
    }
    
    @discardableResult
    public func set(style: NewMessageIndicatorStyle) -> Self {
        self.style = style
        return self
    }
}
