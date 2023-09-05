//
//  File.swift
//  
//
//  Created by Pushpsen Airekar on 04/10/22.
//

import Foundation
import UIKit
import CometChatSDK

public class TransferOwnershipConfiguration: GroupMembersConfiguration {
    
    private(set) var onTransferOwnership: ( (_ group: Group, _ user: User) -> Void)?
    private(set) var submitIcon: UIImage?
    private(set) var selectIcon: UIImage?
    private(set) var transferOwnershipStyle: TransferOwnershipStyle?
   
    @discardableResult
    public func setOnTransferOwnership(onTransferOwnership: @escaping ( (_ group: Group, _ user: User) -> Void)) -> Self {
        self.onTransferOwnership = onTransferOwnership
        return self
    }
    
    @discardableResult
    public func set(submitIcon: UIImage) -> Self {
        self.submitIcon = submitIcon
        return self
    }
    
    @discardableResult
    public func set(selectIcon: UIImage) -> Self {
        self.selectIcon = selectIcon
        return self
    }
    
    @discardableResult
    public func set(transferOwnershipStyle: TransferOwnershipStyle) -> Self {
        self.transferOwnershipStyle = transferOwnershipStyle
        return self
    }
}
