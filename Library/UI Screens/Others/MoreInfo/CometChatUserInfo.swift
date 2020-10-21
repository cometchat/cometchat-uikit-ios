
//  CometChatUserInfo.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.

import UIKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */

public class CometChatUserInfo: UIViewController {
    
    // MARK: - Declaration of Variables
    
    var tableView: UITableView! = nil
    var safeArea: UILayoutGuide!
    var preferances:[Int] = [Int]()
    var others:[Int] = [Int]()
    
    static let VIEW_PROFILE_CELL = 0
    static let PRIVACY_AND_SECURITY_CELL = 1
    
    
    // MARK: - View controller lifecycle methods
    
    override public func loadView() {
        super.loadView()
       
        view.backgroundColor = .white
        safeArea = view.layoutMarginsGuide
        self.setupTableView()
        self.setupNavigationBar()
        self.setupItems()
    }
    
    // MARK: - Public instance methods
    
    
    /**
     This method specifies the navigation bar title for CometChatUserInfo.
     - Parameters:
     - title: This takes the String to set title for CometChatUserInfo.
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
     This method updates the user information
     - Parameters:
     - title: This takes the String to set title for CometChatUserInfo.
     - mode: This specifies the TitleMode such as :
     * .automatic : Automatically use the large out-of-line title based on the state of the previous item in the navigation bar.
     *  .never: Never use a larger title when this item is topmost.
     * .always: Always use a larger title when this item is topmost.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
      public func updateUserInformation(withName: String?) {
          guard let name = withName else { return }
          guard let uid = CometChat.getLoggedInUser()?.uid else { return }
          
          DispatchQueue.main.async {
              let alert = UIAlertController(title: nil, message: "Updating...", preferredStyle: .alert)
              let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
              loadingIndicator.hidesWhenStopped = true
              loadingIndicator.style = UIActivityIndicatorView.Style.gray
              loadingIndicator.startAnimating()
              alert.view.addSubview(loadingIndicator)
              self.present(alert, animated: true, completion: nil)
          }
          let user = User(uid: uid, name: name)
          CometChat.updateUser(user: user, apiKey: "Constants.apiKey", onSuccess: { (user) in
              DispatchQueue.main.async {
                  self.dismiss(animated: true, completion: nil)
                  self.tableView.reloadData()
              }
          }) { (error) in
              DispatchQueue.main.async {
                  self.dismiss(animated: true, completion: nil)
                  if let errorMessage = error?.errorDescription {
                      let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: errorMessage, duration: .short)
                      snackbar.show()
                  }
              }
          }
      }
    
    // MARK: - Private instance methods
    
    /**
     This method sets the list of items needs to be display in CometChatUserInfo.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
    private func setupItems(){
        preferances = [ CometChatUserInfo.PRIVACY_AND_SECURITY_CELL]
    }
    
    /**
     This method setup the tableview to load CometChatUserInfo.
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
     This method register the cells for CometChatUserInfo.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
    private func registerCells(){
        let CometChatUserView  = UINib.init(nibName: "CometChatUserView", bundle: UIKitSettings.bundle)
        self.tableView.register(CometChatUserView, forCellReuseIdentifier: "userView")
        
        let CometChatSettingsView  = UINib.init(nibName: "CometChatSettingsView", bundle: UIKitSettings.bundle)
        self.tableView.register(CometChatSettingsView, forCellReuseIdentifier: "cometChatSettingsView")
    }
    
    /**
     This method setup navigationBar for CometChatUserInfo viewController.
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
}

/*  ----------------------------------------------------------------------------------------- */

// MARK: - Table view Methods

extension CometChatUserInfo: UITableViewDelegate , UITableViewDataSource {
    
    /// This method specifies the number of sections to display list of items.
    /// - Parameter tableView: An object representing the table view requesting this information.
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    /// This method specifies height for section in CometChatUserInfo
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
    
    /// This method specifies the view for header  in CometChatUserInfo
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 25))
        let sectionTitle = UILabel(frame: CGRect(x: 10, y: 2, width: view.frame.size.width, height: 20))
        if section == 0 {
            sectionTitle.text =  ""
        }else if section == 1{
            sectionTitle.text =  NSLocalizedString("PREFERENCES", bundle: UIKitSettings.bundle, comment: "")
        }else if section == 2{
            sectionTitle.text =  ""
        }
        sectionTitle.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        if #available(iOS 13.0, *) {
            sectionTitle.textColor = .lightGray
            returnedView.backgroundColor = .systemBackground
        } else {}
        returnedView.addSubview(sectionTitle)
        return returnedView
    }
    
    /// This method specifiesnumber of rows in CometChatUserInfo
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if  section == 0 {
            return 1
        }else if section == 1{
            return preferances.count
        }else if section == 2 {
            return others.count
        }else{
            return 0
        }
    }
    
    /// This method specifies the view for user  in CometChatUserInfo
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if  indexPath.section == 0 {
            return 140
        }else if indexPath.section == 1{
            return 60
        }else if indexPath.section == 2 {
            return 60
        }else{
            return 0
        }
    }
    
    /// This method specifies the view for user  in CometChatUserInfo
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = UITableViewCell()
        if indexPath.section == 0 && indexPath.row == 0 {
            let userCell = tableView.dequeueReusableCell(withIdentifier: "userView", for: indexPath) as! CometChatUserView
            userCell.avatarWidth.constant = 80
            userCell.avatarHeight.constant = 80
            userCell.userAvatar.cornerRadius = 40
            userCell.delegate = self
            userCell.editInfo.isHidden = false
            userCell.userName.font =  UIFont.systemFont(ofSize: 22, weight: .bold)
            userCell.userStatus.font =  UIFont.systemFont(ofSize: 15, weight: .regular)
            userCell.user = CometChat.getLoggedInUser()
            userCell.userStatus.isHidden = false
            userCell.userStatus.text = NSLocalizedString("ONLINE", bundle: UIKitSettings.bundle, comment: "")
            userCell.separatorInset = UIEdgeInsets(top: 0, left: tableView.frame.size.width, bottom: 0, right: 0)
            return userCell
            
        }else if indexPath.section == 1{
            
            let settingsCell = tableView.dequeueReusableCell(withIdentifier: "cometChatSettingsView", for: indexPath) as! CometChatSettingsView
            
            switch preferances[safe:indexPath.row] {
                
            case CometChatUserInfo.PRIVACY_AND_SECURITY_CELL:
                settingsCell.settingsName.text = NSLocalizedString(
                    "PRIVACY_&_SECURITY", bundle: UIKitSettings.bundle, comment: "")
                settingsCell.settingsIcon.image = UIImage(named: "􀉼", in: UIKitSettings.bundle, compatibleWith: nil)
                return settingsCell
            default:
                break
            }
        }else if indexPath.section == 2{
            
            let settingsCell = tableView.dequeueReusableCell(withIdentifier: "cometChatSettingsView", for: indexPath) as! CometChatSettingsView
            switch others[safe:indexPath.row] {
            default:
                break
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
        
        if indexPath.section == 1{
            switch preferances[safe:indexPath.row] {
                
            case CometChatUserInfo.PRIVACY_AND_SECURITY_CELL:
                let privacyAndSeciruty = CometChatPrivacyAndSecurity()
                navigationController?.pushViewController(privacyAndSeciruty, animated: true)
                
            default: break }
        }else if indexPath.section == 2{
            
        }
        
    }
}


/*  ----------------------------------------------------------------------------------------- */


extension CometChatUserInfo: CometChatUserViewDelegate {
    
    
    func didEditInfoPressed() {
        
        let alert = UIAlertController(title: "Update Information", message: "\nAre you sure you want to update the user information?", preferredStyle: .alert)
        let save = UIAlertAction(title: "Update", style: .default) { (alertAction) in
            let textField = alert.textFields![0] as UITextField
            if textField.text != "" {
                self.updateUserInformation(withName: textField.text)
            } else {
                self.showAlert(title: "Warning!", msg: "User name cannot be empty.")
            }
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Enter your name"
        }
        let cancel = UIAlertAction(title: "Cancel", style: .default) { (alertAction) in }
        alert.addAction(save)
        alert.addAction(cancel)
        self.present(alert, animated:true, completion: nil)
    }
    
    
  
}


/*  ----------------------------------------------------------------------------------------- */
