//  CometChatAddMembers.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.


// MARK: - Importing Frameworks.

import UIKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */

public class CometChatAddMembers: UIViewController {
    
     // MARK: - Declaration of Variables
    
    var userRequest = UsersRequest.UsersRequestBuilder(limit: 20).build()
    var memberRequest: GroupMembersRequest?
    var tableView: UITableView! = nil
    var safeArea: UILayoutGuide!
    var users: [User] = [User]()
    var members: [User] = [User]()
    var filteredUsers: [User] = [User]()
    var activityIndicator:UIActivityIndicatorView?
    var searchController:UISearchController = UISearchController(searchResultsController: nil)
    var sectionTitle : UILabel?
    var sectionsArray = [String]()
    var currentGroup: Group?
    
     
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
    
    // MARK: - Public instance methods
    
    /**
       This method specifies the `group` Objects to add or remove members it it..
       - Parameter group: This specifies `Group` Object.
       - Author: CometChat Team
       - Copyright:  ©  2020 CometChat Inc.
       */
    public func set(group: Group){
        
        guard group != nil else {
            return
        }
        self.currentGroup = group
        self.fetchGroupMembers(group: group)
    }
    
    /**
       This method specifies the navigation bar title for CometChatAddMembers.
       - Parameters:
       - title: This takes the String to set title for CometChatAddMembers.
       - mode: This specifies the TitleMode such as :
       * .automatic : Automatically use the large out-of-line title based on the state of the previous item in the navigation bar.
       *  .never: Never use a larger title when this item is topmost.
       * .always: Always use a larger title when this item is topmost.
       - Author: CometChat Team
       - Copyright:  ©  2020 CometChat Inc.
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
          }}
      
    /**
    This method specifies the navigation bar color for CometChatAddMembers.
      - Parameters:
        - barColor: This specifes navigation bar color.
        - color:  This specifes navigation bar title color.
    - Author: CometChat Team
    - Copyright:  ©  2020 CometChat Inc.
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
    
    
     // MARK: - Private instance methods
    /**
    This method setup the tableview to load CometChatAddMembers.
    - Author: CometChat Team
    - Copyright:  ©  2020 CometChat Inc.
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
        let CometChatUserView  = UINib.init(nibName: "CometChatUserView", bundle: UIKitSettings.bundle)
        self.tableView.register(CometChatUserView, forCellReuseIdentifier: "userView")
    }
    
    
    /**
       This method setup navigationBar for addMembers viewController.
       - Author: CometChat Team
       - Copyright:  ©  2020 CometChat Inc.
       */
    private func setupNavigationBar(){
        if navigationController != nil{
            // NavigationBar Appearance
       
            if #available(iOS 13.0, *) {
                let navBarAppearance = UINavigationBarAppearance()
                navBarAppearance.configureWithOpaqueBackground()
                navBarAppearance.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 20, weight: .regular) as Any]
                navBarAppearance.largeTitleTextAttributes = [.font: UIFont.systemFont(ofSize: 35, weight: .bold) as Any]
                navBarAppearance.shadowColor = .clear
                navigationController?.navigationBar.standardAppearance = navBarAppearance
                navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
                self.navigationController?.navigationBar.isTranslucent = true
                  }
                let closeButton = UIBarButtonItem(title: NSLocalizedString("CLOSE", bundle: UIKitSettings.bundle, comment: ""), style: .plain, target: self, action: #selector(closeButtonPressed))
               closeButton.tintColor = UIKitSettings.primaryColor
                self.navigationItem.rightBarButtonItem = closeButton
            self.set(title: NSLocalizedString("ADD_MEMBERS", bundle: UIKitSettings.bundle, comment: ""), mode: .automatic)
            self.setLargeTitleDisplayMode(.always)
            }
        }

    /**
    This method triggers when user clicks on close button.
    - Author: CometChat Team
    - Copyright:  ©  2020 CometChat Inc.
    */
    @objc func closeButtonPressed(){
        self.dismiss(animated: true, completion: nil)
    }
    
  
    /**
        This method setup the search bar for addMembers viewController.
        - Author: CometChat Team
        - Copyright:  ©  2020 CometChat Inc.
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
     This method fetches the list of users to add inside a group..
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
    private func fetchUsers(){
        activityIndicator?.startAnimating()
        activityIndicator?.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
        tableView.tableFooterView = activityIndicator
        tableView.tableFooterView = activityIndicator
        tableView.tableFooterView?.isHidden = false
        userRequest.fetchNext(onSuccess: { (users) in
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
    This method fetches the list of group members for specified group.
      - Parameter group: This specifies `Group` Object.
    - Author: CometChat Team
    - Copyright:  ©  2020 CometChat Inc.
    */
    private func fetchGroupMembers(group: Group){
        memberRequest = GroupMembersRequest.GroupMembersRequestBuilder(guid: group.guid).set(limit: 100).build()
        memberRequest?.fetchNext(onSuccess: { (groupMember) in
            self.members = groupMember
            DispatchQueue.main.async {self.tableView.reloadData() }
        }, onError: { (error) in
            DispatchQueue.main.async {
                if let errorMessage = error?.errorDescription {
                    let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: errorMessage, duration: .short)
                    snackbar.show()
                }
            }
         })
    }
    
    /**
    This method returns true if  search bar is empty.
    - Author: CometChat Team
    - Copyright:  ©  2020 CometChat Inc.
    
    */
     func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    /**
       This method returns true if  search bar is in active state.
       - Author: CometChat Team
       - Copyright:  ©  2020 CometChat Inc.
       */
     func isSearching() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
}


/*  ----------------------------------------------------------------------------------------- */

// MARK: - Table view Methods


extension CometChatAddMembers: UITableViewDelegate , UITableViewDataSource {
    
    /// This method specifies the number of sections to display list of users. In CometChatAddMembers, the users which has same starting alphabets are clubbed in single section.
       /// - Parameter tableView: An object representing the table view requesting this information.
    public func numberOfSections(in tableView: UITableView) -> Int {
        
        if isSearching() {
            if filteredUsers != nil {
                for user in filteredUsers {
                    if !sectionsArray.contains((user.name?.first?.uppercased())!){
                        sectionsArray.append(String((user.name?.first?.uppercased())!))
                    }
                }
            }
            return sectionsArray.count
        }else{
            if users != nil {
                for user in users {
                    if !sectionsArray.contains((user.name?.first?.uppercased())!){
                        sectionsArray.append(String((user.name?.first?.uppercased())!))
                    }
                }
            }
            return sectionsArray.count
        }
    }
    
    /// This method specifies height for section in CometChatAddMembers
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
    
    /// This method specifiesnumber of rows in CometChatAddMembers
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
    
    /// This method specifies the height for row in CometChatAddMembers
       /// - Parameters:
       ///   - tableView: The table-view object requesting this information.
       ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if isSearching() {
            let user = filteredUsers[safe:indexPath.row]
            if sectionsArray[indexPath.section] == user?.name?.first?.uppercased(){
                return 60
            }else{
                return 0
            }
        }else{
            let user = users[safe:indexPath.row]
            if sectionsArray[indexPath.section] == user?.name?.first?.uppercased(){
                return 60
            }else{
                return 0
            }
        }
    }
    
    
    /// This method specifies the view for user  in CometChatAddMembers
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
            if sectionsArray[indexPath.section] == user?.name?.first?.uppercased(){
                let userCell = tableView.dequeueReusableCell(withIdentifier: "userView", for: indexPath) as! CometChatUserView
                userCell.user = user
                return userCell
            }else{
                cell.separatorInset = UIEdgeInsets(top: 0, left: tableView.frame.size.width, bottom: 0, right: 0)
                return cell
            }
        }
    
    /// This method specifies the view for header  in CometChatAddMembers
       /// - Parameters:
       ///   - tableView: The table-view object requesting this information.
       ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 25))
        sectionTitle = UILabel(frame: CGRect(x: 10, y: 2, width: view.frame.size.width, height: 25))
        sectionTitle?.text = self.sectionsArray[section]
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
    
    /// This method triggers when particulat cell is clicked by the user .
       /// - Parameters:
       ///   - tableView: The table-view object requesting this information.
       ///   - indexPath: specifies current index for TableViewCell.
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let selectedUser = tableView.cellForRow(at: indexPath) as? CometChatUserView else{
            return
        }
        if let user = selectedUser.user {
            let userDetail = CometChatUserDetail()
            userDetail.set(user: user)
            userDetail.currentGroup = currentGroup
            self.navigationController?.pushViewController(userDetail, animated: true)
        }
    }
}

/*  ----------------------------------------------------------------------------------------- */

// MARK: - UISearchBar Delegate

extension CometChatAddMembers : UISearchBarDelegate, UISearchResultsUpdating {
    
    // This method update the list of users as per string provided in search bar
    /// - Parameter searchController: The UISearchController object used as the search bar.
    public func updateSearchResults(for searchController: UISearchController) {
        userRequest = UsersRequest.UsersRequestBuilder(limit: 20).set(searchKeyword: searchController.searchBar.text ?? "").build()
        userRequest.fetchNext(onSuccess: { (users) in
            if users.count != 0 {
            self.filteredUsers = users
            DispatchQueue.main.async(execute: {self.tableView.reloadData()})
            }
        }) { (error) in
        }
    }
}

/*  ----------------------------------------------------------------------------------------- */

