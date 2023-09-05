//
//  CometChatCreateGroup.swift
 
//
//  Created by Pushpsen Airekar on 10/05/22.
//

import UIKit
import CometChatSDK

public class CometChatCreateGroup: CometChatListBase {
    
    @IBOutlet weak var containerView: UIStackView!
    @IBOutlet weak var groupType: UISegmentedControl!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var seperator: UIView!
    
    private (set) var createGroupStyle = CreateGroupStyle()
    private (set) var viewModel = CreateGroupViewModel()
    private (set) var namePlaceholder: String?
    private (set) var passwordPlaceholder: String?
    private (set) var disableCloseButton: Bool?
    private (set) var closeButtonIcon: UIImage?
    private (set) var createGroupButtonTitle: String?
    private (set) var createButton: UIBarButtonItem?
    private (set) var selectedGroupType: CometChat.groupType = .public
    private (set) var groupNameLimit = 25
    private (set) var passwordLimit = 16
   // private (set) var onClose: (() -> ())?
    public var onCreateGroupClick: ((_ group: Group) -> Void)?
    private (set) var onError: ((_ error: CometChatException) -> ())?
    private (set) var createButtonIcon: UIImage?
    private(set) var onBack: (() -> ())?
    
    public override func loadView() {
        let loadedNib = Bundle.module.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)
        if let contentView = loadedNib?.first as? UIView {
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
                if let onCreateGroupClick = this.onCreateGroupClick {
                    onCreateGroupClick(group)
                } else {
                    this.dismiss(animated: true)
                }
            }
        }
        viewModel.failure  = { [weak self] error in
            guard let this = self else { return }
            this.onError?(error)
            DispatchQueue.main.async {
                let confirmDialog = CometChatDialog()
                confirmDialog.set(confirmButtonText: "TRY_AGAIN".localize())
                confirmDialog.set(cancelButtonText: "CANCEL".localize())
                confirmDialog.set(error: CometChatServerError.get(error: error))
                confirmDialog.open(onConfirm: { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.viewDidLoad()
                    strongSelf.viewWillAppear(true)
                })
            }
        }
    }
    
    func set(createGroupStyle: CreateGroupStyle = CreateGroupStyle()) {
        set(background: [createGroupStyle.background.cgColor])
        set(titleFont: createGroupStyle.titleTextFont)
        set(titleColor: createGroupStyle.titleTextColor)
        set(backButtonTint: createGroupStyle.cancelButtonTextColor)
        set(backButtonTitleColor: createGroupStyle.cancelButtonTextColor)
        set(backButtonFont: createGroupStyle.cancelButtonTextFont)
        set(inputBackgroundColor: createGroupStyle.inputBackgroundColor)
        set(inputCornerRadius: createGroupStyle.inputCornerRadius)
        set(inputBorderColor: createGroupStyle.borderColor)
        set(inputBorderWidth: createGroupStyle.borderWidth)
        set(createButtonTint: createGroupStyle.createButtonTextColor)
        set(createButtonFont: createGroupStyle.createButtonTextFont)
        set(selectedTabTextFont: createGroupStyle.selectedTabTextFont, selectedTabTextColor: createGroupStyle.selectedTabTextColor)
        set(passwordTextFont: createGroupStyle.passwordInputTextFont)
        set(passwordTextColor: createGroupStyle.passwordInputTextColor)
        
    }
    
    // Password Text Color
    @discardableResult
    public func set(passwordTextColor: UIColor) -> Self {
        password.textColor = passwordTextColor
        return self
    }
    
    @discardableResult
    public func set(passwordTextFont: UIFont) -> Self{
        password.font = createGroupStyle.passwordInputTextFont
        return self
    }

    // selectedTabTextFont and selectedTabColor
    @discardableResult
    public func set(selectedTabTextFont: UIFont, selectedTabTextColor: UIColor) -> Self {
        // groupType.selectedSegmentTintColor = selectedTabTextColor
        groupType.setTitleTextAttributes([NSAttributedString.Key.font: selectedTabTextFont, NSAttributedString.Key.foregroundColor: createGroupStyle.selectedTabTextColor], for: .normal)
        return self
    }
    
//    @discardableResult
//    public func hide(create: Bool) ->  Self {
//        if !create {
//            createButton = UIBarButtonItem(title: "CREATE".localize(), style: .done, target: self, action: #selector(self.didCreateGroupPressed))
//            set(createButtonFont: createGroupStyle.createButtonTextFont)
//            set(createButtonTint: createGroupStyle.createButtonTextColor)
//            self.navigationItem.rightBarButtonItem = createButton
//        }
//        return self
//    }
    
    private func set(createButtonTint: UIColor) {
        createButton?.tintColor = createButtonTint
    }
    
    private func set(inputBackgroundColor: UIColor) {
        containerView.addBackground(color: inputBackgroundColor)
    }
    
    private func set(inputCornerRadius: CGFloat){
        containerView.layer.cornerRadius = inputCornerRadius
    }
    
    private func set(inputBorderWidth: CGFloat) {
        containerView.layer.borderWidth = inputBorderWidth
    }
    
    private func set(inputBorderColor: UIColor) {
        containerView.layer.borderColor = inputBorderColor.cgColor
    }
    

    private func set(createButtonFont: UIFont) {
        self.createButton?.setTitleTextAttributes([NSAttributedString.Key.font: createButtonFont], for: .normal)
    }
    
    private func disable(closeButton: Bool) {
        self.disableCloseButton = closeButton
    }
    
    @discardableResult
    public func setOnBack(onBack: @escaping () -> Void) -> Self {
        self.onBack = onBack
        return self
    }
    
    @discardableResult
    public func set(createButtonIcon: UIImage) -> Self {
        self.createButtonIcon = createButtonIcon
        return self
    }
    
    @discardableResult
    public override func set(backButtonIcon: UIImage) -> Self {
        self.closeButtonIcon = backButtonIcon
        return self
    }
    
    @discardableResult
    public func setOnCreateGroupClick(onCreateGroupClick: @escaping ((_ group: Group) -> Void)) -> Self {
        self.onCreateGroupClick = onCreateGroupClick
        return self
    }
    
    @discardableResult
    public func setOnError(onError: @escaping (CometChatException) -> Void) -> Self {
        self.onError = onError
        return self
    }
    
    @objc func didCreateGroupPressed() {
        guard let name = self.name.text, !self.name.text!.isEmpty else { return }
        switch selectedGroupType {
        case .public, .private:
            viewModel.createGroup(name: name, groupType: selectedGroupType, password: nil)
        case .password:
            guard let password = password.text, !password.isEmpty else { return }
            viewModel.createGroup(name: name, groupType: selectedGroupType, password: password)
        @unknown default: break
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
                    if !self.password.isHidden {
                        self.password.isHidden = true
                    }
                })
                UIView.transition(with: seperator, duration: 0.4,
                                  options: .transitionCrossDissolve,
                                  animations: {
                    if !self.seperator.isHidden {
                        self.seperator.isHidden = true
                    }
                })
            case 1: selectedGroupType = .private
                UIView.transition(with: password, duration: 0.4,
                                  options: .transitionCrossDissolve,
                                  animations: {
                    if !self.password.isHidden {
                        self.password.isHidden = true
                    }
                })
                UIView.transition(with: seperator, duration: 0.4,
                                  options: .transitionCrossDissolve,
                                  animations: {
                    if !self.seperator.isHidden {
                        self.seperator.isHidden = true
                    }
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
        name.delegate = self
        password.delegate = self
    }
    
    private func setupAppearance() {
        set(createGroupStyle: createGroupStyle)
        self.set(title: "NEW_GROUP".localize(), mode: .never)
            .hide(search: true)
            .set(backButtonTitle: "CANCEL".localize())
            .set(backButtonTitleColor: createGroupStyle.cancelButtonTextColor)
            .set(titleFont: createGroupStyle.titleTextFont)
            .set(titleColor: createGroupStyle.titleTextColor)
            .show(backButton: true)
//        hide(create: false)
        self.groupType.setTitle("PUBLIC".localize(), forSegmentAt: 0)
        self.groupType.setTitle("PRIVATE".localize(), forSegmentAt: 1)
        self.groupType.setTitle("PROTECTED".localize(), forSegmentAt: 2)

        name.font = createGroupStyle.nameInputTextFont
        name.textColor = createGroupStyle.nameInputTextColor
        name.attributedPlaceholder = NSAttributedString(string:"NAME".localize(), attributes: [NSAttributedString.Key.foregroundColor: createGroupStyle.namePlaceholderTextColor, NSAttributedString.Key.font: createGroupStyle.namePlaceholderTextFont])
        password.attributedPlaceholder = NSAttributedString(string:"PASSWORD".localize(), attributes: [NSAttributedString.Key.foregroundColor: createGroupStyle.passwordPlaceholderColor, NSAttributedString.Key.font: createGroupStyle.passwordPlaceholderFont])
        containerView.addBackground(color: createGroupStyle.inputBackgroundColor)
    }
    
    override func onBackCallback() {
        if let onBack = onBack {
            onBack()
        } else {
            switch self.isModal() {
            case true:
                self.dismiss(animated: true, completion: nil)
            case false:
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setupAppearance()
    }
}

extension CometChatCreateGroup: UITextFieldDelegate {
    
    /**
     This method will call everytime when user enter text or delete the text from the UITextFiled,
     and this method has string parameter that gives the latest input that you have entered or deleted.
     */
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
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
