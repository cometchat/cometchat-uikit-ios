//
//  MessageReceiptUtils.swift
//  
//
//  Created by Abdullah Ansari on 17/11/22.
//

import Foundation
import CometChatSDK


public enum ReceiptStatus {
    case inProgress
    case sent
    case delivered
    case failed
    case read
}

public struct MessageReceiptUtils {
    
    public static func get(receiptStatus message: BaseMessage) -> ReceiptStatus {
        if let metaData = message.metaData, let isError = metaData["error"] as? Bool, isError {
            return .failed
        }
        if MessageUtils.isMessageModerationDisapproved(message: message){
            return .failed
        }
        // Offline ON: an unsent row shows the clock or the failed icon, never a receipt, and "failed"
        // is derived from the SDK's status (so it holds after a relaunch) or from the in-memory
        // direct-failure mark. Offline OFF: this block is skipped entirely.
        // A direct-failure mark exists only if an ON-path send made it, so it is honoured whatever the
        // switch says now (a kill switch that flipped off must not turn a failed row back into a clock).
        if OfflineHub.shared.isDirectFailed(message) { return .failed }
        if OfflineGate.isOn() {
            switch MessageIdentity.status(message) {
            case .failed: return .failed
            case .pending, .sending: return .inProgress
            default: break
            }
        }
        if message.readAt > 0 {
            return .read
        } else if message.deliveredAt > 0 {
            return .delivered
        } else if message.id == 0 {
            return .inProgress
        } else if message.id > 0 {
            return  .sent
        }
        return .failed
    }
    
}
