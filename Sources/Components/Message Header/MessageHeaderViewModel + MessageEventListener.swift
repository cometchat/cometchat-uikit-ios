//
//  File.swift
//  
//
//  Created by Abdullah Ansari on 05/02/23.
//

import Foundation
import CometChatSDK


//MARK: Adding Typing Delegate Methods
extension MessageHeaderViewModel: CometChatMessageDelegate {
    
    public func onTypingStarted(_ typingDetails: TypingIndicator) {
        switch typingDetails.receiverType {
        case .user:
            if typingDetails.sender?.uid == user?.uid {
                if let name = typingDetails.sender?.name {
                    updateTypingStatus?(true)
                    self.name = name
                }
            }
        case .group:
            if typingDetails.receiverID == group?.guid {
                if let name = typingDetails.sender?.name {
                    updateTypingStatus?(true)
                    self.name = name
                }
            }
        @unknown default: break
        }
    }
    
    public func onTypingEnded(_ typingDetails: TypingIndicator) {
        switch typingDetails.receiverType {
        case .user:
            if typingDetails.sender?.uid == user?.uid {
                updateTypingStatus?(false)
            }
        case .group:
            if let group = group {
                if typingDetails.receiverID == group.guid {
                    updateTypingStatus?(false)
                }
            }
        @unknown default: break
        }
    }
}
