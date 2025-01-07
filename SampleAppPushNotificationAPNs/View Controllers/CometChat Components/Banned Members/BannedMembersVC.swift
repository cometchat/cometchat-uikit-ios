//  CometChatBannedMembers2.swift
//  Created by admin on 22/11/22.
//

import UIKit
import Foundation
import CometChatSDK
import CometChatUIKitSwift

@MainActor
open class BannedMembersVC: CometChatListBase {
    
    // MARK: - View Model Declaration
    private var viewModel: BannedMembersViewModel
    
    // MARK: - Init
    public init(group: Group, bannedGroupMembersRequestBuilder: BannedGroupMembersRequest.BannedGroupMembersRequestBuilder? = nil) {
        viewModel = BannedMembersViewModel(group: group, bannedGroupMembersRequestBuilder: bannedGroupMembersRequestBuilder)
        super.init(nibName: nil, bundle: nil)
        defaultSetup()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        registerCell()
        setupSearchBar()
        setupNavigationBar()
        tableView.separatorStyle = .none
        showLoadingView()
    }
    
    @objc private func didTapBackButton() {
        self.dismiss(animated: true)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CometChat.addConnectionListener("banned-members-sdk-listener", self)
        fetchBannedMembers()
        reloadData()
        setupStyle()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        CometChat.removeConnectionListener("group-members-sdk-listener")
    }
    
    open override func setupSearchBar() {
        super.setupSearchBar()
    }
    
    private func defaultSetup() {
        title = "Banned Members"
        prefersLargeTitles = false
        
        loadingView = UsersShimmerView()
        
        errorStateTitleText = "OOPS!".localize()
        errorStateSubTitleText = "Looks like something went wrong. Please try again."
        errorStateImage = UIImage(named: "error-icon", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal) ?? UIImage()
        
        emptyStateImage = UIImage(systemName: "person.fill")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
        emptyStateTitleText = "No Members Available"
        emptyStateSubTitleText = ""
        
        let barButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(didTapBackButton))
        barButtonItem.tintColor = CometChatTheme.primaryColor
        leftBarButtonItem = [barButtonItem]
    }
    
    // MARK: - Data Handling
    private func fetchBannedMembers() {
        viewModel.fetchBannedGroupMembers()
    }
    
    private func reloadData() {
        viewModel.reload = { [weak self] in
            DispatchQueue.main.async {
                guard let self = self else { return }
                let isEmpty: Bool
                
                if self.viewModel.isSearching {
                    isEmpty = self.viewModel.filteredBannedGroupMembers.isEmpty
                } else {
                    isEmpty = self.viewModel.bannedGroupMembers.isEmpty
                }
                
                isEmpty ? self.showEmptyView() : self.removeEmptyView()
                self.tableView.reloadData()
                self.removeLoadingView()
                self.hideFooterIndicator()
            }
        }
        
        viewModel.failure = { [weak self] error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.hideFooterIndicator()
                self.showErrorView()
                if self.viewModel.bannedGroupMembers.isEmpty {
                    self.removeLoadingView()
                }
            }
        }
        
        viewModel.reloadAtIndex = { row in
            self.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
        }
    }
    
    open override func onSearch(state: SearchState, text: String) {
        switch state {
        case .clear:
            viewModel.isSearching = false
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if !self.viewModel.bannedGroupMembers.isEmpty {
                    self.removeEmptyView()
                }
                self.tableView.reloadData()
                self.removeEmptyView()
            }
        case .filter:
            viewModel.isSearching = true
            viewModel.filterBannedGroupMembers(text: text)
        @unknown default:
            break
        }
    }
    
    // MARK: - Style Setup
    open override func setupStyle() {
        super.setupStyle()
        
        if let errorStateView = errorStateView as? StateView {
            errorStateView.subtitleLabel.font = CometChatTypography.Body.regular
            errorStateView.subtitleLabel.textColor = CometChatTheme.primaryColor
            errorStateView.titleLabel.font = CometChatTypography.Heading3.bold
            errorStateView.titleLabel.textColor = CometChatTheme.textColorSecondary
            errorStateView.imageView.tintColor = CometChatTheme.neutralColor300
        }
        
        if let emptyStateView = emptyStateView as? StateView {
            emptyStateView.titleLabel.font = CometChatTypography.Heading3.bold
            emptyStateView.titleLabel.textColor = CometChatTheme.textColorPrimary
            emptyStateView.imageView.tintColor = CometChatTheme.neutralColor300
        }
    }
    
    private func registerCell() {
        tableView.register(CometChatListItem.self, forCellReuseIdentifier: CometChatListItem.identifier)
    }
}

// MARK: Table view Delegate and Datasource
extension BannedMembersVC {
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.isSearching ? viewModel.filteredBannedGroupMembers.count : viewModel.bannedGroupMembers.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let listItem = tableView.dequeueReusableCell(withIdentifier: "CometChatListItem", for: indexPath) as? CometChatListItem else {
            return UITableViewCell()
        }
        
        let bannedGroupMember = viewModel.isSearching ? viewModel.filteredBannedGroupMembers[indexPath.row] : viewModel.bannedGroupMembers[indexPath.row]
        
        if let name = bannedGroupMember.name {
            listItem.set(title: name)
        }
        
        listItem.set(avatarURL: bannedGroupMember.avatar ?? "", with: bannedGroupMember.name)
        listItem.set(tail: configureTailView(indexPath))
        listItem.statusIndicator.isHidden = true
        listItem.titleLabel.font = CometChatTypography.Heading4.medium
        
        switch bannedGroupMember.status {
        case .offline, .available:
            listItem.statusIndicator.isHidden = true
        case .online:
            listItem.statusIndicator.isHidden = false
        @unknown default:
            listItem.statusIndicator.isHidden = true
        }
        
        switch selectionMode {
        case .single, .multiple:
            listItem.allow(selection: true)
        case .none:
            listItem.allow(selection: false)
        @unknown default:
            break
        }
        
        return listItem
    }
    
    public override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    open override func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if currentOffset > 0 && maximumOffset - currentOffset <= 10.0 {
            viewModel.fetchBannedGroupMembers()
        }
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let bannedMember = viewModel.isSearching ? viewModel.filteredBannedGroupMembers[indexPath.row] : viewModel.bannedGroupMembers[indexPath.row]
        
        
        if selectionMode == .none {
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            if !viewModel.selectedBannedMembers.contains(bannedMember) {
                viewModel.selectedBannedMembers.append(bannedMember)
            }
        }
        
    }
    
    public override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let bannedMember = viewModel.isSearching ? viewModel.filteredBannedGroupMembers[indexPath.row] : viewModel.bannedGroupMembers[indexPath.row]
        
        if let foundIndex = viewModel.selectedBannedMembers.firstIndex(of: bannedMember) {
            viewModel.selectedBannedMembers.remove(at: foundIndex)
        }
    }
    
    open override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration()
    }
}


//MARK:  CONFIGURE TAIL LABEL AND BANNED MEMBERS OPTIONS
extension BannedMembersVC {
    
    func configureTailView(_ indexPath: IndexPath) -> UIButton {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.imageView?.tintColor = CometChatTheme.iconColorSecondary
        button.heightAnchor.constraint(equalToConstant: 24).isActive = true
        button.widthAnchor.constraint(equalToConstant: 24).isActive = true
        button.tag = indexPath.row
        button.addTarget(self, action: #selector(unBanMember(_:)), for: .touchUpInside)
        
        return button
    }

    @objc func unBanMember(_ sender: UIButton) {
        let row = sender.tag
        let indexPath = IndexPath(row: row, section: 0)
        let bannedMember = viewModel.isSearching ? viewModel.filteredBannedGroupMembers[indexPath.row] : viewModel.bannedGroupMembers[indexPath.row]
        
        showAlert("Unban Member", "Are you sure you want to unban \(bannedMember.name ?? "") ", "Cancel", "Unbann") { [weak self] in
            self?.viewModel.unbanGroupMember(member: bannedMember)
        }
        
    }
}

extension BannedMembersVC: CometChatConnectionDelegate {
    public func connected() {
        fetchBannedMembers()
        reloadData()
    }
    
    public func connecting() {}
    
    public func disconnected() {}
}

 
