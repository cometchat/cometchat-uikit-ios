//
//  JoinProtectedGroupConfiguration.swift
//  
//
//  Created by Abdullah Ansari on 31/08/22.
//

import UIKit
import CometChatSDK

public class JoinProtectedGroupConfiguration {

    private(set) var closeIcon: UIImage?
    private(set) var joinIcon: UIImage?
    private(set) var onJoinClick: ( (_ group: Group, _ password: String) -> Void )?
    private(set) var joinProtectedGroupStyle: JoinProtectedGroupStyle?
    private(set) var onError: ( (_ error: CometChatException) -> Void)?
    private(set) var onBack: (() -> Void)?
    
    public init() {}
    
    @discardableResult
    public func set(closeIcon: UIImage) -> Self {
        self.closeIcon = closeIcon
        return self
    }
    
    @discardableResult
    public func set(joinIcon: UIImage) -> Self {
        self.joinIcon = joinIcon
        return self
    }
    
    @discardableResult
    public func setOnJoinClick(onJoinClick: @escaping ( (_ group: Group, _ password: String) -> Void )) -> Self {
        self.onJoinClick = onJoinClick
        return self
    }
    
    @discardableResult
    public func set(joinProtectedGroupStyle: JoinProtectedGroupStyle) -> Self {
        self.joinProtectedGroupStyle = joinProtectedGroupStyle
        return self
    }
    
    @discardableResult
    public func setOnError(onError: @escaping ((_ error: CometChatException) -> Void)) -> Self {
        self.onError = onError
        return self
    }
    
    @discardableResult
    public func setOnBack(onBack: @escaping (() -> Void)) -> Self {
        self.onBack = onBack
        return self
    }
}
