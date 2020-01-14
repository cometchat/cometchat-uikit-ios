//
//  CometChatBlockedUsers.swift
//  ios-chat-uikit-app
//
//  Created by Pushpsen Airekar on 08/01/20.
//  Copyright © 2020 Pushpsen Airekar. All rights reserved.
//

import UIKit
import CometChatPro

class CometChatBlockedUsers: UIViewController {
    
    var blockedUsers:[User] = [User]()
    var blockedUserRequest = BlockedUserRequest.BlockedUserRequestBuilder(limit: 20).build()
    var tableView: UITableView! = nil
    var safeArea: UILayoutGuide!
    var activityIndicator:UIActivityIndicatorView?
    var sectionTitle : UILabel?
    var sectionsArray = [String]()
    
    
    override public func loadView() {
        super.loadView()
        UIFont.loadAllFonts(bundleIdentifierString: Bundle.main.bundleIdentifier ?? "")
        view.backgroundColor = .white
        safeArea = view.layoutMarginsGuide
        self.setupTableView()
        self.setupNavigationBar()
        self.fetchBlockedUsers()
        self.set(title: "Blocked Users", mode: .automatic)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        
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
        tableView.isEditing = true
        let UserView  = UINib.init(nibName: "CometChatUserView", bundle: nil)
        self.tableView.register(UserView, forCellReuseIdentifier: "userView")
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
            self.setLargeTitleDisplayMode(.always)
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
    
    private func fetchBlockedUsers(){
        activityIndicator?.startAnimating()
        activityIndicator?.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
        tableView.tableFooterView = activityIndicator
        tableView.tableFooterView = activityIndicator
        tableView.tableFooterView?.isHidden = false
        
        blockedUserRequest.fetchNext(onSuccess: { (blockedUsers) in
            if let users =  blockedUsers {
                self.blockedUsers.append(contentsOf: users)
                
                if users.count != 0{
                    DispatchQueue.main.async {
                                       self.activityIndicator?.stopAnimating()
                                       self.tableView.tableFooterView?.isHidden = true
                                       self.tableView.reloadData()}
                }else{
                    DispatchQueue.main.async {
                      self.activityIndicator?.stopAnimating()
                       self.tableView.tableFooterView?.isHidden = true
                    }
                }
            }
           
        }, onError: { (error) in
            print("error while fetchBlockedUsers: \(String(describing: error?.errorDescription))")
            DispatchQueue.main.async {
                                 self.activityIndicator?.stopAnimating()
                                  self.tableView.tableFooterView?.isHidden = true
                               }
        })
    }
}


extension CometChatBlockedUsers: UITableViewDelegate , UITableViewDataSource {
    
    // MARK: - Table view data source
    public func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blockedUsers.count
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let user = blockedUsers[indexPath.row]
        let blockedUserCell = tableView.dequeueReusableCell(withIdentifier: "userView", for: indexPath) as! CometChatUserView
        blockedUserCell.user = user
        return blockedUserCell
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex {
            self.fetchBlockedUsers()
        }
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String?
    {
        return "Unblock"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatUserView {
                CometChat.unblockUsers([(selectedCell.user.uid ?? "")], onSuccess: { (success) in
                    
                    DispatchQueue.main.async {
                        self.blockedUsers.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                        
                        if let name = selectedCell.user.name {
                            self.view.makeToast("\(name) unblocked sucessfully.")
                        }
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didUserBlocked"), object: nil, userInfo: ["count": "\(self.blockedUsers.count)"])
                        
                    }
                }) { (error) in
                    print("error while unblockUsers: \(String(describing: error?.errorDescription))")
                    self.view.makeToast(error?.errorDescription)
                }
            }
        }
    }
    
    
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
    }
}


