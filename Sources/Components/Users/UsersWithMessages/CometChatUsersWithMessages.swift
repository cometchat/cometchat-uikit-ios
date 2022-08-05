//
//  CometChatUsersWithMessages.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 23/05/22.
//

import UIKit
import CometChatPro

open class CometChatUsersWithMessages: CometChatUsers {

    open override func viewDidLoad() {
        super.viewDidLoad()
    }

    public override func onItemClick(user: User, index: IndexPath?) {
        
        let cometChatMessages: CometChatMessages = CometChatMessages()
        cometChatMessages.set(user: user)
        if let configurations = configurations {
            cometChatMessages.set(configurations: configurations)
        }
        cometChatMessages.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(cometChatMessages, animated: true)
    
    }


}
