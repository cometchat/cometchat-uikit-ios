//
//  MessagePreviewConfiguration.swift
//  
//
//  Created by Abdullah Ansari on 07/09/22.
//

import UIKit

public class MessagePreviewConfiguration {
    
    private(set) var closeIcon: UIImage?
    private(set) var onCloseClick: (() -> ())?
    private(set) var style: MessagePreviewStyle?
    
    @discardableResult
    public func set(closeIcon: UIImage) -> Self {
        self.closeIcon = closeIcon
        return self
    }
    
    @discardableResult
    public func setOnCloseClick(onCloseClick: @escaping (() -> ())) -> Self {
        self.onCloseClick = onCloseClick
        return self
    }
    
    @discardableResult
    public func set(style: MessagePreviewStyle) -> Self {
        self.style = style
        return self
    }
}
