//
//  CometChatUsers.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 11/12/21.
//

import UIKit
import CometChatPro


open class CometChatUsers: CometChatListBase {

    @IBOutlet weak var userList: CometChatUserList!
    
    var configurations: [CometChatConfiguration]?
    
    open override func loadView() {
        let loadedNib = Bundle.module.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)
        if let contentView = loadedNib?.first as? UIView  {
            contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.view  = contentView
        }
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        addObervers()
        configureUserList()
    }
    
    deinit {
        
    }
    
    
    @discardableResult
    public func set(configurations: [CometChatConfiguration]) ->  CometChatUsers {
        self.configurations = configurations
        return self
    }

    private func setupAppearance() {
        self.set(background: [CometChatTheme.palatte?.secondary?.cgColor ?? UIColor.systemFill.cgColor])
        self.set(searchBackground: CometChatTheme.palatte?.accent100 ?? UIColor.systemFill)
            .set(searchPlaceholder: "SEARCH".localize())
            .set(searchTextColor: .label)
            .set(title: "Users".localize(), mode: .automatic)
            .set(titleColor: CometChatTheme.palatte?.accent ?? UIColor.black)
            .hide(search: false)
    }
    
   
    private func configureUserList() {
        userList.set(controller: self)
        userList.set(configurations: configurations)
            .set(background: [ UIColor.systemBackground.cgColor])
            .set(sectionHeaderBackground: CometChatTheme.palatte?.secondary ?? UIColor.systemFill)
            .set(sectionHeaderTextColor:  CometChatTheme.palatte?.accent500 ?? UIColor.black)
            .set(sectionHeaderTextFont: CometChatTheme.typography?.Caption1 ?? UIFont.systemFont(ofSize: 13, weight: .medium))
        
    }
    
    private func addObervers() {
        self.cometChatListBaseDelegate = self
        CometChatUserEvents.addListener("users-listner", self as CometChatUserEventListener)
    }
    
    private func removeObervers() {
        CometChatUserEvents.removeListner("users-listner")
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
        switch self.isModal() {
        case true:
            self.dismiss(animated: true, completion: nil)
            removeObervers()
        case false:
            self.navigationController?.popViewController(animated: true)
            removeObervers()
        }
    }
}


extension CometChatUsers: CometChatUserEventListener {
   
    public func onItemClick(user: User, index: IndexPath?) {
        print(#function)
    }
    
    public func onItemLongClick(user: User, index: IndexPath?) {
        print(#function)
    }
    
    public func onUserBlock(user: User) {
        print(#function)
    }
    
    public func onUserUnblock(user: User) {
        print(#function)
    }
    
    public func onError(user: User?, error: CometChatException) {
        print(#function)
    }
}





