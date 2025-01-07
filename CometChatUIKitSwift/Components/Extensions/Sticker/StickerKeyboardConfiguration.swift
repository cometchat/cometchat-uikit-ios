//
//  StickerKeyboardConfiguration.swift
//  
//
//  Created by Abdullah Ansari on 23/08/22.
//

import UIKit

public class StickerKeyboardConfiguration {
    
    private(set) var emptyText: String?
    private(set) var loadingText: String?
    private(set) var errorText: String?
    private(set) var emptyStateView: UIView?
    private(set) var errorStateView: UIView?
    private(set) var stickerKeyboardStyle: StickerKeyboardStyle?
    private(set) var stickerIcon: UIImage?
    private(set) var onClick: (() -> Void)?
    
    public init() {}
    
    @discardableResult
    public func set(stickerKeyboardStyle: StickerKeyboardStyle?) -> Self {
        self.stickerKeyboardStyle = stickerKeyboardStyle
        return self
    }
    
    @discardableResult
    public func set(stickerIcon: UIImage?) -> Self {
        self.stickerIcon = stickerIcon
        return self
    }
    
    @discardableResult
    public func set(emptyText: String) -> Self {
        self.emptyText = emptyText
        return self
    }
    
    @discardableResult
    public func set(loadingText: String) -> Self {
        self.loadingText = loadingText
        return self
    }
    
    @discardableResult
    public func set(errorText: String) -> Self {
        self.errorText = errorText
        return self
    }
    
    @discardableResult
    public func set(emptyStateView: UIView?) -> Self {
        self.emptyStateView = emptyStateView
        return self
    }
    
    @discardableResult
    public func set(errorStateView: UIView?) -> Self {
        self.errorStateView = errorStateView
        return self
    }
    
    @discardableResult
    public func setOnClick(onClick: @escaping () -> Void) -> Self {
        self.onClick = onClick
        return self
    }
    
}
