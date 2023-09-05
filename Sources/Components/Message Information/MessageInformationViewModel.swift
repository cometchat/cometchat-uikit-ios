///  MessageInformationViewModel.swift
/// Created by Ajay Verma on 06/07/23.

import Foundation
import CometChatSDK


protocol MessageInformationViewModelProtocol {
    var message: CometChatSDK.BaseMessage? { get set }
    var receipts: [MessageReceipt] { get set }
}

open class MessageInformationViewModel: NSObject, MessageInformationViewModelProtocol {
    var receipts: [CometChatSDK.MessageReceipt] = [CometChatSDK.MessageReceipt]()
    var message: CometChatSDK.BaseMessage?
    var eventHandler: ((_ event: Event) -> Void)?
    
    
    override init(){}
    
    func getMessageReceipt(information forMessage: BaseMessage) {
        receipts.removeAll()
        self.eventHandler?(.startLoading)
        
        var receiverType: CometChatSDK.MessageReceipt.ReceiptType?
        
        if forMessage.readAt > 0.0 {
            receiverType = .read
        } else if forMessage.deliveredAt > 0.0 {
            receiverType = .delivered
        }
        
        if forMessage.receiverType == .user {
            if let receiptSender = forMessage.receiver as? User {
                if let receiverType = receiverType {
                    let receipt = CometChatSDK.MessageReceipt(messageId: "\(forMessage.id)", sender: receiptSender, receiverId: CometChatUIKit.getLoggedInUser()?.uid ?? "", receiverType: .user, receiptType: receiverType, timeStamp: 0)
                    
                        receipt.deliveredAt = forMessage.deliveredAt
                        receipt.readAt = forMessage.readAt
                        self.receipts.append(receipt)
                        self.eventHandler?(.endLoading)
                        self.eventHandler?(.reload)
                }
            }
            
        } else {
            
            CometChat.getMessageReceipts(forMessage.id, onSuccess: { (fetchedReceipts) in
                self.receipts = fetchedReceipts
                self.eventHandler?(.endLoading)
                self.eventHandler?(.reload)
            }) { (error) in
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.eventHandler?(.endLoading)
                    if let error = error {
                        self.eventHandler?(.error(error))
                    }
                }
            }
        }
        
    }
    
    func connect() {
        CometChat.addMessageListener("message-inforamtion-messages-listener", self)
    }
    
    func remove() {
        CometChat.removeMessageListener("message-inforamtion-messages-listener")
    }
    
}

extension MessageInformationViewModel {
    enum Event {
        case startLoading
        case endLoading
        case reload
        case error(_ error: CometChatException?)
    }
}

extension MessageInformationViewModel: CometChatMessageDelegate {
    
    public func onMessagesRead(receipt: MessageReceipt) {
        if let index = self.receipts.firstIndex(where: {$0.messageId == receipt.messageId}) {
            let deliveredAt = self.receipts[index].deliveredAt
            self.receipts.remove(at: index)
            self.receipts.append(receipt)
            if receipt.readAt > 0.0 {
                self.receipts.last?.deliveredAt = deliveredAt
                self.receipts.last?.readAt = receipt.readAt
            }
            self.eventHandler?(.reload)
        } else {
            if receipt.readAt > 0.0 {
                self.receipts.last?.deliveredAt = receipt.deliveredAt
                self.receipts.last?.readAt = receipt.readAt
            }
            self.receipts.append(receipt)
            self.eventHandler?(.reload)
        }
//        switch self.receipts.contains(receipt) {
//        case false:
//            self.receipts.append(receipt)
//            self.eventHandler?(.reload)
//            break
//        case true:
//            if let index = self.receipts.firstIndex(where: {$0.messageId == receipt.messageId}) {
//                self.receipts.remove(at: index)
//                self.receipts.append(receipt)
//                self.eventHandler?(.reload)
//            }
//            break
//        }
    }
    
    public func onMessagesDelivered(receipt: MessageReceipt) {
        if !self.receipts.contains(where: {$0.messageId == receipt.messageId}) {
            self.receipts.append(receipt)
            self.eventHandler?(.reload)
        }
    }
    
}
