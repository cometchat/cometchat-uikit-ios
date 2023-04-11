//
//  StickerKeyboardStyle.swift
//  
//
//  Created by Abdullah Ansari on 26/09/22.
//

import UIKit

public final class StickerKeyboardStyle: BaseStyle {

    // var categoryBackground: UIView
    private(set) var emptyTextFont: UIFont = .systemFont(ofSize: 42)
    private(set) var emptyTextColor: UIColor = .green
    private(set) var errorTextFont: UIFont = .systemFont(ofSize: 42)
    private(set) var errorTextColor: UIColor = .green
    private(set) var loadingTextColor: UIColor = .green
    private(set) var loadingTextFont: UIFont = .systemFont(ofSize: 42)
    
    @discardableResult
    public func set(emptyTextFont: UIFont) -> Self {
        self.emptyTextFont = emptyTextFont
        return self
    }
    
    @discardableResult
    public func set(emptyTextColor: UIColor) -> Self {
        self.emptyTextColor = emptyTextColor
        return self
    }
    
    @discardableResult
    public func set(errorTextFont: UIFont) -> Self {
        self.errorTextFont = errorTextFont
        return self
    }
    
    @discardableResult
    public func set(errorTextColor: UIColor) -> Self {
        self.errorTextColor = errorTextColor
        return self
    }
    
    @discardableResult
    public func set(loadingTextColor: UIColor) -> Self {
        self.loadingTextColor = loadingTextColor
        return self
    }
    
    @discardableResult
    public func set(loadingTextFont: UIFont) -> Self {
        self.loadingTextFont = loadingTextFont
        return self
    }
 
}
