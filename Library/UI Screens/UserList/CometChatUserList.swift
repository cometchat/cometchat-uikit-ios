//
//  CometChatListView.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 20/09/19.
//  Copyright © 2019 Pushpsen Airekar. All rights reserved.
//

import UIKit
import CometChatPro

public protocol UserListDelegate {
    func didSelectUserAtIndexPath(user: User, indexPath: IndexPath)
}

public class CometChatUserList: UIViewController{
    
    var userRequest = UsersRequest.UsersRequestBuilder(limit: 20).build()
    var tableView: UITableView! = nil
    var safeArea: UILayoutGuide!
    var users: [User] = [User]()
    var filteredUsers: [User] = [User]()
    var delegate : UserListDelegate?
    var activityIndicator:UIActivityIndicatorView?
    var searchController:UISearchController = UISearchController(searchResultsController: nil)
    var sectionTitle : UILabel?
    var sectionsArray = [String]()
    
    override public func loadView() {
        super.loadView()
        UIFont.loadAllFonts(bundleIdentifierString: Bundle.main.bundleIdentifier ?? "")
        view.backgroundColor = .white
        safeArea = view.layoutMarginsGuide
        self.setupTableView()
        self.setupSearchBar()
        self.setupNavigationBar()
        self.fetchUsers()
        print(#function)
    }
    
    private func setupTableView() {
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
            activityIndicator = UIActivityIndicatorView(style: .medium)
        } else {}
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
        let CometChatUserView  = UINib.init(nibName: "CometChatUserView", bundle: nil)
        self.tableView.register(CometChatUserView, forCellReuseIdentifier: "userView")
    }
    
    private func setupNavigationBar(){
        if navigationController != nil{
            // NavigationBar Appearance
            if #available(iOS 13.0, *) {
                let navBarAppearance = UINavigationBarAppearance()
                navBarAppearance.configureWithOpaqueBackground()
               navBarAppearance.titleTextAttributes = [.font: UIFont (name: "SFProDisplay-Regular", size: 20) as Any]
                navBarAppearance.largeTitleTextAttributes = [.font: UIFont(name: "SFProDisplay-Bold", size: 35) as Any]
                navBarAppearance.shadowColor = .clear
                navigationController?.navigationBar.standardAppearance = navBarAppearance
                navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
                self.navigationController?.navigationBar.isTranslucent = true
            }
        }}
    
    @objc public func set(title : String, mode: UINavigationItem.LargeTitleDisplayMode){
       if navigationController != nil{
        navigationItem.title = NSLocalizedString(title, comment: "")
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
    
    @objc public func set(barColor :UIColor, titleColor color: UIColor){
     if navigationController != nil{
               // NavigationBar Appearance
               if #available(iOS 13.0, *) {
                   let navBarAppearance = UINavigationBarAppearance()
                   navBarAppearance.configureWithOpaqueBackground()
                  navBarAppearance.titleTextAttributes = [ .foregroundColor: color,.font: UIFont (name: "SFProDisplay-Regular", size: 20) as Any]
                   navBarAppearance.largeTitleTextAttributes = [.foregroundColor: color, .font: UIFont(name: "SFProDisplay-Bold", size: 35) as Any]
                   navBarAppearance.shadowColor = .clear
                   navBarAppearance.backgroundColor = barColor
                   navigationController?.navigationBar.standardAppearance = navBarAppearance
                   navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
                   self.navigationController?.navigationBar.isTranslucent = true
               }
           }
    }
    
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
    
    private func fetchUsers(){
        activityIndicator?.startAnimating()
        activityIndicator?.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
        tableView.tableFooterView = activityIndicator
        tableView.tableFooterView = activityIndicator
        tableView.tableFooterView?.isHidden = false
        userRequest.fetchNext(onSuccess: { (users) in
            print("fetchUsers onSuccess: \(users)")
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
            print("fetchUsers error:\(String(describing: error?.errorDescription))")
        }
    }
    
    // MARK: - Private instance methods
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isSearching() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
}


extension CometChatUserList: UITableViewDelegate , UITableViewDataSource {
    
    // MARK: - Table view data source
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
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isSearching(){
            return 0
        }else{
            return 25
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isSearching(){
            return filteredUsers.count
        }else{
            return users.count
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if isSearching() {
            let user = filteredUsers[indexPath.row]
            if sectionsArray[indexPath.section] == user.name?.first?.uppercased(){
                return 60
            }else{
                return 0
            }
        }else{
            let user = users[indexPath.row]
            if sectionsArray[indexPath.section] == user.name?.first?.uppercased(){
                return 60
            }else{
                return 0
            }
        }
    }
    
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = UITableViewCell()
        var user: User?
        
        if isSearching() {
            user = filteredUsers[indexPath.row]
        } else {
            user = users[indexPath.row]
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
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex {
            self.fetchUsers()
        }
    }
    
    public func tableView(_ tableView: UITableView,
                          sectionForSectionIndexTitle title: String,
                          at index: Int) -> Int{
        return index
    }
    
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


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// MARK: - UISearchResultsUpdating Delegate
extension CometChatUserList : UISearchBarDelegate, UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {
        userRequest = UsersRequest.UsersRequestBuilder(limit: 20).set(searchKeyword: searchController.searchBar.text ?? "").build()
        userRequest.fetchNext(onSuccess: { (users) in
            if users.count != 0 {
            self.filteredUsers = users
            DispatchQueue.main.async(execute: {self.tableView.reloadData()})
            }
        }) { (error) in
            print("error while searching users: \(String(describing: error?.errorDescription))")
        }
    }
}

