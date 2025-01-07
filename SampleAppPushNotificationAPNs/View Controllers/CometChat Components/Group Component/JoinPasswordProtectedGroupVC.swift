//
//  JoinPasswordProtectedGroupVC.swift
//  Sample App
//
//  Created by Dawinder on 21/10/24.
//

import Foundation
import UIKit
import CometChatSDK
import CometChatUIKitSwift

class JoinPasswordProtectedGroupVC: UIViewController {
    
    // Optional group object representing the group to join
    var group: Group?

    // Create a CometChatAvatar for displaying the group image
    let groupImageView: CometChatAvatar = {
        let imageView = CometChatAvatar(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 30 // Set circular corners for the image
        imageView.layer.masksToBounds = true // Ensure image respects corner radius
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // Label for "Join Group" heading
    let joinGroupLabel: UILabel = {
        let label = UILabel()
        label.text = "Join Group"
        label.font = CometChatTypography.Heading2.bold // Apply heading font style
        label.textColor = CometChatTheme.textColorPrimary // Use primary theme color
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Label for displaying the group name
    let groupNameLabel: UILabel = {
        let label = UILabel()
        label.font = CometChatTypography.Heading4.medium // Medium heading style
        label.textColor = CometChatTheme.textColorPrimary // Primary text color
        label.textAlignment = .center
        label.numberOfLines = 0 // Allow multiple lines
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Label for displaying the number of members in the group
    let groupMembersLabel: UILabel = {
        let label = UILabel()
        label.font = CometChatTypography.Caption1.regular // Caption style font
        label.textColor = CometChatTheme.textColorSecondary // Secondary text color
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Label to prompt the user to enter the group password
    let passwordLabel: UILabel = {
        let label = UILabel()
        label.font = CometChatTypography.Caption1.medium // Caption font for password label
        label.textColor = CometChatTheme.textColorPrimary // Primary text color
        label.text = "Enter Password" // Default text for the label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // View container for password text field
    let passwordTextFieldView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8 // Rounded corners for the container
        view.layer.borderWidth = 1 // Add border to the container
        view.layer.borderColor = CometChatTheme.borderColorLight.cgColor // Light border color
        view.backgroundColor = CometChatTheme.backgroundColor02 // Background color from the theme
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // TextField for entering the password
    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter the password" // Placeholder text
        textField.attributedPlaceholder = NSAttributedString(
            string: "Enter the password",
            attributes: [NSAttributedString.Key.foregroundColor: CometChatTheme.textColorTertiary, .font: CometChatTypography.Body.regular]
        ) // Custom attributes for the placeholder
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // Label to display error messages when the password is invalid
    let errorLabel: UILabel = {
        let label = UILabel()
        label.text = "Invalid password. Please try again." // Error message text
        label.font = CometChatTypography.Caption1.regular // Font style for the error label
        label.textColor = CometChatTheme.errorColor // Error color from the theme
        label.numberOfLines = 0 // Allow multiple lines for the error message
        label.isHidden = true // Initially hidden
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Button to initiate the action of joining the group
    let joinGroupButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Join Group", for: .normal) // Button title
        button.backgroundColor = CometChatTheme.primaryColor // Button background color
        button.titleLabel?.font = CometChatTypography.Button.medium // Button font style
        button.setTitleColor(.white, for: .normal) // Text color
        button.layer.cornerRadius = 8 // Rounded corners for the button
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Closure to be called when the group is successfully joined
    var onGroupJoined: ((_ group: Group) -> ())?
    
    // Activity indicator to show loading state
    private var loadingIndicator: UIActivityIndicatorView?
    
    // Called when the view has loaded into memory
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up view background color and corner radius
        view.backgroundColor = CometChatTheme.backgroundColor01
        view.layer.cornerRadius = 16

        // Add a tap gesture recognizer to dismiss the keyboard when tapping outside the text field
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)

        // Set up the button's tap action
        joinGroupButton.addTarget(self, action: #selector(joinGroupTapped), for: .touchUpInside)
        
        // Add UI elements to the view
        view.addSubview(joinGroupLabel)
        view.addSubview(groupImageView)
        view.addSubview(groupNameLabel)
        view.addSubview(groupMembersLabel)
        view.addSubview(passwordLabel)
        view.addSubview(passwordTextFieldView)
        passwordTextFieldView.addSubview(passwordTextField)
        view.addSubview(errorLabel)
        view.addSubview(joinGroupButton)
        
        // Set up layout constraints
        setupConstraints()
        setupUI() // Update the UI with the current group data
    }
    
    // Dismiss the keyboard when the user taps outside the text field
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    // Set up Auto Layout constraints for the UI elements
    func setupConstraints() {
        NSLayoutConstraint.activate([
            // Join group label constraints
            joinGroupLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
            joinGroupLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Group image constraints
            groupImageView.topAnchor.constraint(equalTo: joinGroupLabel.bottomAnchor, constant: 28),
            groupImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            groupImageView.widthAnchor.constraint(equalToConstant: 60),
            groupImageView.heightAnchor.constraint(equalToConstant: 60),
            
            // Group name label constraints
            groupNameLabel.topAnchor.constraint(equalTo: groupImageView.bottomAnchor, constant: 12),
            groupNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            groupNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            // Group members label constraints
            groupMembersLabel.topAnchor.constraint(equalTo: groupNameLabel.bottomAnchor, constant: 4),
            groupMembersLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Password label constraints
            passwordLabel.topAnchor.constraint(equalTo: groupMembersLabel.bottomAnchor, constant: 28),
            passwordLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            passwordLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            // Password text field view constraints
            passwordTextFieldView.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: 4),
            passwordTextFieldView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            passwordTextFieldView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            passwordTextFieldView.heightAnchor.constraint(equalToConstant: 40),
            
            // Password text field constraints
            passwordTextField.topAnchor.constraint(equalTo: passwordTextFieldView.topAnchor),
            passwordTextField.bottomAnchor.constraint(equalTo: passwordTextFieldView.bottomAnchor),
            passwordTextField.leadingAnchor.constraint(equalTo: passwordTextFieldView.leadingAnchor, constant: 8),
            passwordTextField.trailingAnchor.constraint(equalTo: passwordTextFieldView.trailingAnchor, constant: -8),
            
            // Error label constraints
            errorLabel.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 10),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            // Join group button constraints
            joinGroupButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 20),
            joinGroupButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            joinGroupButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            joinGroupButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // Update UI elements with group data
    private func setupUI(){
        groupImageView.setAvatar(avatarUrl: group?.icon ?? "", with: group?.name ?? "") // Set group avatar
        groupNameLabel.text = group?.name ?? "" // Set group name
        groupMembersLabel.text = "\(group?.membersCount ?? 0) \("members")" // Set group members count
    }
    
    // Action handler for join group button
    @objc func joinGroupTapped() {
        guard let group = group, let groupPassword = passwordTextField.text else { return }
        if groupPassword.isEmpty {
            showError("Please enter the group password.") // Show error if no password entered
            return
        }
        
        startLoadingIndicator() // Show loading indicator while joining
        joinGroup(with: groupPassword, for: group) { [weak self] success in
            self?.stopLoadingIndicator() // Stop loading indicator when done
            if success {
                // Trigger the onGroupJoined closure if the group was joined successfully
                if let onGroupJoined = self?.onGroupJoined {
                    onGroupJoined(group)
                }
            } else {
                self?.showError("Invalid password. Please try again.") // Show error on failure
            }
        }
    }
    
    // Show error message on the error label
    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false // Display the error message
    }
    
    // Method to simulate the process of joining a group
    private func joinGroup(with password: String, for group: Group, completion: @escaping (Bool) -> Void) {
        CometChat.joinGroup(GUID: group.guid, groupType: .password, password: password) { joinSuccess in
            DispatchQueue.main.async {
                completion(true)
            }
        } onError: { error in
            DispatchQueue.main.async {
                completion(false)
            }
        }
    }
    
    // Start the loading indicator to show that a process is ongoing
    private func startLoadingIndicator() {
        if loadingIndicator == nil {
            loadingIndicator = UIActivityIndicatorView(style: .medium)
            loadingIndicator?.color = CometChatTheme.white
            loadingIndicator?.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(loadingIndicator!)
            NSLayoutConstraint.activate([
                loadingIndicator!.centerXAnchor.constraint(equalTo: joinGroupButton.centerXAnchor),
                loadingIndicator!.centerYAnchor.constraint(equalTo: joinGroupButton.centerYAnchor)
            ])
        }
        loadingIndicator?.startAnimating() // Start the animation
        joinGroupButton.setTitle("", for: .normal) // Hide button title while loading
    }
    
    // Stop the loading indicator and restore the button state
    private func stopLoadingIndicator() {
        loadingIndicator?.stopAnimating() // Stop the animation
        joinGroupButton.setTitle("Join Group", for: .normal) // Restore the button title
    }
}

