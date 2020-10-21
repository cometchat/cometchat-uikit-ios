//  CometChatPrivacyAndSecurity.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.

import UIKit
import CometChatPro


/*  ----------------------------------------------------------------------------------------- */

class CometChatPrivacyAndSecurity: UIViewController {
    
    // MARK: - Declaration of Variables
    
    var tableView: UITableView! = nil
    var safeArea: UILayoutGuide!
    var privacy:[Int] = [Int]()
    var blockedUserRequest: BlockedUserRequest?
    var blockUsersCount: String = ""
    static let GROUP_CELL = 0
    static let CALLS_CELL = 1
    
      // MARK: - View controller lifecycle methods
    
    override public func loadView() {
        super.loadView()
       
        view.backgroundColor = .white
        safeArea = view.layoutMarginsGuide
        self.setupTableView()
        self.setupNavigationBar()
        self.setupItems()
        self.fetchBlockedUsersCount()
        self.addObservers()
        self.set(title: NSLocalizedString("PRIVACY_AND_SECURITY", bundle: UIKitSettings.bundle, comment: ""), mode: .automatic)
    }
    
    
    public override func viewWillAppear(_ animated: Bool) {
        self.addObservers()
    }
    
     // MARK: - Public instance methods
    
    
    /**
    This method specifies the navigation bar title for CometChatPrivacyAndSecurity.
    - Parameters:
    - title: This takes the String to set title for CometChatPrivacyAndSecurity.
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
    
    
     // MARK: - Private instance methods
    
    /**
    This method observes for perticular events such as `didUserBlocked` in CometChatPrivacyAndSecurity.
    - Author: CometChat Team
    - Copyright:  ©  2020 CometChat Inc.
    */
    fileprivate func addObservers(){
        
        NotificationCenter.default.addObserver(self, selector:#selector(self.didUserBlocked(_:)), name: NSNotification.Name(rawValue: "didUserBlocked"), object: nil)
    }
    
    /**
    This method triggeres when user is blocked.
    - Author: CometChat Team
    - Copyright:  ©  2020 CometChat Inc.
    */
    @objc func didUserBlocked(_ notification: NSNotification) {
        self.fetchBlockedUsersCount()
    }
    
    /**
       This method sets the list of items needs to be display in CometChatPrivacyAndSecurity.
       - Author: CometChat Team
       - Copyright:  ©  2020 CometChat Inc.
       */
    private func setupItems(){
        
        privacy = [CometChatPrivacyAndSecurity.GROUP_CELL,CometChatPrivacyAndSecurity.CALLS_CELL]
        
    }
    
    /**
        This method setup the tableview to load CometChatPrivacyAndSecurity.
        - Author: CometChat Team
        - Copyright:  ©  2020 CometChat Inc.
        */
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
        self.registerCells()
    }
    
    /**
    This method register the cells for CometChatPrivacyAndSecurity.
    - Author: CometChat Team
    - Copyright:  ©  2020 CometChat Inc.
    */
    private func registerCells(){
        let AdministratorView  = UINib.init(nibName: "AdministratorView", bundle: UIKitSettings.bundle)
        self.tableView.register(AdministratorView, forCellReuseIdentifier: "administratorView")
    }
    
    
    /**
        This method setup navigationBar for CometChatPrivacyAndSecurity viewController.
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
        }
    }
    

    /**
     This method fetches the blocked Users and diplay the count .
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
    private func fetchBlockedUsersCount(){
        blockedUserRequest = BlockedUserRequest.BlockedUserRequestBuilder(limit: 20).build()
        blockedUserRequest?.fetchNext(onSuccess: { (blockedUsers) in
            if let count =  blockedUsers?.count {
                if  count == 0 {
                    self.blockUsersCount =  NSLocalizedString("0_USERS", bundle: UIKitSettings.bundle, comment: "")
                }else if count > 0 && count < 100 {
                    self.blockUsersCount = "\(count) " + NSLocalizedString("USERS", bundle: UIKitSettings.bundle, comment: "")
                }else{
                    self.blockUsersCount = "100+ " + NSLocalizedString("USERS", bundle: UIKitSettings.bundle, comment: "")
                }
                DispatchQueue.main.async { self.tableView.reloadData() }
            }
        }, onError: { (error) in
            DispatchQueue.main.async {
                if let errorMessage = error?.errorDescription {
                     let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: errorMessage, duration: .short)
                     snackbar.show()
                }
            }
        })
    }
}

/*  ----------------------------------------------------------------------------------------- */

// MARK: - Table view Methods


extension CometChatPrivacyAndSecurity : UITableViewDelegate , UITableViewDataSource {
    
    /// This method specifies the number of sections to display list of items.
       /// - Parameter tableView: An object representing the table view requesting this information.
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    /// This method specifies height for section in CometChatPrivacyAndSecurity
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return 0
        }else{
            return 25
        }
    }
    
    /// This method specifies the view for header  in CometChatPrivacyAndSecurity
       /// - Parameters:
       ///   - tableView: The table-view object requesting this information.
       ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 25))
        let sectionTitle = UILabel(frame: CGRect(x: 10, y: 2, width: view.frame.size.width, height: 20))
        if section == 0 {
            sectionTitle.text =  ""
        }else if section == 1{
            sectionTitle.text =  NSLocalizedString("PRIVACY", bundle: UIKitSettings.bundle, comment: "")
        }
        sectionTitle.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        if #available(iOS 13.0, *) {
            sectionTitle.textColor = .lightGray
            returnedView.backgroundColor = .systemBackground
        } else {}
        returnedView.addSubview(sectionTitle)
        return returnedView
    }
    
    /// This method specifiesnumber of rows in CometChatPrivacyAndSecurity
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if UIKitSettings.blockUser == .disabled {
                 return 0
            }else{
                 return 1
            }
        case 1: return 0
        default: return 0 }
    }
    
    /// This method specifies the view for user  in CometChatPrivacyAndSecurity
       /// - Parameters:
       ///   - tableView: The table-view object requesting this information.
       ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    /// This method specifies the view for user  in CometChatPrivacyAndSecurity
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        if indexPath.section == 0 && indexPath.row == 0 {
            let blockedUserCell = tableView.dequeueReusableCell(withIdentifier: "administratorView", for: indexPath) as! AdministratorView
            blockedUserCell.title.text = NSLocalizedString("BLOCKED_USERS", bundle: UIKitSettings.bundle, comment: "")
            return blockedUserCell
        }else{
            switch privacy[safe:indexPath.row] {
            case CometChatPrivacyAndSecurity.GROUP_CELL:
                let groupsCell = tableView.dequeueReusableCell(withIdentifier: "administratorView", for: indexPath) as! AdministratorView
                groupsCell.title.text = NSLocalizedString("Groups", bundle: UIKitSettings.bundle, comment: "")
                return groupsCell
                
            case CometChatPrivacyAndSecurity.CALLS_CELL:
                let callsCell = tableView.dequeueReusableCell(withIdentifier: "administratorView", for: indexPath) as! AdministratorView
                callsCell.title.text = NSLocalizedString("CALLS", bundle: UIKitSettings.bundle, comment: "")
                return callsCell
            default: break
            }
        }
        return cell
    }
    
    /// This method triggers when particular cell is clicked by the user .
       /// - Parameters:
       ///   - tableView: The table-view object requesting this information.
       ///   - indexPath: specifies current index for TableViewCell.
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 && indexPath.row == 0 {
            let blockedUsers = CometChatBlockedUsers()
            self.navigationController?.pushViewController(blockedUsers, animated: true)
        }else{
            switch privacy[safe:indexPath.row] {
            case CometChatPrivacyAndSecurity.GROUP_CELL: break
            case CometChatPrivacyAndSecurity.CALLS_CELL: break
            default: break
            }
        }
    }
}
/*  ----------------------------------------------------------------------------------------- */
