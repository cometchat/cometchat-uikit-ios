//
//  CometChatPrivacyAndSecurity.swift
//  ios-chat-uikit-app
//
//  Created by Pushpsen Airekar on 08/01/20.
//  Copyright © 2020 Pushpsen Airekar. All rights reserved.
//

import UIKit
import CometChatPro

class CometChatPrivacyAndSecurity: UIViewController {
    
    var tableView: UITableView! = nil
    var safeArea: UILayoutGuide!
    var privacy:[Int] = [Int]()
    var blockedUserRequest: BlockedUserRequest?
    var blockUsersCount: String = ""
    static let GROUP_CELL = 0
    static let CALLS_CELL = 1
    
    override public func loadView() {
        super.loadView()
        UIFont.loadAllFonts(bundleIdentifierString: Bundle.main.bundleIdentifier ?? "")
        view.backgroundColor = .white
        safeArea = view.layoutMarginsGuide
        self.setupTableView()
        self.setupNavigationBar()
        self.setupSettingsItems()
        self.fetchBlockedUsersCount()
        self.addObservers()
        self.set(title: "Privacy and Security", mode: .automatic)
    }
    
    
    public override func viewWillAppear(_ animated: Bool) {
        self.addObservers()
    }
    
    fileprivate func addObservers(){
        
        NotificationCenter.default.addObserver(self, selector:#selector(self.didUserBlocked(_:)), name: NSNotification.Name(rawValue: "didUserBlocked"), object: nil)
    }
    
    @objc func didUserBlocked(_ notification: NSNotification) {
        self.fetchBlockedUsersCount()
    }
    
    
    private func setupSettingsItems(){
        
        privacy = [CometChatPrivacyAndSecurity.GROUP_CELL,CometChatPrivacyAndSecurity.CALLS_CELL]
        
    }
    
    private func setupTableView() {
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
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
        
        let AdministratorView  = UINib.init(nibName: "AdministratorView", bundle: nil)
        self.tableView.register(AdministratorView, forCellReuseIdentifier: "administratorView")
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
    
    private func fetchBlockedUsersCount(){
        blockedUserRequest = BlockedUserRequest.BlockedUserRequestBuilder(limit: 20).build()
        blockedUserRequest?.fetchNext(onSuccess: { (blockedUsers) in
            if let count =  blockedUsers?.count {
                if  count == 0 {
                    self.blockUsersCount = "0 Users"
                }else if count > 0 && count < 100 {
                    self.blockUsersCount = "\(count) users"
                }else{
                    self.blockUsersCount = "100+ users"
                }
                DispatchQueue.main.async { self.tableView.reloadData() }
            }
        }, onError: { (error) in
            print("error while fetchBlockedUsersCount: \(String(describing: error?.errorDescription))")
        })
    }
}


extension CometChatPrivacyAndSecurity : UITableViewDelegate , UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return 0
        }else{
            return 25
        }
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 25))
        let sectionTitle = UILabel(frame: CGRect(x: 10, y: 2, width: view.frame.size.width, height: 20))
        if section == 0 {
            sectionTitle.text =  ""
        }else if section == 1{
            sectionTitle.text =  "PRIVACY"
        }
        sectionTitle.font = UIFont(name: "SFProDisplay-Medium", size: 13)
        if #available(iOS 13.0, *) {
            sectionTitle.textColor = .lightGray
            returnedView.backgroundColor = .systemBackground
        } else {}
        returnedView.addSubview(sectionTitle)
        return returnedView
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return privacy.count
        default: return 0 }
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        
        if indexPath.section == 0 && indexPath.row == 0 {
            let blockedUserCell = tableView.dequeueReusableCell(withIdentifier: "administratorView", for: indexPath) as! AdministratorView
            blockedUserCell.title.text = "Blocked Users"
            blockedUserCell.adminCount.text =  blockUsersCount
            return blockedUserCell
        }else{
            switch privacy[indexPath.row] {
            case CometChatPrivacyAndSecurity.GROUP_CELL:
                let groupsCell = tableView.dequeueReusableCell(withIdentifier: "administratorView", for: indexPath) as! AdministratorView
                groupsCell.title.text = "Groups"
                groupsCell.adminCount.text = "Everybody"
                return groupsCell
                
            case CometChatPrivacyAndSecurity.CALLS_CELL:
                let callsCell = tableView.dequeueReusableCell(withIdentifier: "administratorView", for: indexPath) as! AdministratorView
                callsCell.title.text = "Calls"
                callsCell.adminCount.text = "Everybody"
                return callsCell
            default: break
            }
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 && indexPath.row == 0 {
            let blockedUsers = CometChatBlockedUsers()
            self.navigationController?.pushViewController(blockedUsers, animated: true)
        }else{
            switch privacy[indexPath.row] {
            case CometChatPrivacyAndSecurity.GROUP_CELL: break
            case CometChatPrivacyAndSecurity.CALLS_CELL: break
            default: break
            }
        }
    }
    
}
