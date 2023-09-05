//
//  StartConversation.swift
//  
//
//  Created by nabhodipta on 26/06/23.
//

import UIKit
import CometChatSDK

/// The enum `TabVisibility` is used to set the visibility of the tabs in the `UISegmentedControl`
public enum TabVisibility{ case users, groups, usersAndGroups}

///  `CometChatContacts` is a UIViewController with a list of users and groups. The view controller has `UISegmentedControl` to switch between users and groups list. It can be used to create a new conversation or add members to an existing conversation.
public class CometChatContacts: UIViewController{
    
    /// the property `usersTabTitle` is used set the title of the users tab in the `UISegmentedControl`
    private (set) var usersTabTitle: String?
    
    /// the property `groupsTabTitle` is used set the title of the groups tab in the `UISegmentedControl`
    private (set) var groupsTabTitle: String?
    
    /// the property `usersConfiguration` is used to set the configuration for the `CometChatUsers` component
    private (set) var usersConfiguration: UsersConfiguration?
    
    /// the property `groupsConfiguration` is used to set the configuration for the `CometChatGroups` component
    private (set) var groupsConfiguration: GroupsConfiguration?
    
    /// the property `onItemTap` is used to set the action to be performed when a user or group is tapped
    private (set) var onItemTap: ((_ context: UIViewController?, _ user: User?, _ group: Group?) -> Void)?
    
    /// the property `closeIcon` is used to set the close icon for the `CometChatContacts` component
    private (set) var closeIcon: UIImage?
    
    /// the property `onClose` is used to set the action to be performed when the close icon is tapped
    private (set) var onClose: (() -> Void)?
    
    /// the property `submitIcon` is used to set the submit icon for the `CometChatContacts` component
    private (set) var submitIcon: UIImage?
    
    /// the property `onSubmitIconTap` is used to set the action to be performed when the submit icon is tapped
    private (set) var onSubmitIconTap: ((_ selectedUsers: [User]? ,_ selectedGroups: [Group]?) -> Void)?
    
    /// the property `hideSubmitButton` is used to hide the submit button
    private (set) var hideSubmitButton: Bool = false
    
    /// the property `selectionLimit` is used to set the selection limit for the `CometChatUsers` and `CometChatGroups` component
    private (set) var selectionLimit: Int?
    
    /// the property `selectionMode` is used to set the selection mode for the `CometChatUsers` and `CometChatGroups` component
    private (set) var selectionMode: SelectionMode?
    
    /// the property `contactsStyle` is used to set the style for the `CometChatContacts` component
    private (set) var contactsStyle: ContactsStyle = ContactsStyle()
    
    /// the property `tabVisibility` is used to set the visibility of the tabs in the `UISegmentedControl`. Default value is `TabVisibility.usersAndGroups`
    private (set) var tabVisibility: TabVisibility = .usersAndGroups
    
    
    private var viewModel = ContactsViewModel()
    
    /// This method sets the title for the users tab in the `UISegmentedControl`
    /// - Parameters: 
    ///     - usersTabTitle: This specifies the title for the users tab in the `UISegmentedControl`
    @discardableResult
    public func setUsersTabTitle(usersTabTitle: String?) -> Self {
        self.usersTabTitle = usersTabTitle
        return self
    }
    
    /// This method sets the title for the groups tab in the `UISegmentedControl`
    /// - Parameters:
    ///    - groupsTabTitle: This specifies the title for the groups tab in the `UISegmentedControl`
    @discardableResult
    public func setGroupsTabTitle(groupsTabTitle: String?) -> Self {
        self.groupsTabTitle = groupsTabTitle
        return self
    }
    
    /// This method sets the configuration for the `CometChatUsers` component
    /// - Parameters:
    ///    - usersConfiguration: This specifies the configuration for the `CometChatUsers` component
    @discardableResult
    public func setUsersConfiguration(usersConfiguration: UsersConfiguration?) -> Self {
        self.usersConfiguration = usersConfiguration
        return self
    }
    
    /// This method sets the configuration for the `CometChatGroups` component
    /// - Parameters:
    ///   - groupsConfiguration: This specifies the configuration for the `CometChatGroups` component
    @discardableResult
    public func setGroupsConfiguration(groupsConfiguration: GroupsConfiguration?) -> Self {
        self.groupsConfiguration = groupsConfiguration
        return self
    }
    
    /// This method sets the action to be performed when a user or group is tapped
    /// - Parameters:
    ///  - onItemTap: This specifies the action to be performed when a user or group is tapped
    ///    - contrtoller: This specifies the UIViewController on which the action is to be performed
    ///    - user: This specifies the tapped user
    ///    - group: This specifies the tapped group
    @discardableResult
    public func setOnItemTap(onItemTap:((_ controller: UIViewController?, _ user: User?, _ group: Group?) -> Void)?) -> Self {
        self.onItemTap = onItemTap
        return self
    }
    
    /// This method sets the close icon for the `CometChatContacts` component
    /// - Parameters:
    ///  - closeIcon: This specifies the close icon for the `CometChatContacts` component
    @discardableResult
    public func setCloseIcon(closeIcon: UIImage?) -> Self {
        self.closeIcon = closeIcon
        return self
    }
    
    /// This method sets the action to be performed when the close icon is tapped
    /// - Parameters:
    ///     - onClose: This specifies the action to be performed when the close icon is tapped
    @discardableResult
    public func setOnClose(onClose: (() -> Void)?) -> Self {
        self.onClose = onClose
        return self
    }
    
    /// This method sets the submit icon for the `CometChatContacts` component
    /// - Parameters:
    ///     - submitIcon: This specifies the submit icon for the `CometChatContacts` component
    @discardableResult
    public func setSubmitIcon(submitIcon: UIImage?) -> Self {
        self.submitIcon = submitIcon
        return self
    }
    
    /// This method sets the action to be performed when the submit icon is tapped
    /// - Parameters:
    ///     - onSubmitIconTap: This specifies the action to be performed when the submit icon is tapped
    ///         - selectedUsers: The function `onSubmitIconTap` takses an array of `User` as a parameter
    ///         - selectedGroups: The function `onSubmitIconTap` takses an array of `Group` as a parameter
    @discardableResult
    public func setOnSubmitIconTap(onSubmitIconTap: ((_ selectedUsers: [User]? ,_ selectedGroups: [Group]?) -> Void)?) -> Self {
        self.onSubmitIconTap = onSubmitIconTap
        return self
    }
    
    /// This method hides the submit button
    /// - Parameters:
    ///    - hideSubmitButton: This specifies whether to hide the submit button or not
    @discardableResult
    public func setHideSubmitButton(hideSubmitButton: Bool?) -> Self {
        self.hideSubmitButton = hideSubmitButton ?? false
        return self
    }
    
    /// This method sets the selection limit for the `CometChatUsers` and `CometChatGroups` component
    /// - Parameters:
    ///   - selectionLimit: This specifies the selection limit for the `CometChatUsers` and `CometChatGroups` component
    @discardableResult
    public func setSelectionLimit(selectionLimit: Int?) -> Self {
        self.selectionLimit = selectionLimit
        return self
    }
    
    /// This method sets the selection mode for the `CometChatUsers` and `CometChatGroups` component
    /// - Parameters:
    ///  - selectionMode: This specifies the selection mode for the `CometChatUsers` and `CometChatGroups` component
    @discardableResult
    public func setSelectionMode(selectionMode: SelectionMode) -> Self {
        self.selectionMode = selectionMode
        return self
    }
    
    /// This method sets the style for the `CometChatContacts` component
    /// - Parameters:
    ///  - tabVisibility: This specifies the tab which will be visible for the `CometChatContacts` component
    @discardableResult
    public func setTabVisibility(tabVisibility: TabVisibility) -> Self {
        self.tabVisibility = tabVisibility
        viewModel.setTabVisibility(tabVisibility: tabVisibility)
        return self
    }
    
    /// This method sets the style for the `CometChatContacts` component
    /// - Parameters:
    /// - contactsStyle: This specifies the style for the `CometChatContacts` component
    @discardableResult
    public func setContactsStyle(contactsStyle: ContactsStyle) -> Self {
        self.contactsStyle = contactsStyle
        return self
    }
    

    public init() {
        super.init(nibName: nil, bundle: nil)
        }


    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private var column = UIStackView()
    
    private var usersListView : CometChatUsers!
    private var groupsListView : CometChatGroups!
    private var searchController : UISearchController!
    private var segmentedControl: UISegmentedControl!
    private var containerView: UIView!
        

    override public func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
        }
    
    // setting up the container view that will hold the users and groups list
    private func setupContainerView(){
        containerView = UIView()
        containerView.backgroundColor = contactsStyle.background
    }

    // setting up the segmented control that will hold the users and groups tabs
    private func setupSegmentedControl(){
        segmentedControl = UISegmentedControl(items: [ self.usersTabTitle ??  "USERS".localize(), self.groupsTabTitle ??   "GROUPS".localize()])
        segmentedControl.selectedSegmentIndex = 0

        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        segmentedControl.sendActions(for: .valueChanged)
        segmentedControl.selectedSegmentTintColor = contactsStyle.activeTabBackground
        segmentedControl.setTitleTextAttributes([.foregroundColor : contactsStyle.tabTitleTextColor, .font : contactsStyle.tabTitleTextFont], for: .normal)
        segmentedControl.setTitleTextAttributes([.foregroundColor : contactsStyle.activeTabTitleTextColor], for: .selected)
    }

    // setting up the users list
    private func setupUsers(){
        
        usersListView = CometChatUsers(usersRequestBuilder: usersConfiguration?.usersRequestBuilder)
        usersListView
            .show(backButton: false)
            .hide(search: true)
            .selectionMode(mode: selectionMode ?? usersConfiguration?.selectionMode ?? .none)
            .set(listItemStyle: ListItemStyle().set(selectionIconTint: contactsStyle.selectionIconTint))
            .set(usersStyle: UsersStyle().set(background: contactsStyle.background).set(tableViewStyle: .insetGrouped))
            
            
            
        
        if  selectionLimit != nil {
            usersListView.setSelectionLimit(limit: selectionLimit!)
        }
        
        if self.onItemTap != nil {
            usersListView.setOnItemClick { user, indexPath in
                do {
                    try self.onItemTap!(self,user,nil)
                } catch {
                    self.showError(error: error)
                }
            }
        }
            
        
        usersListView.title=""
        configureUsers()

    }
    
    private func configureUsers(){
        if let avatarStyle = usersConfiguration?.avatarStyle {
            usersListView.set(avatarStyle: avatarStyle)
        }
        if let subtitle = usersConfiguration?.subtitle {
            usersListView.setSubtitle(subtitle: subtitle)
        }
        if let listItemView = usersConfiguration?.listItemView {
            usersListView.setListItemView(listItemView: listItemView)
        }
        if let options = usersConfiguration?.options {
            usersListView.setOptions(options: options)
        }
        if let hideSeparator = usersConfiguration?.hideSeparator {
            usersListView.hide(separator: hideSeparator)
        }
        if let statusIndicatorStyle = usersConfiguration?.statusIndicatorStyle {
            usersListView.set(statusIndicatorStyle: statusIndicatorStyle)
        }
        if let disableUsersPresence = usersConfiguration?.disableUsersPresence {
            usersListView.disable(userPresence: disableUsersPresence)
        }
        if let showSectionHeader = usersConfiguration?.showSectionHeader {
            usersListView.show(sectionHeader: showSectionHeader)
        }
        if let emptyStateText = usersConfiguration?.emptyStateText {
            usersListView.set(emptyStateText: emptyStateText)
        }
        if let errorStateText = usersConfiguration?.errorStateText {
            usersListView.set(errorStateText: errorStateText)
        }
        if let onError = usersConfiguration?.onError {
            usersListView.setOnError(onError: onError)
        }
        if let emptyStateView = usersConfiguration?.emptyStateView {
            usersListView.set(emptyView: emptyStateView)
        }
        if let errorStateView = usersConfiguration?.errorStateView {
            usersListView.set(errorView: errorStateView)
        }
        if let onItemLongClick = usersConfiguration?.onItemLongClick {
            usersListView.setOnItemLongClick(onItemLongClick: onItemLongClick)
        }
    }
    
    
    
    // setting up the groups list
    private func setupGroups(){
        groupsListView = CometChatGroups(groupsRequestBuilder: groupsConfiguration?.groupsRequestBuilder ?? GroupsBuilder.getDefaultRequestBuilder())
        groupsListView
            .set(groupsStyle: GroupsStyle().set(background: contactsStyle.background).set(tableViewStyle: .insetGrouped))
            .show(backButton: false)
            .hide(search: true)
            .selectionMode(mode: selectionMode ?? groupsConfiguration?.selectionMode ?? .none)
            .set(listItemStyle: ListItemStyle().set(selectionIconTint: contactsStyle.selectionIconTint))
            .set(groupsRequestBuilder: groupsConfiguration?.groupsRequestBuilder ?? GroupsBuilder.getDefaultRequestBuilder())
        
        groupsListView.title = groupsConfiguration?.title ?? ""
        
        if selectionLimit != nil {
            groupsListView.setSelectionLimit(limit: selectionLimit!)
        }
        
        if self.onItemTap != nil {
            groupsListView.setOnItemClick { group, indexPath in
                do {
                    try self.onItemTap!(self,nil,group)
                } catch {
                    self.showError(error: error)
                }
            }
        }
        
        configureGroups()
      
    }
    
    private func configureGroups(){
        if let subtitleView = groupsConfiguration?.subtitleView {
            groupsListView.setSubtitleView(subtitle: subtitleView)
        }
        if let listItemView = groupsConfiguration?.listItemView {
            groupsListView.setListItemView(listItemView: listItemView)
        }
        if let options = groupsConfiguration?.options {
            groupsListView.setOptions(options: options)
        }
        if let hideSeparator = groupsConfiguration?.hideSeparator {
            groupsListView.hide(separator: hideSeparator)
        }

        if let emptyStateText = groupsConfiguration?.emptyStateText {
            groupsListView.set(emptyStateText: emptyStateText)
        }
        if let errorStateText = groupsConfiguration?.errorStateText {
            groupsListView.set(errorStateText: errorStateText)
        }
        if let onError = groupsConfiguration?.onError {
            groupsListView.setOnError(onError: onError)
        }
        if let emptyStateView = groupsConfiguration?.emptyStateView {
            groupsListView.set(emptyView: emptyStateView)
        }
        if let errorStateView = groupsConfiguration?.errorStateView {
            groupsListView.set(errorView: errorStateView)
        }
        if let privateGroupIcon = groupsConfiguration?.privateGroupIcon {
            groupsListView.set(privateGroupIcon: privateGroupIcon)
        }
        if let protectedGroupIcon = groupsConfiguration?.protectedGroupIcon {
            groupsListView.set(protectedGroupIcon: protectedGroupIcon)
        }
        if let onItemLongClick = groupsConfiguration?.onItemLongClick {
            groupsListView.setOnItemLongClick(onItemLongClick: onItemLongClick)
        }
    }
   
        private func setupUI() {
            setupContainerView()
            
            if viewModel.shouldSetupUsers() {
                setupUsers()
            }
            if viewModel.shouldSetupGroups() {
                setupGroups()
            }
            
            setupSearch()
            
            self.view.backgroundColor = contactsStyle.background
            
            let cancelButton = UIBarButtonItem(title: "CANCEL".localize(), style: .plain, target: self, action: #selector(self.cancelButtonTapped))
            cancelButton.tintColor = contactsStyle.closeIconTint
            cancelButton.image = closeIcon

            self.navigationItem.leftBarButtonItem=cancelButton
            let titleView = UILabel()
            titleView.text = self.title ?? "NEW CHAT".localize().capitalized
            titleView.font = contactsStyle.titleTextFont
            titleView.textColor = contactsStyle.titleTextColor
            self.navigationItem.titleView = titleView
            
            
            // Add column below title bar
            view.addSubview(column)

            column.axis=NSLayoutConstraint.Axis.vertical
            column.distribution = UIStackView.Distribution.equalSpacing
            column.alignment=UIStackView.Alignment.center
            column.spacing=16
            column.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                column.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                column.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                column.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                column.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])

            if tabVisibility == .usersAndGroups {
                setupSegmentedControl()
                column.addArrangedSubview(segmentedControl)
                // Add segmented control below nav bar
                segmentedControl.translatesAutoresizingMaskIntoConstraints = false
                if contactsStyle.tabHeight != nil && contactsStyle.tabHeight! > 0 {
                    segmentedControl.heightAnchor.constraint(equalToConstant: contactsStyle.tabHeight!).isActive = true
                }
                if contactsStyle.tabWidth != nil && contactsStyle.tabWidth! > 0 {
                    segmentedControl.widthAnchor.constraint(equalToConstant: contactsStyle.tabWidth!).isActive = true
                }
                segmentedControl.topAnchor.constraint(equalTo: column.topAnchor).isActive = true
                segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
                segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
            }
            
            column.addArrangedSubview(containerView)
            
            
            
            
            //aligning the container with respect to segmentedControl
            
            if hideSubmitButton != true {
                let doneButton = UIBarButtonItem(title: "DONE".localize(), style: .plain, target: self, action: #selector(self.doneButtonTapped))
                doneButton.setTitleTextAttributes([.foregroundColor : contactsStyle.submitButtonTextColor, .font : contactsStyle.submitButtonTextFont], for: .normal)
                doneButton.image = submitIcon
                doneButton.tintColor = contactsStyle.submitButtonBackground
                self.navigationItem.rightBarButtonItem=doneButton
            }
            
            if tabVisibility == .usersAndGroups {
                containerView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16).isActive = true
            } else {
                containerView.topAnchor.constraint(equalTo: column.topAnchor).isActive = true
            }
            
            
            
            containerView.leadingAnchor.constraint(equalTo: column.leadingAnchor).isActive=true
            containerView.trailingAnchor.constraint(equalTo: column.trailingAnchor ).isActive=true
            containerView.bottomAnchor.constraint(equalTo: column.bottomAnchor ).isActive=true
            
            if tabVisibility == .usersAndGroups {
                // Show initial content in the container view based on segmented control's initial value
                switchTab()
            } else {
                updateContainerViewContent()
            }
            
        }
    

        @objc private func cancelButtonTapped() {
            if onClose != nil {
                onClose!()
            } else {
                self.dismiss(animated: true, completion: nil)
            }
            

        }
    
    @objc private func doneButtonTapped() throws{
        if onSubmitIconTap != nil {
            do {
                try onSubmitIconTap!(usersListView.getSelectedUsers(),groupsListView.getSelectedGroups())
            } catch {
                showError(error:error)
            }
        }

    }
        
        @objc private func segmentedControlValueChanged() {
            dismissSearch()
            switchTab()
        }
    
    @objc private func dismissSearch(){
        if searchController.isActive {
            searchController.searchBar.resignFirstResponder()
        }
    }
        
    
        private func switchTab() {
            // Remove previous content from the container view
            self.containerView.subviews.forEach { $0.removeFromSuperview() }
            
            // Determine which content to display based on the selected segment
           
            
            let selectedSegmentIndex = segmentedControl.selectedSegmentIndex
            if selectedSegmentIndex == 0 {
                //display users list
                
                if tabVisibility == .usersAndGroups {
                    groupsListView.onSearch(state: SearchState.clear, text: "")
                }
                
                updateContainerViewWithUsers()
       
            } else {
                // Display groups list
                if tabVisibility == .usersAndGroups {
                    usersListView.onSearch(state: SearchState.clear, text: "")
                }
                updateContainerViewWithGroups()
            }

        }
    
    // updating the container view with users or groups list on the basis of the selected tab
    private func updateContainerViewContent(){
        if tabVisibility == .users {
            updateContainerViewWithUsers()
        } else if tabVisibility == .groups {
            updateContainerViewWithGroups()
        }
    }
    
    private func updateContainerViewWithUsers(){
        self.addChild(usersListView)
        self.containerView.addSubview(usersListView.view)
        usersListView.didMove(toParent: self)
        usersListView.view.translatesAutoresizingMaskIntoConstraints=false

        
        NSLayoutConstraint.activate([
            usersListView.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            usersListView.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            usersListView.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            usersListView.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

        ])
    }
    
    private func updateContainerViewWithGroups(){
        self.addChild(groupsListView)
        groupsListView.willMove(toParent:self)
        containerView.addSubview(groupsListView.view)
        groupsListView.view.translatesAutoresizingMaskIntoConstraints=false

        
        NSLayoutConstraint.activate([
            groupsListView.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            groupsListView.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            groupsListView.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            groupsListView.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
        ])
    }
    
    // setting up the search controller
    private func setupSearch(){
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self // Make sure to conform to the UISearchResultsUpdating protocol
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "SEARCH".localize()
        

        // Add the search controller to the navigation item
            navigationItem.searchController = searchController
            
            // Configure the search controller's appearance
            searchController.searchBar.delegate = self // Make sure to conform to the UISearchBarDelegate protocol
    }
    

}


extension CometChatContacts: UISearchResultsUpdating, UISearchBarDelegate {
    public func updateSearchResults(for searchController: UISearchController) {
        // This method is called when the user interacts with the search controller
        if let searchText = searchController.searchBar.text {
            // Perform search operations based on the entered search text
            if !searchText.isEmpty {
                if viewModel.shouldClearUsersSearch(segmentedControl.selectedSegmentIndex) {
                    usersListView.onSearch(state: SearchState.filter, text: searchText)
                } else if viewModel.shouldClearGroupsSearch(segmentedControl.selectedSegmentIndex) {
                    groupsListView.onSearch(state: SearchState.filter, text: searchText)
                }
            }else{
                if viewModel.shouldClearUsersSearch(segmentedControl.selectedSegmentIndex) {
                    usersListView.onSearch(state: SearchState.clear, text: "")
                } else if viewModel.shouldClearGroupsSearch(segmentedControl.selectedSegmentIndex) {
                    groupsListView.onSearch(state: SearchState.clear, text: "")
                }
            }
        }
    }
  
    func willPresentSearchController(_ searchController: UISearchController) {
            // Update the constraints for the stack view when the search field is in focus
            column.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -searchController.searchBar.frame.height).isActive = true
        }

        func didDismissSearchController(_ searchController: UISearchController) {
            // Update the constraints for the stack view when the search field is dismissed
            column.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        }

}


extension CometChatContacts {
    private func showError(error : Error){
        
        let alert = UIAlertController(title: "ERROR".localize(), message: error.localizedDescription, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK".localize(), style: .default) { _ in
           
        }
        alert.addAction(okAction)
        alert.view.tintColor = CometChatTheme.palatte.primary
        self.present(alert, animated: true, completion: nil)
    }
}
