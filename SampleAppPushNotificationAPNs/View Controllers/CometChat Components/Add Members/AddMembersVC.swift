//
//  CometChatAddMembers.swift
 
//
//  Created by Pushpsen Airekar on 11/12/21.
//

import UIKit
import CometChatSDK
import CometChatUIKitSwift

@MainActor
open class AddMembersVC: CometChatUsers {
    // MARK: - Properties
    var addMembersViewModel: AddMembersViewModel?
    
    private let tryAgainText = "TRY_AGAIN".localize()
    private let cancelText = "CANCEL".localize()
    private let addMembersText = "ADD_MEMBERS".localize()

    private var loadingIndicator: UIActivityIndicatorView?
    
    private var composerBottomAnchor: NSLayoutConstraint?

    let addMemberButton = UIButton()
    let addMemberButtonSeperator = UIView()
    let addMemberButtonView = UIView()

    // MARK: - Initializers
    public init(group: Group, userRequestBuilder: UsersRequest.UsersRequestBuilder? = nil) {
        self.addMembersViewModel = AddMembersViewModel(group: group)
        super.init(usersRequestBuilder: userRequestBuilder ?? UsersBuilder.getDefaultRequestBuilder())
        defaultSetup()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle Methods
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView(style: .grouped)
        registerCells()
        setUpSelectionMode()
        setupSearchBar()
        configureTableView()
        setupAddMemberButton()
        showLoadingView()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let keyboardHeight = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        UIView.animate(withDuration: 0.2) {
            self.composerBottomAnchor?.constant = -keyboardHeight
            self.view.layoutIfNeeded()
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.2) {
            self.composerBottomAnchor?.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        observeMembersAdded()
        observeFailure()
    }

    open override func defaultSetup() {
        super.defaultSetup()
        title = addMembersText
        prefersLargeTitles = false
        loadingView = UsersShimmerView()
        
        errorStateTitleText = "OOPS!".localize()
        errorStateSubTitleText = "Looks like something went wrong. Please try again."
        errorStateImage = UIImage(named: "error-icon", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal) ?? UIImage()

        emptyStateImage = UIImage(systemName: "person.fill")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
        emptyStateTitleText = "No Members Available"
        emptyStateSubTitleText = ""
        
        let barButtonItem = UIBarButtonItem(title: cancelText, style: .done, target: self, action: #selector(didTapBackButton))
        barButtonItem.tintColor = CometChatTheme.primaryColor
        leftBarButtonItem = [barButtonItem]
    }
    
    open override func setupStyle() {
        super.setupStyle()
        if let errorStateView = errorStateView as? StateView {
            errorStateView.subtitleLabel.font = CometChatTypography.Body.regular
            errorStateView.subtitleLabel.textColor = CometChatTheme.textColorSecondary
            errorStateView.titleLabel.font = CometChatTypography.Heading3.bold
            errorStateView.titleLabel.textColor = CometChatTheme.textColorPrimary
            errorStateView.imageView.tintColor = CometChatTheme.neutralColor300
        }
        
        if let emptyStateView = emptyStateView as? StateView {
            emptyStateView.titleLabel.font = CometChatTypography.Heading3.bold
            emptyStateView.titleLabel.textColor = CometChatTheme.textColorPrimary
            emptyStateView.imageView.tintColor = CometChatTheme.neutralColor300
        }
    }

    private func setUpSelectionMode() {
        selectionMode = .multiple
    }

    private func configureTableView() {
        tableView.separatorStyle = .none
        tableView.allowsMultipleSelection = true
    }

    private func setupAddMemberButton() {
        addMemberButton.setTitle("Add \(selectedCellCount) Members", for: .normal)
        addMemberButton.titleLabel?.font = CometChatTypography.Button.medium
        addMemberButton.setTitleColor(CometChatTheme.white, for: .normal)
        addMemberButton.backgroundColor = CometChatTheme.primaryColor
        addMemberButton.layer.cornerRadius = 8
        addMemberButton.addTarget(self, action: #selector(didAddMembersPressed), for: .touchUpInside)
        
        addMemberButtonSeperator.backgroundColor = CometChatTheme.borderColorLight
        
        [addMemberButton, addMemberButtonSeperator, addMemberButtonView].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addMemberButtonView.backgroundColor = CometChatTheme.backgroundColor01
        view.addSubview(addMemberButtonView)
        addMemberButtonView.addSubview(addMemberButton)
        addMemberButtonView.addSubview(addMemberButtonSeperator)
        
        [addMemberButton, addMemberButtonSeperator, addMemberButtonView].forEach { $0.isHidden = true }
        
        setupAddMemberButtonConstraints()
    }

    private func setupAddMemberButtonConstraints() {
        NSLayoutConstraint.activate([
            addMemberButtonView.heightAnchor.constraint(equalToConstant: 78),
            addMemberButtonView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            addMemberButtonView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            addMemberButtonSeperator.heightAnchor.constraint(equalToConstant: 1),
            addMemberButtonSeperator.leadingAnchor.constraint(equalTo: addMemberButtonView.leadingAnchor),
            addMemberButtonSeperator.trailingAnchor.constraint(equalTo: addMemberButtonView.trailingAnchor),
            addMemberButtonSeperator.bottomAnchor.constraint(equalTo: addMemberButton.topAnchor, constant: -16),
            
            addMemberButton.heightAnchor.constraint(equalToConstant: 40),
            addMemberButton.leadingAnchor.constraint(equalTo: addMemberButtonView.leadingAnchor, constant: 16),
            addMemberButton.trailingAnchor.constraint(equalTo: addMemberButtonView.trailingAnchor, constant: -16),
            addMemberButton.bottomAnchor.constraint(equalTo: addMemberButtonView.bottomAnchor, constant: -22)
        ])
        
        composerBottomAnchor = addMemberButtonView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        composerBottomAnchor?.isActive = true
    }

    // MARK: - Action Methods
    @objc private func didTapBackButton() {
        dismiss(animated: true)
    }
    
    @objc private func didAddMembersPressed() {
        self.searchController.searchBar.endEditing(true)
        self.searchController.searchBar.resignFirstResponder()

        showLoader()
        
        onSelection { [weak self] users in
            guard let self = self else { return }
            var groupMembers: [GroupMember] = []
            
            users.forEach {
                if let uid = $0.uid {
                    var member = GroupMember(UID: uid, groupMemberScope: .participant)
                    member.name = $0.name ?? ""
                    groupMembers.append(member)
                }
            }
            
            DispatchQueue.main.async {
                self.addMembersViewModel?.addMembers(members: groupMembers)
                self.addMembersViewModel?.unableToAddMember = { error in
                    self.showAlert(with: error)
                    self.hideLoader()
                }
            }
        }
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }

    open override func updateNavigationBarTitleWithCount() {
        let shouldHide = selectedCellCount == 0
        [addMemberButton, addMemberButtonSeperator, addMemberButtonView].forEach { $0.isHidden = shouldHide }
        
        if !shouldHide {
            addMemberButton.setTitle("Add \(selectedCellCount) Members", for: .normal)
        }
    }

    // MARK: - ViewModel Observers
    private func observeMembersAdded() {
        addMembersViewModel?.isMembersAdded = { [weak self] actionMessages, members, group, loggedInUser in
            DispatchQueue.main.async {
                self?.dismiss(animated: true) {
                    self?.hideLoader()
                    CometChatGroupEvents.ccGroupMemberAdded(messages: actionMessages, usersAdded: members, groupAddedIn: group, addedBy: loggedInUser)
                }
            }
        }
    }

    private func observeFailure() {
        addMembersViewModel?.failure = { [weak self] _ in
            let confirmDialog = CometChatDialog()
            confirmDialog.set(confirmButtonText: self?.tryAgainText ?? "")
            confirmDialog.set(cancelButtonText: self?.cancelText ?? "")
        }
    }

    // MARK: - Loader Methods
    private func showLoader() {
        if loadingIndicator == nil {
            loadingIndicator = UIActivityIndicatorView(style: .medium)
            loadingIndicator?.translatesAutoresizingMaskIntoConstraints = false
            loadingIndicator?.color = .white
            addMemberButton.addSubview(loadingIndicator!)
            
            NSLayoutConstraint.activate([
                loadingIndicator!.centerXAnchor.constraint(equalTo: addMemberButton.centerXAnchor),
                loadingIndicator!.centerYAnchor.constraint(equalTo: addMemberButton.centerYAnchor)
            ])
        }
        
        addMemberButton.setTitle("", for: .normal)
        loadingIndicator?.startAnimating()
    }

    private func hideLoader() {
        DispatchQueue.main.async {
            self.loadingIndicator?.stopAnimating()
            self.addMemberButton.setTitle("Add \(self.selectedCellCount) Members", for: .normal)
        }
    }
}

extension UIViewController {
    func showAlert(with error: String) {
        let alertController = UIAlertController(title: "ERROR".localize(), message: error, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK".localize(), style: .cancel) { _ in
            alertController.dismiss(animated: true, completion: nil)
        })
        DispatchQueue.main.async { [weak self] in
        guard let this = self else { return }
            this.present(alertController, animated: true, completion: nil)
        }
    }
}
