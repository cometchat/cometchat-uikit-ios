//
//  FlagReasonsManager.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 11/12/25.
//

import Foundation
import CometChatSDK

final class FlagReasonsManager {

    static let shared = FlagReasonsManager()
    private init() {}

    public var flagReasons: [FlagReason] = []

    /// Called globally after CometChat.init() or after user login
    func getFlagReasons() {
        CometChat.getFlagReasons { [weak self] reasons in
            self?.flagReasons = reasons
        } onError: { error in
            print("Failed to preload flag reasons: \(error?.errorDescription ?? "")")
        }
    }

    /// Read-only access for UI classes
    func getReasons() -> [FlagReason] {
        return flagReasons
    }

    /// Call this on logout if needed
    func clear() {
        flagReasons = []
    }
}
