//
//  File.swift
//  
//
//  Created by Pushpsen Airekar on 04/10/22.
//

import Foundation
import CometChatSDK

extension CometChatDetails: CometChatUserEventListener {
    
    public func onUserBlock(user: CometChatSDK.User) {
        DispatchQueue.main.async {
            if let blockOption = DetailsUtils().getDefaultOption(id: UserOptionConstants.block), let unblockOption = DetailsUtils().getDefaultOption(id: UserOptionConstants.unblock) {
                
                self.update(oldOption: blockOption, newOption: unblockOption, templateID: DetailTemplateConstants.secondaryActions)
            }
        }
    }
    
    public func onUserUnblock(user: CometChatSDK.User) {
        DispatchQueue.main.async {
            if let blockOption = DetailsUtils().getDefaultOption(id: UserOptionConstants.block), let unblockOption = DetailsUtils().getDefaultOption(id: UserOptionConstants.unblock) {
                
                self.update(oldOption: unblockOption, newOption: blockOption, templateID: DetailTemplateConstants.secondaryActions)
            }
        }
    }
    
}

    
