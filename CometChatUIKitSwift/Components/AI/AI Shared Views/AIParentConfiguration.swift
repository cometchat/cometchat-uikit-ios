//
//  AIParentConfiguration.swift
//  
//
//  Created by SuryanshBisen on 25/09/23.
//

import Foundation
import UIKit
import CometChatSDK

public class AIParentConfiguration {
    
    private(set) var loadingView: UIView?
    private(set) var emptyRepliesView: UIView?
    private(set) var errorView: UIView?
    
    private(set) var loadingIcon: UIImage?
    private(set) var emptyIcon: UIImage?
    private(set) var errorIcon: UIImage?

    public init() { }
    
    @discardableResult
    public func set(loadingView: UIView) -> Self {
        self.loadingView = loadingView
        return self
    }
    
    @discardableResult
    public func set(errorView: UIView) -> Self {
        self.errorView = errorView
        return self
    }
    
    @discardableResult
    public func set(emptyRepliesView: UIView) -> Self {
        self.emptyRepliesView = emptyRepliesView
        return self
    }
    
    @discardableResult
    public func set(loadingIcon: UIImage?) -> Self {
        self.loadingIcon = loadingIcon
        return self
    }
    
    @discardableResult
    public func set(emptyIcon: UIImage?) -> Self {
        self.emptyIcon = emptyIcon
        return self
    }
    
    @discardableResult
    public func set(errorIcon: UIImage?) -> Self {
        self.errorIcon = errorIcon
        return self
    }
    

    
}
