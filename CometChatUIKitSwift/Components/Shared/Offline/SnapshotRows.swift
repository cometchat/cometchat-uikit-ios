//
//  SnapshotRows.swift
//  CometChatUIKitSwift
//
//  The reconcile every two-phase snapshot list shares (users, groups, group members, ...). The
//  cached page paints first; the server's page for the same slice then replaces it. No UIKit.
//

import Foundation

internal enum SnapshotRows {

    /// `current` is what is shown, whose tail may be the cached page just painted (`cachedKeys`).
    /// Rows outside the cached page are kept in place; the cached rows the server page does not
    /// have are dropped (the server proves them gone); the server page follows, de-duplicated by
    /// key against what is kept. A row with no key is kept. An empty server page after an empty
    /// cached page leaves the list as it was.
    static func reconcile<T>(current: [T], cachedKeys: Set<String>, serverPage: [T], key: (T) -> String?) -> [T] {
        let serverKeys = Set(serverPage.compactMap(key))
        var result = current.filter { row in
            guard let k = key(row) else { return true }
            return !cachedKeys.contains(k) && !serverKeys.contains(k)
        }
        result.append(contentsOf: serverPage)
        return result
    }

    /// Paint the cached page: replace rows with the same key, append the rest.
    static func paintCached<T>(current: [T], cachedPage: [T], key: (T) -> String?) -> [T] {
        return reconcile(current: current, cachedKeys: [], serverPage: cachedPage, key: key)
    }

    /// A refresh of the first page over rows already shown: rows in `page` are updated where they
    /// are and new ones follow; `gone` (rows the server proved removed) leave; nothing else moves.
    static func mergeInPlace<T>(current: [T], page: [T], gone: Set<String> = [], key: (T) -> String?) -> [T] {
        var merged = current.filter { row in
            guard let k = key(row) else { return true }
            return !gone.contains(k)
        }
        for row in page {
            if let k = key(row), let index = merged.firstIndex(where: { key($0) == k }) {
                merged[index] = row
            } else {
                merged.append(row)
            }
        }
        return merged
    }

    /// A first page (refresh) replaces what was shown, but never blanks it for an empty cache.
    static func startRefresh<T>(current: [T], cachedPage: [T]) -> [T] {
        return cachedPage.isEmpty ? current : cachedPage
    }
}

/// Hop to the main queue, running inline when already there.
internal enum OfflineSnapshotMain {
    static func run(_ block: @escaping () -> Void) {
        if Thread.isMainThread { block() } else { DispatchQueue.main.async(execute: block) }
    }
}
