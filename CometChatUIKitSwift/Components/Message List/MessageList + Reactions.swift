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
    internal func buildReactionsView(forMessage: BaseMessage, cell: CometChatMessageBubble, alignment: MessageBubbleAlignment, reactionStlye : ReactionsStyle) {
        
        if disableReactions == true { return }
        if forMessage.reactions.isEmpty == true { return }
        
        cell.bubbleStackView.layoutIfNeeded()
        let width = cell.bubbleStackView.bounds.width
        
        let cometChatReaction = CometChatReactions()
            .set(message: forMessage)
            .set(width: width)
            .set(onReactionsLongPressed: { [weak self] reaction, baseMessage in
                guard let this = self else { return }
                guard let message = baseMessage else { return }
                let reactionList = CometChatReactionList()
                    .set(message: message)
                    .set(defaultReaction: reaction.reaction)
                    .set(configuration: this.reactionListConfiguration)
                
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
                self?.reactToMessage(baseMessage: baseMessage, reaction: reaction.reaction)
            })
            .set(reactionAlignment: alignment)
            .set(configuration: reactionsConfiguration)
            .buildUI()
        
        cometChatReaction.style = reactionStlye
        cometChatReaction.isLayoutMarginsRelativeArrangement = true
        cometChatReaction.layoutMargins = UIEdgeInsets(top: -6, left: 3, bottom: 0, right: 3)
        cell.set(footerView: cometChatReaction)
        
    }
    
    //Reacting to a Message
    func reactToMessage(baseMessage: BaseMessage?, reaction: String) {
        guard let baseMessage = baseMessage else { return }
        let reactionData = baseMessage.reactions
        let tappedReactionIndex = reactionData.firstIndex(where: { $0.reaction == reaction })
        guard let tappedReactionIndex = tappedReactionIndex else {
            
            let newReaction = ReactionCount()
            newReaction.count = 1
            newReaction.reactedByMe = true
            newReaction.reaction = reaction
            baseMessage.reactions.append(newReaction)
            self.update(message: baseMessage)
            
            CometChat.addReaction(messageId: baseMessage.id, reaction: reaction) { [weak self] message in
                guard let this = self else { return }
                message.mentionedUsers = baseMessage.mentionedUsers //TODO: API LEVEL BUG
                this.update(message: message)
            } onError: { [weak self] error in
                guard let this = self else { return }
                
                //removing the locally added reaction
                for (index, reactionCount) in baseMessage.reactions.enumerated() {
                    if newReaction.reaction == reactionCount.reaction {
                        if reactionCount.count == 1 && reactionCount.reactedByMe == true {
                            baseMessage.reactions.remove(at: index)
                            this.update(message: baseMessage)
                            return
                        } else if reactionCount.reactedByMe == true && reactionCount.count > 1 {
                            baseMessage.reactions[index].count = baseMessage.reactions[index].count - 1
                            baseMessage.reactions[index].reactedByMe = false
                            this.update(message: baseMessage)
                            return
                        }
                    }
                }
            }
            
            return
            
        }
        let tappedReaction = reactionData[tappedReactionIndex]
        
        if tappedReaction.reactedByMe == true {
            
            //Update for responsive UI
            tappedReaction.reactedByMe = false
            tappedReaction.count -= 1
            if tappedReaction.count <= 0 {
                if baseMessage.reactions.count == 1 {
                    baseMessage.reactions = [ReactionCount]()
                } else {
                    baseMessage.reactions.remove(at: tappedReactionIndex)
                }
            } else {
                baseMessage.reactions[tappedReactionIndex] = tappedReaction
            }
            self.update(message: baseMessage)
            
            CometChat.removeReaction(messageId: baseMessage.id, reaction: tappedReaction.reaction) { [weak self] message in
                guard let this = self else { return }
                
                message.mentionedUsers = baseMessage.mentionedUsers //TODO: API LEVEL BUG
                this.update(message: message)
            } onError: { [weak self] error in
                guard let this = self else { return }
                
                tappedReaction.reactedByMe = true
                tappedReaction.count += 1
                let reactedIndex = baseMessage.reactions.firstIndex(where: { $0.reaction == reaction })
                if let reactedIndex = reactedIndex {
                    baseMessage.reactions[reactedIndex] = tappedReaction
                } else {
                    baseMessage.reactions.append(tappedReaction)
                }
                this.update(message: baseMessage)
            }
        } else {
            
            //Update for responsive UI
            tappedReaction.reactedByMe = true
            tappedReaction.count += 1
            baseMessage.reactions[tappedReactionIndex] = tappedReaction
            self.update(message: baseMessage)
            
            CometChat.addReaction(messageId: baseMessage.id, reaction: tappedReaction.reaction) { [weak self] message in
                guard let this = self else { return }
                message.mentionedUsers = baseMessage.mentionedUsers //TODO: API LEVEL BUG
                this.update(message: message)
            } onError: { [weak self] error in
                guard let this = self else { return }
                
                //removing locally added reaction on error occurred
                tappedReaction.reactedByMe = false
                tappedReaction.count -= 1
                baseMessage.reactions[tappedReactionIndex] = tappedReaction
                this.update(message: baseMessage)
            }
        }
        
    }
    
}
