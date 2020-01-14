//
//  CometChatListView.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 20/09/19.
//  Copyright © 2019 Pushpsen Airekar. All rights reserved.
//

import UIKit
import CometChatPro


enum Mode {
    case fetchGroupMembers
    case fetchAdministrators
}

public class CometChatAddAdministrators: UIViewController {
    
    var groupMembers:[GroupMember] = [GroupMember]()
    var administrators:[GroupMember] = [GroupMember]()
    var memberRequest: GroupMembersRequest?
    var tableView: UITableView! = nil
    var safeArea: UILayoutGuide!
    var activityIndicator:UIActivityIndicatorView?
    var sectionTitle : UILabel?
    var sectionsArray = [String]()
    var currentGroup: Group?
    var mode: Mode?
    
    
    override public func loadView() {
        super.loadView()
        UIFont.loadAllFonts(bundleIdentifierString: Bundle.main.bundleIdentifier ?? "")
        view.backgroundColor = .white
        safeArea = view.layoutMarginsGuide
        self.setupTableView()
        self.addObservers()
        self.setupNavigationBar()
        if let group = currentGroup {
            fetchAdmins(for: group)
        }
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        self.addObservers()
    }
    
    
    fileprivate func addObservers(){
        CometChat.groupdelegate = self
        NotificationCenter.default.addObserver(self, selector:#selector(self.didRefreshMembers(_:)), name: NSNotification.Name(rawValue: "didRefreshMembers"), object: nil)
    }
    
    @objc func didRefreshMembers(_ notification: NSNotification) {
        if let group = currentGroup {
            self.fetchAdmins(for: group)
        }
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
        
        let AddMemberView  = UINib.init(nibName: "AddMemberView", bundle: nil)
        self.tableView.register(AddMemberView, forCellReuseIdentifier: "addMemberView")
        
        let MembersView  = UINib.init(nibName: "MembersView", bundle: nil)
        self.tableView.register(MembersView, forCellReuseIdentifier: "membersView")
    }
    
    public func set(group: Group){
        
        guard group != nil else {
            return
        }
        self.currentGroup = group
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
            let closeButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeButtonPressed))
            self.navigationItem.rightBarButtonItem = closeButton
            
            switch mode {
            case .fetchGroupMembers: self.set(title: "Make Group Admin", mode: .automatic)
            case .fetchAdministrators: self.set(title: "Administrators", mode: .automatic)
            @unknown default: break }
            self.setLargeTitleDisplayMode(.always)
        }
    }
    
    
    @objc func closeButtonPressed(){
        self.dismiss(animated: true, completion: nil)
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
    
    private func fetchAdmins(for group: Group){
        
        DispatchQueue.main.async {
            self.activityIndicator?.startAnimating()
            self.activityIndicator?.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: self.tableView.bounds.width, height: CGFloat(44))
            self.tableView.tableFooterView = self.activityIndicator
            self.tableView.tableFooterView = self.activityIndicator
            self.tableView.tableFooterView?.isHidden = false
        }
        memberRequest = GroupMembersRequest.GroupMembersRequestBuilder(guid: currentGroup?.guid ?? "").set(limit: 100).build()
        memberRequest?.fetchNext(onSuccess: { (groupMembers) in
            
            self.groupMembers = groupMembers.filter {$0.scope == .participant}
            self.administrators = groupMembers.filter {$0.scope == .admin}
            DispatchQueue.main.async {
                self.activityIndicator?.stopAnimating()
                self.tableView.tableFooterView?.isHidden = true
                self.tableView.reloadData()
                self.tableView.tableFooterView?.isHidden = true}
        }, onError: { (error) in
            print("fetchAdmins error:\(String(describing: error?.errorDescription))")
        })
    }
    
    
}


extension CometChatAddAdministrators: UITableViewDelegate , UITableViewDataSource {
    
    // MARK: - Table view data source
    public func numberOfSections(in tableView: UITableView) -> Int {
        switch  mode {
        case .fetchGroupMembers:
            return 1
        case .fetchAdministrators:
            return 2
        case .none: break
        }
        return 0
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if mode == .fetchAdministrators {
            if section == 0 {
                return 1
            } else{
                return administrators.count
            }
        }else if mode == .fetchGroupMembers {
            return groupMembers.count
        }else { return 0 }
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 { return 20 } else { return 0 }
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        if mode == .fetchAdministrators {
            if indexPath.section == 0 {
                let addAdminCell = tableView.dequeueReusableCell(withIdentifier: "addMemberView", for: indexPath) as! AddMemberView
                addAdminCell.textLabel?.text = "Add Admin"
                return addAdminCell
            }else{
                let  admin = administrators[indexPath.row]
                let membersCell = tableView.dequeueReusableCell(withIdentifier: "membersView", for: indexPath) as! MembersView
                membersCell.member = admin
                if admin.uid == currentGroup?.owner {
                    membersCell.scope.text = "Owner"
                }
                return membersCell
            }
            
        }else if mode == .fetchGroupMembers {
            let  member =  groupMembers[indexPath.row]
            let membersCell = tableView.dequeueReusableCell(withIdentifier: "membersView", for: indexPath) as! MembersView
            membersCell.member = member
            return membersCell
        }
        return cell
    }
    
    
    @available(iOS 13.0, *)
    public func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in
            
            if self.mode == .fetchAdministrators {
                if indexPath.section == 0 &&  indexPath.row == 0 {
                    let addAdmins = CometChatAddAdministrators()
                    addAdmins.mode = .fetchGroupMembers
                    if let group = self.currentGroup {
                        addAdmins.set(group: group)
                    }
                    self.navigationController?.pushViewController(addAdmins, animated: true)
                }else{
                    
                    if  let selectedCell = tableView.cellForRow(at: indexPath) as? MembersView {
                        if let member = selectedCell.member{
                            let removeAdmin = UIAction(title: "Dismiss as Admin", image: UIImage(systemName: "trash"), attributes: .destructive) { action in
                                
                                CometChat.updateGroupMemberScope(UID: member.uid ?? "", GUID: self.currentGroup?.guid ?? "", scope: .participant, onSuccess: { (success) in
                                    
                                     NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didRefreshMembers"), object: nil, userInfo: ["guid":self.currentGroup?.guid ?? ""])
                                    
                                    DispatchQueue.main.async {
                                        if let group = self.currentGroup {
                                            self.fetchAdmins(for: group)
                                        }
                                    }
                                }) { (error) in
                                     DispatchQueue.main.async {
                                        self.view.makeToast(error?.errorDescription)}
                                    print("updateGroupMemberScope error: \(String(describing: error?.errorDescription))")
                                }
                                
                            }
                            let memberName = (tableView.cellForRow(at: indexPath) as? MembersView)?.member.name ?? ""
                            let groupName = self.currentGroup?.name ?? ""
                            
                            if self.currentGroup?.owner == CometChat.getLoggedInUser()?.uid {
                            
                            if member.uid != CometChat.getLoggedInUser()?.uid {
                                 return UIMenu(title: "⚠️ Remove \(memberName) as admin from \(groupName) group?" , children: [removeAdmin])
                            }
                            }
                        }
                    }
                }
            }else{
                
                
                if  let selectedCell = tableView.cellForRow(at: indexPath) as? MembersView {
                    
                    if let member = selectedCell.member {
                        let removeAdmin = UIAction(title: "Assign as Admin", image: UIImage(systemName: "add"), attributes: .destructive) { action in
                            
                            CometChat.updateGroupMemberScope(UID: member.uid ?? "", GUID: self.currentGroup?.guid ?? "", scope: .admin, onSuccess: { (success) in
                                
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didRefreshMembers"), object: nil, userInfo: ["guid":self.currentGroup?.guid ?? ""])
                                
                                DispatchQueue.main.async {
                                    if let group = self.currentGroup {
                                        self.fetchAdmins(for: group)
                                    }
                                }
                            }) { (error) in
                                 DispatchQueue.main.async {
                                    self.view.makeToast(error?.errorDescription)}
                                print("updateGroupMemberScope error: \(String(describing: error?.errorDescription))")
                            }
                            
                        }
                        let memberName = (tableView.cellForRow(at: indexPath) as? MembersView)?.member.name ?? ""
                        let groupName = self.currentGroup?.name ?? ""
                        return UIMenu(title: "✅ Add \(memberName) as admin in \(groupName) group?" , children: [removeAdmin])
                        
                    }
                }
                
            }
            return UIMenu(title: "")
        })
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)


        if mode == .fetchAdministrators {
            if indexPath.section == 0 &&  indexPath.row == 0 {
                let addAdmins = CometChatAddAdministrators()
                addAdmins.mode = .fetchGroupMembers
                guard let group = currentGroup else { return }
                addAdmins.set(group: group)
                self.navigationController?.pushViewController(addAdmins, animated: true)
            }else{
            }
//                if  let selectedCell = tableView.cellForRow(at: indexPath) as? MembersView {
//
//                    if let member = selectedCell.member {
//                        let alert = UIAlertController(title: "⚠️ Remove", message: "Remove \(String(describing: member.name!.capitalized)) as a Admin.", preferredStyle: .alert)
//
//                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
//
//                            CometChat.updateGroupMemberScope(UID: member.uid ?? "", GUID: self.currentGroup?.guid ?? "", scope: .participant, onSuccess: { (success) in
//
//                                DispatchQueue.main.async {
//                                    if let group = self.currentGroup {
//                                        self.fetchAdmins(for: group)
//                                    }
//                                }
//                            }) { (error) in
//                                print("updateGroupMemberScope error: \(String(describing: error?.errorDescription))")
//                            }
//                        }))
//                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
//                        }))
//                        self.present(alert, animated: true)
//                    }
//                }
//            }
//        }else{
//
//            if  let selectedCell = tableView.cellForRow(at: indexPath) as? MembersView {
//
//                if let member = selectedCell.member {
//                    let alert = UIAlertController(title: "✅ Add", message: "Add \(String(describing: member.name!.capitalized)) as a Admin.", preferredStyle: .alert)
//
//                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
//
//                        CometChat.updateGroupMemberScope(UID: member.uid ?? "", GUID: self.currentGroup?.guid ?? "", scope: .admin, onSuccess: { (success) in
//
//                            DispatchQueue.main.async {
//                                self.navigationController?.popViewController(animated: true)
//                                self.mode = .fetchGroupMembers
//
//                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didRefreshMembers"), object: nil, userInfo: nil)
//
//                            }
//                        }) { (error) in
//                            print("updateGroupMemberScope error: \(String(describing: error?.errorDescription))")
//                        }
//                    }))
//                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
//                    }))
//                    self.present(alert, animated: true)
//                }
          }
        }
    }
    


extension CometChatAddAdministrators: CometChatGroupDelegate {
    
    public func onGroupMemberJoined(action: ActionMessage, joinedUser: User, joinedGroup: Group) {
        if let group = currentGroup {
            if group == joinedGroup {
                fetchAdmins(for: group)
            }
        }
    }
    
    public func onGroupMemberLeft(action: ActionMessage, leftUser: User, leftGroup: Group) {
        if let group = currentGroup {
            if group == leftGroup {
                fetchAdmins(for: group)
            }
        }
    }
    
    public func onGroupMemberKicked(action: ActionMessage, kickedUser: User, kickedBy: User, kickedFrom: Group) {
        if let group = currentGroup {
            if group == kickedFrom {
                fetchAdmins(for: group)
            }
        }
    }
    
    public func onGroupMemberBanned(action: ActionMessage, bannedUser: User, bannedBy: User, bannedFrom: Group) {
        if let group = currentGroup {
            if group == bannedFrom {
                fetchAdmins(for: group)
            }
        }
    }
    
    public func onGroupMemberUnbanned(action: ActionMessage, unbannedUser: User, unbannedBy: User, unbannedFrom: Group) {
        if let group = currentGroup {
            if group == unbannedFrom {
                fetchAdmins(for: group)
            }
        }
    }
    
    public func onGroupMemberScopeChanged(action: ActionMessage, scopeChangeduser: User, scopeChangedBy: User, scopeChangedTo: String, scopeChangedFrom: String, group: Group) {
        if let group = currentGroup {
            if group == group {
                fetchAdmins(for: group)
            }
        }
    }
    
    public func onMemberAddedToGroup(action: ActionMessage, addedBy: User, addedUser: User, addedTo: Group) {
        if let group = currentGroup {
            if group == group {
                fetchAdmins(for: group)
            }
        }
    }
}
