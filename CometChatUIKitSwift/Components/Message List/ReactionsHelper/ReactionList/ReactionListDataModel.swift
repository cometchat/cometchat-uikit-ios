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
        self.reactionsRequest = reactionsRequest?.build()
    }
    
    func fetchPrevious(onSuccess: @escaping () -> Void, onError: @escaping (_ error: CometChatSDK.CometChatException?) -> Void) {
        
        if reactionsRequest == nil {
            let reactionsRequestBuilder = ReactionsRequestBuilder()
                .set(limit: 10)
                .set(messageId: messageID)
            if reaction != "All" {
                reactionsRequestBuilder.set(reaction: reaction)
            }
            reactionsRequest = reactionsRequestBuilder.build()
        }
        
        reactionsRequest?.fetchPrevious(onSuccess: { [weak self] messageReactions in
            guard let self = self else { return }
            if messageReactions.isEmpty {
                self.hasAllReactions = true
            }
            self.messageReaction.append(contentsOf: messageReactions)
            onSuccess()
        }, onError: onError)
        
    }
}
