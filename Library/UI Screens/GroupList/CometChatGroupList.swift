//
//  CometChatListView.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 20/09/19.
//  Copyright © 2019 Pushpsen Airekar. All rights reserved.
//

import UIKit
import CometChatPro


public protocol GroupListDelegate {
    func didSelectGroupAtIndexPath(group: Group, indexPath: IndexPath)
}

public class CometChatGroupList: UIViewController, CometChatMessageDelegate {
    
    var groupRequest = GroupsRequest.GroupsRequestBuilder(limit: 20).build()
    var tableView: UITableView! = nil
    var safeArea: UILayoutGuide!
    var groups: [Group] = [Group]()
    var filteredGroups: [Group] = [Group]()
    var delegate: GroupListDelegate?
    var storedVariable: String?
    var activityIndicator:UIActivityIndicatorView?
    var searchController:UISearchController = UISearchController(searchResultsController: nil)
    
    override public func loadView() {
        super.loadView()
        UIFont.loadAllFonts(bundleIdentifierString: Bundle.main.bundleIdentifier ?? "")
        view.backgroundColor = .white
        safeArea = view.layoutMarginsGuide
        self.setupTableView()
        self.setupSearchBar()
        self.setupNavigationBar()
        self.setupDelegates()
        fetchGroups()
    }
    
    
    public func setupDelegates(){
        CometChat.messagedelegate = self
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        setupDelegates()
    }
    
    func setupTableView() {
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
        let CometChatGroupView  = UINib.init(nibName: "CometChatGroupView", bundle: nil)
        self.tableView.register(CometChatGroupView, forCellReuseIdentifier: "groupView")
    }
    
    private func setupNavigationBar(){
           if navigationController != nil{
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
           }
       }
    
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
           }
       }
       
       func setupSearchBar(){
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
    
    internal func fetchGroups(){
        activityIndicator?.startAnimating()
               activityIndicator?.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
               tableView.tableFooterView = activityIndicator
               tableView.tableFooterView = activityIndicator
               tableView.tableFooterView?.isHidden = false
            groupRequest.fetchNext(onSuccess: { (groups) in
            print("fetchGroups onSuccess: \(groups)")
                if groups.count != 0{
                self.groups.append(contentsOf: groups)
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
            print("fetchGroups error:\(String(describing: error?.errorDescription))")
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
    
    public func onTypingStarted(_ typingDetails: TypingIndicator) {
            if let row = self.groups.firstIndex(where: {$0.guid == typingDetails.receiverID}) {
                       let indexPath = IndexPath(row: row, section: 0)
                      DispatchQueue.main.async {
                          let cell = self.tableView.cellForRow(at: indexPath) as! CometChatGroupView
                          self.storedVariable = cell.groupDetails.text
                          let user = typingDetails.sender?.name
                          cell.typing.text = user! + " is typing..."
                          if cell.groupDetails.isHidden == false{
                              cell.typing.isHidden = false
                              cell.groupDetails.isHidden = true
                          }
                          cell.reloadInputViews()
                      }
       }
    }
       
    public func onTypingEnded(_ typingDetails: TypingIndicator) {
             if let row = self.groups.firstIndex(where: {$0.guid == typingDetails.receiverID}) {
                                  let indexPath = IndexPath(row: row, section: 0)
                                 DispatchQueue.main.async {
                                     let cell = self.tableView.cellForRow(at: indexPath) as! CometChatGroupView
                                    if cell.typing.isHidden == false{
                                         cell.groupDetails.isHidden = false
                                         cell.typing.isHidden = true
                                     }
                                     cell.reloadInputViews()
                                 }
       }
        }

  
}

// MARK: - UISearchResultsUpdating Delegate
extension CometChatGroupList : UISearchBarDelegate, UISearchResultsUpdating {
    
    public func updateSearchResults(for searchController: UISearchController) {
        groupRequest  = GroupsRequest.GroupsRequestBuilder(limit: 20).set(searchKeyword: searchController.searchBar.text ?? "").build()
        groupRequest.fetchNext(onSuccess: { (groups) in
            print("fetchGroups onSuccess: \(groups)")
               if groups.count != 0{
               self.filteredGroups = groups
               DispatchQueue.main.async {self.tableView.reloadData()}
                }
        }) { (error) in
            print("fetchGroups error:\(String(describing: error?.errorDescription))")
        }
       
    }
}

extension CometChatGroupList: UITableViewDelegate , UITableViewDataSource {
    
    // MARK: - Table view data source
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isSearching(){
            return filteredGroups.count
        }else{
           return groups.count
        }
        
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
          return 0
      }
      
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
          let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 0.5))
              return returnedView
         }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
       guard let selectedGroup = tableView.cellForRow(at: indexPath) as? CometChatGroupView else{
           return
       }
        delegate?.didSelectGroupAtIndexPath(group: selectedGroup.group!, indexPath: indexPath)
        
        if selectedGroup.group.hasJoined == false{
            CometChat.joinGroup(GUID: selectedGroup.group.guid, groupType: selectedGroup.group.groupType, password: "", onSuccess: { (group) in
                    DispatchQueue.main.async {
                        self.tableView.deselectRow(at: indexPath, animated: true)
                        let messageList = CometChatMessageList()
                        messageList.set(conversationWith: group, type: .group)
                        messageList.hidesBottomBarWhenPushed = true
                        self.navigationController?.pushViewController(messageList, animated: true)
                    }
                    
                }) { (error) in
                }
            }else{
                tableView.deselectRow(at: indexPath, animated: true)
                let messageList = CometChatMessageList()
                messageList.set(conversationWith: selectedGroup.group, type: .group)
                messageList.hidesBottomBarWhenPushed = true
               navigationController?.pushViewController(messageList, animated: true)
            }
        }
       
    
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
           let lastSectionIndex = tableView.numberOfSections - 1
           let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
           if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex {
               
               self.fetchGroups()
           }
       }
    

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupView", for: indexPath) as! CometChatGroupView
        let group: Group?
        
        if isSearching() {
            group = filteredGroups[indexPath.row]
        }else{
           group = groups[indexPath.row]
        }
        cell.group = group
        return cell
    }

}
