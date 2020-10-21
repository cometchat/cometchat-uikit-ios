//  CometChatGroupList.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.


/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
 CometChatGroupList: The CometChatGroupList is a view controller with a list of groups. The view controller has all the necessary delegates and methods.
 
 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  */

// MARK: - Importing Frameworks.

import UIKit
import CometChatPro

// MARK: - Declaration of Protocol.

public protocol GroupListDelegate: AnyObject {
    /**
     This method triggers when user taps perticular group in CometChatGroupList
     - Parameters:
     - group: Specifies the `Group` Object for selected cell.
     - indexPath: pecifies the indexpath for selected group
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatGroupList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-2-comet-chat-group-list)
     */
    func didSelectGroupAtIndexPath(group: Group, indexPath: IndexPath)
}

/*  ----------------------------------------------------------------------------------------- */

public class CometChatGroupList: UIViewController {
    
    // MARK: - Declaration of Variables
    
    var groupRequest = GroupsRequest.GroupsRequestBuilder(limit: 20).build()
    var tableView: UITableView! = nil
    var safeArea: UILayoutGuide!
    var groups: [Group] = [Group]()
    var filteredGroups: [Group] = [Group]()
    weak var delegate: GroupListDelegate?
    var storedVariable: String?
    var activityIndicator:UIActivityIndicatorView?
    var searchController:UISearchController = UISearchController(searchResultsController: nil)
    
    
    // MARK: - View controller lifecycle methods
    
    override public func loadView() {
        super.loadView()
        view.backgroundColor = .white
        safeArea = view.layoutMarginsGuide
        self.setupTableView()
        self.setupSearchBar()
        self.setupNavigationBar()
        self.addObservers()
        fetchGroups()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        refreshGroups()
    }
    
    // MARK: - Public instance methods
    
    /**
     This method specifies the navigation bar title for CometChatGroupList.
     - Parameters:
     - title: This takes the String to set title for CometChatGroupList.
     - mode: This specifies the TitleMode such as :
     * .automatic : Automatically use the large out-of-line title based on the state of the previous item in the navigation bar.
     *  .never: Never use a larger title when this item is topmost.
     * .always: Always use a larger title when this item is topmost.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatGroupList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-2-comet-chat-group-list)
     */
    @objc public func set(title : String, mode: UINavigationItem.LargeTitleDisplayMode){
        if navigationController != nil{
            navigationItem.title = NSLocalizedString(title, bundle: UIKitSettings.bundle, comment: "")
            navigationItem.largeTitleDisplayMode = mode
            switch mode {
            case .automatic:
                navigationController?.navigationBar.prefersLargeTitles = true
            case .always:
                navigationController?.navigationBar.prefersLargeTitles = true
            case .never:
                navigationController?.navigationBar.prefersLargeTitles = false
            @unknown default:break }
        }
    }
    
    
    // MARK: - Private instance methods
    
    /**
    This method fetches the list of groups from  Server using **GroupRequest** Class.
    - Author: CometChat Team
    - Copyright:  ©  2020 CometChat Inc.
    - See Also:
   [CometChatGroupList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-2-comet-chat-group-list)
    */
    private func fetchGroups(){
        activityIndicator?.startAnimating()
        activityIndicator?.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
        tableView.tableFooterView = activityIndicator
        tableView.tableFooterView?.isHidden = false
        groupRequest.fetchNext(onSuccess: { (groups) in
            if groups.count != 0{
                let joinedGroups = groups.filter({$0.hasJoined == true})
                self.groups.append(contentsOf: joinedGroups)
                DispatchQueue.main.async {
                    self.activityIndicator?.stopAnimating()
                    self.tableView.tableFooterView?.isHidden = true
                    self.tableView.reloadData()
                }
            }
            DispatchQueue.main.async {
                self.activityIndicator?.stopAnimating()
                self.tableView.tableFooterView?.isHidden = true}
        }) { (error) in
            DispatchQueue.main.async {
                if let errorMessage = error?.errorDescription {
                    let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: errorMessage, duration: .short)
                    snackbar.show()
                }
            }
        }
    }
    
    /**
     This method refreshes the list of groups from  Server using **GroupRequest** Class.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
    [CometChatGroupList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-2-comet-chat-group-list)
     */
    private func refreshGroups(){
        groups.removeAll()
        activityIndicator?.startAnimating()
        activityIndicator?.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
        tableView.tableFooterView = activityIndicator
        tableView.tableFooterView = activityIndicator
        tableView.tableFooterView?.isHidden = false
        groupRequest = GroupsRequest.GroupsRequestBuilder(limit: 20).build()
        groupRequest.fetchNext(onSuccess: { (groups) in
            if groups.count != 0 {
                self.groups.append(contentsOf: groups)
                DispatchQueue.main.async {
                    self.activityIndicator?.stopAnimating()
                    self.tableView.tableFooterView?.isHidden = true
                    self.tableView.reloadData()
                }
            }else{
                DispatchQueue.main.async {
                    self.activityIndicator?.stopAnimating()
                    self.tableView.tableFooterView?.isHidden = true
                    self.tableView.reloadData()
                }
            }
            DispatchQueue.main.async {
                self.activityIndicator?.stopAnimating()
                self.tableView.tableFooterView?.isHidden = true}
        }) { (error) in
           DispatchQueue.main.async {
                if let errorMessage = error?.errorDescription {
                  let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: errorMessage, duration: .short)
                    snackbar.show()
                }
            }
        }
    }
    
    /**
     This method observes for perticular events such as `didGroupDeleted`, `didGroupCreated` in CometChatGroupList.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatGroupList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-2-comet-chat-group-list)
     */
    private func addObservers(){
        NotificationCenter.default.addObserver(self, selector:#selector(self.didGroupDeleted(_:)), name: NSNotification.Name(rawValue: "didGroupDeleted"), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(self.didGroupCreated(_:)), name: NSNotification.Name(rawValue: "didGroupCreated"), object: nil)
    }
    
    
    /**
     This method triggers when new group is created
     - Parameter notification: Specifies the `NSNotification` Object.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatGroupList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-2-comet-chat-group-list)
     */
    @objc func didGroupCreated(_ notification: NSNotification) {
        
        if let group = notification.userInfo?["group"] as? Group {
            self.refreshGroups()
            let messageList = CometChatMessageList()
            messageList.set(conversationWith: group, type: .group)
            messageList.hidesBottomBarWhenPushed = true
            self.navigationController?.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(messageList, animated: true)
        }
    }
    
    /**
     This method triggers when  group is deleted.
     - Parameter notification: Specifies the `NSNotification` Object.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatGroupList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-2-comet-chat-group-list)
     */
    @objc func didGroupDeleted(_ notification: NSNotification) {
        
        self.refreshGroups()
        
    }
    
    /**
     This method setup the tableview to load CometChatGroupList.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatGroupList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-2-comet-chat-group-list)
     */
    private func setupTableView() {
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
            activityIndicator = UIActivityIndicatorView(style: .medium)
        } else {
            activityIndicator = UIActivityIndicatorView(style: .gray)
        }
        tableView = UITableView()
        self.view.addSubview(self.tableView)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.topAnchor.constraint(equalTo: self.safeArea.topAnchor).isActive = true
        self.tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView(frame: .zero)
        self.registerCells()
    }
    
    /**
    This method register the cells for CometChatGroupList.
    - Author: CometChat Team
    - Copyright:  ©  2020 CometChat Inc.
    - See Also:
    [CometChatGroupList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-2-comet-chat-group-list)
    */
    private func registerCells(){
        let CometChatGroupView  = UINib.init(nibName: "CometChatGroupView", bundle: UIKitSettings.bundle)
        self.tableView.register(CometChatGroupView, forCellReuseIdentifier: "groupView")
    }
    
    /**
     This method setup navigationBar for groupList viewController.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatGroupList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-2-comet-chat-group-list)
     */
    private func setupNavigationBar(){
        if navigationController != nil{
            if #available(iOS 13.0, *) {
                let navBarAppearance = UINavigationBarAppearance()
                navBarAppearance.configureWithOpaqueBackground()
                navBarAppearance.titleTextAttributes = [.font:UIFont.systemFont(ofSize: 20, weight: .regular) as Any]
                navBarAppearance.largeTitleTextAttributes = [.font: UIFont.systemFont(ofSize: 35, weight: .bold) as Any]
                navBarAppearance.shadowColor = .clear
                navigationController?.navigationBar.standardAppearance = navBarAppearance
                navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
                self.navigationController?.navigationBar.isTranslucent = true
            }
            
            if UIKitSettings.groupCreation == .enabled {
                self.addCreateGroup(true)
            }
        }
    }
    
    /**
     This method adds create group button  for groupList viewController.
     - Parameter inNavigationBar: Specifies `Bool` value which decides whether you want to add create group or not.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatGroupList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-2-comet-chat-group-list)
     */
    private func addCreateGroup(_ inNavigationBar: Bool){
        if inNavigationBar == true {
            let createGroupImage = UIImage(named: "createGroup", in: UIKitSettings.bundle, compatibleWith: nil)
            let createGroupButton = UIBarButtonItem(image: createGroupImage, style: .plain, target: self, action: #selector(didCreateGroupPressed))
            createGroupButton.tintColor = UIKitSettings.primaryColor
            self.navigationItem.rightBarButtonItem = createGroupButton
        }
    }
    
    
    /**
     This method triggers when create group button is pressed.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatGroupList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-2-comet-chat-group-list)
     */
    @objc func didCreateGroupPressed(){
        let createGroup = CometChatCreateGroup()
        let navigationController: UINavigationController = UINavigationController(rootViewController: createGroup)
        createGroup.set(title: NSLocalizedString("CREATE_GROUP", bundle: UIKitSettings.bundle, comment: ""), mode: .automatic)
        self.present(navigationController, animated: true, completion: nil)
        
    }
    
    /**
     This method setup the search bar for groupList viewController.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatGroupList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-2-comet-chat-group-list)
     */
    private func setupSearchBar(){
        // SearchBar Apperance
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.delegate = self
        if #available(iOS 13.0, *) {
            searchController.searchBar.barTintColor = .systemBackground
        } else {}
        if #available(iOS 11.0, *) {
            if navigationController != nil{
                navigationItem.searchController = searchController
            }else{
                if let textfield = searchController.searchBar.value(forKey: "searchField") as? UITextField {
                    if #available(iOS 13.0, *) {textfield.textColor = .label } else {}
                    if let backgroundview = textfield.subviews.first{
                        backgroundview.backgroundColor = UIColor.init(white: 1, alpha: 0.5)
                        backgroundview.layer.cornerRadius = 10
                        backgroundview.clipsToBounds = true
                    }
                }
                tableView.tableHeaderView = searchController.searchBar
            }
        } else {}
    }
    
    /**
        This method returns true if  search bar is empty.
        - Author: CometChat Team
        - Copyright:  ©  2020 CometChat Inc.
        - See Also:
        [CometChatGroupList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-2-comet-chat-group-list)
        */
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    /**
    This method returns true if  search bar is in active state.
    - Author: CometChat Team
    - Copyright:  ©  2020 CometChat Inc.
    - See Also:
    [CometChatGroupList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-2-comet-chat-group-list)
    */
    func isSearching() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
}

/*  ----------------------------------------------------------------------------------------- */
  
// MARK: - Table view Methods

extension CometChatGroupList: UITableViewDelegate , UITableViewDataSource {
    
  /// This method specifies the number of sections to display list of Groups.
  /// - Parameter tableView: An object representing the table view requesting this information.
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /// This method specifiesnumber of rows in CometChatGroupList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if groups.isEmpty {
            self.tableView.setEmptyMessage("No Groups Found.")
        } else{
            self.tableView.restore()
        }
        if isSearching(){
            return filteredGroups.count
        }else{
            return groups.count
        }
    }
    
    /// This method specifies height for section in CometChatGroupList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
   /// This method specifies the view for header  in CometChatGroupList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 0.5))
        return returnedView
    }
    
    /// This method specifies the height for row in CometChatGroupList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    /// This method triggers when particular cell is clicked by the user .
     /// - Parameters:
     ///   - tableView: The table-view object requesting this information.
     ///   - indexPath: specifies current index for TableViewCell.
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let selectedGroup = (tableView.cellForRow(at: indexPath) as? CometChatGroupView)?.group else{
            return
        }
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.didSelectGroupAtIndexPath(group: selectedGroup, indexPath: indexPath)
        
        if selectedGroup.hasJoined == false{
            
            if selectedGroup.groupType == .private || selectedGroup.groupType == .public {

                self.joinGroup(withGuid: selectedGroup.guid, name: selectedGroup.name ?? "", groupType: selectedGroup.groupType, password: "", indexPath: indexPath)
                
            }else{

                let alert = UIAlertController(title: "Enter Group Password", message: "Kindly, enter correct password to join the group.", preferredStyle: .alert)
                let save = UIAlertAction(title: "Join", style: .default) { (alertAction) in
                    let textField = alert.textFields![0] as UITextField
                    
                    if textField.text != "" {
                        if let password = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
                                   self.joinGroup(withGuid: selectedGroup.guid, name: selectedGroup.name ?? "", groupType: selectedGroup.groupType, password: password, indexPath: indexPath)
                        }
                    } else {
                        self.showAlert(title: "Warning!", msg: "Password cannot be empty.")
                    }
                }
                alert.addTextField { (textField) in
                    textField.placeholder = "Enter your name"
                    textField.isSecureTextEntry = true
                }
                let cancel = UIAlertAction(title: "Cancel", style: .default) { (alertAction) in }
                alert.addAction(save)
                alert.addAction(cancel)
                alert.view.tintColor = UIKitSettings.primaryColor
                self.present(alert, animated:true, completion: nil)
            }
            
           
        }else{
           
            let messageList = CometChatMessageList()
            messageList.set(conversationWith: selectedGroup, type: .group)
            messageList.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(messageList, animated: true)
        }
    }
    
    
    private func joinGroup(withGuid: String, name: String, groupType: CometChat.groupType, password: String, indexPath: IndexPath) {
        CometChat.joinGroup(GUID: withGuid, groupType: groupType, password: password, onSuccess: { (group) in
            DispatchQueue.main.async {
                let message = NSLocalizedString("YOU_JOINED", bundle: UIKitSettings.bundle, comment: "") +  (name) + "."
                let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: message, duration: .short)
                snackbar.show()
                self.tableView.deselectRow(at: indexPath, animated: true)
                let messageList = CometChatMessageList()
                messageList.set(conversationWith: group, type: .group)
                messageList.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(messageList, animated: true)
            }
            
        }) { (error) in
            DispatchQueue.main.async {
                if let errorMessage = error?.errorDescription {
                    let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: errorMessage, duration: .short)
                    snackbar.show()
                }
            }
        }
    }
    
    /// This method loads the upcoming groups coming inside the tableview
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - indexPath: specifies current index for TableViewCell.
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex && groups.count > 10 {
            self.fetchGroups()
        }
    }
    
    /// This method specifies the view for user  in CometChatGroupList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView.
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupView", for: indexPath) as! CometChatGroupView
        let group: Group?
        
        if  groups.count != 0 {
            if isSearching() {
                group = filteredGroups[safe:indexPath.row]
            }else{
                group = groups[safe:indexPath.row]
            }
            cell.group = group
        }
        return cell
    }
    
}

/*  ----------------------------------------------------------------------------------------- */

// MARK: - UISearchResultsUpdating Delegate

extension CometChatGroupList : UISearchBarDelegate, UISearchResultsUpdating {
    
    /**
    This method update the list of groups as per string provided in search bar
    - Parameter searchController: The UISearchController object used as the search bar.
    - Author: CometChat Team
    - Copyright:  ©  2020 CometChat Inc.
    - See Also:
    [CometChatGroupList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-2-comet-chat-group-list)
    */
    public func updateSearchResults(for searchController: UISearchController) {
        groupRequest  = GroupsRequest.GroupsRequestBuilder(limit: 20).set(searchKeyword: searchController.searchBar.text ?? "").build()
        groupRequest.fetchNext(onSuccess: { (groups) in
            if groups.count != 0{
                self.filteredGroups = groups
                DispatchQueue.main.async {self.tableView.reloadData()}
            }
        }) { (error) in
        }
        
    }
}


/*  ----------------------------------------------------------------------------------------- */


