//
//  CometChatUsers.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 11/12/21.
//

import UIKit
import CometChatPro


// MARK: - Declaring Protocol.
@objc public protocol CometChatUsersDelegate {

    /**
     - This method will get triggered when the user clicks on a particular conversation.
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @objc optional func onItemClick(user: User)
    
    /**
     - This method will get triggered when the user long press on a particular conversation.
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @objc optional func onItemLongClick(user: User)
    
    
    @objc optional func onError(error: CometChatException)
}


class CometChatUsers: CometChatListBase {

    @IBOutlet weak var userList: CometChatUserList!
    var configurations: [CometChatConfiguration]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupDelegates()
        configureUserList()
       
    }
    
    
    @discardableResult
    public func set(configurations: [CometChatConfiguration]) ->  CometChatUsers {
        self.configurations = configurations
        return self
    }

    private func setupAppearance() {
        self.set(background: [CometChatTheme.palatte?.background?.cgColor ?? UIColor.systemBackground.cgColor])
        self.set(searchBackground: CometChatTheme.palatte?.accent100 ?? UIColor.systemFill)
            .set(searchPlaceholder: "SEARCH".localize())
            .set(searchTextColor: .label)
            .set(title: "Users".localize(), mode: .automatic)
            .set(titleColor: CometChatTheme.palatte?.accent ?? UIColor.black)
            .hide(search: false)
    }
    
    private func configureUserList() {
        userList.set(controller: self)
            .set(configurations: configurations)
            .set(background: [CometChatTheme.palatte?.background?.cgColor ?? UIColor.systemBackground.cgColor])
            .set(sectionHeaderBackground: CometChatTheme.palatte?.background ?? UIColor.clear)
            .set(sectionHeaderTextColor:  CometChatTheme.palatte?.accent500 ?? UIColor.black)
            .set(sectionHeaderTextFont: CometChatTheme.typography?.Caption1 ?? UIFont.systemFont(ofSize: 13, weight: .medium))
    }
    
    private func setupDelegates() {
        self.cometChatListBaseDelegate = self
    }
}

extension CometChatUsers: CometChatListBaseDelegate {
 
    public func onSearch(state: SearchState, text: String) {
        switch state {
        case .clear:
            userList.isSearching = false
            userList.filterUsers(forText: "")
        case .filter:
            userList.isSearching = true
            userList.filterUsers(forText: text)
        }
    }
    
    public func onBack() {
        print(#function)
    }
}

extension CometChatUsers {
    static var comethatUsersDelegate: CometChatUsersDelegate?
}




