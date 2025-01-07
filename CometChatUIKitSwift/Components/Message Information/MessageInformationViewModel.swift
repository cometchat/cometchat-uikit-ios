import Foundation
import CometChatSDK

public protocol MessageInformationViewModelProtocol {
    var receipts: [CometChatSDK.MessageReceipt] { get set }
    var message: CometChatSDK.BaseMessage? { get set }
    var onError: ((_ error: CometChatException?) -> Void)? { get set }
    var reload: (() -> Void)? { get set }
    
    func connect()
    func disconnect()
    func update(receipt: MessageReceipt)
    func getMessageReceipt(information forMessage: BaseMessage)
}

open class MessageInformationViewModel: NSObject, MessageInformationViewModelProtocol {
    public var receipts: [CometChatSDK.MessageReceipt] = [CometChatSDK.MessageReceipt]()
    public var message: CometChatSDK.BaseMessage?
    public var onError: ((_ error: CometChatException?) -> Void)?
    public var reload: (() -> Void)?
    
    public override init(){}
    
    open func getMessageReceipt(information forMessage: BaseMessage) {
        receipts.removeAll()
        
        if forMessage.receiverType == .user { //if user we are getting the receipt from the Base Message
            
            if let receiptSender = forMessage.receiver as? User {
                
                //adding read receipt
                let readReceipt = CometChatSDK.MessageReceipt(
                    messageId: "\(forMessage.id)",
                    sender: receiptSender,
                    receiverId: CometChatUIKit.getLoggedInUser()?.uid ?? "",
                    receiverType: .user,
                    receiptType: .read,
                    timeStamp: Int(forMessage.readAt)
                )
                
                readReceipt.deliveredAt = forMessage.deliveredAt
                readReceipt.readAt = forMessage.readAt
                self.receipts.append(readReceipt)
                
                //adding delivered receipt
                let deliveredReceipt = CometChatSDK.MessageReceipt(
                    messageId: "\(forMessage.id)",
                    sender: receiptSender,
                    receiverId: CometChatUIKit.getLoggedInUser()?.uid ?? "",
                    receiverType: .user,
                    receiptType: .delivered,
                    timeStamp: Int(forMessage.deliveredAt)
                )
                
                deliveredReceipt.deliveredAt = forMessage.deliveredAt
                deliveredReceipt.readAt = forMessage.readAt
                self.receipts.append(deliveredReceipt)
                
                self.reload?()
            }
            
        } else {
            
            CometChat.getMessageReceipts(forMessage.id, onSuccess: { [weak self] (fetchedReceipts) in
                guard let self else { return }
                self.receipts.removeAll()
                self.receipts = fetchedReceipts
                self.reload?()
            }) { (error) in
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.onError?(error)
                    if let error = error {
                        self.onError?(error)
                    }
                }
            }
        }
        
    }
    
    open func connect() {
        CometChatMessageEvents.addListener("message-inforamtion-messages-listener", self)
    }
    
    open func disconnect() {
        CometChatMessageEvents.removeListener("message-inforamtion-messages-listener")
    }
    
    open func update(receipt: MessageReceipt) {
        if receipt.messageId == String(message?.id ?? 0) {
            if let index = self.receipts.firstIndex(where: {
                $0.sender?.uid == receipt.sender?.uid
            }) {
                let excitingReceipt = self.receipts[index]
                switch receipt.receiptType {
                case .delivered:
                    if excitingReceipt.deliveredAt == 0.0 {
                        excitingReceipt.readAt = receipt.readAt
                    }
                case .read:
                    if excitingReceipt.readAt == 0.0 {
                        excitingReceipt.readAt = receipt.readAt
                    }
                case .deliveredToAll:
                    break
                case .readByAll:
                    break
                case .unread:
                    break
                @unknown default:
                    break
                }
                self.receipts[index] = excitingReceipt
                self.reload?()
            } else {
                self.receipts.append(receipt)
                self.reload?()
            }
        }
    }
    
}

extension MessageInformationViewModel: CometChatMessageEventListener {
    
    public func onMessagesRead(receipt: MessageReceipt) {
        update(receipt: receipt)
    }
    
    public func onMessagesDelivered(receipt: MessageReceipt) {
        update(receipt: receipt)
    }
    
}
