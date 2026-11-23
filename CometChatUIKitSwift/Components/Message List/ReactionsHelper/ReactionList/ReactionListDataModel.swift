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
    
    /// Asks whether offline is on for this read (`OfflineGate.isOn`, read once per read). A seam so a
    /// test can force the offline path for this one model.
    internal var offlineGate: () -> Bool = { OfflineGate.isOn() }

    /// Offline ON only: the page in two phases, the on-device copy first.
    internal var fetchPreviousTwoPhase: (_ request: ReactionsRequest,
                                         _ onCached: @escaping ([CometChatSDK.Reaction]) -> Void,
                                         _ onServer: @escaping ([CometChatSDK.Reaction]) -> Void,
                                         _ onError: @escaping (CometChatSDK.CometChatException?) -> Void) -> Void = { request, onCached, onServer, onError in
        request.fetchPrevious(onCachedReactions: onCached, onServerReactions: onServer, onError: onError)
    }

    /// Whoever is waiting on the offline read in flight. The SDK answers a read made during another
    /// with an empty page (BEH-SNAP-14), which is not the end of the list, so there is only one.
    private var offlineWaiters: [(success: () -> Void, failure: (CometChatSDK.CometChatException?) -> Void)] = []

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
        
        // Offline ON (read once for this read): two phases, cached then server.
        if offlineGate() {
            offlineFetchPrevious(onSuccess: onSuccess, onError: onError)
            return
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
    
    /// The cached page paints, the server's replaces the same slice. Only an empty server page ends
    /// the list. Not connected over saved reactors is a calm state, not an error (BEH-READ-05).
    private func offlineFetchPrevious(onSuccess: @escaping () -> Void, onError: @escaping (CometChatSDK.CometChatException?) -> Void) {
        offlineWaiters.append((onSuccess, onError))
        guard offlineWaiters.count == 1, let request = reactionsRequest else { return }
        var cachedKeys = Set<String>()
        let key: (CometChatSDK.Reaction) -> String? = { "\($0.uid)|\($0.reaction)" }

        fetchPreviousTwoPhase(request, { [weak self] page in
            guard let self = self, !page.isEmpty else { return }
            cachedKeys = Set(page.compactMap(key))
            self.append(page: page)
            self.offlineWaiters.forEach { $0.success() }
        }, { [weak self] page in
            guard let self = self else { return }
            if page.isEmpty { self.hasAllReactions = true }
            self.messageReaction = SnapshotRows.reconcile(current: self.messageReaction, cachedKeys: cachedKeys, serverPage: page, key: key)
            let waiters = self.offlineWaiters
            self.offlineWaiters.removeAll()
            waiters.forEach { $0.success() }
        }, { [weak self] error in
            guard let self = self else { return }
            let waiters = self.offlineWaiters
            self.offlineWaiters.removeAll()
            if OfflineErrors.isNotConnected(code: error?.errorCode), !self.messageReaction.isEmpty {
                waiters.forEach { $0.success() }
            } else {
                waiters.forEach { $0.failure(error) }
            }
        })
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
