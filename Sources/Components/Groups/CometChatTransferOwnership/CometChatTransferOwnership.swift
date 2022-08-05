//
//  CometChatTransferOwnership.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 11/12/21.
//

import UIKit
import CometChatPro


open class CometChatTransferOwnership: CometChatListBase {

    @IBOutlet weak var memberList: CometChatMemberList!
    
    var transferOwnershipButton: UIBarButtonItem?
    var configurations: [CometChatConfiguration]?
    var group: Group?
    
    open override func loadView() {
        let loadedNib = Bundle.module.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)
        if let contentView = loadedNib?.first as? UIView  {
            contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.view = contentView
        }
    }
        
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        addObervers()
        configureViewMembers()
    }
    
    deinit {
        
    }
    
    
    @discardableResult
    @objc public func set(group: Group?) -> CometChatTransferOwnership {
        self.group = group
        return self
    }
    
    
    @discardableResult
    @objc public func set(configurations: [CometChatConfiguration]?) -> CometChatTransferOwnership {
        self.configurations = configurations
        return self
    }
    
    @discardableResult
    public func hide(transferOwnership: Bool) ->  CometChatTransferOwnership {
        if !transferOwnership {
            transferOwnershipButton = UIBarButtonItem(title: "TRANSFER".localize(), style: .done, target: self, action: #selector(self.didTransferOwnershipPressed))
            self.navigationItem.rightBarButtonItem = transferOwnershipButton
        }
        return self
    }
    
    @discardableResult
    public func set(transferOwnershipTint: UIColor) ->  CometChatTransferOwnership {
        transferOwnershipButton?.tintColor = transferOwnershipTint
        return self
    }
    
    @objc func didTransferOwnershipPressed(){
        
        if let member = memberList.selectedMember {
            CometChat.transferGroupOwnership(UID: member.uid ?? "", GUID: group?.guid ?? "") { success in
                CometChatGroupEvents.emitOnOwnershipChange(group: self.group, member: member)
                DispatchQueue.main.async {
                    self.dismiss(animated: true)
                }
            }
        onError: { error in
            if let error = error {
                CometChatGroupEvents.emitOnError(group: self.group, error: error)
            }
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            
          }
        }
    }
  

    private func setupAppearance() {
        self.set(background: [CometChatTheme.palatte?.secondary?.cgColor ?? UIColor.systemBackground.cgColor])
        self.set(searchBackground: CometChatTheme.palatte?.accent100 ?? UIColor.systemFill)
            .set(searchPlaceholder: "SEARCH".localize())
            .set(searchTextColor: .label)
            .set(title: "TRANSFER_OWNERSHIP".localize(), mode: .automatic)
            .set(titleColor: CometChatTheme.palatte?.accent ?? UIColor.black)
            .hide(search: false)
            .set(backButtonTitle: "CANCEL".localize())
            .show(backButton: true)
            
        self.hide(transferOwnership: false)
    }
    
    private func configureViewMembers() {
        
        memberList.set(controller: self)
            .set(group: group)
            .set(configurations: configurations)
            .allow(promoteDemoteMembers: false)
            .allow(selection: true)
            .set(background: [CometChatTheme.palatte?.secondary?.cgColor ?? UIColor.systemBackground.cgColor])
    }
    
    private func addObervers() {
        self.cometChatListBaseDelegate = self
    }
    
    private func removeObervers() {
      
    }
}

extension CometChatTransferOwnership: CometChatListBaseDelegate {
 
    public func onSearch(state: SearchState, text: String) {
        switch state {
        case .clear:
            memberList.isSearching = false
            memberList.filterGroupMembers(forText: "")
        case .filter:
            memberList.isSearching = true
            memberList.filterGroupMembers(forText: text)
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
