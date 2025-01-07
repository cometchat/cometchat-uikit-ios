//
//  CometChatReactions.swift
//  CometChatUIKitSwift
//
//  Created by SuryanshBisen on 29/02/24.
//

import Foundation
import CometChatSDK

/// `CometChatReactions` is a UIStackView subclass that displays a collection of reaction views
/// for a specific message in the chat interface. It supports gesture recognition for both taps
/// and long presses on the reaction views and manages the styling and layout of the reactions.
open class CometChatReactions: UIStackView {
    
    /// The optional width of the reactions view, used to limit the number of reactions displayed.
    private(set) var width: CGFloat?
    
    /// The alignment of the reactions in relation to the message bubble.
    private(set) var reactionAlignment: MessageBubbleAlignment = .left
    
    /// The base message associated with the reactions, containing relevant data.
    private(set) var message: BaseMessage?
    
    /// Closure that is called when a reaction is long-pressed.
    private(set) var onReactionsLongPressed: ((_ reaction: ReactionCount, _ baseMessage: BaseMessage?) -> ())?
    
    /// Closure that is called when a reaction is tapped.
    private(set) var onReactionsPressed: ((_ reaction: ReactionCount, _ baseMessage: BaseMessage?) -> ())?
    
    /// Static property to define global styling for all reaction views.
    public static var style = ReactionsStyle()
    
    /// Instance property for component-level styling, defaults to the global style.
    public lazy var style = CometChatReactions.style
    
    /// Initializes a new instance of `CometChatReactions`.
    override public init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    open override func willMove(toWindow newWindow: UIWindow?) {
        if newWindow != nil{
            // buildUI()
            // TODO: FIX THIS
        }
    }
    
    /// Builds the reactions view by arranging reaction buttons based on the provided message data.
    @discardableResult
    open func buildUI() -> Self {
        guard let message = message else { return self }
        // Set up layout properties for the stack view.
        self.spacing = 3
        self.distribution = .fill
        self.axis = .horizontal
        self.alignment = .trailing
        
        guard let cellWidth = width else { return self }
        let reactionsData = message.reactions
        var reactionWidth: CGFloat = 82
        var index = 0
        var displayedCount = 0
        
        // If the alignment is right, add an empty UIView for spacing.
        if reactionAlignment == .right {
            self.addArrangedSubview(UIView())
        }
        
        // Loop through the reactions and create views for each one.
        while (index < reactionsData.count && cellWidth > reactionWidth) {
            let reactions = reactionsData[index]
            
            let reactionView = ReactionsView(baseMessage: message, reaction: reactions, style: style)
            
            // Set up gesture recognizers for long press and tap.
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(onReactionsLongPressed(_:)))
            reactionView.addGestureRecognizer(longPressGesture)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onReactionTappedGesture(_:)))
            tapGesture.require(toFail: longPressGesture)
            reactionView.addGestureRecognizer(tapGesture)
                        
            // Wrap the reaction view with a background color and add to the stack.
            self.addArrangedSubview(reactionView)
            
            reactionWidth += 45
            displayedCount += 1
            index += 1
        }
        
        // Handle the case where there are more reactions than can fit.
        if displayedCount < reactionsData.count {
            
            if (displayedCount + 1) == reactionsData.count {
                let reactions = reactionsData[index]
                let reactionView = ReactionsView(baseMessage: message, reaction: reactions, style: style)
                let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(onReactionsLongPressed(_:)))
                reactionView.addGestureRecognizer(longPressGesture)
                
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onReactionTappedGesture(_:)))
                tapGesture.require(toFail: longPressGesture)
                reactionView.addGestureRecognizer(tapGesture)
                
                self.addArrangedSubview(reactionView)
            } else {
                var iterativeIndex = index
                var hasReactionThatIsReactedByMe = false
                while (iterativeIndex < reactionsData.count) {
                    let reactions = reactionsData[iterativeIndex]
                    if reactions.reactedByMe {
                        hasReactionThatIsReactedByMe = true
                        break
                    }
                    iterativeIndex = iterativeIndex + 1
                }
                
                let allReactionCountObject = ReactionCount()
                allReactionCountObject.count = reactionsData.count - displayedCount
                allReactionCountObject.reaction = "+"
                allReactionCountObject.reactedByMe = hasReactionThatIsReactedByMe
                
                let reactionView = ReactionsView(baseMessage: message, reaction: allReactionCountObject, style: style)
                reactionView.emojiStackView.spacing = 0
                let longPressGesture = UITapGestureRecognizer(target: self, action: #selector(onReactionsLongPressed(_:)))
                reactionView.addGestureRecognizer(longPressGesture)

                self.addArrangedSubview(reactionView)
            }
        }
        
        // If the alignment is left, add an empty UIView for spacing.
        if reactionAlignment == .left {
            self.addArrangedSubview(UIView())
        }
        
        return self
    }
    
    /// Handles long press gestures on reaction views.
    /// - Parameter sender: The gesture recognizer that triggered the action.
    @objc func onReactionsLongPressed(_ sender: Any) {
        
        var button = (((sender as? UILongPressGestureRecognizer)?.view) as? ReactionsView) ?? (((sender as? UITapGestureRecognizer)?.view) as? ReactionsView)
        guard let button = button else { return }
        
        // Trigger the long-press callback with the reaction data.
        onReactionsLongPressed?(button.reaction, message)
    }
    
    /// Triggers the tap callback for a reaction.
    /// - Parameter reaction: The `ReactionCount` associated with the tapped reaction.
    @objc func onReactionsTapped(_ reaction: ReactionCount) {
        onReactionsPressed?(reaction, message)
    }
    
    /// Handles tap gestures on reaction views.
    /// - Parameter sender: The gesture recognizer that triggered the action.
    @objc func onReactionTappedGesture(_ sender: UITapGestureRecognizer) {
        if let reactionView = sender.view as? ReactionsView {
            let reaction = reactionView.reaction
            onReactionsTapped(reaction)
        }
    }
}

extension CometChatReactions {
    
    /// Sets the width for the `CometChatReactions` view.
    /// - Parameter width: The desired width for the reactions view.
    /// - Returns: The instance of `CometChatReactions` for method chaining.
    @discardableResult
    public func set(width: CGFloat) -> Self {
        self.width = width
        return self
    }
    
    /// Sets the alignment of the reactions in relation to the message bubble.
    /// - Parameter reactionAlignment: The desired alignment (left or right).
    /// - Returns: The instance of `CometChatReactions` for method chaining.
    @discardableResult
    public func set(reactionAlignment: MessageBubbleAlignment) -> Self {
        self.reactionAlignment = reactionAlignment
        return self
    }
    
    /// Sets the message associated with the reactions.
    /// - Parameter message: The `BaseMessage` object containing reaction data.
    /// - Returns: The instance of `CometChatReactions` for method chaining.
    @discardableResult
    public func set(message: BaseMessage) -> Self {
        self.message = message
        return self
    }
    
    /// Sets the closure to be called when a reaction is long-pressed.
    /// - Parameter onReactionsLongPressed: Closure that handles long-press actions on reactions.
    /// - Returns: The instance of `CometChatReactions` for method chaining.
    @discardableResult
    public func set(onReactionsLongPressed: @escaping ((_ reaction: ReactionCount, _ baseMessage: BaseMessage?) -> ())) -> Self {
        self.onReactionsLongPressed = onReactionsLongPressed
        return self
    }
    
    /// Sets the closure to be called when a reaction is tapped.
    /// - Parameter onReactionsPressed: Closure that handles tap actions on reactions.
    /// - Returns: The instance of `CometChatReactions` for method chaining.
    @discardableResult
    public func set(onReactionsPressed: @escaping ((_ reaction: ReactionCount, _ baseMessage: BaseMessage?) -> ())) -> Self {
        self.onReactionsPressed = onReactionsPressed
        return self
    }
    
    /// Configures the `CometChatReactions` view with a `ReactionsConfiguration` object.
    /// - Parameter configuration: The configuration object containing optional settings.
    /// - Returns: The instance of `CometChatReactions` for method chaining.
    @discardableResult
    public func set(configuration: ReactionsConfiguration?) -> Self {
        
        if let configuration = configuration {
            // Set the width if provided.
            if let width = configuration.width {
                set(width: width)
            }
            
            // Set the reaction alignment if provided (deprecated).
            if let reactionAlignment = configuration.reactionAlignment {
                set(reactionAlignment: reactionAlignment)
            }
            
            // Set the tap handler if provided.
            if let onReactionsPressed = configuration.onReactionsPressed {
                set(onReactionsPressed: onReactionsPressed)
            }
            
            // Set the long-press handler if provided.
            if let onReactionsLongPressed = configuration.onReactionsLongPressed {
                set(onReactionsLongPressed: onReactionsLongPressed)
            }
        }
        
        return self
    }
}



