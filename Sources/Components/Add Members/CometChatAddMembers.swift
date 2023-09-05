//
//  CometChatAddMembers.swift
 
//
//  Created by Pushpsen Airekar on 11/12/21.
//

import UIKit
import CometChatSDK

@MainActor
open class CometChatAddMembers: CometChatUsers {
    //MARK: OUTLETS
    private var addMembersStyle =  AddMembersStyle()
    private var addMembersButton: UIBarButtonItem?
    private var viewModel : AddMembersViewModel?
    private let tryAgainText = "TRY_AGAIN".localize()
    private let cancelText = "CANCEL".localize()
    private let addText = "ADD".localize()
    private let addMembersText = "ADD_MEMBERS".localize()
    private let searchText = "SEARCH".localize()

    public init(group: Group, userRequestBuilder: UsersRequest.UsersRequestBuilder? = nil) {
        self.viewModel = AddMembersViewModel(group: group)
        super.init(usersRequestBuilder: userRequestBuilder)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        setupTableView(style: .insetGrouped)
        registerCells()
        setUpSelectionMode()
        setupAppearance()
        hide(addButton: false)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        viewModel?.isMembersAdded = { [weak self] _ in
            guard let this = self else { return }
            DispatchQueue.main.async {
                this.dismiss(animated: true)
            }
        }
        viewModel?.failure = { [weak self] error in
            guard let this = self else { return }
            // this is a callback to user.
            this.onError?(error)
            DispatchQueue.main.async {
                let confirmDialog = CometChatDialog()
                confirmDialog.set(confirmButtonText: this.tryAgainText)
                confirmDialog.set(cancelButtonText: this.cancelText)
                if this.errorStateText.isEmpty {
                    confirmDialog.set(error: CometChatServerError.get(error: error))
                } else {
                    confirmDialog.set(messageText: this.errorStateText)
                }
            }
        }
    }
    
    @discardableResult
    public override func setOnBack(onBack: @escaping () -> Void) -> Self {
        self.onBack = onBack
        return self
    }
            
    @discardableResult
    public func hide(addButton: Bool) ->  Self {
        if !addButton {
            addMembersButton = UIBarButtonItem(title: addText, style: .done, target: self, action: #selector(self.didAddMembersPressed))
            self.navigationItem.rightBarButtonItem = addMembersButton
        }
        return self
    }
    
    private func setUpSelectionMode() {
        selectionMode(mode: .multiple)
    }
    
    override func setupAppearance() {
        self.set(title: addMembersText, mode: .never)
        self.set(searchPlaceholder: searchText)
            .set(searchTextColor: .label)
            .set(backButtonTitle: cancelText)
            .show(backButton: true)
            .hide(search: false)
        self.set(style: addMembersStyle)
    }
    
    private func set(style: AddMembersStyle) {
        set(background: [style.background.cgColor])
        set(titleColor: style.titleColor)
        set(titleFont: style.titleFont)
        set(largeTitleFont: style.largeTitleFont)
        set(backButtonTint: style.backIconTint)
        set(searchBorderColor: style.searchBorderColor)
        set(searchBackground: style.searchBackgroundColor)
        set(searchTextColor: style.searchTextColor)
        set(searchTextFont: style.searchTextFont)
        set(searchPlaceholderColor: style.searchPlaceholderColor)
        set(background: [style.background.cgColor])
        set(corner: style.cornerRadius)
        set(borderWidth: style.borderWidth)
        set(borderColor: style.borderColor)
        set(searchBorderColor: style.searchBorderColor)
        set(searchBorderWidth: style.searchBorderWidth)
        set(searchIconTint: style.searchIconTint)
        set(searchCancelButtonFont: style.searchCancelButtonFont)
        set(searchCancelButtonTint: style.searchCancelButtonTint)
    }

    public override func onBackCallback() {
        if let onBack = onBack {
            onBack()
        } else {
            if self.navigationController != nil {
                if self.navigationController?.viewControllers.first == self {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
               
            }else{
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @objc func didAddMembersPressed() {
        
        onSelection { [weak self] users in
            guard let  this = self else { return }
           // guard let users = users else { return }
            var members: [GroupMember] = [GroupMember]()
            for user in users {
                members.append(GroupMember(UID: user.uid ?? "", groupMemberScope: .participant))
            }
            this.viewModel?.addMembers(members: members)
        }
    }
    
}
