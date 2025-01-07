
//  CometChatActionMessageBubble.swift
 
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2022 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.
import UIKit
import CometChatSDK

/// A custom UIView that displays group action messages (e.g., user joined, left, kicked) in a chat interface.
public class CometChatGroupActionBubble: UIView {
    
    // MARK: - Properties
    
    /// The style properties for the group action bubble.
    public var style = GroupActionBubbleStyle()
    
    // MARK: - Lazy properties
    
    /// The label that displays the action message.
    public lazy var message: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints()
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    public override func willMove(toWindow newWindow: UIWindow?) {
        if newWindow != nil {
            setupStyle()
        }
    }
    
    // MARK: - UI Setup
    
    /// Builds the user interface for the bubble.
    public func buildUI() {
        self.withoutAutoresizingMaskConstraints()
        self.embed(message, insets: .init(top: CometChatSpacing.Padding.p1,
                                           leading: CometChatSpacing.Padding.p3,
                                           bottom: CometChatSpacing.Padding.p1,
                                           trailing: CometChatSpacing.Padding.p3))
        self.pin(anchors: [.height], to: 22)
    }
    
    /// Configures the styles for the message bubble.
    open func setupStyle() {
        super.layoutIfNeeded()
        self.message.textColor = style.bubbleTextColor
        self.message.font = style.bubbleTextFont
    }
    
    // MARK: - Message Handling
    
    /// Sets the action message to be displayed in the bubble.
    /// - Parameter messageObject: The base message containing action information.
    /// - Returns: The configured `CometChatGroupActionBubble`.
    @discardableResult
    @objc public func set(messageObject: BaseMessage) -> CometChatGroupActionBubble {
        if let actionMessage = messageObject as? ActionMessage {
            if let action = actionMessage.action {
                switch action {
                case .joined:
                    if let user = (actionMessage.actionBy as? User)?.name {
                        message.text = user + " " + "JOINED".localize()
                    }
                case .left:
                    if let user = (actionMessage.actionBy as? User)?.name {
                        message.text = user + " " + "LEFT".localize()
                    }
                case .kicked:
                    if let actionBy = (actionMessage.actionBy as? User)?.name,
                       let actionOn = (actionMessage.actionOn as? User)?.name {
                        message.text = actionBy + " " + "KICKED".localize() + " " + actionOn
                    }
                case .banned:
                    if let actionBy = (actionMessage.actionBy as? User)?.name,
                       let actionOn = (actionMessage.actionOn as? User)?.name {
                        message.text = actionBy + " " + "BANNED".localize() + " " + actionOn
                    }
                case .unbanned:
                    if let actionBy = (actionMessage.actionBy as? User)?.name,
                       let actionOn = (actionMessage.actionOn as? User)?.name {
                        message.text = actionBy + " " + "UNBANNED".localize() + " " + actionOn
                    }
                case .scopeChanged:
                    self.onScopeChanged(actionMessage: actionMessage)
                case .messageEdited, .messageDeleted:
                    message.text = actionMessage.message
                case .added:
                    if let actionBy = (actionMessage.actionBy as? User)?.name,
                       let actionOn = (actionMessage.actionOn as? User)?.name {
                        message.text = actionBy + " " + "ADDED".localize() + " " + actionOn
                    }
                @unknown default:
                    message.text = "ACTION_MESSAGE".localize()
                }
            }
        }
        return self
    }
    
    // MARK: - Scope Change Handling
    
    /// Handles scope changes for a user in the group.
    /// - Parameter actionMessage: The action message containing scope change information.
    private func onScopeChanged(actionMessage: ActionMessage) {
        if let actionBy = (actionMessage.actionBy as? User)?.name,
           let actionOn = (actionMessage.actionOn as? User)?.name {
            switch actionMessage.newScope {
            case .admin:
                let admin = "ADMIN".localize()
                message.text = actionBy + " " + "MADE".localize() + " \(actionOn) \(admin)"
            case .moderator:
                let moderator = "MODERATOR".localize()
                message.text = actionBy + " " + "MADE".localize() + " \(actionOn) \(moderator)"
            case .participant:
                let participant = "PARTICIPANT".localize()
                message.text = actionBy + " " + "MADE".localize() + " \(actionOn) \(participant)"
            @unknown default:
                break
            }
        }
    }
}
