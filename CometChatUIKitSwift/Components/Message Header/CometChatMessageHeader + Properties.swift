//
//  CometChatMessageHeader + Properties.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 10/02/25.
//

import Foundation
import CometChatSDK
import UIKit

extension CometChatMessageHeader {
    
    //MARK: Data
    @discardableResult
    @objc public func set(user: User) -> CometChatMessageHeader {
        viewModel.set(user: user)
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.configure(user: user)
        }
        return self
    }
    
    @discardableResult
    @objc public func set(group: Group) -> CometChatMessageHeader {
        viewModel.set(group: group)
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.configure(group: group)
        }
        return self
    }
    
    
    //MARK: Events
    @discardableResult
    public func set(onError: @escaping ((_ error: CometChatException) -> Void)) -> Self {
        self.onError = onError
        return self
    }
    
    @discardableResult
    public func set(onBack: @escaping (() -> Void)) -> Self {
        self.onBack = onBack
        return self
    }
    
    
    //MARK: Overrides
    @discardableResult
    public func set(listItemView: @escaping ((_ user: User?, _ group: Group?) -> UIView)) -> Self {
        self.listItemView = listItemView
        return self
    }
    
    @discardableResult
    public func set(trailView: @escaping ((_ user: User?, _ group: Group?) -> UIView)) -> Self {
        if viewModel.user?.isAgentic == false{
            self.trailView = trailView
        }
        return self
    }
    
    @discardableResult
    public func set(subtitleView: @escaping ((_ user: User?, _ group: Group?) -> UIView)) -> Self {
        self.subtitleView = subtitleView
        return self
    }
    
    @discardableResult
    public func set(leadingView: @escaping ((_ user: User?, _ group: Group?) -> UIView)) -> Self {
        self.leadingView = leadingView
        return self
    }
    
    @discardableResult
    public func set(titleView: @escaping ((_ user: User?, _ group: Group?) -> UIView)) -> Self {
        self.titleView = titleView
        return self
    }
    
    @discardableResult
    public func set(controller: UIViewController) -> Self {
        self.controller = controller
        return self
    }
    
}
