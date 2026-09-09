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
    
    /// Puts the header in thread mode: pass the thread's root message and the
    /// subscribe/unsubscribe bell renders in the trailing area.
    @discardableResult
    public func set(parentMessage: BaseMessage?) -> Self {
        self.parentMessage = parentMessage
        return self
    }

    /// Hides the bell while leaving the feature on — for a host that already
    /// renders its own control elsewhere on the screen.
    @discardableResult
    public func set(hideThreadSubscriptionButton: Bool) -> Self {
        self.hideThreadSubscriptionButton = hideThreadSubscriptionButton
        addCustomViews()
        return self
    }

    @discardableResult
    public func set(trailView: @escaping ((_ user: User?, _ group: Group?) -> UIView)) -> Self {
        if viewModel.user?.isAgentic != true{
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
    
    /// Sets the ⋮ overflow menu items.
    ///
    /// Safe to call again after the header is on screen: if the menu button already exists
    /// the menu is rebuilt in place, so an item whose title or icon depends on state (a
    /// Pin/Unpin toggle, say) can be flipped by re-setting the array. Before first layout
    /// this just stores the items, and `addCustomViews()` builds the button.
    @discardableResult
    public func set(options: [CometChatPopupMenu.MenuItem]?) -> CometChatMessageHeader {
        self.options = options
        if let options = options, !options.isEmpty {
            rebuildMenu(for: options)
        }
        return self
    }
    
}


public struct CometChatPopupMenu {

    public struct MenuItem {
        let title: String
        let icon: UIImage
        let action: (() -> Void)?

        public init(title: String, icon: UIImage, action: (() -> Void)? = nil) {
            self.title = title
            self.icon = icon
            self.action = action
        }
    }
}
