//
//  File.swift
//  
//
//  Created by Pushpsen Airekar on 13/12/22.
//
import Foundation
import CometChatSDK

class TransferOwnerShipViewModel {
    
    enum ChangeOwnershipStatus {
        case success
        case error(CometChatException?)
    }
    
    func transferOwnership(UID: String, GUID: String, status: @escaping ((ChangeOwnershipStatus) -> Void)) {
        CometChat.transferGroupOwnership(UID: UID, GUID: GUID) { success in
            status(.success)
        } onError: { error in
            status(.error(error))
        }
    }
    
}
