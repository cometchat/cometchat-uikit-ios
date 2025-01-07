//
//  ReactionListConfiguration.swift
//  CometChatUIKitSwift
//
//  Created by SuryanshBisen on 29/02/24.
//

import Foundation
import CometChatSDK

open class ReactionListConfiguration {
    
    private (set) var reactionRequestBuilder: ReactionsRequestBuilder?
    private (set) var avatarStyle: AvatarStyle?
    private (set) var listItemStyle: ListItemStyle?
    private (set) var onTappedToRemoveClicked: ((_ messageReaction: CometChatSDK.Reaction, _ messageObject: BaseMessage) -> ())?
    private (set) var errorStateView: UIView?
    private (set) var loadingStateView: UIView?
    private (set) var style: ReactionListStyle?
    
    public init() { }
    
    @discardableResult
    public func set(reactionRequestBuilder: ReactionsRequestBuilder?) -> Self {
        self.reactionRequestBuilder = reactionRequestBuilder
        return self
    }
    
    @discardableResult
    public func set(avatarStyle: AvatarStyle?) -> Self {
        self.avatarStyle = avatarStyle
        return self
    }
    
    @discardableResult
    public func set(listItemStyle: ListItemStyle?) -> Self {
        self.listItemStyle = listItemStyle
        return self
    }
    
    @discardableResult
    public func set(onTappedToRemoveClicked: ((_ messageReaction: CometChatSDK.Reaction, _ messageObject: BaseMessage) -> ())?) -> Self {
        self.onTappedToRemoveClicked = onTappedToRemoveClicked
        return self
    }
    
    @discardableResult
    public func set(errorStateView: UIView?) -> Self {
        self.errorStateView = errorStateView
        return self
    }
    
    @discardableResult
    public func set(loadingStateView: UIView?) -> Self {
        self.loadingStateView = loadingStateView
        return self
    }
    
    @discardableResult
    public func set(style: ReactionListStyle?) -> Self {
        self.style = style
        return self
    }
    
}
