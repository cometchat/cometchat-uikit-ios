//
//  QuickReactionConfiguration.swift
//  CometChatUIKitSwift
//
//  Created by SuryanshBisen on 29/02/24.
//

import UIKit
import Foundation

open class QuickReactionsConfiguration {
    private (set) var onReacted: ((_ reaction: String?) -> Void)?
    private (set) var onAddReactionIconTapped: (() -> Void)?
    private (set) var reactionList: [String]?
    private (set) var addReactionIcon: UIImage?
    private (set) var style: QuickReactionsStyle?
    
    public init() { }
    
    @discardableResult
    public func set(onReacted: ((_ reaction: String?) -> Void)?) -> Self {
        self.onReacted = onReacted
        return self
    }
    
    @discardableResult
    public func set(onAddReactionIconTapped: (() -> Void)?) -> Self {
        self.onAddReactionIconTapped = onAddReactionIconTapped
        return self
    }
    
    @discardableResult
    public func set(reactionList: [String]?) -> Self {
        self.reactionList = reactionList
        return self
    }
    
    @discardableResult
    public func set(addReactionIcon: UIImage?) -> Self {
        self.addReactionIcon = addReactionIcon
        return self
    }
    
    @discardableResult
    public func set(style: QuickReactionsStyle?) -> Self {
        self.style = style
        return self
    }
    
}
