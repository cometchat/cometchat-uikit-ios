//
//  CometChatJoinGroup.swift
 
//
//  Created by Pushpsen Airekar on 10/05/22.


import UIKit
import CometChatSDK

public class CometChatJoinProtectedGroup: CometChatListBase {
    
    @IBOutlet weak var containerView: UIStackView!
    @IBOutlet weak var caption: UILabel!
    @IBOutlet weak var password: UITextField!
    private (set) var group: Group?
    private (set) var joinProtectedGroupStyle = JoinProtectedGroupStyle()
    private (set) var viewModel = JoinProtectedGroupViewModel()
    private (set) var disableCloseButton: Bool?
    private (set) var closeButtonIcon: UIImage?
    private (set) var createGroupButtonTitle: String?
    private (set) var createButton: UIBarButtonItem?
    private (set) var selectedGroupType: CometChat.groupType = .public
    private (set) var passwordLimit = 100
    private (set) var joinIcon: UIImage?
    private (set) var onBack: (() -> ())?
    private (set) var onJoinClick: ((_ group: Group, _ password: String) -> ())?
    private (set) var onError: ((_ error: CometChatException) -> ())?
    private (set) var continueButton: UIBarButtonItem?
    private let tryAgainText = "TRY_AGAIN".localize()
    private var passwordPlaceholderText = "PASSWORD".localize()
    private let cancelText = "CANCEL".localize()
    private let errorWrongGroupPassText = "ERR_WRONG_GROUP_PASS".localize()
    private let wrongPasswordText = "WRONG_PASSWORD".localize()
    
    public override func loadView() {
        let loadedNib = Bundle.module.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)
        if let contentView = loadedNib?.first as? UIView  {
            contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.view  = contentView
        }
        addObervers()
        setupAppearance()
        reloadData()
    }
    
    private func reloadData() {
        viewModel.success  = { [weak self] group in
            guard let this = self else { return }
            DispatchQueue.main.async {
                switch this.isModal() {
                case true:
                    this.dismiss(animated: true)
                case false:
                    this.navigationController?.popViewController(animated: true)
                }
                if let user = CometChat.getLoggedInUser() {
                    CometChatGroupEvents.emitOnGroupMemberJoin(joinedUser: user, joinedGroup: group)
                }
            }
        }
        viewModel.failure  = { [weak self] error in
            guard let this = self else { return }
            // this is call back to user.
            this.onError?(error)
            DispatchQueue.main.async {
                let confirmDialog = CometChatDialog()
                confirmDialog.set(confirmButtonText: this.tryAgainText)
                confirmDialog.set(cancelButtonText: this.cancelText)
                confirmDialog.set(error: error.errorCode == this.errorWrongGroupPassText ? this.wrongPasswordText : CometChatServerError.get(error: error))
                confirmDialog.open(onConfirm: { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.viewDidLoad()
                    strongSelf.viewWillAppear(true)
                })
            }
        }
    }
    
    @discardableResult
    func set(joinProtectedGroupStyle: JoinProtectedGroupStyle = JoinProtectedGroupStyle())  -> Self {
        set(background: [joinProtectedGroupStyle.background.cgColor])
        set(titleFont: joinProtectedGroupStyle.titleTextFont)
        set(titleColor: joinProtectedGroupStyle.titleTextColor)
        set(backButtonTint: joinProtectedGroupStyle.cancelButtonTextColor)
        set(inputBackgroundColor: joinProtectedGroupStyle.passwordInputBackground)
        set(inputCornerRadius: joinProtectedGroupStyle.passwordInputCornerRadius)
        set(inputBorderColor: joinProtectedGroupStyle.borderColor)
        set(inputBorderWidth: joinProtectedGroupStyle.borderWidth)
        return self
    }
    
    @discardableResult
    public func setOnBack(onBack: @escaping () -> ()) -> Self{
        self.onBack = onBack
        return self
    }
    
    @discardableResult
    public func set(joinIcon: UIImage) -> Self{
        self.joinIcon = joinIcon
        return self
    }
    
    @discardableResult
    public func setOnJoinClick(onJoinClick: @escaping ((_ group: Group, _ password: String) -> ())) -> Self {
        self.onJoinClick = onJoinClick
        return self
    }
    
    @discardableResult
    public func setOnError(onError: @escaping (_ error: CometChatException) -> ()) -> Self {
        self.onError = onError
        return self
    }
    
    @discardableResult
    private func set(inputBackgroundColor: UIColor) ->  Self {
        containerView.addBackground(color: .yellow)
        return self
    }
    
    @discardableResult
    private func set(inputCornerRadius: CGFloat) ->  Self {
        containerView.layer.cornerRadius = inputCornerRadius
        return self
    }
    
    @discardableResult
    private func set(inputBorderWidth: CGFloat) ->  Self {
        containerView.layer.borderWidth = inputBorderWidth
        return self
    }
    
    @discardableResult
    private func set(inputBorderColor: UIColor) ->  Self {
        containerView.layer.borderColor = inputBorderColor.cgColor
        return self
    }
    
    @discardableResult
    private func set(continueButtonTint: UIColor) ->  Self {
        continueButton?.tintColor = continueButtonTint
        return self
    }
    
    @discardableResult
    private func set(continueButtonFont: UIFont) ->  Self {
        self.continueButton?.setTitleTextAttributes([NSAttributedString.Key.font: continueButtonFont], for: .normal)
        return self
    }
    
    @discardableResult
    private func set(captionFont: UIFont) ->  Self {
        self.caption.font = captionFont
        return self
    }
    
    @discardableResult
    private func set(captionColor: UIColor) ->  Self {
        self.caption.textColor = captionColor
        return self
    }
    
    @objc func didContinueButtonPressed(){
        if let group = group, let password = self.password.text , !self.password.text!.isEmpty {
            if let onJoinClick = onJoinClick {
                onJoinClick(group,password)
            } else {
                viewModel.joinGroup(group: group, password: password)
            }
        }
    }
    
    private func addObervers() {
        password.delegate = self
    }
    
    private func setupAppearance() {
        self.set(title: "PROTECTED_GROUP".localize(), mode: .never)
            .hide(search: true)
            .show(backButton: true)
            .hide(continueButton: false)

        if let group = group, let name = group.name {
            self.set(description: "ENTER_PASSWORD_TO_ACCESS".localize() + name + "GROUP_WITH_DOT".localize())
                .set(captionFont: joinProtectedGroupStyle.captionTextFont)
                .set(captionColor: joinProtectedGroupStyle.captionTextColor)
        } else {
            self.set(description: "ENTER_PASSWORD_TO_ACCESS".localize() + "GROUP_WITH_DOT".localize())
                .set(captionFont: joinProtectedGroupStyle.captionTextFont)
                .set(captionColor: joinProtectedGroupStyle.captionTextColor)
        }

        if let backIcon = backIcon {
            set(backButtonIcon: backIcon)
        } else {
            set(backButtonTitle: cancelText)
        }
    }
    
    public override func onBackCallback() {
        if let onBack = onBack {
            onBack()
        } else {
            if self.navigationController != nil {
                if self.navigationController?.viewControllers.first == self {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
               
            }else{
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setupAppearance()
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
        continueButton?.isEnabled = count > passwordLimit ? false : true
        return true
    }
}

extension CometChatJoinProtectedGroup {
    
    @discardableResult
    public func set(group: Group) ->  Self {
        self.group = group
        return self
    }
    
    @discardableResult
    public func hide(continueButton: Bool) ->  Self {
        if !continueButton {
            if let joinIcon = joinIcon {
                self.continueButton = UIBarButtonItem(image: joinIcon, style: .done, target: self, action: #selector(self.didContinueButtonPressed))
            } else {
                self.continueButton = UIBarButtonItem(title: "CONTINUE".localize(), style: .done, target: self, action: #selector(self.didContinueButtonPressed))
                set(continueButtonFont: CometChatTheme.typography.title2)
                set(continueButtonTint: CometChatTheme.palatte.primary)
            }
            self.navigationItem.rightBarButtonItem = self.continueButton
        }
        return self
    }
    
    @discardableResult
    public func set(passwordPlaceholderText: String) ->  Self {
        self.passwordPlaceholderText = passwordPlaceholderText
        return self
    }
    
    @discardableResult
    public func set(description: String) ->  Self {
        self.caption.text = description
        return self
    }
}
