
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
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var icon: Avatar!
    @IBOutlet weak var createGroup: UIButton!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var createGroupBtnBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var typeView: UIView!
    @IBOutlet weak var selectedGroupType: UILabel!
    
    
    // MARK: - Declaration of Variables
    
    let modelName = UIDevice.modelName
    var group : Group?
    var groupType : CometChat.groupType = .public
    var documentsUrl: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    // MARK: - View controller lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupSuperView()
        self.setupNavigationBar()
        self.addObservers()
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
            let closeButton = UIBarButtonItem(title: NSLocalizedString("CLOSE", bundle: UIKitSettings.bundle, comment: ""), style: .plain, target: self, action: #selector(closeButtonPressed))
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
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: "Choose one of the group type to create group.", preferredStyle: .actionSheet)
        
        let publicGroup: UIAlertAction = UIAlertAction(title: NSLocalizedString("PUBLIC", bundle: UIKitSettings.bundle, comment: "")  + " Group", style: .default) { action -> Void in
            self.groupType = .public
            self.selectedGroupType.text = NSLocalizedString("PUBLIC", bundle: UIKitSettings.bundle, comment: "")  + " Group"
            self.passwordView.isHidden = true
            self.password.text = ""
        }
        
        let passwordProtectedGroup: UIAlertAction = UIAlertAction(title: NSLocalizedString("PASSWORD_PROTECTED", bundle: UIKitSettings.bundle, comment: "")  + " Group", style: .default) { action -> Void in
            self.groupType = .password
            self.selectedGroupType.text = NSLocalizedString("PASSWORD_PROTECTED", bundle: UIKitSettings.bundle, comment: "")  + " Group"
            self.passwordView.isHidden = false
        }
        
        let privateGroup: UIAlertAction = UIAlertAction(title: NSLocalizedString("PRIVATE", bundle: UIKitSettings.bundle, comment: "") + " Group", style: .default) { action -> Void in
            self.groupType = .private
            self.selectedGroupType.text = NSLocalizedString("PRIVATE", bundle: UIKitSettings.bundle, comment: "") + " Group"
            self.passwordView.isHidden = true
            self.password.text = ""
        }
        
        let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("CANCEL", bundle: UIKitSettings.bundle, comment: ""), style: .cancel) { action -> Void in
        }
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        
        switch  UIKitSettings.groupInMode {
            
        case .publicGroups:
            actionSheetController.addAction(publicGroup)
        case .passwordProtectedGroups:
            actionSheetController.addAction(passwordProtectedGroup)
        case .publicAndPasswordProtectedGroups:
            actionSheetController.addAction(publicGroup)
            actionSheetController.addAction(passwordProtectedGroup)
            actionSheetController.addAction(privateGroup)
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
        
        if selectedGroupType.text == "Select Group Type" {
            self.showAlert(title: "Warning!", msg: "Select group type first to create a group.")
       
        }else if groupType == .password && password.text?.count == 0 {
            self.showAlert(title: "Warning!", msg: "Group password cannot be empty.")
        }else{
            
            guard let name = name.text else {
                let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: NSLocalizedString("ENTER_GROUP_NAME", bundle: UIKitSettings.bundle, comment: ""), duration: .short)
                snackbar.show()
                return
            }
            
            if groupType == .public {
                group = Group(guid: "group_\(Int(Date().timeIntervalSince1970 * 100))", name: name, groupType: .public, password: nil)
            }else if groupType == .password {
                group = Group(guid: "group_\(Int(Date().timeIntervalSince1970 * 100))", name: name, groupType: .password, password: password.text)
            }else if groupType == .private {
                group = Group(guid: "group_\(Int(Date().timeIntervalSince1970 * 100))", name: name, groupType: .private, password: nil)
            }
            
            if let group = group {
                CometChat.createGroup(group: group, onSuccess: { (group) in
                    DispatchQueue.main.async {
                        let data:[String: Group] = ["group": group]
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didGroupCreated"), object: nil, userInfo: data)
                        self.dismiss(animated: true, completion: nil)
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


/*  ----------------------------------------------------------------------------------------- */
