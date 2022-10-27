
//  CometChatStartConversation.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
 CometChatStartConversation:  CometChatStartConversation is a view controller with a list of users. The view controller has all the necessary delegates and methods.
 
 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  */

// MARK: - Importing Frameworks.

import UIKit
import CometChatPro



// MARK: - Declaring Protocol.

public protocol StartConversationDelegate: AnyObject {
    /**
     This method triggers when user taps perticular user in CometChatStartConversation
     - Parameters:
     - conversation: Specifies the `User` Object for selected cell.
     - indexPath: Specifies the indexpath for selected user.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatStartConversation Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-1-comet-chat-user-list)
     */
    func didSelectUserAtIndexPath(user: CometChatPro.User, indexPath: IndexPath)
    func didSelectGroupAtIndexPath(group: CometChatPro.Group, indexPath: IndexPath)
}

/*  ----------------------------------------------------------------------------------------- */

public class CometChatStartConversation: UIViewController {
    
    
    // MARK: - Declaration of Variables
    
    var userRequest : UsersRequest?
    var groupRequest : GroupsRequest?
    var tableView: UITableView! = nil
    var safeArea: UILayoutGuide!
    var users: [[CometChatPro.User]] = [[CometChatPro.User]]()
    var filteredUsers: [CometChatPro.User] = [CometChatPro.User]()
    var groups: [CometChatPro.Group] = [CometChatPro.Group]()
    var filteredGroups:  [CometChatPro.Group] = [CometChatPro.Group]()
    weak var delegate : StartConversationDelegate?
    var activityIndicator:UIActivityIndicatorView?
    var searchController:UISearchController = UISearchController(searchResultsController: nil)
    var sectionTitle : UILabel?
    var sections = [String]()
    var sortedKeys = [String]()
    var globalGroupedUsers: [String : [CometChatPro.User]] = [:]
    
    // MARK: - View controller lifecycle methods
    
    override public func loadView() {
        super.loadView()
        
        view.backgroundColor = .white
        safeArea = view.layoutMarginsGuide
        self.setupTableView()
        self.setupSearchBar()
        self.setupNavigationBar()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        if users.isEmpty {
             refreshUsers()
        }
        if groups.isEmpty {
            refreshGroups()
        }
    }
    
    // MARK: - Public Instance methods
    
    /**
     This method specifies the navigation bar title for CometChatStartConversation.
     - Parameters:
     - title: This takes the String to set title for CometChatStartConversation.
     - mode: This specifies the TitleMode such as :
     * .automatic : Automatically use the large out-of-line title based on the state of the previous item in the navigation bar.
     *  .never: Never use a larger title when this item is topmost.
     * .always: Always use a larger title when this item is topmost.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatStartConversation Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-1-comet-chat-user-list)
     */
    @objc public func set(title : String, mode: UINavigationItem.LargeTitleDisplayMode){
        if navigationController != nil{
            navigationItem.title = title.localized()
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
    
    
    /**
     This method specifies the navigation bar color for CometChatStartConversation.
     - Parameters:
     - barColor: This  specifies the navigation bar color.
     - color: This  specifies the navigation bar title color.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatStartConversation Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-1-comet-chat-user-list)
     */
    @objc public func set(barColor :UIColor, titleColor color: UIColor){
        if navigationController != nil{
            // NavigationBar Appearance
            if #available(iOS 13.0, *) {
                let navBarAppearance = UINavigationBarAppearance()
                navBarAppearance.configureWithOpaqueBackground()
                navBarAppearance.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 20, weight: .regular) as Any]
                navBarAppearance.largeTitleTextAttributes = [.font: UIFont.systemFont(ofSize: 35, weight: .bold) as Any]
                navBarAppearance.shadowColor = .clear
                navBarAppearance.backgroundColor = barColor
                navigationController?.navigationBar.standardAppearance = navBarAppearance
                navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
                self.navigationController?.navigationBar.isTranslucent = true
            }
        }
    }
    
    
    // MARK: - Private instance methods.
    
    /**
     This method fetches the list of users from  Server using **UserRequest** Class.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatStartConversation Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-1-comet-chat-user-list)
     */
    private func fetchUsers(){
        activityIndicator?.startAnimating()
        activityIndicator?.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
        tableView.tableFooterView = activityIndicator
        tableView.tableFooterView?.isHidden = false
        userRequest?.fetchNext(onSuccess: { (users) in
            if users.count != 0 {
                self.groupUsers(users: users)
            }else{
                DispatchQueue.main.async {
                    self.tableView.restore()
                    self.activityIndicator?.stopAnimating()
                    self.tableView.tableFooterView?.isHidden = true
                }
            }
        }) { (error) in
            DispatchQueue.main.async {
                if let error = error {
                    CometChatSnackBoard.showErrorMessage(for: error)
                }
            }
         }
    }
    
    private func fetchNextUsers(){
        activityIndicator?.startAnimating()
        activityIndicator?.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
        tableView.tableFooterView = activityIndicator
        tableView.tableFooterView?.isHidden = false
        userRequest?.fetchNext(onSuccess: { (users) in
            if users.count != 0 {
                self.groupUsers(users: users)
            }else{
                DispatchQueue.main.async {
                    self.tableView.restore()
                    self.activityIndicator?.stopAnimating()
                    self.tableView.tableFooterView?.isHidden = true
                }
            }
        }) { (error) in
            DispatchQueue.main.async {
                if let error = error {
                    CometChatSnackBoard.showErrorMessage(for: error)
                }
            }
         }
    }
    
    private func groupUsers(users: [CometChatPro.User]){
        DispatchQueue.main.async {  [weak self] in
            guard let strongSelf = self else { return }
            if strongSelf.users.isEmpty { strongSelf.tableView?.setEmptyMessage("NO_USERS_FOUND".localized())
            }else{ strongSelf.tableView?.restore() }
        }
        let groupedUsers = Dictionary(grouping: users) { (element) -> String in
            guard let name = element.name?.capitalized.trimmingCharacters(in: .whitespacesAndNewlines) else {return ""}
            return (name as NSString).substring(to: 1)
        }
        globalGroupedUsers.merge(groupedUsers, uniquingKeysWith: +)
        for key in groupedUsers.keys {
            if !sortedKeys.contains(key) { sortedKeys.append(key) }
        }
        sortedKeys = sortedKeys.sorted{ $0.lowercased() < $1.lowercased()}
        var staticUsers: [[CometChatPro.User]] = [[CometChatPro.User]]()
        sortedKeys.forEach { (key) in
            if let value = globalGroupedUsers[key] {
                staticUsers.append(value)
            }
        }
        DispatchQueue.main.async {
            self.users = staticUsers
            self.activityIndicator?.stopAnimating()
            self.tableView.tableFooterView?.isHidden = true
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: - Private instance methods.
    
    /**
     This method fetches the list of users from  Server using **UserRequest** Class.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatStartConversation Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-1-comet-chat-user-list)
     */
    private func refreshUsers(){
        self.globalGroupedUsers.removeAll()
        self.sections.removeAll()
        self.users.removeAll()
        activityIndicator?.startAnimating()
        activityIndicator?.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
        tableView.tableFooterView = activityIndicator
        tableView.tableFooterView = activityIndicator
        tableView.tableFooterView?.isHidden = false
        
        if UIKitSettings.userInMode == .all {
            userRequest = UsersRequest.UsersRequestBuilder(limit: 20).build()
        }else if UIKitSettings.userInMode == .friends {
        
            userRequest = UsersRequest.UsersRequestBuilder(limit: 20).friendsOnly(true).build()
        }else if UIKitSettings.userInMode == .none {
            userRequest = UsersRequest.UsersRequestBuilder(limit: 0).build()
        }else {
         userRequest = UsersRequest.UsersRequestBuilder(limit: 20).build()
        }
        userRequest?.fetchNext(onSuccess: { (users) in
            if users.count != 0 {

                self.groupUsers(users: users)
              
            }else{

                DispatchQueue.main.async {
                    self.tableView.restore()
                    self.activityIndicator?.stopAnimating()
                    self.tableView.tableFooterView?.isHidden = true
                }
            }
        
        }) { (error) in
            DispatchQueue.main.async {
                if let error = error {
                    CometChatSnackBoard.showErrorMessage(for: error)
                }
            }
        }
    }
    
    
    private func fetchGroups(){
        activityIndicator?.startAnimating()
        activityIndicator?.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
        tableView.tableFooterView = activityIndicator
        tableView.tableFooterView?.isHidden = false
        groupRequest?.fetchNext(onSuccess: { (groups) in
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
                if let error = error {
                    CometChatSnackBoard.showErrorMessage(for: error)
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
        groupRequest?.fetchNext(onSuccess: { (groups) in
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
            if let error = error {
                CometChatSnackBoard.showErrorMessage(for: error)
            }
            }
        }
    }
    
    /**
     This method setup the tableview to load CometChatStartConversation.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatStartConversation Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-1-comet-chat-user-list)
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
     This method register 'CometChatStartConversationItem' cell in tableView.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatStartConversation Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-1-comet-chat-user-list)
     */
    private func registerCells(){
        let CometChatUserListItem  = UINib.init(nibName: "CometChatUserListItem", bundle: UIKitSettings.bundle)
        self.tableView.register(CometChatUserListItem, forCellReuseIdentifier: "CometChatUserListItem")

        let CometChatGroupListItem  = UINib.init(nibName: "CometChatGroupListItem", bundle: UIKitSettings.bundle)
        self.tableView.register(CometChatGroupListItem, forCellReuseIdentifier: "CometChatGroupListItem")
    }
    
    /**
     This method setup navigationBar for StartConversation viewController.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatStartConversation Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-1-comet-chat-user-list)
     */
    private func setupNavigationBar(){
        if navigationController != nil{
            // NavigationBar Appearance
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
            self.addBackButton(bool: true)
        }}
    
    private func addBackButton(bool: Bool) {
        let backButton = UIButton(type: .custom)
        if #available(iOS 13.0, *) {
            let edit = UIImage(named: "chats-back.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
             backButton.setImage(edit, for: .normal)
            backButton.tintColor = UIKitSettings.primaryColor
        } else {}
        backButton.tintColor = UIKitSettings.primaryColor
        backButton.setTitleColor(backButton.tintColor, for: .normal) // You can change the TitleColor
        backButton.addTarget(self, action: #selector(self.didBackButtonPressed), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = nil
        if bool == true {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        }else{
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        }
    }
    
    @objc func didBackButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    /**
     This method setup the search bar for StartConversation viewController.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatStartConversation Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-1-comet-chat-user-list)
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
        searchController.searchBar.placeholder = "SEARCH_USERS".localized()
        if #available(iOS 11.0, *) {
            if navigationController != nil{
                FeatureRestriction.isUserSearchEnabled { (success) in
                    if success == .enabled {
                        self.navigationItem.searchController = self.searchController
                    }
                }
            }else{
               
                if let textfield = searchController.searchBar.value(forKey: "searchField") as? UITextField {
                    if #available(iOS 13.0, *) {textfield.textColor = .label } else {}
                    if let backgroundview = textfield.subviews.first{
                        backgroundview.backgroundColor = UIColor.init(white: 1, alpha: 0.5)
                        backgroundview.layer.cornerRadius = 10
                        backgroundview.clipsToBounds = true
                    }
                }
                FeatureRestriction.isUserSearchEnabled { (success) in
                    if success == .enabled {
                        self.tableView.tableHeaderView = self.searchController.searchBar
                    }
                }
                
            }
        } else {}
        searchController.searchBar.scopeButtonTitles = ["USERS".localized(), "GROUPS".localized()]
        searchController.searchBar.showsScopeBar = true
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    
    /**
     This method returns true if  search bar is empty.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatStartConversation Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-1-comet-chat-user-list)
     */
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    /**
     This method returns true if  search bar is in active state.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatStartConversation Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-1-comet-chat-user-list)
     */
    func isSearching() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
}

/*  ----------------------------------------------------------------------------------------- */

// MARK: - Table view Methods

extension CometChatStartConversation: UITableViewDelegate , UITableViewDataSource {
    
    
    /// This method specifies the number of sections to display list of users. In CometChatStartConversation, the users which has same starting alphabets are clubbed in single section.
    /// - Parameter tableView: An object representing the table view requesting this information.
    public func numberOfSections(in tableView: UITableView) -> Int {
        
        if searchController.searchBar.selectedScopeButtonIndex == 0 {
            if isSearching() {
                return 1
            }else{
                return users.count
            }
        }else{
            return 1
        }
    }
    
    
    /// This method specifies height for section in CometChatStartConversation
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if searchController.searchBar.selectedScopeButtonIndex == 0 {
            return 25
        }else{
            return 0
        }
    }
    
    
    /// This method specifiesnumber of rows in CometChatStartConversation
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.searchBar.selectedScopeButtonIndex == 0 {
            if isSearching(){
                return filteredUsers.count
            }else{
                return users[safe: section]?.count ?? 0
            }
        }else{
            if groups.isEmpty {
                self.tableView.setEmptyMessage("NO_GROUPS_FOUND".localized())
            } else{
                self.tableView.restore()
            }
            if isSearching(){
                return filteredGroups.count
            }else{
                return groups.count
            }
        }
    }
    
    
    /// This method specifies the height for row in CometChatStartConversation
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if searchController.searchBar.selectedScopeButtonIndex == 0 {
            return 60
        }else{
            return 70
        }
    }
    
    
    /// This method specifies the view for user  in CometChatStartConversation
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if searchController.searchBar.selectedScopeButtonIndex == 0 {
            guard let section = indexPath.section as? Int else { return UITableViewCell() }
            if isSearching() {
        
                if let user = filteredUsers[safe: indexPath.row] {
                    let userCell = tableView.dequeueReusableCell(withIdentifier: "CometChatUserListItem", for: indexPath) as! CometChatUserListItem
                    userCell.user = user
                    return userCell
                }
            } else {

                if let user = users[safe: section]?[safe: indexPath.row] {
                    let userCell = tableView.dequeueReusableCell(withIdentifier: "CometChatUserListItem", for: indexPath) as! CometChatUserListItem
                    userCell.user = user
                    return userCell
                }
            }
            
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CometChatGroupListItem", for: indexPath) as! CometChatGroupListItem
            let group: CometChatPro.Group?
            
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
        
     
        return UITableViewCell()
    }
    
    
    /// This method specifies the view for header  in CometChatStartConversation
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        if searchController.searchBar.selectedScopeButtonIndex == 0 {
            let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width - 20, height: 25))
            sectionTitle = UILabel(frame: CGRect(x: 10, y: 2, width: returnedView.frame.size.width, height: 25))
            if isSearching() {
                sectionTitle?.text = ""
            }else{
                if let title = ((users[safe: section]?.first?.name?.capitalized ?? "") as? NSString)?.substring(to: 1) {
                    sectionTitle?.text = title
                }
            }
            if #available(iOS 13.0, *) {
                sectionTitle?.textColor = .lightGray
                returnedView.backgroundColor = .systemBackground
            } else {}
            returnedView.addSubview(sectionTitle!)
            return returnedView
        }else{
            let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width - 20, height: 0.5))
            return returnedView
        }
    }
    
    
    /// This method specifies upcoming cells to be display in tableView
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - cell: The TableViewCell object requesting this information.
    ///   - indexPath: specifies current index for TableViewCell.
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if searchController.searchBar.selectedScopeButtonIndex == 0 {
            let lastSectionIndex = tableView.numberOfSections - 1
            let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
            if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex {
                self.fetchNextUsers()
            }
        }else{
            let lastSectionIndex = tableView.numberOfSections - 1
            let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
            if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex && groups.count > 10 {
                self.fetchGroups()
            }
        }
       
    }
    
    
    /// This method specified te section index title for current index
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - title: specifies current index title.
    ///   - index: specifies current index.
    public func tableView(_ tableView: UITableView,
                          sectionForSectionIndexTitle title: String,
                          at index: Int) -> Int{
        return index
    }
    
    
    /// This method triggers when particular cell is clicked by the user .
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - indexPath: specifies current index for TableViewCell.
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if searchController.searchBar.selectedScopeButtonIndex == 0 {
            guard let selectedUser = tableView.cellForRow(at: indexPath) as? CometChatUserListItem else{
                return
            }
            tableView.deselectRow(at: indexPath, animated: true)
            let  messageList = CometChatMessageList()
            messageList.set(conversationWith: selectedUser.user!, type: .user)
            messageList.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(messageList, animated: true)
            delegate?.didSelectUserAtIndexPath(user: selectedUser.user!, indexPath: indexPath)
        }else{
            guard let selectedGroup = (tableView.cellForRow(at: indexPath) as? CometChatGroupListItem)?.group else{
                return
            }
            tableView.deselectRow(at: indexPath, animated: true)
            delegate?.didSelectGroupAtIndexPath(group: selectedGroup, indexPath: indexPath)
            
            if selectedGroup.hasJoined == false{
                
                if selectedGroup.groupType == .private || selectedGroup.groupType == .public {

                    self.joinGroup(withGuid: selectedGroup.guid, name: selectedGroup.name ?? "", groupType: selectedGroup.groupType, password: "", indexPath: indexPath)
                    
                }else{

                    let alert = UIAlertController(title: "ENTER_GROUP_PWD".localized(), message: "ENTER_PASSWORD_TO_JOIN".localized(), preferredStyle: .alert)
                    let save = UIAlertAction(title: "JOIN".localized(), style: .default) { (alertAction) in
                        let textField = alert.textFields![0] as UITextField
                        
                        if textField.text != "" {
                            if let password = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
                                       self.joinGroup(withGuid: selectedGroup.guid, name: selectedGroup.name ?? "", groupType: selectedGroup.groupType, password: password, indexPath: indexPath)
                            }
                        } else {
                            self.showAlert(title: "WARNING".localized(), msg: "GROUP_PASSWORD_CANNOT_EMPTY".localized())
                        }
                    }
                    alert.addTextField { (textField) in
                        textField.placeholder = "ENTER_YOUR_NAME".localized()
                        textField.isSecureTextEntry = true
                    }
                    let cancel = UIAlertAction(title: "CANCEL".localized(), style: .default) { (alertAction) in }
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
    }
    
    
    private func joinGroup(withGuid: String, name: String, groupType: CometChat.groupType, password: String, indexPath: IndexPath) {
        CometChat.joinGroup(GUID: withGuid, groupType: groupType, password: password, onSuccess: { (group) in
            DispatchQueue.main.async {
                self.tableView.deselectRow(at: indexPath, animated: true)
                let messageList = CometChatMessageList()
                messageList.set(conversationWith: group, type: .group)
                messageList.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(messageList, animated: true)
            }
            
        }) { (error) in
            DispatchQueue.main.async {
                if let error = error {
                    CometChatSnackBoard.showErrorMessage(for: error)
                }
            }
        }
    }
}

/*  ----------------------------------------------------------------------------------------- */

// MARK: - UISearchResultsUpdating Delegate

extension CometChatStartConversation : UISearchBarDelegate, UISearchResultsUpdating {
    
    /// This method update the list of users as per string provided in search bar
    /// - Parameter searchController: The UISearchController object used as the search bar.
    public func updateSearchResults(for searchController: UISearchController) {
        
        if searchController.searchBar.selectedScopeButtonIndex == 0 {
            
            if UIKitSettings.userInMode == .all {
                userRequest = UsersRequest.UsersRequestBuilder(limit: 20).set(searchKeyword: searchController.searchBar.text ?? "").build()
            }else if UIKitSettings.userInMode == .friends {
                userRequest = UsersRequest.UsersRequestBuilder(limit: 20).friendsOnly(true).set(searchKeyword: searchController.searchBar.text ?? "").build()
            }else if UIKitSettings.userInMode == .none {
                userRequest = UsersRequest.UsersRequestBuilder(limit: 0).set(searchKeyword: searchController.searchBar.text ?? "").build()
            }else {
                userRequest = UsersRequest.UsersRequestBuilder(limit: 20).set(searchKeyword: searchController.searchBar.text ?? "").build()
            }
            userRequest?.fetchNext(onSuccess: { (users) in
                if users.count != 0 {
                    self.filteredUsers = users
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.tableView?.restore()
                        self.activityIndicator?.stopAnimating()
                        self.tableView.tableFooterView?.isHidden = true
                    }
                   
                }else{
                    self.filteredUsers = []
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.activityIndicator?.stopAnimating()
                        self.tableView.tableFooterView?.isHidden = true
                        self.tableView?.setEmptyMessage("NO_USERS_FOUND".localized())
                    }
                }
            }) { (error) in
            }
            
        }else{
            
            groupRequest  = GroupsRequest.GroupsRequestBuilder(limit: 20).set(searchKeyword: searchController.searchBar.text ?? "").build()
            groupRequest?.fetchNext(onSuccess: { (groups) in
                if groups.count != 0 {
                    self.filteredGroups = groups
                    DispatchQueue.main.async {self.tableView.reloadData()}
                }else{
                    self.filteredGroups = []
                    DispatchQueue.main.async {self.tableView.reloadData()}
                }
            }) { (error) in
            }
            
        }
      
    }
    
    
    public func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
            
            switch selectedScope {
            case 0:
                searchBar.placeholder = "SEARCH_USERS".localized()
                self.set(title: "SELECT_USER".localized(), mode: .automatic)
                self.tableView.reloadData()
            case 1:
                searchBar.placeholder = "SEARCH_GROUPS".localized()
                self.set(title: "SELECT_GROUP".localized(), mode: .automatic)
                self.tableView.reloadData()
            default:break
            }
        }
}

/*  ----------------------------------------------------------------------------------------- */


