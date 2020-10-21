
//  CometChatUserList.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
 CometChatUserList:  CometChatUserList is a view controller with a list of users. The view controller has all the necessary delegates and methods.
 
 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  */

// MARK: - Importing Frameworks.

import UIKit
import CometChatPro


// MARK: - Declaring Protocol.

public protocol UserListDelegate: AnyObject {
    /**
     This method triggers when user taps perticular user in CometChatUserList
     - Parameters:
     - conversation: Specifies the `User` Object for selected cell.
     - indexPath: Specifies the indexpath for selected user.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatUserList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-1-comet-chat-user-list)
     */
    func didSelectUserAtIndexPath(user: User, indexPath: IndexPath)
}

/*  ----------------------------------------------------------------------------------------- */

public class CometChatUserList: UIViewController {
    
    // MARK: - Declaration of Variables
    
    var userRequest : UsersRequest?
    var tableView: UITableView! = nil
    var safeArea: UILayoutGuide!
    var users: [User] = [User]()
    var filteredUsers: [User] = [User]()
    weak var delegate : UserListDelegate?
    var activityIndicator:UIActivityIndicatorView?
    var searchController:UISearchController = UISearchController(searchResultsController: nil)
    var sectionTitle : UILabel?
    var sections = [String]()
    
    
    // MARK: - View controller lifecycle methods
    
    override public func loadView() {
        super.loadView()
        
        view.backgroundColor = .white
        safeArea = view.layoutMarginsGuide
        self.setupTableView()
        self.setupSearchBar()
        self.setupNavigationBar()
        self.fetchUsers()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        if users.isEmpty {
             refreshUsers()
        }
    }
    
    // MARK: - Public Instance methods
    
    /**
     This method specifies the navigation bar title for CometChatUserList.
     - Parameters:
     - title: This takes the String to set title for CometChatUserList.
     - mode: This specifies the TitleMode such as :
     * .automatic : Automatically use the large out-of-line title based on the state of the previous item in the navigation bar.
     *  .never: Never use a larger title when this item is topmost.
     * .always: Always use a larger title when this item is topmost.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatUserList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-1-comet-chat-user-list)
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
    
    
    /**
     This method specifies the navigation bar color for CometChatUserList.
     - Parameters:
     - barColor: This  specifies the navigation bar color.
     - color: This  specifies the navigation bar title color.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatUserList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-1-comet-chat-user-list)
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
     [CometChatUserList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-1-comet-chat-user-list)
     */
    private func fetchUsers(){
        activityIndicator?.startAnimating()
        activityIndicator?.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
        tableView.tableFooterView = activityIndicator
        tableView.tableFooterView = activityIndicator
        tableView.tableFooterView?.isHidden = false
        userRequest?.fetchNext(onSuccess: { (users) in
            if users.count != 0 {
                self.users = self.users.sorted(by: { (Obj1, Obj2) -> Bool in
                    let Obj1_Name = Obj1.name ?? ""
                    let Obj2_Name = Obj2.name ?? ""
                    return (Obj1_Name.localizedCaseInsensitiveCompare(Obj2_Name) == .orderedAscending)
                })
                
                self.users.append(contentsOf: users)
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
    
    // MARK: - Private instance methods.
    
    /**
     This method fetches the list of users from  Server using **UserRequest** Class.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatUserList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-1-comet-chat-user-list)
     */
    private func refreshUsers(){
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
                self.users = self.users.sorted(by: { (Obj1, Obj2) -> Bool in
                    let Obj1_Name = Obj1.name ?? ""
                    let Obj2_Name = Obj2.name ?? ""
                    return (Obj1_Name.localizedCaseInsensitiveCompare(Obj2_Name) == .orderedAscending)
                })
                
                self.users.append(contentsOf: users)
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
     This method setup the tableview to load CometChatUserList.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatUserList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-1-comet-chat-user-list)
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
     This method register 'CometChatUserView' cell in tableView.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatUserList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-1-comet-chat-user-list)
     */
    private func registerCells(){
        let CometChatUserView  = UINib.init(nibName: "CometChatUserView", bundle: UIKitSettings.bundle)
        self.tableView.register(CometChatUserView, forCellReuseIdentifier: "userView")
    }
    
    /**
     This method setup navigationBar for userList viewController.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatUserList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-1-comet-chat-user-list)
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
        }}
    
    /**
     This method setup the search bar for userList viewController.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatUserList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-1-comet-chat-user-list)
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
     [CometChatUserList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-1-comet-chat-user-list)
     */
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    /**
     This method returns true if  search bar is in active state.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatUserList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-1-comet-chat-user-list)
     */
    func isSearching() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
}

/*  ----------------------------------------------------------------------------------------- */

// MARK: - Table view Methods

extension CometChatUserList: UITableViewDelegate , UITableViewDataSource {
    
    
    /// This method specifies the number of sections to display list of users. In CometChatUserList, the users which has same starting alphabets are clubbed in single section.
    /// - Parameter tableView: An object representing the table view requesting this information.
    public func numberOfSections(in tableView: UITableView) -> Int {
        if isSearching() {
            if filteredUsers.count != 0 {
                for user in filteredUsers {
                    if !sections.contains((user.name?.first?.uppercased())!){
                        sections.append(String((user.name?.first?.uppercased())!))
                    }
                }
            }
            return sections.count
        }else{
            if users.count != 0 {
                for user in users {
                    if !sections.contains((user.name?.first?.uppercased())!){
                        sections.append(String((user.name?.first?.uppercased())!))
                    }
                }
            }
            return sections.count
        }
    }
    
    
    /// This method specifies height for section in CometChatUserList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isSearching(){
            return 0
        }else{
            return 25
        }
    }
    
    
    /// This method specifiesnumber of rows in CometChatUserList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isSearching(){
            return filteredUsers.count
        }else{
            return users.count
        }
    }
    
    
    /// This method specifies the height for row in CometChatUserList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if isSearching() {
            let user = filteredUsers[safe: indexPath.row]
            if sections[safe: indexPath.section] == user?.name?.first?.uppercased(){
                return 60
            }else{
                return 0
            }
        }else{
             let user = users[safe:indexPath.row]
            if sections[safe: indexPath.section] == user?.name?.first?.uppercased(){
                return 60
            }else{
                return 0
            }
           
        }
    }
    
    
    /// This method specifies the view for user  in CometChatUserList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = UITableViewCell()
        var user: User?
        if isSearching() {
            user = filteredUsers[safe:indexPath.row]
        } else {
            user = users[safe:indexPath.row]
        }
        if sections[safe: indexPath.section] == user?.name?.first?.uppercased(){
            let userCell = tableView.dequeueReusableCell(withIdentifier: "userView", for: indexPath) as! CometChatUserView
            userCell.user = user
            return userCell
        }else{
            cell.separatorInset = UIEdgeInsets(top: 0, left: tableView.frame.size.width, bottom: 0, right: 0)
            return cell
        }
    }
    
    
    /// This method specifies the view for header  in CometChatUserList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 25))
        sectionTitle = UILabel(frame: CGRect(x: 10, y: 2, width: view.frame.size.width, height: 25))
        sectionTitle?.text = self.sections[safe: section]
        if #available(iOS 13.0, *) {
            sectionTitle?.textColor = .lightGray
            returnedView.backgroundColor = .systemBackground
        } else {}
        returnedView.addSubview(sectionTitle!)
        return returnedView
    }
    
    
    /// This method specifies upcoming cells to be display in tableView
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - cell: The TableViewCell object requesting this information.
    ///   - indexPath: specifies current index for TableViewCell.
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex {
            self.fetchUsers()
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
        guard let selectedUser = tableView.cellForRow(at: indexPath) as? CometChatUserView else{
            return
        }
        tableView.deselectRow(at: indexPath, animated: true)
        let  messageList = CometChatMessageList()
        messageList.set(conversationWith: selectedUser.user!, type: .user)
        messageList.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(messageList, animated: true)
        delegate?.didSelectUserAtIndexPath(user: selectedUser.user!, indexPath: indexPath)
    }
}

/*  ----------------------------------------------------------------------------------------- */

// MARK: - UISearchResultsUpdating Delegate

extension CometChatUserList : UISearchBarDelegate, UISearchResultsUpdating {
    
    /// This method update the list of users as per string provided in search bar
    /// - Parameter searchController: The UISearchController object used as the search bar.
    public func updateSearchResults(for searchController: UISearchController) {
        
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
                DispatchQueue.main.async(execute: {self.tableView.reloadData()})
            }
        }) { (error) in
        }
    }
}

/*  ----------------------------------------------------------------------------------------- */
