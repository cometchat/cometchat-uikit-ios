//
//  CometChatUsers + Properties.swift
//  CometChatUIKitSwift
//
//  Created by Suryansh on 19/06/24.
//

import Foundation
import CometChatSDK

extension CometChatUsers {
    
    @discardableResult
    public func setSubtitle(subtitle: ((_ user: User?) -> UIView)?) -> Self {
        self.subtitle = subtitle
        return self
    }
    
    @discardableResult
    public func setListItemView(listItemView: ((_ user: User?) -> UIView)?) -> Self {
        self.listItemView = listItemView
        return self
    }
    
    @discardableResult
    public func setOptions(options: ((_ user: User?) -> [CometChatUserOption])?) -> Self {
        self.options = options
        return self
    }
    
    @discardableResult
    public func show(sectionHeader: Bool) -> Self {
        self.showSectionHeader = sectionHeader
        return self
    }
    
    @discardableResult
    public func disable(userPresence: Bool) -> Self {
        self.disableUsersPresence = userPresence
        return self
    }
    
    @discardableResult
    public func setOnItemClick(onItemClick: @escaping ((_ user: User, _ indexPath: IndexPath?) -> Void)) -> Self {
        self.onItemClick = onItemClick
        return self
    }
    
    @discardableResult
    public func setOnItemLongClick(onItemLongClick: @escaping ((_ user: User, _ indexPath: IndexPath) -> Void)) -> Self {
        self.onItemLongClick = onItemLongClick
        return self
    }
    
    @discardableResult
    public func setOnError(onError: @escaping ((_ error: CometChatException) -> Void)) -> Self {
        self.onError = onError
        return self
    }
    
    @discardableResult
    public func setOnBack(onBack: @escaping () -> Void) -> Self {
        self.onBack = onBack
        return self
    }
    
    @discardableResult
    public func setSelectionLimit(limit : Int) -> Self {
        self.selectionLimit = limit
        return self
    }

}
