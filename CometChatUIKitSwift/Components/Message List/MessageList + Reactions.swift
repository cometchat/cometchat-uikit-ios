//
//  MessageList + Reactions.swift
//  CometChatUIKitSwift
//
//  Created by SuryanshBisen on 18/02/24.
//

import Foundation
import CometChatSDK

extension CometChatMessageList {
    
    //Adding Reaction View in TableViewCell
    internal func buildReactionsView(forMessage: BaseMessage, cell: CometChatMessageBubble, alignment: MessageBubbleAlignment, reactionStlye : ReactionsStyle, template: CometChatMessageTemplate) {
        
        if forMessage.reactions.isEmpty == true { return }
        
        cell.bubbleStackView.layoutIfNeeded()
        let width = cell.bubbleStackView.bounds.width
        
        let cometChatReaction = CometChatReactions()
            .set(message: forMessage)
            .set(width: width)
            .set(onReactionsLongPressed: { [weak self] reactionCount, baseMessage in
                guard let this = self else { return }
                guard let message = baseMessage else { return }
                let reactionList = CometChatReactionList()
                    .set(message: message)
                    .set(defaultReaction: reactionCount.reaction)
                    .set(configuration: this.reactionListConfiguration)
                
                if let onReactionListItemClick = self?.onReactionListItemClick{
                    reactionList.set { reaction, baseMessage in
                        onReactionListItemClick(reaction, baseMessage)
                    }
                }
                if let reactionsRequestBuilder = self?.reactionsRequestBuilder{
                    reactionList.set(reactionRequestBuilder: reactionsRequestBuilder)
                }
                
                if #available(iOS 15.0, *) {
                    if let presentationController = reactionList.presentationController as? UISheetPresentationController {
                        presentationController.detents = [.medium()]
                        presentationController.prefersGrabberVisible = true
                        presentationController.preferredCornerRadius = CGFloat(reactionList.style.cornerRadius?.cornerRadius ?? 0)
                        this.controller?.present(reactionList, animated: true)
                    }
                } else {
                    this.controller?.presentPanModal(reactionList)
                }
                
            })
            .set(onReactionsPressed: { [weak self] reaction, baseMessage in
                if let onReactionClick = self?.onReactionClick?(reaction, baseMessage){
                    onReactionClick
                }else{
                    self?.reactToMessage(baseMessage: baseMessage, reaction: reaction.reaction)
                }
            })
            .set(reactionAlignment: alignment)
            .set(configuration: reactionsConfiguration)
//            .buildUI()
        
        cometChatReaction.style = reactionStlye
        cometChatReaction.isLayoutMarginsRelativeArrangement = true
        cometChatReaction.layoutMargins = UIEdgeInsets(top: -6, left: 3, bottom: 0, right: 3)
        cell.set(footerView: cometChatReaction)
        
    }
    
    //Reacting to a Message
    func reactToMessage(baseMessage: BaseMessage?, reaction: String,
                        service: MessageReactionServicing = LiveMessageReactionService()) {
        guard let baseMessage = baseMessage else { return }
        ReactionToggle.toggle(reaction, on: baseMessage, service: service, update: { [weak self] message in
            self?.update(message: message)
        }, failed: { [weak self] error in
            // Offline ON: the reaction went back, and the user is told why with the notice a refused
            // delete shows (BUG-3), not left to guess. Offline OFF is unchanged.
            DispatchQueue.main.async {
                guard OfflineGate.isOn() else { return }
                let reason = error ?? CometChatException(errorCode: "", errorDescription: "")
                (self?.viewModel as? MessageListViewModel)?.onOfflineActionError?(reason)
            }
        })
    }
    
}

/// The SDK's reaction calls behind a seam, so the optimistic update and its rollback can be
/// exercised without a live SDK.
internal protocol MessageReactionServicing {
    func addReaction(messageId: Int, reaction: String,
                     onSuccess: @escaping (BaseMessage) -> Void,
                     onError: @escaping (CometChatException?) -> Void)
    func removeReaction(messageId: Int, reaction: String,
                        onSuccess: @escaping (BaseMessage) -> Void,
                        onError: @escaping (CometChatException?) -> Void)
}

internal struct LiveMessageReactionService: MessageReactionServicing {
    func addReaction(messageId: Int, reaction: String,
                     onSuccess: @escaping (BaseMessage) -> Void,
                     onError: @escaping (CometChatException?) -> Void) {
        CometChat.addReaction(messageId: messageId, reaction: reaction, onSuccess: onSuccess, onError: onError)
    }

    func removeReaction(messageId: Int, reaction: String,
                        onSuccess: @escaping (BaseMessage) -> Void,
                        onError: @escaping (CometChatException?) -> Void) {
        CometChat.removeReaction(messageId: messageId, reaction: reaction, onSuccess: onSuccess, onError: onError)
    }
}

/// A tap on a reaction pill or a quick reaction: the bubble changes at once, and a failed add or
/// remove puts the bubble's reactions back.
///
/// The optimistic edit is made on COPIES of the message's `ReactionCount` objects. The originals are
/// never touched, so the rollback restores their real count and `reactedByMe`, and their place in
/// the list: editing the message's own objects in place left the rollback with objects that already
/// held the edited values, and a reaction that had been removed came back at the end of the row.
/// The reactions popover (`CometChatReactionList`) is not part of this and is unchanged.
internal enum ReactionToggle {

    private static func copy(_ reaction: ReactionCount) -> ReactionCount {
        let clone = ReactionCount()
        clone.reaction = reaction.reaction
        clone.count = reaction.count
        clone.reactedByMe = reaction.reactedByMe
        return clone
    }

    /// `failed` runs once a refused add or remove has been put back, with the SDK's error.
    static func toggle(_ emoji: String,
                       on message: BaseMessage,
                       service: MessageReactionServicing,
                       update: @escaping (BaseMessage) -> Void,
                       failed: ((CometChatException?) -> Void)? = nil) {
        // The message's own objects: only read from here on.
        let original = message.reactions
        let originalIndex = original.firstIndex(where: { $0.reaction == emoji })
        let originalEntry = originalIndex.map { original[$0] }

        var edited = original.map(copy)
        let removing: Bool
        if let index = originalIndex {
            let entry = edited[index]
            if entry.reactedByMe {
                removing = true
                entry.reactedByMe = false
                entry.count -= 1
                if entry.count <= 0 { edited.remove(at: index) }
            } else {
                removing = false
                entry.reactedByMe = true
                entry.count += 1
            }
        } else {
            removing = false
            let added = ReactionCount()
            added.reaction = emoji
            added.count = 1
            added.reactedByMe = true
            edited.append(added)
        }
        // Responsive UI: the bubble shows the change before the server answers.
        message.reactions = edited
        update(message)

        let onSuccess: (BaseMessage) -> Void = { sent in
            sent.mentionedUsers = message.mentionedUsers //TODO: API LEVEL BUG
            update(sent)
        }
        let onError: (CometChatException?) -> Void = { error in
            restore(emoji, entry: originalEntry, index: originalIndex, on: message)
            update(message)
            failed?(error)
        }
        if removing {
            service.removeReaction(messageId: message.id, reaction: emoji, onSuccess: onSuccess, onError: onError)
        } else {
            service.addReaction(messageId: message.id, reaction: emoji, onSuccess: onSuccess, onError: onError)
        }
    }

    /// Put this one reaction back as it was before the tap: the untouched original object, at its
    /// place. Other reactions on the message (a realtime change that landed meanwhile) are left alone.
    private static func restore(_ emoji: String, entry: ReactionCount?, index: Int?, on message: BaseMessage) {
        var current = message.reactions
        if let entry = entry {
            if let position = current.firstIndex(where: { $0.reaction == emoji }) {
                current[position] = entry
            } else {
                current.insert(entry, at: min(index ?? current.count, current.count))
            }
        } else {
            current.removeAll { $0.reaction == emoji }
        }
        message.reactions = current
    }
}
