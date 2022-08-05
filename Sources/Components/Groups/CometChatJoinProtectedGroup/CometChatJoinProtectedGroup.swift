//
//  CometChatJoinGroup.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 10/05/22.
//

import UIKit
import CometChatPro

open class CometChatJoinProtectedGroup: CometChatListBase {
    
    private var continueButton: UIBarButtonItem?
    private var selectedGroupType: CometChat.groupType = .public
    private var groupNameAndPasswordLimit = 100
    private var group: Group?
    
    @IBOutlet weak var caption: UILabel!
    @IBOutlet weak var password: UITextField!
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
    
    deinit {
        
    }
    
    @discardableResult
    public func set(group: Group) ->  Self {
        self.group = group
        return self
    }
    
    
    @discardableResult
    public func hide(continueButton: Bool) ->  Self {
        if !continueButton {
            self.continueButton = UIBarButtonItem(title: "CONTINUE".localize(), style: .done, target: self, action: #selector(self.didContinueButtonPressed))
            set(continueButtonFont: CometChatTheme.typography?.Name2 ?? UIFont.systemFont(ofSize: 17))
            set(continueButtonTint: CometChatTheme.palatte?.primary ?? .blue)
            self.navigationItem.rightBarButtonItem = self.continueButton
        }
        return self
    }
    
    @discardableResult
    public func set(continueButtonTint: UIColor) ->  Self {
        continueButton?.tintColor = continueButtonTint
        return self
    }

    @discardableResult
    public func set(continueButtonFont: UIFont) ->  Self {
        self.continueButton?.setTitleTextAttributes([NSAttributedString.Key.font: continueButtonFont], for: .normal)
        return self
    }
    
    @discardableResult
    public func set(caption: String) ->  Self {
        self.caption.text = caption
        return self
    }
    
    @discardableResult
    public func set(captionFont: UIFont) ->  Self {
        self.caption.font = captionFont
        return self
    }
    
    @discardableResult
    public func set(captionColor: UIColor) ->  Self {
        self.caption.textColor = captionColor
        return self
    }
    
    
    
    @objc func didContinueButtonPressed(){
        
        if let group = group, let password = password.text {
            if password.count == 0 {
            }else{
                CometChat.joinGroup(GUID: group.guid, groupType: .password, password: password) { joinSuccess in
                    DispatchQueue.main.async { [weak self] in
                        
                        if let user = CometChat.getLoggedInUser() {
                            
                            CometChatGroupEvents.emitOnGroupMemberJoin(joinedUser: user, joinedGroup: joinSuccess)
                        }
                        self?.dismiss(animated: true, completion: nil)
                        self?.removeObervers()
                    }
                } onError: { error in
                        if let error = error {
                            let confirmDialog = CometChatDialog()
                            confirmDialog.set(confirmButtonText: "TRY_AGAIN".localize())
                            confirmDialog.set(cancelButtonText: "CANCEL".localize())
                            confirmDialog.set(error: CometChatServerError.get(error: error))
                            confirmDialog.open(onConfirm: { [weak self] in
                                guard let strongSelf = self else { return }
                                // Referesh view
                                strongSelf.viewDidLoad()
                                strongSelf.viewWillAppear(true)
                            })
                        }
                }
            }
        }
    }

    private func addObervers() {
        self.cometChatListBaseDelegate = self
        password.delegate = self
    }
    
    private func removeObervers() {
       
    }
 
  
    private func setupAppearance() {
        
        self.set(title: "PROTECTED_GROUP".localize(), mode: .never)
            .hide(search: true)
            .set(backButtonTitle: "CANCEL".localize())
            .show(backButton: true)
            .set(backButtonTitleColor: CometChatTheme.palatte?.primary ?? .systemBlue)
            .set(titleFont: CometChatTheme.typography?.Title2 ?? .systemFont(ofSize: 17))
            .set(titleColor: CometChatTheme.palatte?.accent ?? .black)
        hide(continueButton: false)
        
        self.view.backgroundColor = CometChatTheme.palatte?.secondary
        password.placeholder = "PASSWORD".localize()
        if let group = group, let name = group.name {
            self.set(caption: "ENTER_PASSWORD_TO_ACCESS".localize() + name + "GROUP_WITH_DOT".localize())
                .set(captionFont: CometChatTheme.typography?.Subtitle2 ?? UIFont.systemFont(ofSize: 13))
                .set(captionColor: CometChatTheme.palatte?.accent600 ?? UIColor.lightGray)
        }else{
            self.set(caption: "ENTER_PASSWORD_TO_ACCESS".localize() + "GROUP_WITH_DOT".localize())
                .set(captionFont: CometChatTheme.typography?.Subtitle2 ?? UIFont.systemFont(ofSize: 13))
                .set(captionColor: CometChatTheme.palatte?.accent600 ?? UIColor.lightGray)
        }
        containerView.addBackground(color: CometChatTheme.palatte?.background ?? .white)
        password.font = CometChatTheme.typography?.Body ?? .systemFont(ofSize: 17)
    }
    
}

extension CometChatJoinProtectedGroup: UITextFieldDelegate {
    
    /**
     This method will call everytime when user enter text or delete the text from the UITextFiled,
     and this method has string parameter that gives the latest input that you have entered or deleted.
     */
   public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        /// If either password or groupname text exceeds over 100, disable the button, otherwise enable.
        let count = string.isEmpty ? textField.text!.count - 1 : textField.text!.count + string.count
        continueButton?.isEnabled = count > groupNameAndPasswordLimit ? false : true
        return true
    }
}


extension CometChatJoinProtectedGroup: CometChatListBaseDelegate{
    
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
