//
//  CreateGroupConfiguration.swift
//  
//
//  Created by Abdullah Ansari on 19/08/22.
//

import UIKit
import CometChatSDK

public class CreateGroupConfiguration {
    
    private(set) var hideCloseButton: Bool?
    private(set) var closeButtonIcon: UIImage?
    private(set) var createButtonIcon: UIImage?
    private(set) var onCreateGroupClick: ((_ group: Group) -> ())?
    private(set) var createGroupStyle: CreateGroupStyle?
    private(set) var onError: ((_ error: CometChatException) -> Void)?
    private(set) var onBack: ( () -> Void)?
    
    public init() {}
    
    @discardableResult
    public func hide(closeButton: Bool) -> Self {
        self.hideCloseButton = closeButton
        return self
    }
    
    @discardableResult
    public func set(closeButtonIcon: UIImage?) -> Self {
        self.closeButtonIcon = closeButtonIcon
        return self
    }
    
    @discardableResult
    public func set(createButtonIcon: UIImage?) -> Self {
        self.createButtonIcon = createButtonIcon
        return self
    }
    
    @discardableResult
    public func setOnCreateGroupClick(onCreateGroupClick: @escaping ((_ group: Group) -> Void)) -> Self {
        self.onCreateGroupClick = onCreateGroupClick
        return self
    }
    
    @discardableResult
    public func set(createGroupStyle: CreateGroupStyle) -> Self {
        self.createGroupStyle = createGroupStyle
        return self
    }
    
    @discardableResult
    public func setOnError(onError: @escaping (_ error: CometChatException) -> Void) -> Self {
        self.onError = onError
        return self
    }
    
    @discardableResult
    public func setOnBack(onBack: @escaping () -> Void) -> Self {
        self.onBack = onBack
        return self
    }
        
}
