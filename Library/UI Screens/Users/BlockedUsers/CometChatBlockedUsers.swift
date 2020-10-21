
//  CometChatBlockedUsers.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks

import UIKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */

class CometChatBlockedUsers: UIViewController {
    
    // MARK: - Declaration of Variables
    
    var blockedUsers:[User] = [User]()
    var blockedUserRequest = BlockedUserRequest.BlockedUserRequestBuilder(limit: 20).build()
    var tableView: UITableView! = nil
    var safeArea: UILayoutGuide!
    var activityIndicator:UIActivityIndicatorView?
    var sectionTitle : UILabel?
    var sectionsArray = [String]()
    
    
    // MARK: - View controller lifecycle methods
    
    override public func loadView() {
        super.loadView()
       
        view.backgroundColor = .white
        safeArea = view.layoutMarginsGuide
        self.setupTableView()
        self.setupNavigationBar()
        self.fetchBlockedUsers()
        self.set(title: NSLocalizedString("BLOCKED_USERS", bundle: UIKitSettings.bundle, comment: ""), mode: .automatic)
    }
    
    
    // MARK: - Public instance methods
    
    /**
     This method specifies the navigation bar title for CometChatBlockedUsers.
     - Parameters:
     - title: This takes the String to set title for CometChatGroupList.
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
        }
    }
    
    /**
     This method specifies the navigation bar color for CometChatBlockedUsers.
     - Parameters:
     - barColor: This takes color for Navigation bar background.
     - titleColor: This takes color for Navigation bar title.
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
     This method setup the tableview to load CometChatBlockedUsers.
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
        tableView.isEditing = true
        let UserView  = UINib.init(nibName: "CometChatUserView", bundle: UIKitSettings.bundle)
        self.tableView.register(UserView, forCellReuseIdentifier: "userView")
    }
    
    /**
     This method setup the navigation bar in CometChatBlockedUsers.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
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
            self.setLargeTitleDisplayMode(.always)
        }
    }
    
    
    /**
     This method fetches the list of blocked users using `BlockedUserRequest`.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
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
            DispatchQueue.main.async {
                    if let errorMessage = error?.errorDescription {
                       let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: errorMessage, duration: .short)
                        snackbar.show()
                    }
                self.activityIndicator?.stopAnimating()
                self.tableView.tableFooterView?.isHidden = true
            }
        })
    }
}

/*  ----------------------------------------------------------------------------------------- */

// MARK: - Table view Methods

extension CometChatBlockedUsers: UITableViewDelegate , UITableViewDataSource {
    
    
    /// This method specifies the number of sections to display list of blocked users.
    /// - Parameter tableView: An object representing the table view requesting this information.
    public func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    /// This method specifiesnumber of rows in CometChatBlockedUsers
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blockedUsers.count
    }
    
    /// This method specifies the height for row in CometChatBlockedUsers
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView.
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    /// This method specifies the view for user  in CometChatBlockedUsers
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView.
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = blockedUsers[safe:indexPath.row]
        let blockedUserCell = tableView.dequeueReusableCell(withIdentifier: "userView", for: indexPath) as! CometChatUserView
        blockedUserCell.user = user
        return blockedUserCell
    }
    
    /// This method loads the upcoming blocked users coming inside the tableview
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - indexPath: specifies current index for TableViewCell.
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex {
            self.fetchBlockedUsers()
        }
    }
    
    
    /// This method enables tableview cell to edit mode.
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - indexPath: specifies current index for TableViewCell.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    /// This method denotes the title for delete action in tableview cell
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - indexPath: specifies current index for TableViewCell.
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String?
    {
        return NSLocalizedString("UNBLOCK", bundle: UIKitSettings.bundle, comment: "")
    }
    
    
    /// This method performs action on button pressed in Editing style mode.
    /// - Parameters:
    /// This method denotes the title for delete action in tableview cell
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - editingStyle: The editing control used by a cell.
    ///   - indexPath: specifies current index for TableViewCell.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatUserView {
                CometChat.unblockUsers([(selectedCell.user?.uid ?? "")], onSuccess: { (success) in
                    
                    DispatchQueue.main.async {
                        self.blockedUsers.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                        
                        if let name = selectedCell.user?.name {
                            let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "\(name)" + NSLocalizedString("UNBLOCKED_SUCCESSFULLY", bundle: UIKitSettings.bundle, comment: ""), duration: .short)
                            snackbar.show()
                        }
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didUserBlocked"), object: nil, userInfo: ["count": "\(self.blockedUsers.count)"])
                        
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
        }
    }
    
    
    /// This method triggers when particular cell is clicked by the user .
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - indexPath: specifies current index for TableViewCell.
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
    }
}

/*  ----------------------------------------------------------------------------------------- */
