//
//  CometChatGroups.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 11/12/21.
//

import UIKit
import CometChatPro

open class CometChatGroups: CometChatListBase {

    @IBOutlet weak var groupList: CometChatGroupList!
    var createGroupIcon = UIImage(named: "groups-create.png", in: CometChatUIKit.bundle, compatibleWith: nil)
    var createGroupButton: UIBarButtonItem?
    var configurations: [CometChatConfiguration]?
    var joinedOnly: Bool = true
    
    open override func loadView() {
        let loadedNib = Bundle.module.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)
        if let contentView = loadedNib?.first as? UIView  {
            contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.view  = contentView
        }
    }
    
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        addObervers()
        configureGroupList()
    }
    
    deinit {
       
    }
    
    @discardableResult
    @objc public func set(configurations: [CometChatConfiguration]?) -> CometChatGroups {
        self.configurations = configurations
        return self
    }
    
    @discardableResult
    @objc public func set(joinedOnly: Bool) -> CometChatGroups {
        self.joinedOnly = joinedOnly
        return self
    }

    
    
    @discardableResult
    public func hide(createGroup: Bool) ->  CometChatGroups {
        if !createGroup {
            createGroupButton = UIBarButtonItem(image: createGroupIcon, style: .plain, target: self, action: #selector(self.didCreateGroupPressed))
            self.navigationItem.rightBarButtonItem = createGroupButton
        }
        return self
    }
    
    /**
     This method will set the icon for the start conversation icon image in `CometChatGroups`
     - Parameters:
     - createGroupIcon: This method will set the icon for the start conversation icon image in CometChatGroups
     - Returns: This method will return `CometChatGroups`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    public func set(createGroupIcon: UIImage) ->  CometChatGroups {
        self.createGroupIcon = createGroupIcon.withRenderingMode(.alwaysTemplate)
        return self
    }
    
    /**
     This method will set the icon for the start conversation icon tint color  in `CometChatGroups`
     - Parameters:
     - createGroupIcon: This method will set the icon tint color for the start conversation  in CometChatGroups
     - Returns: This method will return `CometChatGroups`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    public func set(createGroupIconTint: UIColor) ->  CometChatGroups {
        createGroupButton?.tintColor = createGroupIconTint
        return self
    }
    
    @objc func didCreateGroupPressed(){
        DispatchQueue.main.async {
            CometChatGroupEvents.emitOnCreateGroupClick()
            let cometChatCreateGroup = CometChatCreateGroup()
            let naviVC = UINavigationController(rootViewController: cometChatCreateGroup)
            self.present(naviVC, animated: true)
        }
    }
   
    

    private func setupAppearance() {
        self.set(background: [CometChatTheme.palatte?.background?.cgColor ?? UIColor.systemBackground.cgColor])
        self.set(searchBackground: CometChatTheme.palatte?.accent100 ?? UIColor.systemFill)
            .set(searchPlaceholder: "SEARCH".localize())
            .set(searchTextColor: .label)
            .set(title: "GROUPS".localize(), mode: .automatic)
            .set(titleColor: CometChatTheme.palatte?.accent ?? UIColor.black)
            .hide(search: false)
           
        self.hide(createGroup: false)
        .set(createGroupIcon: createGroupIcon ?? UIImage())
        .set(createGroupIconTint: CometChatTheme.palatte?.primary ?? UIColor.clear)
    }
    
    private func configureGroupList() {
        groupList.set(configurations: configurations ?? [])
                 .set(background: [CometChatTheme.palatte?.background?.cgColor ?? UIColor.systemBackground.cgColor])
           
    }
    
    private func addObervers() {
        self.cometChatListBaseDelegate = self
        CometChatGroupEvents.addListener("group-listener", self as CometChatGroupEventListner)
    }
    
    private func removeObervers() {
        CometChatGroupEvents.removeListner("group-listener")
    }
}

extension CometChatGroups: CometChatListBaseDelegate {
 
    public func onSearch(state: SearchState, text: String) {
        switch state {
        case .clear:
            groupList.isSearching = false
            groupList.filterGroups(forText: "")
        case .filter:
            groupList.isSearching = true
            groupList.filterGroups(forText: text)
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

extension CometChatGroups: CometChatGroupEventListner {
    
    public func onOwnershipChange(group: Group?, member: GroupMember?) {
        
    }
    
    
    public func onGroupMemberAdd(group: Group, members: [GroupMember]) {
        print(#function)
    }
    
    public func onCreateGroupClick() {
        print(#function)
    }
    
    
    public func onItemClick(group: Group, index: IndexPath?) {
        print(#function)
    }
    
    public func onGroupCreate(group: Group) {
        groupList.insert(group: group)
    }
    
    public func onGroupMemberJoin(joinedUser: User, joinedGroup: Group) {
        groupList.update(group: joinedGroup)
    }
    
    
    public func onItemLongClick(group: Group, index: IndexPath?) {
        print(#function)
    }
    
    public func onGroupDelete(group: Group) {
        groupList.remove(group: group)
    }
    
    public func onGroupMemberLeave(leftUser: User, leftGroup: Group) {
        if joinedOnly == true {
            groupList.remove(group: leftGroup)
        }else{
            leftGroup.hasJoined = false
            groupList.update(group: leftGroup)
        }
    }
    

    public func onGroupMemberBan(bannedUser: User, bannedGroup: Group) {
        print(#function)
    }
    
    public func onGroupMemberUnban(unbannedUserUser: User, unbannedUserGroup: Group) {
        print(#function)
    }
    
    public func onGroupMemberKick(kickedUser: User, kickedGroup: Group) {
        print(#function)
    }
    
    public func onGroupMemberChangeScope(updatedBy: User, updatedUser: User, scopeChangedTo: CometChat.MemberScope, scopeChangedFrom: CometChat.MemberScope, group: Group) {
        print(#function)
    }
    
    public func onError(group: Group?, error: CometChatException) {
        print(#function)
    }
}

