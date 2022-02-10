//
//  CometChatMessageList + MessageComposerDelegate.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 30/01/22.
//

import Foundation
import UIKit
import CometChatPro

extension CometChatMessageList: CometChatMessageComposerDelegate {
    
    func onEditTextMessage(message: TextMessage, status: MessageStatus) {
        
    }
    

   
    func onMessageSent(message: BaseMessage, status: MessageStatus) {
        switch status {
        case .inProgress:
            self.appendMessage(message: message)
        case .success:
            self.updateMessage(message: message)
        }
        
    }
    
    func onMessageError(message: BaseMessage, error: CometChatException) {
        
    }

    
    func onLiveReaction(message: TransientMessage) {
        if isAnimating == false {
            reactionView.image1 = UIImage(named: "messages-heart", in: CometChatUIKit.bundle, compatibleWith: nil)
            self.reactionView.isHidden = false
            
            isAnimating = true
            
            Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { timer in
                self.reactionView.sendReaction()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                    timer.invalidate()
                    self.reactionView.stopReaction()
                })
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                self.isAnimating = false
            })
            
            if !reactionView.isAnimating {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
                self.reactionView.isHidden = true
            })
            }
        }
    }
}

