//
//  TransferOwnership.swift
//  CometChatUIKitSwift
//
//  Created by Suryansh on 30/10/24.
//

import Foundation
import CometChatSDK
import CometChatUIKitSwift

class TransferOwnership: CometChatGroupMembers {
    
    lazy var spinnerView: UIActivityIndicatorView = {
        let spinnerView = UIActivityIndicatorView(style: .medium)
        spinnerView.translatesAutoresizingMaskIntoConstraints = false
        return spinnerView
    }()
    
    override func viewDidLoad() {
        selectionMode = .single
        super.viewDidLoad()
        title = "Ownership Transfer"
        onSelectedItemProceed = { [weak self] users in
            if let users = users.first {
                self?.transferOwnership(to: users)
            }
        }
    }
    
    override func reloadData() {
        super.reloadData()
        
        viewModel.reload = { [weak self] in
            guard let this = self else { return }
            
            //removing logged-in user from the list
            this.viewModel.groupMembers.enumerated().forEach { index, member in
                if member.uid == CometChat.getLoggedInUser()?.uid {
                    this.viewModel.groupMembers.remove(at: index)
                    return
                }
            }
            
            //Default implementation
            DispatchQueue.main.async(execute: {
                this.removeLoadingView()
                this.removeErrorView()
                this.reload()
                
                switch this.viewModel.isSearching {
                case true:
                    if this.viewModel.filteredGroupMembers.isEmpty {
                        if this.viewModel.groupMembers.isEmpty {
                            this.showEmptyView()
                        }
                    }
                case false:
                    if this.viewModel.groupMembers.isEmpty {
                        this.showEmptyView()
                    }
                }
            })
        }
    }
    
    func addSpinnerView() {
        spinnerView.startAnimating()
        spinnerView.color = CometChatTheme.textColorPrimary
        rightBarButtonItem.first!.customView = spinnerView
    }
    
    func removeSpinnerView() {
        view.isUserInteractionEnabled = true
        spinnerView.stopAnimating()
        spinnerView.removeFromSuperview()
    }
    
    func transferOwnership(to user: GroupMember) {
        addSpinnerView()
        guard let uid = user.uid else { return }
        let guid = self.viewModel.group.guid
        CometChat.transferGroupOwnership(UID: uid, GUID: guid) { [weak self] result in
            DispatchQueue.main.async {
                if let group = self?.viewModel.group {
                    group.owner = user.uid
                    CometChatGroupEvents.ccOwnershipChanged(group: group, newOwner: user)
                }
                self?.removeSpinnerView()
                self?.dismiss(animated: true)
            }
        } onError: { [weak self] error in
            DispatchQueue.main.async {
                self?.removeSpinnerView()
            }
            //TODO: show error
        }
    }
    
    override func configureMenu(groupMember: GroupMember) -> [UIContextualAction] {
        return [UIContextualAction]()
    }
}
