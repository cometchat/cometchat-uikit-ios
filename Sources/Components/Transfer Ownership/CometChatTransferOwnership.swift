//
//  CometChatTransferOwnership.swift
 
//
//  Created by Pushpsen Airekar on 11/12/21.
//

import UIKit
import CometChatSDK

@MainActor
open class CometChatTransferOwnership: CometChatGroupMembers {
    
    var transferOwnershipButton: UIBarButtonItem?
    var transferOwnershipConfiguration: TransferOwnershipConfiguration?
    var transferViewModel: TransferOwnerShipViewModel?
    var submitIcon: UIImage?
    var selectIcon: UIImage?
    
    public var onTransferOwnership: ((_ group: Group, _ groupMember: GroupMember) -> Void)?
    
    //MARK: - INIT
    public override init(group: Group, groupMembersRequestBuilder: GroupMembersRequest.GroupMembersRequestBuilder? = nil) {
        super.init(group: group, groupMembersRequestBuilder: groupMembersRequestBuilder)
        self.set(style: TransferOwnershipStyle())
        transferOwnershipButton = UIBarButtonItem(title: "TRANSFER".localize(), style: .done, target: self, action: #selector(self.didTransferOwnershipPressed))
        self.navigationItem.rightBarButtonItem = transferOwnershipButton
        self.transferViewModel = TransferOwnerShipViewModel()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        setupTableView(style: .insetGrouped)
        setupAppearance()
        registerCells()
        configureOptions()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        setupAppearance()
    }
    
    @discardableResult
    public func onSelection(_ onSelection: @escaping (_ group: Group, _ groupMember: GroupMember?) -> ()) -> Self {
        onSelection(viewModel.group, viewModel.selectedGroupMembers.last)
        return self
    }
    
    @discardableResult
    public func set(transferOwnerShipStyle: TransferOwnershipStyle) -> Self {
        set(style: transferOwnerShipStyle)
        return self
    }
    
    @discardableResult
    public func set(submitIcon: UIImage) -> Self {
        self.submitIcon = submitIcon
        return self
    }
    
    @discardableResult
    public func set(selectIcon: UIImage) -> Self {
        self.selectIcon = selectIcon
        return self
    }
    
    @discardableResult
    public func setOnTransferOwnership(onTransferOwnership: @escaping ((_ group: Group, _ groupMember: GroupMember) -> Void)) -> Self {
        self.onTransferOwnership = onTransferOwnership
        return self
    }
    
    @discardableResult
    public func set(transferOwnershipConfiguration: TransferOwnershipConfiguration) ->  CometChatTransferOwnership {
        self.transferOwnershipConfiguration = transferOwnershipConfiguration
        return self
    }
   
    @discardableResult
    public func hide(transferOwnership: Bool) ->  CometChatTransferOwnership {
        if !transferOwnership {
            transferOwnershipButton?.customView?.isHidden = true
        }
        return self
    }
    
    @discardableResult
    public func set(transferOwnershipIcon: UIImage) -> Self {
        self.transferOwnershipButton?.image = transferOwnershipIcon
        return self
    }
    
    @discardableResult
    public func set(transferOwnershipTint: UIColor) ->  CometChatTransferOwnership {
        transferOwnershipButton?.tintColor = transferOwnershipTint
        return self
    }
    
    @discardableResult
    public func set(transferOwnershipFont: UIFont) ->  Self {
        self.transferOwnershipButton?.setTitleTextAttributes([NSAttributedString.Key.font: transferOwnershipFont], for: .normal)
        return self
    }
    
    @objc func didTransferOwnershipPressed() {
        onSelection { groupMembers in
            if let member = super.viewModel.selectedGroupMembers.last {
                guard let transferViewModel = self.transferViewModel else { return }
                transferViewModel.transferOwnership(UID: member.uid ?? "", GUID: super.viewModel.group.guid) { status in
                    switch status {
                    case .success:
                        super.viewModel.group.owner = member.uid
                        // Broadcasting transferowner event.
                        CometChatGroupEvents.emitOnOwnershipChange(group: super.viewModel.group, member: member)
                    case .error(let error):
                        if let error = error {
                            /*
                             on Transfer Ownership
                             do we receive an action message when we fetch historical message.
                             */
                           // CometChatGroupEvents.emitOnError(group: super.viewModel.group, error: error)
                        }
                    }
                    DispatchQueue.main.async {
                        self.dismiss(animated: true)
                    }
                }
            }
        }
    }
    
    override func setupAppearance() {
        self.set(background: [CometChatTheme.palatte.secondary.cgColor])
        self.set(searchBackground: CometChatTheme.palatte.accent100)
            .set(searchPlaceholder: searchPlaceholder)
            .set(searchTextColor: .label)
            .set(title: "TRANSFER_OWNERSHIP".localize(), mode: .never)
            .set(titleColor: CometChatTheme.palatte.accent)
            .hide(search: false)
            .set(backButtonTitle: "CANCEL".localize())
            .show(backButton: true)
        set(style: TransferOwnershipStyle())
        selectionMode(mode: .single)
        self.hide(transferOwnership: false)
        setTailView { groupMember in
            let label = UILabel()
            if CometChat.getLoggedInUser()?.uid == self.viewModel.group.owner {
                label.text = "OWNER".localize()
            } else {
                switch groupMember?.scope {
                case .admin:
                    label.text = "ADMIN".localize()
                case .moderator:
                    label.text = "MODERATOR".localize()
                case .participant:
                    label.text = "PARTICIPANT".localize()
                default: break
                }
            }
            label.textColor = CometChatTheme.palatte.accent600
            label.font = CometChatTheme.typography.subtitle1
            label.textAlignment = .right
            return label
        }
    }
    
    private func configureTransferOwnership() {
        if let transferOwnershipConfiguration = transferOwnershipConfiguration {
            if let hideSearch = transferOwnershipConfiguration.hideSearch {
                hide(search: hideSearch)
            }
            set(searchIcon: transferOwnershipConfiguration.searchBoxIcon)
            set(backButtonIcon: transferOwnershipConfiguration.backButton ?? UIImage())
            set(searchPlaceholder: transferOwnershipConfiguration.searchPlaceholder ?? "")
            if let transferOwnershipStyle = transferOwnershipConfiguration.transferOwnershipStyle {
                set(style: transferOwnershipStyle)
            }
        }
    }
    
    private func set(style: TransferOwnershipStyle) {
        set(titleColor: style.titleColor)
        set(titleFont: style.titleFont)
        set(largeTitleFont: style.largeTitleFont)
        set(backButtonTint: style.backIconTint)
        set(searchBorderColor: style.searchBorderColor)
        set(searchBackground: style.searchBackgroundColor)
        set(searchCornerRadius: style.searchBorderRadius)
        set(searchTextColor: style.searchTextColor)
        set(searchTextFont: style.searchTextFont)
        set(searchPlaceholderColor: style.searchPlaceholderColor)
        set(background: [style.background.cgColor])
        set(transferOwnershipTint: style.transferButtonTint)
        set(transferOwnershipFont: style.transferButtonFont)
        set(corner: style.cornerRadius)
        set(borderColor: style.borderColor)
        set(borderWidth: style.borderWidth)
        set(searchBorderColor: style.searchBorderColor)
        set(searchBorderWidth: style.searchBorderWidth)
        set(searchIconTint: style.searchIconTint)
        set(searchCancelButtonTint: style.searchCancelButtonTint)
    }
}

