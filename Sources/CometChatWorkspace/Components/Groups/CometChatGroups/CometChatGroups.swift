//
//  CometChatGroups.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 11/12/21.
//

import UIKit
import CometChatPro

@objc public protocol CometChatGroupsDelegate {
  
    /**
     - This method will get triggered when the user clicks on the start conversation button.
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @objc optional func onCreateGroup()
    
    /**
     - This method will get triggered when the user clicks on a particular conversation.
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @objc optional func onItemClick(group: Group)
    
    /**
     - This method will get triggered when the user long press on a particular conversation.
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @objc optional func onItemLongClick(group: Group)
    
    /**
     - This method will get triggered when the user long press on a particular conversation.
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @objc optional func onDeleteGroup(group: Group)
    

    @objc optional func onError(error: CometChatException)
    
    
    
}

class CometChatGroups: CometChatListBase {

    @IBOutlet weak var groupList: CometChatGroupList!
    var createGroupIcon = UIImage(named: "groups-create.png", in: CometChatUIKit.bundle, compatibleWith: nil)
    var createGroupButton: UIBarButtonItem?
    var configurations: [CometChatConfiguration]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupDelegates()
        configureGroupList()
    }
    
    @discardableResult
    @objc public func set(configurations: [CometChatConfiguration]?) -> CometChatGroups {
        self.configurations = configurations
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
        CometChatGroups.comethatGroupsDelegate?.onCreateGroup?()
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
        groupList.set(controller: self)
            .set(configurations: configurations)
            .set(background: [CometChatTheme.palatte?.background?.cgColor ?? UIColor.systemBackground.cgColor])
    }
    
    private func setupDelegates() {
        self.cometChatListBaseDelegate = self
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
        print(#function)
    }
}

extension CometChatGroups {
    static var comethatGroupsDelegate: CometChatGroupsDelegate?
}
