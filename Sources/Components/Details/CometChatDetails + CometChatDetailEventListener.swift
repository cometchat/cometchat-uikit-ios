//
//  File.swift
//  
//
//  Created by Pushpsen Airekar on 04/10/22.
//

import Foundation
import CometChatSDK

extension CometChatDetails : CometChatDetailEventListener {
    
    public func onDetailOptionUpdate(templateID: String, oldOption: CometChatDetailsOption?, newOption: CometChatDetailsOption?) {
        if let newOption = newOption, let oldOption = oldOption {
            update(oldOption: oldOption, newOption: newOption, templateID: templateID)
        }
    }
    
    public func onDetailOptionAdd(templateID: String, option: CometChatDetailsOption) {
        add(option: option, templateID: templateID)
    }
    
    public func onDetailOptionRemove(templateID: String, option: CometChatDetailsOption) {
        remove(option: option, templateID: templateID)
    }
    
}
    
