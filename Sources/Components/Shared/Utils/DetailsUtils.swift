//
//  File.swift
//  
//
//  Created by Pushpsen Airekar on 20/01/23.
//

import Foundation
import UIKit
import CometChatSDK


public class DetailsUtils {
    
    // options
    let viewProfile: CometChatDetailsOption
    let block: CometChatDetailsOption
    let unblock: CometChatDetailsOption
    let viewMembers: CometChatDetailsOption
    let addMembers: CometChatDetailsOption
    let bannedMembers: CometChatDetailsOption
    let leaveGroup: CometChatDetailsOption
    let deleteGroup: CometChatDetailsOption
    

    public init() {
        viewProfile = CometChatDetailsOption(id: UserOptionConstants.viewProfile,
                                             title:  "VIEW_PROFILE".localize(),
                                             customView: nil,
                                             titleColor: CometChatTheme.palatte.primary,
                                             titleFont: CometChatTheme.typography.title2 ,
                                             height: 50,
                                             onClick: nil)
        
        block = CometChatDetailsOption(id: UserOptionConstants.block,
                                       title:  "BLOCK_USER".localize(),
                                       customView: nil,
                                       titleColor: CometChatTheme.palatte.error,
                                       titleFont: CometChatTheme.typography.title2,
                                       height: 50,
                                       onClick: nil)
        
        unblock = CometChatDetailsOption(id: UserOptionConstants.unblock,
                                         title:  "UNBLOCK_USER".localize(),
                                         customView: nil,
                                         titleColor: CometChatTheme.palatte.success,
                                         titleFont: CometChatTheme.typography.title2,
                                         height: 50,
                                         onClick: nil)
        
        viewMembers = CometChatDetailsOption(id: GroupOptionConstants.viewMembers,
                                             title:  "VIEW_MEMBERS".localize(),
                                             customView: nil,
                                             titleColor: CometChatTheme.palatte.primary,
                                             titleFont: CometChatTheme.typography.title2,
                                             height: 50,
                                             onClick: nil)
        
        addMembers = CometChatDetailsOption(id: GroupOptionConstants.addMembers,
                                            title:  "ADD_MEMBERS".localize(),
                                            customView: nil,
                                            titleColor: CometChatTheme.palatte.primary,
                                            titleFont: CometChatTheme.typography.title2,
                                            height: 50,
                                            onClick: nil)
        
        bannedMembers = CometChatDetailsOption(id: GroupOptionConstants.bannedMembers,
                                               title:  "BANNED_MEMBERS".localize(),
                                               customView: nil,
                                               titleColor: CometChatTheme.palatte.primary,
                                               titleFont: CometChatTheme.typography.title2,
                                               height: 50,
                                               onClick: nil)
        
        leaveGroup = CometChatDetailsOption(id: GroupOptionConstants.leave,
                                            title:  "LEAVE_GROUP".localize(),
                                            customView: nil,
                                            titleColor: CometChatTheme.palatte.error,
                                            titleFont: CometChatTheme.typography.title2,
                                            height: 50,
                                            onClick: nil)
        
        deleteGroup = CometChatDetailsOption(id: GroupOptionConstants.delete,
                                             title:  "DELETE_GROUP".localize(),
                                             customView: nil,
                                             titleColor: CometChatTheme.palatte.error,
                                             titleFont: CometChatTheme.typography.title2,
                                             height: 50,
                                             onClick: nil)
  
    }
    
    public func getDefaultDetailsTemplate() -> [CometChatDetailsTemplate] {
        return [getPrimaryDetailsTemplate(),
                getSecondaryDetailsTeamplate()]
    }
    
    public func getPrimaryDetailsTemplate() -> CometChatDetailsTemplate {
        return CometChatDetailsTemplate(id: DetailTemplateConstants.primaryActions, title: "", titleFont: nil, titleColor: nil, itemSeparatorColor: nil, hideItemSeparator: false, customView: nil) { user, group in
            if let user = user , let link = user.link, !link.isEmpty {
                return [self.viewProfile]
            }
            if let group = group {
                switch group.scope {
                case .admin:
                    return [self.viewMembers , self.addMembers, self.bannedMembers]
                case .moderator:
                    return [self.viewMembers , self.bannedMembers]
                case .participant:
                    return [self.viewMembers]
                    @unknown default: break }
            }
            return []
        }
    }
    
    public func getSecondaryDetailsTeamplate() -> CometChatDetailsTemplate {
        return CometChatDetailsTemplate(id: DetailTemplateConstants.secondaryActions, title: nil, titleFont: nil, titleColor: nil, itemSeparatorColor: CometChatTheme.palatte.accent500, hideItemSeparator: false, customView: nil) { user, group in
            if let user = user {
                if user.blockedByMe {
                    return [self.unblock]
                } else {
                    return [self.block]
                }
            }
            if let group = group {
                switch group.scope {
                case .admin: return [self.leaveGroup, self.deleteGroup]
                case .moderator: return [self.leaveGroup]
                case .participant: return [self.leaveGroup]
                @unknown default: break
                }
            }
            return []
        }
    }
    
    public func getDetailsOptions(templateID: String, for user: User?, for group: Group?) -> [CometChatDetailsOption]? {
        let templates = getDefaultDetailsTemplate()
        if let template = templates.filter({ template in
            return template.id == templateID
        }).last {
            return template.options?(user, group)
        }
        return nil
    }
    
    public func getDefaultOption(id: String) -> CometChatDetailsOption? {
        switch id {
        case UserOptionConstants.block: return block
        case UserOptionConstants.unblock: return unblock
        case UserOptionConstants.viewProfile: return viewProfile
        case GroupOptionConstants.viewMembers: return viewMembers
        case GroupOptionConstants.addMembers: return addMembers
        case GroupOptionConstants.bannedMembers: return bannedMembers
        case GroupOptionConstants.leave: return leaveGroup
        case GroupOptionConstants.delete: return deleteGroup
        default: break
        }
        return nil
    }
}
