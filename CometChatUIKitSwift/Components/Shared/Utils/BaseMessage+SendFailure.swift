//
//  BaseMessage+SendFailure.swift
//  CometChatUIKitSwift
//

import Foundation
import CometChatSDK

extension BaseMessage {

    /// Marks an own message as failed to send by adding `error: true` to its metadata.
    ///
    /// The integrator's own metadata keys are kept; the composers used to replace the whole
    /// dictionary, which dropped them from the `ccMessageSent(.error)` payload.
    ///
    /// A message sent through the offline send helper is not stamped with `error`: its failed state
    /// is derived from the SDK's status, or from the hub's direct-failure mark, never remembered in
    /// metadata. `permissionDenied` (an RBAC refusal from the server) is stamped either way, because
    /// it is not an offline concept.
    func markSendFailed(permissionDenied error: CometChatException? = nil) {
        var metaData = self.metaData ?? [:]
        var changed = false
        if !OfflineHub.shared.isTracked(self) {
            metaData["error"] = true
            changed = true
        }
        if let error = error, error.errorCode == "ERR_PERMISSION_DENIED" {
            metaData["rbac_permission_denied"] = true
            metaData["error_message"] = error.errorDescription
            changed = true
        }
        if changed { self.metaData = metaData }
    }

    /// `true` when `error: true` is stamped on a regular message (not an action message).
    var hasSendErrorFlag: Bool {
        metaData?["error"] as? Bool == true && messageCategory == .message
    }

    /// `true` when the server refused the send for permissions and the kit stamped it.
    var hasPermissionDeniedFlag: Bool {
        metaData?["rbac_permission_denied"] as? Bool == true && messageCategory == .message
    }

    /// Whether the row's long press must be disabled because of a failure flag. An unsent own row
    /// (offline ON) stays actionable (Retry / Delete) whatever its metadata says, so a flag
    /// can never lock a failed send out of its menu.
    func blocksLongPress(unsentRowIsActionable: Bool) -> Bool {
        if unsentRowIsActionable { return false }
        return hasSendErrorFlag || hasPermissionDeniedFlag
    }
}
