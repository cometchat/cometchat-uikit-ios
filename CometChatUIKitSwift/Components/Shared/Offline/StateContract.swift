//
//  StateContract.swift
//  CometChatUIKitSwift
//
//  The state contract (TEST-PLAN §3.3): automation identifiers the UI Kit conformance runners read.
//  They ship in release builds, are set only through `accessibilityIdentifier` (never a label or a
//  value, so what VoiceOver announces is unchanged) and never contain message text.
//
//  Native shape: the value travels inside the identifier, dot-separated.
//
//  | Element            | Identifier                                                         |
//  |--------------------|--------------------------------------------------------------------|
//  | Message row        | cc.message.<renderKey>.<sending|sent|delivered|read|failed>        |
//  | Row menu           | cc.message.options (container) · cc.message.option.<optionId>      |
//  | Notice             | cc.notice.<STRING_KEY>                                             |
//  | List footer        | cc.list-footer.<loading|connect-to-load-more|end|none>             |
//  | Newer-edge row     | cc.list-header.connect-to-load-more                                |
//  | Jump to latest     | cc.list.jump-to-latest                                             |
//  | Composer           | cc.composer.input · cc.composer.send · cc.composer.tray-tile.<fileId>.<uploading|done|failed|rejected> |
//  | Conversation row   | cc.conversation.<user|group>.<with>.<previewState>.<unread>.<pinned> |
//  | Empty / error view | cc.empty.<reason> · cc.error.<reason>                              |
//  | Media placeholder  | cc.message.media.available-when-online                             |
//  | Unsent-row status  | cc.message.retry (tap to retry)                                    |
//
//  No UIKit imports.
//

import Foundation

internal enum StateContract {

    static func messageRow(renderKey: String, state: String) -> String {
        return "cc.message.\(renderKey).\(state)"
    }

    static let messageOptions = "cc.message.options"

    static func messageOption(_ optionId: String) -> String {
        return "cc.message.option.\(optionId)"
    }

    static func notice(_ key: String) -> String {
        return "cc.notice.\(key)"
    }

    enum Footer: String {
        case loading, connectToLoadMore = "connect-to-load-more", end, none
    }

    static func listFooter(_ footer: Footer) -> String {
        return "cc.list-footer.\(footer.rawValue)"
    }

    /// The "Connect to load more" row at the newest end of the message list (D84 rule 9). The older end
    /// is `listFooter(.connectToLoadMore)`.
    static let newerEdgeConnectToLoadMore = "cc.list-header.connect-to-load-more"

    static let jumpToLatest = "cc.list.jump-to-latest"
    static let composerInput = "cc.composer.input"
    static let composerSend = "cc.composer.send"

    static func trayTile(fileId: String, state: String) -> String {
        return "cc.composer.tray-tile.\(fileId).\(state)"
    }

    /// `previewState`: `sending`, `failed` or `sent` for an own last message, `none` otherwise.
    static func conversationRow(isGroup: Bool, with id: String, previewState: String, unread: Int, pinned: Bool) -> String {
        return "cc.conversation.\(isGroup ? "group" : "user").\(id).\(previewState).\(unread).\(pinned ? "pinned" : "unpinned")"
    }

    static func empty(_ reason: String) -> String { return "cc.empty.\(reason)" }
    static func error(_ reason: String) -> String { return "cc.error.\(reason)" }

    static let mediaAvailableWhenOnline = "cc.message.media.available-when-online"
    /// The tap-to-retry control of an unsent row (its status icon, and the "Not sent. Tap to retry" line).
    static let retryControl = "cc.message.retry"
}
