//
//  PinSaveErrorCodes.swift
//  CometChatUIKitSwift
//

import Foundation

/// Server error codes for pin/save, matching the backend's actual repo conventions
/// (ENG-37690 comment, 2026-07-29) rather than the earlier design doc, which named
/// codes — `ERR_ACTION_NOT_ALLOWED`, `ERR_MESSAGE_NOT_FOUND`, `ERR_MESSAGE_NOT_ACCESSIBLE`
/// — that don't exist in the codebase.
///
/// The limit case does not rely on these at all — it is recognised by `errorParams`
/// carrying the cap, which is contract. These codes only refine the message when no
/// params arrive.
///
/// RBAC/SBAC on pin/unpin is not enforced server-side yet (§8), so `permissionCodes`
/// is here for when it lands, not because it fires today.
public struct PinSaveErrorCodes {

    public static let pinLimitReached = "ERR_PINNED_MESSAGES_LIMIT_EXCEEDED"
    public static let saveLimitReached = "ERR_SAVED_MESSAGES_LIMIT_EXCEEDED"

    public static let pinPermissionDenied = "ERR_PERMISSION_DENIED"
    public static let messageNoAccess = "ERR_MESSAGE_NO_ACCESS"
    public static let messageActionNotAllowed = "ERR_MESSAGE_ACTION_NOT_ALLOWED"
    public static let featureNotAccessible = "ERR_FEATURE_NOT_ACCESSIBLE"

    static let permissionCodes: Set<String> = [pinPermissionDenied, messageNoAccess, messageActionNotAllowed, featureNotAccessible]
    static let limitCodes: Set<String> = [pinLimitReached, saveLimitReached]
}
