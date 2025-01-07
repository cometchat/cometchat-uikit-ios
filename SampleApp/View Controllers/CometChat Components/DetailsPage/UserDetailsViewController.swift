//
//  DeatilsViewController.swift
//  Sample App
//
//  Created by Suryansh on 22/07/24.
//

import UIKit
import CometChatSDK
import CometChatUIKitSwift

class UserDetailsViewController: UIViewController {

    // MARK: - UI Components
    public var user: User?
    
    public lazy var userImageView: CometChatAvatar = {
        let imageView = CometChatAvatar(frame: .null)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setAvatar(avatarUrl: user?.avatar ?? "", with: user?.name ?? "")
        imageView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        imageView.layer.cornerRadius = 60
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.style.textFont = CometChatTypography.Title.bold
        return imageView
    }()
    
    public lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.text = user?.name ?? ""
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = CometChatTypography.Heading2.medium
        label.textColor = CometChatTheme.textColorPrimary
        label.textAlignment = .center
        return label
    }()
    
    public lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = user?.status == .online ? "Online" : "Offline"
        label.font = CometChatTypography.Caption1.regular
        label.textColor = CometChatTheme.textColorSecondary
        label.textAlignment = .center
        return label
    }()
    
    public lazy var buttonContainerStackView : UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = CometChatSpacing.Padding.p2
        stackView.heightAnchor.constraint(equalToConstant: 75).isActive = true
        return stackView
    }()
    
    public lazy var separatorView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = CometChatTheme.borderColorLight
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 2).isActive = true
        return view
    }()
    
    #if canImport(CometChatCallsSDK)
    public lazy var audioCallButton: CometChatCallButtons = {
        let callButton = CometChatCallButtons(width: 40, height: 75)
        callButton.set(controller: self)
        callButton.style.audioCallIconTint = CometChatTheme.primaryColor
        callButton.style.audioCallIconTint = CometChatTheme.primaryColor
        callButton.style.audioCallTextFont = CometChatTypography.Body.regular
        callButton.style.audioCallTextColor = CometChatTheme.textColorSecondary
        callButton.translatesAutoresizingMaskIntoConstraints = false
        callButton.hide(videoCall: true)
        if let user = user { callButton.set(user: user) }
        callButton.set(voiceCallIconText: "Voice")
        callButton.layer.borderWidth = 1
        callButton.layer.borderColor = CometChatTheme.borderColorDefault.cgColor
        callButton.layer.cornerRadius = 8
        if let user = user { callButton.set(user: user) }
        return callButton
    }()
    
    public lazy var videoCallButton: CometChatCallButtons = {
        let callButton = CometChatCallButtons(width: 40, height: 75)
        callButton.set(controller: self)
        callButton.style.videoCallIconTint = CometChatTheme.primaryColor
        callButton.style.videoCallTextFont = CometChatTypography.Body.regular
        callButton.style.videoCallTextColor = CometChatTheme.textColorSecondary
        callButton.translatesAutoresizingMaskIntoConstraints = false
        callButton.hide(voiceCall: true)
        if let user = user { callButton.set(user: user) }
        callButton.set(videoCallIconText: "Video")
        callButton.layer.borderWidth = 1
        callButton.layer.borderColor = CometChatTheme.borderColorDefault.cgColor
        callButton.layer.cornerRadius = 8
        if let user = user { callButton.set(user: user) }
        return callButton
    }()
    #endif
    
    public var listenerRandomID = Date().timeIntervalSince1970
    
    public lazy var blockButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "block_image"), for: .normal)
        
        if user?.blockedByMe == false {
            button.tag = 0 // tag = 0 is blocked, tag = 1 is unblocked
            button.setTitle("Block", for: .normal)
            button.setTitleColor(CometChatTheme.errorColor, for: .normal)
            button.tintColor = CometChatTheme.errorColor
        } else {
            button.tag = 1
            button.setTitle("Unblock", for: .normal)
            button.tintColor = CometChatTheme.successColor
            button.setTitleColor(CometChatTheme.successColor, for: .normal)
        }
        
        // Set spacing between the image and title
        let spacing: CGFloat = 8.0
        button.imageView?.contentMode = .scaleAspectFit
        
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -spacing)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -spacing, bottom: 0, right: 0)
        button.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        // Ensure content is centered
        button.addTarget(self, action: #selector(showBlockAlert), for: .primaryActionTriggered)
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.titleLabel?.font = CometChatTypography.Heading4.regular
        return button
    }()
    
    public lazy var deleteChatButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Delete Chat", for: .normal)
        button.setTitleColor(CometChatTheme.errorColor, for: .normal)
        button.setImage(UIImage(systemName: "trash"), for: .normal)
        button.tintColor = CometChatTheme.errorColor
        button.addTarget(self, action: #selector(showDeleteAlert), for: .primaryActionTriggered)
        
        let spacing: CGFloat = 8.0
        button.imageView?.contentMode = .scaleAspectFit
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: -spacing)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -spacing, bottom: 0, right: 0)
        button.heightAnchor.constraint(equalToConstant: 24).isActive = true
        button.titleLabel?.font = CometChatTypography.Heading4.regular
        
        return button
    }()

    
    // MARK: - Lifecycle Methods
    override public func viewDidLoad() {
        super.viewDidLoad()
        connect()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        setupLayout()
        setupNavigationBar()
    }
    
    deinit {
        disconnect()
    }
    
    // MARK: - Setup Navigation Bar
    public func setupNavigationBar() {
        navigationItem.title = "User Info"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = CometChatTheme.iconColorPrimary
    }
    
    // MARK: - Setup Layout
    public func setupLayout() {
        
        view.backgroundColor = CometChatTheme.backgroundColor01
        
        var constantsToActive = [NSLayoutConstraint]()
        
        view.addSubview(userImageView)
        constantsToActive += [
            userImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
            userImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0)
        ]
        
        view.addSubview(userNameLabel)
        constantsToActive += [
            userNameLabel.topAnchor.constraint(equalTo: userImageView.bottomAnchor, constant: CometChatSpacing.Padding.p3),
            userNameLabel.centerXAnchor.constraint(equalTo: userImageView.centerXAnchor, constant: 0)
        ]
        
        view.addSubview(statusLabel)
        constantsToActive += [
            statusLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 3),
            statusLabel.centerXAnchor.constraint(equalTo: userNameLabel.centerXAnchor, constant: 0)
        ]
        
        view.addSubview(buttonContainerStackView)
        #if canImport(CometChatCallsSDK)
        buttonContainerStackView.addArrangedSubview(audioCallButton)
        buttonContainerStackView.addArrangedSubview(videoCallButton)
        #endif
        constantsToActive += [
            buttonContainerStackView.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: CometChatSpacing.Padding.p5),
            buttonContainerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 60),
            buttonContainerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60)
        ]
        
        view.addSubview(separatorView)
        constantsToActive += [
            separatorView.topAnchor.constraint(equalTo: buttonContainerStackView.bottomAnchor, constant: CometChatSpacing.Padding.p5),
            separatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]
        
        view.addSubview(blockButton)
        constantsToActive += [
            blockButton.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: CometChatSpacing.Padding.p5),
            blockButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: CometChatSpacing.Padding.p5),
        ]
        
        view.addSubview(deleteChatButton)
        constantsToActive += [
            deleteChatButton.topAnchor.constraint(equalTo: blockButton.bottomAnchor, constant: CometChatSpacing.Padding.p5),
            deleteChatButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: CometChatSpacing.Padding.p5),
        ]
        
        NSLayoutConstraint.activate(constantsToActive)
    } 
    
    @objc func showBlockAlert(){
        if blockButton.tag == 0 {
            self.showAlert("Block \(user?.name ?? "")", "Are you sure you want to block \(user?.name ?? "").", "Cancel", "Block", onActionsTriggered: { [weak self] in
                if let user = self?.user {
                    CometChat.blockUsers([user.uid ?? ""]) { success in
                        DispatchQueue.main.async {
                            user.blockedByMe = true
                            CometChatUserEvents.ccUserBlocked(user: user)
                            self?.blockButton.tag = 1
                            self?.blockButton.setTitle("Unblock", for: .normal)
                            self?.blockButton.tintColor = CometChatTheme.successColor
                            self?.blockButton.setTitleColor(CometChatTheme.successColor, for: .normal)
                        }
                    } onError: { error in
                        //TODO: ERROR
                    }
                }
            })
        } else {
            CometChat.unblockUsers([user?.uid ?? ""]) { [weak self] success in
                DispatchQueue.main.async {
                    if let user = self?.user {
                        user.blockedByMe = false
                        CometChatUserEvents.ccUserUnblocked(user: user)
                    }
                    self?.blockButton.tag = 0
                    self?.blockButton.setTitle("Block", for: .normal)
                    self?.blockButton.setTitleColor(CometChatTheme.errorColor, for: .normal)
                    self?.blockButton.tintColor = CometChatTheme.errorColor
                }
            } onError: { error in
                //TODO: ERROR
            }
        }
    }
    
    @objc func showDeleteAlert(){
        self.showAlert("Delete Chat", "Are you sure you want to delete this chat. This action cannot be undone.", "Cancel", "Delete", onActionsTriggered: { [weak self] in
            if let user = self?.user {
                CometChat.deleteConversation(conversationWith: user.uid ?? "", conversationType: .user) { [weak self] message in
                    DispatchQueue.main.async {
                        self?.navigationController?.popToViewController(ofClass: HomeScreenViewController.self, animated: true)
                    }
                } onError: { error in
                    //TODO: ERROR
                }

            }
        })
    }
    
    
    func connect() {
        CometChat.addUserListener("group-info-groups-event-listner-\(listenerRandomID)", self)
        CometChatUserEvents.addListener("group-info-groups-event-listner-\(listenerRandomID)", self)
    }
    
    func disconnect() {
        CometChat.removeUserListener("group-info-groups-event-listner-\(listenerRandomID)")
        CometChatUserEvents.removeListener("group-info-groups-event-listner-\(listenerRandomID)")
    }
}

extension UserDetailsViewController: CometChatUserEventListener, CometChatUserDelegate {
    
    func onUserOnline(user: User) {
        statusLabel.text = "Online"
    }
    
    func onUserOffline(user: User) {
        statusLabel.text = "Offline"
    }
    
    func ccUserBlocked(user: User) {
        statusLabel.text = "Offline"
    }
    
    func ccUserUnblocked(user: User) {
        statusLabel.text = user.status == .online ? "Online" : "Offline"
    }
    
}

extension UINavigationController {
  func popToViewController(ofClass: AnyClass, animated: Bool = true) {
    if let vc = viewControllers.last(where: { $0.isKind(of: ofClass) }) {
      popToViewController(vc, animated: animated)
    }
  }
}
