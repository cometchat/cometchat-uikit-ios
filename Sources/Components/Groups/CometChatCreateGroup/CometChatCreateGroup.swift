//
//  CometChatCreateGroup.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 10/05/22.
//

import UIKit
import CometChatPro

open class CometChatCreateGroup: CometChatListBase {
    
    private var createButton: UIBarButtonItem?
    private var selectedGroupType: CometChat.groupType = .public
    private var groupNameLimit = 25
    private var passwordLimit = 16
    
    @IBOutlet weak var groupType: UISegmentedControl!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var seperator: UIView!
    @IBOutlet weak var containerView: UIStackView!
    
    
    open override func loadView() {
        let loadedNib = Bundle.module.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)
        if let contentView = loadedNib?.first as? UIView  {
            contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.view  = contentView
        }
        addObervers()
        setupAppearance()
    }
    
    deinit {}
    
    @discardableResult
    public func hide(create: Bool) ->  CometChatCreateGroup {
        if !create {
            createButton = UIBarButtonItem(title: "CREATE".localize(), style: .done, target: self, action: #selector(self.didCreateGroupPressed))
            set(createButtonFont: CometChatTheme.typography?.Name2 ?? UIFont.systemFont(ofSize: 17))
            set(createButtonTint: CometChatTheme.palatte?.primary ?? .blue)
            self.navigationItem.rightBarButtonItem = createButton
        }
        return self
    }
    
    @discardableResult
    public func set(createButtonTint: UIColor) ->  CometChatCreateGroup {
        createButton?.tintColor = createButtonTint
        return self
    }
    
    @discardableResult
    public func set(createButtonFont: UIFont) ->  CometChatCreateGroup {
        self.createButton?.setTitleTextAttributes([NSAttributedString.Key.font: createButtonFont], for: .normal)
        return self
    }
    
    @objc func didCreateGroupPressed() {
        createGroup(with: name.text, type: selectedGroupType, password: password.text)
    }
    
    private func createGroup(with name: String?, type: CometChat.groupType, password: String?) {
        
        if (selectedGroupType == .public || selectedGroupType == .private || selectedGroupType == .public) && self.name.text?.count == 0 {
        }else{
            
            if selectedGroupType == .public || selectedGroupType == .private {
                let group = Group(guid: "group_\(Int(Date().timeIntervalSince1970 * 100))", name: name ?? "", groupType: type, password: nil)
                
                CometChat.createGroup(group: group) { group in
                    
                    DispatchQueue.main.async { [weak self] in
                        self?.dismiss(animated: true) {
                            CometChatGroupEvents.emitOnGroupCreate(group: group)
                            self?.removeObervers()
                        }
                    }
                    
                } onError: { error in
                    if let error = error  {
                        CometChatGroupEvents.emitOnError(group: group, error: error)
                        let confirmDialog = CometChatDialog()
                        confirmDialog.set(confirmButtonText: "TRY_AGAIN".localize())
                        confirmDialog.set(cancelButtonText: "CANCEL".localize())
                        confirmDialog.set(error: CometChatServerError.get(error: error))
                        confirmDialog.open(onConfirm: { [weak self] in
                            guard let strongSelf = self else { return }
                            // Referesh the view.
                            strongSelf.viewDidLoad()
                            strongSelf.viewWillAppear(true)
                        })
                    }
                }
                
            } else if selectedGroupType == .password {
                
                if self.password.text?.count == 0 {
                 
                }else{
                    let group = Group(guid: "group_\(Int(Date().timeIntervalSince1970 * 100))", name: name ?? "", groupType: type, password: password)
                    
                    CometChat.createGroup(group: group) { group in
                        DispatchQueue.main.async {
                        
                            self.dismiss(animated: true) { [weak self] in
                                CometChatGroupEvents.emitOnGroupCreate(group: group)
                                self?.removeObervers()
                            }
                        }
                    } onError: { error in
                        if let error = error  {
                            CometChatGroupEvents.emitOnError(group: group, error: error)
                            let confirmDialog = CometChatDialog()
                            confirmDialog.set(confirmButtonText: "TRY_AGAIN".localize())
                            confirmDialog.set(cancelButtonText: "CANCEL".localize())
                            confirmDialog.set(error: CometChatServerError.get(error: error))
                            confirmDialog.open(onConfirm: { [weak self] in
                                guard let strongSelf = self else { return }
                                // Referesh the view.
                                strongSelf.viewDidLoad()
                                strongSelf.viewWillAppear(true)
                            })
                        }
                    }
                }
            }
        }
    }
    
    
    @IBAction func didGroupTypeSelected(_ sender: Any) {
        if let sender = sender as? UISegmentedControl {
            
            switch sender.selectedSegmentIndex {
            case 0:
                selectedGroupType = .public
                UIView.transition(with: password, duration: 0.4,
                                  options: .transitionCrossDissolve,
                                  animations: {
                    self.password.isHidden = true
                })
                UIView.transition(with: seperator, duration: 0.4,
                                  options: .transitionCrossDissolve,
                                  animations: {
                    self.seperator.isHidden = true
                })
            case 1: selectedGroupType = .private
                UIView.transition(with: password, duration: 0.4,
                                  options: .transitionCrossDissolve,
                                  animations: {
                    self.password.isHidden = true
                })
                UIView.transition(with: seperator, duration: 0.4,
                                  options: .transitionCrossDissolve,
                                  animations: {
                    self.seperator.isHidden = true
                })
            case 2:
                selectedGroupType = .password
                UIView.transition(with: password, duration: 0.4,
                                  options: .transitionCrossDissolve,
                                  animations: {
                    self.password.isHidden = false
                })
                UIView.transition(with: seperator, duration: 0.4,
                                  options: .transitionCrossDissolve,
                                  animations: {
                    self.seperator.isHidden = false
                })
                
            default: break
                
            }
        }
    }
    
    private func addObervers() {
        self.cometChatListBaseDelegate = self
        name.delegate = self
        password.delegate = self
    }
    
    private func removeObervers() {}
    
    private func setupAppearance() {
        
        self.set(title: "NEW_GROUP".localize(), mode: .never)
            .hide(search: true)
            .set(backButtonTitle: "CANCEL".localize())
            .set(backButtonTitleColor: CometChatTheme.palatte?.primary ?? .systemBlue)
            .set(titleFont: CometChatTheme.typography?.Title2 ?? .systemFont(ofSize: 17))
            .set(titleColor: CometChatTheme.palatte?.accent ?? .black)
            .show(backButton: true)
        hide(create: false)
        
        self.view.backgroundColor = CometChatTheme.palatte?.secondary
        self.name.placeholder = "NAME".localize()
        self.password.placeholder = "PASSWORD".localize()
        self.groupType.setTitle("PUBLIC".localize(), forSegmentAt: 0)
        self.groupType.setTitle("PRIVATE".localize(), forSegmentAt: 1)
        self.groupType.setTitle("PROTECTED".localize(), forSegmentAt: 2)
        groupType.selectedSegmentTintColor = CometChatTheme.palatte?.background ?? .white
        groupType.setTitleTextAttributes([NSAttributedString.Key.font: CometChatTheme.typography?.Caption1 ?? .systemFont(ofSize: 17), NSAttributedString.Key.foregroundColor: CometChatTheme.palatte?.accent], for: .normal)
        name.font = CometChatTheme.typography?.Body ?? .systemFont(ofSize: 17)
        password.font = CometChatTheme.typography?.Body ?? .systemFont(ofSize: 17)
        containerView.addBackground(color: CometChatTheme.palatte?.background ?? .white)
    }
    
}

extension CometChatCreateGroup: UITextFieldDelegate {
    
    /**
     This method will call everytime when user enter text or delete the text from the UITextFiled,
     and this method has string parameter that gives the latest input that you have entered or deleted.
     */
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        /// If either password or groupname text exceeds over 100, disable the button, otherwise enable.
        
        let count = string.isEmpty ? textField.text!.count - 1 : textField.text!.count + string.count
        
        if textField == name {
            createButton?.isEnabled = count > groupNameLimit ? false : true
        }
        
        if textField == password &&  selectedGroupType == .password {
            
             createButton?.isEnabled =  count > passwordLimit ? false : true
            
        }
       
        return true
    }
}


extension CometChatCreateGroup: CometChatListBaseDelegate {
    
    public func onSearch(state: SearchState, text: String) {
        
    }
    
    public func onBack() {
        switch self.isModal() {
        case true:
            self.dismiss(animated: true, completion: nil)
            self.removeObervers()
        case false:
            self.navigationController?.popViewController(animated: true)
            self.removeObervers()
        }
    }
}
