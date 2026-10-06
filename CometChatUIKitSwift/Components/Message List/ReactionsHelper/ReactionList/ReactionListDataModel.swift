//
//  ReactionListDataModel.swift
//  CometChatUIKitSwift
//
//  Created by SuryanshBisen on 29/02/24.
//

import Foundation
import CometChatSDK

open class ReactionListDataModel {
    var reaction: String
    var count: Int
    var reactionsRequest: ReactionsRequest?
    var messageReaction: [CometChatSDK.Reaction] = [CometChatSDK.Reaction]()
    var messageID: Int
    var hasAllReactions = false
    
    public init(reaction: String, count: Int, messageID: Int, reactionsRequest: ReactionsRequestBuilder? = nil) {
        self.reaction = reaction
        self.count = count
        self.messageID = messageID
        if let reactionsRequest = reactionsRequest {
            // The All tab lists every reactor, so it must not narrow the request to an emoji named "All".
            if !ReactionListDataModel.isAllBucket(reaction) {
                _ = reactionsRequest.set(reaction: reaction)
            }
            self.reactionsRequest = reactionsRequest.build()
        }
    }
    
    /// Whether `reaction` is the aggregate "All" tab rather than an emoji, in English or the current locale.
    static func isAllBucket(_ reaction: String) -> Bool {
        return reaction == "All" || reaction == "ALL".localize()
    }
    
    func fetchPrevious(onSuccess: @escaping () -> Void, onError: @escaping (_ error: CometChatSDK.CometChatException?) -> Void) {
        
        if reactionsRequest == nil {
            let reactionsRequestBuilder = ReactionsRequestBuilder()
                .set(limit: 10)
                .set(messageId: messageID)
            if !ReactionListDataModel.isAllBucket(reaction) {
                reactionsRequestBuilder.set(reaction: reaction)
            }
            reactionsRequest = reactionsRequestBuilder.build()
        }
        
        reactionsRequest?.fetchPrevious(onSuccess: { [weak self] messageReactions in
            guard let self = self else { return }
            if messageReactions.isEmpty {
                self.hasAllReactions = true
            }
            self.append(page: messageReactions)
            onSuccess()
        }, onError: onError)
        
    }
    
    /// Appends a fetched page, skipping reactors already listed for the same emoji
    /// (a page can overlap the previous one, e.g. after a reaction is added mid-scroll).
    func append(page messageReactions: [CometChatSDK.Reaction]) {
        var seen = Set(messageReaction.map { "\($0.uid)|\($0.reaction)" })
        for reaction in messageReactions where seen.insert("\(reaction.uid)|\(reaction.reaction)").inserted {
            messageReaction.append(reaction)
        }
    }
}
