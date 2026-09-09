//
//  CometChatThreadEvents.swift
//  CometChatUIKitSwift
//
//  Copyright © 2026 CometChat. All rights reserved.
//

import Foundation
import CometChatSDK

/// Keeps the action-sheet option and the thread header in agreement without a refetch.
public class CometChatThreadEvents {

    static private var observer = NSMapTable<NSString, AnyObject>(keyOptions: .strongMemory, valueOptions: .weakMemory)

    @objc public static func addListener(_ id: String, _ observer: CometChatThreadEventListener) {
        self.observer.setObject(observer, forKey: NSString(string: id))
    }

    @objc public static func removeListener(_ id: String) {
        self.observer.removeObject(forKey: NSString(string: id))
    }

    public static func ccThreadSubscriptionChanged(parentMessageId: Int, isSubscribed: Bool) {
        let objectEnumerator = self.observer.objectEnumerator()
        while let observer = objectEnumerator?.nextObject() as? CometChatThreadEventListener {
            observer.ccThreadSubscriptionChanged?(parentMessageId: parentMessageId, isSubscribed: isSubscribed)
        }
    }
}

/// Admits one toggle per parent message at a time, shared by the action sheet and the
/// thread header so the two entry points cannot fire concurrently for the same thread.
/// A toggle is also refused within `debounceInterval` of the last one settling.
/// Main-thread only, matching every caller.
final class ThreadSubscriptionToggleGuard {

    static let shared = ThreadSubscriptionToggleGuard()

    private static let debounceInterval: TimeInterval = 0.4

    private var inFlight = Set<Int>()
    private var lastSettled = [Int: TimeInterval]()

    /// Returns false when a toggle for this thread is in flight or too recent.
    func begin(parentMessageId: Int) -> Bool {
        if inFlight.contains(parentMessageId) { return false }
        if let settled = lastSettled[parentMessageId],
           Date().timeIntervalSince1970 - settled < Self.debounceInterval {
            return false
        }
        inFlight.insert(parentMessageId)
        return true
    }

    func end(parentMessageId: Int) {
        inFlight.remove(parentMessageId)
        lastSettled[parentMessageId] = Date().timeIntervalSince1970
    }
}

/// Public entry point for a host that renders its own follow/unfollow control.
/// The guard itself stays internal: it holds the debounce and the one-in-flight-per-thread
/// rule, and a caller that took a slot without releasing it would block that thread's
/// toggle for the life of the process. Here the slot is released for you.
public enum CometChatThreadSubscription {

    /// Runs `toggle` only if no toggle for this thread is in flight or too recent,
    /// and releases the slot when `toggle` calls its completion. Main-thread only.
    /// - Returns: false when the toggle was refused, so the caller can skip its own work.
    @discardableResult
    public static func withToggleSlot(parentMessageId: Int,
                                      _ toggle: (@escaping () -> Void) -> Void) -> Bool {
        guard ThreadSubscriptionToggleGuard.shared.begin(parentMessageId: parentMessageId) else {
            return false
        }
        // Guarded so a caller that signals completion twice cannot open a second slot.
        var released = false
        toggle {
            guard !released else { return }
            released = true
            ThreadSubscriptionToggleGuard.shared.end(parentMessageId: parentMessageId)
        }
        return true
    }
}
