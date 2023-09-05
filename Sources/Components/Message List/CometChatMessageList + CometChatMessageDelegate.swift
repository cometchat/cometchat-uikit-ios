//
//  CometChatMessageList + CometChatMessageDelegate.swift
 
//
//  Created by Pushpsen Airekar on 31/01/22.
//

import Foundation
import CometChatSDK
//
//extension CometChatMessageListOld: CometChatMessageDelegate {
//
//    public func onTextMessageReceived(textMessage: TextMessage) {
//        
//        switch textMessage.receiverType {
//        case .user:
//            if textMessage.sender?.uid == currentUser?.uid {
//                if enableSoundForMessages {
//                    CometChatSoundManager().play(sound: .incomingMessage, customSound: customIncomingMessageSound)
//                }
//                self.addOnReceiving(message: textMessage)
//            }
//        case .group:
//            if textMessage.receiverUid == currentGroup?.guid {
//                if enableSoundForMessages {
//                    CometChatSoundManager().play(sound: .incomingMessage, customSound: customIncomingMessageSound)
//                }
//                self.addOnReceiving(message: textMessage)
//            }
//        @unknown default: break
//        }
//       
//    }
//    
//    public  func onMediaMessageReceived(mediaMessage: MediaMessage) {
//        switch mediaMessage.receiverType {
//        case .user:
//            if mediaMessage.sender?.uid == currentUser?.uid {
//                if enableSoundForMessages {
//                    CometChatSoundManager().play(sound: .incomingMessage, customSound: customIncomingMessageSound)
//                }
//                self.addOnReceiving(message: mediaMessage)
//            }
//        case .group:
//            if mediaMessage.receiverUid == currentGroup?.guid {
//                if enableSoundForMessages {
//                    CometChatSoundManager().play(sound: .incomingMessage, customSound: customIncomingMessageSound)
//                }
//                self.addOnReceiving(message: mediaMessage)
//            }
//        @unknown default: break
//        }
//    }
//    
//    public func onCustomMessageReceived(customMessage: CustomMessage) {
//        switch customMessage.receiverType {
//        case .user:
//            if customMessage.sender?.uid == currentUser?.uid || customMessage.sender?.uid == CometChat.getLoggedInUser()?.uid {
//                if enableSoundForMessages {
//                    CometChatSoundManager().play(sound: .incomingMessage, customSound: customIncomingMessageSound)
//                }
//                self.addOnReceiving(message: customMessage)
//            }
//        case .group:
//            if customMessage.receiverUid == currentGroup?.guid {
//                if enableSoundForMessages {
//                    CometChatSoundManager().play(sound: .incomingMessage, customSound: customIncomingMessageSound)
//                }
//                self.addOnReceiving(message: customMessage)
//            }
//        @unknown default: break
//        }
//    }
//    
//    public func onMessagesDelivered(receipt: MessageReceipt) {
//        if let indexpath = self.chatMessages.indexPath(where: {$0.id == Int(receipt.messageId)}){
//            let message = chatMessages[indexpath.section][indexpath.row]
//            message.deliveredAt = receipt.deliveredAt
//            self.update(message: message)
//        }
//    }
//    
//    public func onMessagesRead(receipt: MessageReceipt) {
//        if let indexpath = self.chatMessages.indexPath(where: {$0.id == Int(receipt.messageId)}){
//            let message = chatMessages[indexpath.section][indexpath.row]
//            message.readAt = receipt.readAt
//            self.update(message: message)
//        }
//    }
//    
//    public func onMessageEdited(message: BaseMessage) {
//        if enableSoundForMessages {
//            CometChatSoundManager().play(sound: .incomingMessage, customSound: customIncomingMessageSound)
//        }
//        self.update(message: message)
//    }
//    
//    public func onMessageDeleted(message: BaseMessage) {
//        if enableSoundForMessages {
//            CometChatSoundManager().play(sound: .incomingMessage, customSound: customIncomingMessageSound)
//        }
//        self.update(message: message)
//    }
//    
//    
//}
//
