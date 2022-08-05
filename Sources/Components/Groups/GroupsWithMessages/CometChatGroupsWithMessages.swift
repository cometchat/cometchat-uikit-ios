//
//  CometChatGroupsWithMessages.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 11/12/21.
//

import UIKit
import CometChatPro

open class CometChatGroupsWithMessages: CometChatGroups {

    
    open override func viewDidLoad() {
        super.viewDidLoad()
      
    }
    
    deinit {
       
    }
   
    
    public override func onItemClick(group: Group, index: IndexPath?) {
        if group.hasJoined == true {
            let messages = CometChatMessages()
            messages.set(group: group)
            if let configurations = configurations {
                messages.set(configurations: configurations)
            }
            if navigationController != nil {
                self.navigationController?.pushViewController(messages, animated: true)
            }else{
                self.present(messages, animated: true)
            }
        }
    }
    
    public  override func onGroupCreate(group: Group) {
        groupList.add(group: group)
        if group.hasJoined == true {
            let messages = CometChatMessages()
            messages.set(group: group)
            if navigationController != nil {
                self.navigationController?.pushViewController(messages, animated: true)
            }else{
                self.present(messages, animated: true)
            }
        }
    }
    
    public override func onGroupMemberJoin(joinedUser: User, joinedGroup: Group) {
        groupList.update(group: joinedGroup)
        if joinedGroup.hasJoined == true {
            let messages = CometChatMessages()
            messages.set(group: joinedGroup)
            if navigationController != nil {
                self.navigationController?.pushViewController(messages, animated: true)
            }else{
                self.present(messages, animated: true)
            }
        }
    }
    

    
    public  override func onGroupDelete(group: Group) {
        groupList.remove(group: group)
    }
    
    public override func onGroupMemberLeave(leftUser: User, leftGroup: Group) {
        if joinedOnly == true {
            groupList.remove(group: leftGroup)
        }else{
            leftGroup.hasJoined = false
            groupList.update(group: leftGroup)
        }
    }
    
}


