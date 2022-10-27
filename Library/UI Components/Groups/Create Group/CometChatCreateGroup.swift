
//  CometChatCreateGroup.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.

import UIKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */

class CometChatCreateGroup: UIViewController {
    
    // MARK: - Declaration of Outlets
    
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var icon: CometChatAvatar!
    @IBOutlet weak var createGroup: UIButton!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var createGroupBtnBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var typeView: UIView!
    @IBOutlet weak var selectedGroupType: UILabel!
    
    
    // MARK: - Declaration of Variables
    
    let modelName = UIDevice.modelName
    var group : CometChatPro.Group?
    var groupType : CometChat.groupType = .public
    var documentsUrl: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    /// This is a limit for group name and password.
    private var groupNameAndPasswordLimit = 100
    
    // MARK: - View controller lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupSuperView()
        self.setupNavigationBar()
        self.addObservers()
        name.isUserInteractionEnabled = true
    }
    
    override func loadView() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "CometChatCreateGroup", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view  = view
    }
    
     // MARK: - Public Instance methods
    
    /**
    This method specifies the navigation bar title for CometChatCreateGroup.
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
              navigationItem.title = title.localized()
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
    
    
    // MARK: - Private Instance methods
    
    private func setupSuperView(){
        
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
            typeView.layer.borderColor = UIColor.systemFill.cgColor
        } else {
            view.backgroundColor = .white
            typeView.layer.borderColor = UIColor.lightGray.cgColor
        }
        typeView.layer.borderWidth = 1
        typeView.clipsToBounds = true
        createGroup.backgroundColor = UIKitSettings.primaryColor
        createGroup.setTitle("CREATE_GROUP".localized(), for: .normal)
        selectedGroupType.text = "SELECT_GROUP_TYPE".localized()
        name.placeholder = "ENTER_GROUP_NAME".localized()
        detailLabel.text = "KINDLY_ENTER_GROUP_NAME".localized()
        password.placeholder = "ENTER_GROUP_PWD".localized()
        password.delegate = self
        name.delegate = self
    }
    
    
    /**
        This method setup navigationBar for createGroup viewController.
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
            let closeButton = UIBarButtonItem(title: "CLOSE".localized(), style: .plain, target: self, action: #selector(closeButtonPressed))
            closeButton.tintColor = UIKitSettings.primaryColor
            self.navigationItem.rightBarButtonItem = closeButton
        }
    }
    
    /**
    This method observes for perticular events such as `didGroupDeleted`, `keyboardWillShow`, `dismissKeyboard` in CometChatCreateGroup..
    - Author: CometChat Team
    - Copyright:  ©  2020 CometChat Inc.
    */
    fileprivate func addObservers(){
        //Register Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dismissKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
          NotificationCenter.default.addObserver(self, selector:#selector(self.didGroupDeleted(_:)), name: NSNotification.Name(rawValue: "didGroupDeleted"), object: nil)
        self.hideKeyboardWhenTappedArround()
        
    }
    
    /**
    This method triggers when  group is deleted.
    - Parameter notification: Specifies the `NSNotification` Object.
    - Author: CometChat Team
    - Copyright:  ©  2020 CometChat Inc.
    */
    @objc func didGroupDeleted(_ notification: NSNotification) {
           
        self.dismiss(animated: true, completion: nil)
           
     }
    
    /**
    This method triggers when  keyboard is shown.
    - Parameter notification: Specifies the `NSNotification` Object.
    - Author: CometChat Team
    - Copyright:  ©  2020 CometChat Inc.
    */
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if let userinfo = notification.userInfo
        {
            let keyboardHeight = (userinfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue?.size.height
            
            if (modelName == "iPhone X" || modelName == "iPhone XS" || modelName == "iPhone XR" || modelName == "iPhone12,1"){
                createGroupBtnBottomConstraint.constant = (keyboardHeight)! - 10
                UIView.animate(withDuration: 0.5) {
                    self.view.layoutIfNeeded()
                }
            }else{
                createGroupBtnBottomConstraint.constant = (keyboardHeight)! + 20
                UIView.animate(withDuration: 0.5) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    /**
    This method triggers when  user taps arround the view.
    - Author: CometChat Team
    - Copyright:  ©  2020 CometChat Inc.
    */
    private func hideKeyboardWhenTappedArround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        backgroundView.addGestureRecognizer(tap)
    }
    
     /**
    This method dismiss the  keyboard
    - Author: CometChat Team
    - Copyright:  ©  2020 CometChat Inc.
    */
    @objc  func dismissKeyboard() {
        name.resignFirstResponder()
        password.resignFirstResponder()
        if self.createGroup.frame.origin.y != 0 {
            createGroupBtnBottomConstraint.constant = 40
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    
    @IBAction func didSelectGroupPressed(_ sender: Any) {
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: "CHOOSE_GROUP_TYPE".localized(), preferredStyle: .actionSheet)
        
        let publicGroup: UIAlertAction = UIAlertAction(title: "PUBLIC".localized()  + "GROUP".localized(), style: .default) { action -> Void in
            self.groupType = .public
            self.selectedGroupType.text = "PUBLIC".localized()  + "GROUP".localized()
            self.passwordView.isHidden = true
            self.password.text = ""
        }
        
        let passwordProtectedGroup: UIAlertAction = UIAlertAction(title: "PASSWORD_PROTECTED".localized()  + "GROUP".localized(), style: .default) { action -> Void in
            self.groupType = .password
            self.selectedGroupType.text = "PASSWORD_PROTECTED".localized()  + "GROUP".localized()
            self.passwordView.isHidden = false
        }
        
        let privateGroup: UIAlertAction = UIAlertAction(title: "PRIVATE".localized() + "GROUP".localized(), style: .default) { action -> Void in
            self.groupType = .private
            self.selectedGroupType.text = "PRIVATE".localized() + "GROUP".localized()
            self.passwordView.isHidden = true
            self.password.text = ""
        }
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "CANCEL".localized(), style: .cancel) { action -> Void in
        }
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        
        switch  UIKitSettings.groupInMode {
            
        case .publicGroups:
            
            FeatureRestriction.isPublicGroupEnabled { (success) in
                if success == .enabled {
                    actionSheetController.addAction(publicGroup)
                }
            }
            
        case .passwordProtectedGroups:
            FeatureRestriction.isPasswordGroupEnabled { (success) in
                if success == .enabled {
                    actionSheetController.addAction(passwordProtectedGroup)
                }
            }
        case .publicAndPasswordProtectedGroups:
            
            FeatureRestriction.isPublicGroupEnabled { (success) in
                if success == .enabled {
                    actionSheetController.addAction(publicGroup)
                }
            }
            FeatureRestriction.isPasswordGroupEnabled { (success) in
                if success == .enabled {
                    actionSheetController.addAction(passwordProtectedGroup)
                }
            }
            
            FeatureRestriction.isPrivateGroupEnabled { (success) in
                if success == .enabled {
                    actionSheetController.addAction(privateGroup)
                }
            }
        case .none: break
        }
        actionSheetController.addAction(cancelAction)
        actionSheetController.view.tintColor = UIKitSettings.primaryColor
        // Added ActionSheet support for iPad
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad ){
            if let currentPopoverpresentioncontroller =
                actionSheetController.popoverPresentationController{
                currentPopoverpresentioncontroller.sourceView = self.view
                self.present(actionSheetController, animated: true, completion: nil)
            }
        }else{
            self.present(actionSheetController, animated: true, completion: nil)
        }
    }
    
    
    /**
    This method triggeres when  create group button pressed.
    - Author: CometChat Team
    - Copyright:  ©  2020 CometChat Inc.
    */
    @IBAction func didCreateGroupPressed(_ sender: Any) {
        
        if selectedGroupType.text == "SELECT_GROUP_TYPE".localized() {
            CometChatSnackBoard.display(message: "SELECT_GROUP_TYPE".localized(), mode: .error, duration: .short)
       
        }else if groupType == .password && password.text?.count == 0 {
            CometChatSnackBoard.display(message: "GROUP_PASSWORD_CANNOT_EMPTY".localized(), mode: .error, duration: .short)
        }else{
            
            guard let name = name.text else {
                CometChatSnackBoard.display(message:  "ENTER_GROUP_NAME".localized(), mode: .error, duration: .short)
                return
            }
            
            if groupType == .public {
                group = CometChatPro.Group(guid: "group_\(Int(Date().timeIntervalSince1970 * 100))", name: name, groupType: .public, password: nil)
            }else if groupType == .password {
                group = CometChatPro.Group(guid: "group_\(Int(Date().timeIntervalSince1970 * 100))", name: name, groupType: .password, password: password.text)
            }else if groupType == .private {
                group = CometChatPro.Group(guid: "group_\(Int(Date().timeIntervalSince1970 * 100))", name: name, groupType: .private, password: nil)
            }
            
            if let group = group {
                CometChat.createGroup(group: group, onSuccess: { (group) in
                    DispatchQueue.main.async {
                        let data:[String: CometChatPro.Group] = ["group": group]
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didGroupCreated"), object: nil, userInfo: data)
                        self.dismiss(animated: true, completion: nil)
                    }
                }) { (error) in
                    DispatchQueue.main.async {
                        if let error = error {
                            CometChatSnackBoard.showErrorMessage(for: error)
                        }
                    }
                }
            }
        }
    }
    
    
    /**
    This method triggeres when upload icon is pressed.  This view is hidden by default. If user wants to upload its own image in group icon then he can use this option.
    - Author: CometChat Team
    - Copyright:  ©  2020 CometChat Inc.
    */
    @IBAction func didUploadIconPressed(_ sender: Any) {
        
        CameraHandler.shared.presentPhotoLibrary(for: self)
        CameraHandler.shared.imagePickedBlock = { (photoURL) in
            
            self.icon.image = self.load(fileName: photoURL)
        }
        
    }
    
    /**
    This method loads the image using filepath.
    - Author: CometChat Team
    - Copyright:  ©  2020 CometChat Inc.
    */
    private func load(fileName: String) -> UIImage? {
        let fileURL = documentsUrl.appendingPathComponent(fileName)
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {
            
        }
        return nil
    }
    
    /**
    This method when user clicks on Close button.
    - Author: CometChat Team
    - Copyright:  ©  2020 CometChat Inc.
    */
    @objc func closeButtonPressed(){
        self.dismiss(animated: true, completion: nil)
    }
}

extension CometChatCreateGroup: UITextFieldDelegate {
    
    /**
        This method will call everytime when user enter text or delete the text from the UITextFiled,
           and this method has string parameter that gives the latest input that you have entered or deleted.
     */
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        /// If either password or groupname text exceeds over 100, disable the button, otherwise enable.
        let count = string.isEmpty ? textField.text!.count - 1 : textField.text!.count + string.count
        createGroup.backgroundColor = count > groupNameAndPasswordLimit ? UIColor.lightGray : UIKitSettings.primaryColor
        createGroup.isEnabled = count > groupNameAndPasswordLimit ? false : true
        return true
    }
}


/*  ----------------------------------------------------------------------------------------- */
