//
//  CometChatCreateGroup.swift
//  ios-chat-uikit-app
//
//  Created by Pushpsen Airekar on 06/01/20.
//  Copyright © 2020 Pushpsen Airekar. All rights reserved.
//

import UIKit
import CometChatPro


class CometChatCreateGroup: UIViewController {
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var icon: Avtar!
    @IBOutlet weak var createGroup: UIButton!
    
    @IBOutlet var backgroundView: UIView!
    let modelName = UIDevice.modelName
   
    
    
    @IBOutlet weak var createGroupBtnBottomConstraint: NSLayoutConstraint!
    
    var documentsUrl: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationBar()
        self.registerObservers()
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
                
                let closeButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeButtonPressed))
                self.navigationItem.rightBarButtonItem = closeButton
            }
        }
    }
    
    fileprivate func registerObservers(){
        //Register Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dismissKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
          NotificationCenter.default.addObserver(self, selector:#selector(self.didGroupDeleted(_:)), name: NSNotification.Name(rawValue: "didGroupDeleted"), object: nil)
        self.hideKeyboardWhenTappedArround()
        
    }
    
    @objc func didGroupDeleted(_ notification: NSNotification) {
           
        self.dismiss(animated: true, completion: nil)
           
     }
    
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
    
    fileprivate func hideKeyboardWhenTappedArround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        backgroundView.addGestureRecognizer(tap)
    }
    
    
    // This function dismiss the  keyboard
    @objc  func dismissKeyboard() {
        name.resignFirstResponder()
        if self.createGroup.frame.origin.y != 0 {
            createGroupBtnBottomConstraint.constant = 40
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    
    @IBAction func didUploadIconPressed(_ sender: Any) {
        
        CameraHandler.shared.presentPhotoLibrary(for: self)
        CameraHandler.shared.imagePickedBlock = { (photoURL) in
            
            self.icon.image = self.load(fileName: photoURL)
        }
        
    }
    
    @IBAction func didCreateGroupPressed(_ sender: Any) {
        
        guard let name = name.text else {
            self.view.makeToast("Kindly, enter group name.")
            return
        }
        
        let group = Group(guid: "group_\(Int(Date().timeIntervalSince1970 * 100))", name: name , groupType: .public, password: nil, icon: "http://support.universum.com/bitbucket-old/atlassian-bitbucket/static/bitbucket/internal/images/avatar/group-avatar-256.png", description: ".")
        
        CometChat.createGroup(group: group, onSuccess: { (group) in
            print("createGroup: \(group.stringValue())")
            DispatchQueue.main.async {
                let data:[String: Group] = ["group": group]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didGroupCreated"), object: nil, userInfo: data)
                self.dismiss(animated: true, completion: nil)
            }
            
        }) { (error) in
                DispatchQueue.main.async {
                    print("error while creating group: \(String(describing: error?.errorDescription))")
                    self.view.makeToast(error?.errorDescription)
            }
        }
        
        
        
    }
    
    
    private func load(fileName: String) -> UIImage? {
        let fileURL = documentsUrl.appendingPathComponent(fileName)
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {
            print("Error loading image : \(error)")
        }
        return nil
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
            
        }
    }
}
