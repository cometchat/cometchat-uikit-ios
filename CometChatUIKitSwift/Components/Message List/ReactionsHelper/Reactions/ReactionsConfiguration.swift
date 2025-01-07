//
//  ReactionConfiguration.swift
//  CometChatUIKitSwift
//
//  Created by SuryanshBisen on 29/02/24.
//

import Foundation
import CometChatSDK

open class ReactionsConfiguration {
    
    private(set) var width: CGFloat?
    private(set) var reactionAlignment: MessageBubbleAlignment?
    private(set) var onReactionsLongPressed: ((_ reaction: ReactionCount, _ baseMessage: BaseMessage?) -> ())?
    private(set) var onReactionsPressed: ((_ reaction: ReactionCount, _ baseMessage: BaseMessage?) -> ())?
    private(set) var style = ReactionsStyle()
    
    public init() {}
    
    @discardableResult
    public func set(width: CGFloat) -> Self {
        self.width = width
        return self
    }
    
    @available(*, deprecated)
    public func set(reactionAlignment: MessageBubbleAlignment) -> Self {
        self.reactionAlignment = reactionAlignment
        return self
    }
    
    @discardableResult
    public func set(onReactionsLongPressed: @escaping ((_ reaction: ReactionCount, _ baseMessage: BaseMessage?) -> ())) -> Self {
        self.onReactionsLongPressed = onReactionsLongPressed
        return self
    }
    
    @discardableResult
    public func set(onReactionsPressed: @escaping ((_ reaction: ReactionCount, _ baseMessage: BaseMessage?) -> ())) -> Self {
        self.onReactionsPressed = onReactionsPressed
        return self
    }
    
    @discardableResult
    public func set(style: ReactionsStyle) -> Self {
        self.style = style
        return self
    }
    
    
}
