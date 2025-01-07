//
//  CometChatCreateGroup.swift
//  Sample App
//
//  Created by Dawinder on 16/10/24.
//

import Foundation
import UIKit
import CometChatSDK
import CometChatUIKitSwift

class CreateGroupVC: UIViewController {

    // MARK: - UI Components
    private let groupImageBackView = UIImageView()
    private let groupImage = UIImageView()
    private let titleLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    private let typeLabel = UILabel()
    private let segmentedControl = UISegmentedControl(items: ["Public", "Private", "Password"])
    private let nameLabel = UILabel()
    private let nameTextFieldView = UIView()
    private let nameTextField = UITextField()
    private let passwordLabel = UILabel()
    private let passwordTextFieldView = UIView()
    private let passwordTextField = UITextField()
    private let fieldsStackView = UIStackView()
    private let createGroupButton = UIButton(type: .system)
    private var loadingIndicator: UIActivityIndicatorView?
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var scrollViewBottomAnchor: NSLayoutConstraint?
    
    // MARK: - Callbacks
    var success: ((CometChatSDK.Group) -> Void)?
    var failure: ((CometChatSDK.CometChatException) -> Void)?
    var openGroupChat: ((Group) -> ())?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureSegmentedControl()
        createGroupButton.addTarget(self, action: #selector(createGroupButtonTapped), for: .touchUpInside)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height
            scrollViewBottomAnchor?.constant = -keyboardHeight
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.view?.layoutIfNeeded()
            }
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        scrollViewBottomAnchor?.constant = 0
    }

    // MARK: - UI Setup
    private func setupUI() {
        setupView()
        setupGroupImageBackView()
        setupGroupImage()
        setupTitleLabel()
        setupCloseButton()
        setupTypeLabel()
        setupSegmentedControl()
        setupNameFields()
        setupPasswordFields()
        setupFieldsStackView()
        setupCreateGroupButton()
        setupScrollView()
        setupConstraints()
    }

    private func setupView() {
        self.view.layer.cornerRadius = 16
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.backgroundColor = CometChatTheme.backgroundColor01
    }
    
    private func setupGroupImageBackView(){
        groupImageBackView.backgroundColor = CometChatTheme.backgroundColor02
        groupImageBackView.layer.cornerRadius = 40
        groupImageBackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(groupImageBackView)
    }
    
    private func setupGroupImage(){
        groupImage.image = UIImage(named: "new-group-icon", in: CometChatUIKit.bundle, with: nil)
        groupImage.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(groupImage)
    }

    private func setupTitleLabel() {
        titleLabel.text = "New Group"
        titleLabel.textAlignment = .center
        titleLabel.textColor = CometChatTheme.textColorPrimary
        titleLabel.font = CometChatTypography.Heading2.medium
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
    }

    private func setupCloseButton() {
        closeButton.setImage(UIImage(systemName: "xmark")?.withRenderingMode(.alwaysTemplate), for: .normal)
        closeButton.tintColor = .black
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
    }

    private func setupTypeLabel() {
        typeLabel.text = "Type"
        typeLabel.font = CometChatTypography.Caption1.medium
        typeLabel.textColor = CometChatTheme.textColorPrimary
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(typeLabel)
    }

    private func setupSegmentedControl() {
        segmentedControl.backgroundColor = CometChatTheme.backgroundColor01
        segmentedControl.selectedSegmentTintColor = CometChatTheme.backgroundColor01
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.isOpaque = true
        
        let normalTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: CometChatTheme.textColorSecondary,
            .font: CometChatTypography.Body.regular
        ]
        segmentedControl.setTitleTextAttributes(normalTextAttributes, for: .normal)
        
        let selectedTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: CometChatTheme.textColorHighlight,
            .font: CometChatTypography.Body.medium
        ]
        segmentedControl.setTitleTextAttributes(selectedTextAttributes, for: .selected)
        
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(segmentedControl)
    }

    private func setupNameFields() {
        nameLabel.text = "Name"
        nameLabel.font = CometChatTypography.Caption1.medium
        nameLabel.textColor = CometChatTheme.textColorPrimary
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        nameTextField.placeholder = "Enter the group name"
        nameTextField.attributedPlaceholder = NSAttributedString(
            string: "Enter the group name",
            attributes: [NSAttributedString.Key.foregroundColor: CometChatTheme.textColorTertiary, .font: CometChatTypography.Body.regular]
        )
        nameTextField.borderStyle = .none
        nameTextField.backgroundColor = .clear
        nameTextFieldView.backgroundColor = CometChatTheme.backgroundColor02
        nameTextFieldView.layer.borderWidth = 1
        nameTextFieldView.layer.borderColor = CometChatTheme.borderColorLight.cgColor
        nameTextFieldView.layer.cornerRadius = 8
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        nameTextFieldView.translatesAutoresizingMaskIntoConstraints = false
        nameTextFieldView.addSubview(nameTextField)
    }

    private func setupPasswordFields() {
        passwordLabel.text = "Password"
        passwordLabel.font = CometChatTypography.Caption1.medium
        passwordLabel.textColor = CometChatTheme.textColorPrimary
        passwordLabel.translatesAutoresizingMaskIntoConstraints = false

        passwordTextField.placeholder = "Enter the password"
        passwordTextField.attributedPlaceholder = NSAttributedString(
            string: "Enter the password",
            attributes: [NSAttributedString.Key.foregroundColor: CometChatTheme.textColorTertiary, .font: CometChatTypography.Body.regular]
        )
        passwordTextField.borderStyle = .none
        passwordTextField.backgroundColor = .clear
        passwordTextFieldView.backgroundColor = CometChatTheme.backgroundColor02
        passwordTextFieldView.layer.borderWidth = 1
        passwordTextFieldView.layer.borderColor = CometChatTheme.borderColorLight.cgColor
        passwordTextFieldView.layer.cornerRadius = 8
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextFieldView.translatesAutoresizingMaskIntoConstraints = false
        passwordTextFieldView.addSubview(passwordTextField)

        passwordLabel.isHidden = true
        passwordTextFieldView.isHidden = true
    }

    private func setupFieldsStackView() {
        fieldsStackView.axis = .vertical
        fieldsStackView.distribution = .fill
        fieldsStackView.alignment = .fill
        fieldsStackView.spacing = 20
        fieldsStackView.translatesAutoresizingMaskIntoConstraints = false
        fieldsStackView.addArrangedSubview(nameLabel)
        fieldsStackView.setCustomSpacing(4, after: nameLabel)
        fieldsStackView.addArrangedSubview(nameTextFieldView)
        fieldsStackView.addArrangedSubview(passwordLabel)
        fieldsStackView.setCustomSpacing(4, after: passwordLabel)
        fieldsStackView.addArrangedSubview(passwordTextFieldView)
        contentView.addSubview(fieldsStackView)
    }

    private func setupCreateGroupButton() {
        createGroupButton.setTitle("Create Group", for: .normal)
        createGroupButton.backgroundColor = CometChatTheme.primaryColor
        createGroupButton.setTitleColor(CometChatTheme.buttonTextColor, for: .normal)
        createGroupButton.titleLabel?.font = CometChatTypography.Button.medium
        createGroupButton.layer.cornerRadius = 8
        createGroupButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(createGroupButton)
    }

    // MARK: - Constraints Setup
    private func setupScrollView() {
        // Add the scroll view and content view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Set scroll view constraints
        scrollViewBottomAnchor = scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            scrollViewBottomAnchor!,
        ])
        
        // Set content view constraints
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor), // Important for vertical scrolling
        ])
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Group Image Constraints
            groupImageBackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            groupImageBackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32),
            groupImageBackView.heightAnchor.constraint(equalToConstant: 80),
            groupImageBackView.widthAnchor.constraint(equalToConstant: 80),
            groupImage.centerXAnchor.constraint(equalTo: groupImageBackView.centerXAnchor),
            groupImage.centerYAnchor.constraint(equalTo: groupImageBackView.centerYAnchor),
            groupImage.heightAnchor.constraint(equalToConstant: 48),
            groupImage.widthAnchor.constraint(equalToConstant: 48),
            
            // Title Label Constraints
            titleLabel.topAnchor.constraint(equalTo: groupImageBackView.bottomAnchor, constant: 8),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 24),
            nameLabel.heightAnchor.constraint(equalToConstant: 14),
            passwordLabel.heightAnchor.constraint(equalToConstant: 14),
            typeLabel.heightAnchor.constraint(equalToConstant: 14),

            // Type Label Constraints
            typeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            typeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            // Segmented Control Constraints
            segmentedControl.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 4),
            segmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            segmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            segmentedControl.heightAnchor.constraint(equalToConstant: 28),
            
            nameTextField.leadingAnchor.constraint(equalTo: nameTextFieldView.leadingAnchor, constant: 8),
            nameTextField.trailingAnchor.constraint(equalTo: nameTextFieldView.trailingAnchor, constant: -8),
            nameTextField.topAnchor.constraint(equalTo: nameTextFieldView.topAnchor),
            nameTextField.bottomAnchor.constraint(equalTo: nameTextFieldView.bottomAnchor),
            nameTextFieldView.heightAnchor.constraint(equalToConstant: 36),
            nameTextField.heightAnchor.constraint(equalToConstant: 36),
            
            passwordTextField.leadingAnchor.constraint(equalTo: passwordTextFieldView.leadingAnchor, constant: 8),
            passwordTextField.trailingAnchor.constraint(equalTo: passwordTextFieldView.trailingAnchor, constant: -8),
            passwordTextField.topAnchor.constraint(equalTo: passwordTextFieldView.topAnchor),
            passwordTextField.bottomAnchor.constraint(equalTo: passwordTextFieldView.bottomAnchor),
            passwordTextFieldView.heightAnchor.constraint(equalToConstant: 36),

            // Fields Stack View Constraints
            fieldsStackView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
            fieldsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            fieldsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Create Group Button Constraints
            createGroupButton.topAnchor.constraint(equalTo: fieldsStackView.bottomAnchor, constant: 30),
            createGroupButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            createGroupButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            createGroupButton.heightAnchor.constraint(equalToConstant: 40),
            createGroupButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20), // Important for scrollable content
        ])
    }
}

extension CreateGroupVC{
    // MARK: - Actions
    @objc private func closeTapped() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func segmentedControlValueChanged() {
        let isPasswordGroup = segmentedControl.selectedSegmentIndex == 2
        
        UIView.animate(withDuration: 0.3, animations: {
            if isPasswordGroup {
                // Slide the password fields into view
                self.passwordLabel.isHidden = false
                self.passwordTextFieldView.isHidden = false
                
                self.passwordLabel.alpha = 1
                self.passwordTextFieldView.alpha = 1
                
                if #available(iOS 15.0, *) {
                    let newHeight = 440
                    self.manageSheetHeight(height: newHeight)
                } else {
                    // Fallback on earlier versions
                }
                // Adjust any layout if necessary (optional)
                self.fieldsStackView.layoutIfNeeded()
            } else {
                // Slide the password fields out of view
                if #available(iOS 15.0, *) {
                    let newHeight = 356
                    self.manageSheetHeight(height: newHeight)
                } else {
                    // Fallback on earlier versions
                }
                self.passwordLabel.alpha = 0
                self.passwordTextFieldView.alpha = 0
                self.passwordLabel.isHidden = true
                self.passwordTextFieldView.isHidden = true
            }
        }, completion: { _ in
            if !isPasswordGroup {
                // After the animation is done, fully hide the fields (no visible space)
                self.passwordLabel.isHidden = true
                self.passwordTextFieldView.isHidden = true
            }
        })
    }

    @objc private func createGroupButtonTapped() {
        guard let groupName = nameTextField.text, !groupName.isEmpty else {
            showError(message: "Group name cannot be empty")
            return
        }

        if segmentedControl.selectedSegmentIndex == 2,
           let password = passwordTextField.text, password.isEmpty {
            showError(message: "Password cannot be empty for a password-protected group")
            return
        }

        createGroup()
    }
    
    private func configureSegmentedControl() {
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
    }
}

extension CreateGroupVC{
    // MARK: - Helper Methods
    private func createGroup() {
        showLoader()
        
        guard let groupName = nameTextField.text else { return }
        var password: String?
        var groupType: CometChat.groupType = .public
        
        if segmentedControl.selectedSegmentIndex == 0{
            groupType = .public
        }else if segmentedControl.selectedSegmentIndex == 1{
            groupType = .private
        }else{
            groupType = .password
            password = self.passwordTextField.text ?? ""
        }
        
        let group = Group(guid: "group_\(Int(Date().timeIntervalSince1970 * 100))", name: groupName, groupType: groupType, password: password)
        
        CometChat.createGroup(group: group) { [weak self] group in
            DispatchQueue.main.async {
                self?.handleGroupCreationSuccess(group)
                CometChatUIKitHelper.onGroupCreated(group: group)
            }
        } onError: { [weak self] error in
            self?.handleGroupCreationError(error)
        }
    }

    private func handleGroupCreationSuccess(_ group: Group) {
        success?(group)
        dismiss(animated: true) {
            self.openGroupChat?(group)
        }
        hideLoader()
    }

    private func handleGroupCreationError(_ error: CometChatException?) {
        if let error = error {
            failure?(error)
        }
        hideLoader()
    }

    private func showError(message: String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func showLoader() {
        if loadingIndicator == nil {
            loadingIndicator = UIActivityIndicatorView(style: .medium)
            loadingIndicator?.translatesAutoresizingMaskIntoConstraints = false
            createGroupButton.addSubview(loadingIndicator!)
            
            NSLayoutConstraint.activate([
                loadingIndicator!.centerXAnchor.constraint(equalTo: createGroupButton.centerXAnchor),
                loadingIndicator!.centerYAnchor.constraint(equalTo: createGroupButton.centerYAnchor)
            ])
        }

        createGroupButton.setTitle("", for: .normal)
        loadingIndicator?.startAnimating()
    }

    private func hideLoader() {
        DispatchQueue.main.async {
            self.loadingIndicator?.stopAnimating()
            self.createGroupButton.setTitle("Create Group", for: .normal)
        }
    }
    
    private func manageSheetHeight(height: Int){
        if #available(iOS 15.0, *) {
            if let sheetController = self.sheetPresentationController {
                if #available(iOS 16.0, *) {
                    let customDetent = UISheetPresentationController.Detent.custom { _ in
                        return CGFloat(height)
                    }
                    sheetController.detents = [customDetent]
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
}
