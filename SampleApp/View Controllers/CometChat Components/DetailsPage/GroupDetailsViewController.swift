//
//  GroupInfoViewController.swift
//  Sample App
//
//  Created by Dawinder on 20/10/24.
//

import Foundation
import UIKit
import CometChatSDK
import CometChatUIKitSwift

class GroupDetailsViewController: UIViewController {

    // MARK: - UI Components
    public let scrollView = UIScrollView()
    public let contentView = UIView()
    public var group : Group?
    
    public let topStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.alignment = .center
        view.distribution = .fill
        view.spacing = 20
        return view
    }()
    
    public let groupErrorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = CometChatTheme.warningColor
        view.heightAnchor.constraint(equalToConstant: 30).isActive = true
        return view
    }()
    
    public let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "info.circle")
        imageView.tintColor = CometChatTheme.iconColorPrimary
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        return imageView
    }()
    
    public let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "You are no longer part of this group"
        label.font = CometChatTypography.Heading4.regular
        label.textColor = CometChatTheme.textColorPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    public let errorstackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    public let groupImageView: CometChatAvatar = {
        let imageView = CometChatAvatar(frame: .zero)
        imageView.layer.cornerRadius = 60
        imageView.clipsToBounds = true
        imageView.style.textFont = CometChatTypography.Title.bold
        return imageView
    }()
    
    public let groupNameLabel: UILabel = {
        let label = UILabel()
        label.font = CometChatTypography.Heading2.medium
        label.textColor = CometChatTheme.textColorPrimary
        label.textAlignment = .center
        return label
    }()
    
    public let memberCountLabel: UILabel = {
        let label = UILabel()
        label.font = CometChatTypography.Caption1.regular
        label.textColor = CometChatTheme.textColorSecondary
        label.textAlignment = .center
        return label
    }()
    
    public let sepearatorView : UIView = {
        let view = UIView()
        view.backgroundColor = CometChatTheme.borderColorLight
        return view
    }()
    
    public let addMembersView = GroupActionView(title: "Add Members", image: UIImage(systemName: "person.badge.plus"))
    public let viewMembersView = GroupActionView(title: "View Members", image: UIImage(systemName: "person.2"))
    public let bannedMembersView = GroupActionView(title: "Banned Members", image: UIImage(named: "ban_member"))
    
    public var listenerRandomID = Date().timeIntervalSince1970
    public var onExitGroup: ((_ group: Group) -> ())?
    
    public let bottomContainerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = CometChatSpacing.Padding.p6
        stackView.distribution = .fillEqually
        stackView.alignment = .leading
        stackView.isUserInteractionEnabled = true
        return stackView
    }()
    
    public lazy var leaveButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 35).isActive = true
        button.setTitle("Leave", for: .normal)
        button.setTitleColor(CometChatTheme.errorColor, for: .normal)
        button.setImage(UIImage(systemName: "rectangle.portrait.and.arrow.right"), for: .normal)
        button.tintColor = CometChatTheme.errorColor
        
        // Set spacing between the image and title
        let spacing: CGFloat = 8.0
        button.imageView?.contentMode = .scaleAspectFit
        
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: -spacing)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -spacing, bottom: 0, right: 0)
        
        // Ensure content is centered
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.titleLabel?.font = CometChatTypography.Heading4.regular
        button.addTarget(self, action: #selector(showLeaveGroupAlert), for: .primaryActionTriggered)
        return button
    }()
    
    public lazy var deleteAndExitButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 35).isActive = true
        button.setTitle("Delete and Exit", for: .normal)
        button.setTitleColor(CometChatTheme.errorColor, for: .normal)
        button.setImage(UIImage(systemName: "trash"), for: .normal)
        button.tintColor = CometChatTheme.errorColor
        
        // Set spacing between the image and title
        let spacing: CGFloat = 8.0
        button.imageView?.contentMode = .scaleAspectFit
        
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: -spacing)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -spacing, bottom: 0, right: 0)
        
        // Ensure content is centered
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.titleLabel?.font = CometChatTypography.Heading4.regular
        button.addTarget(self, action: #selector(showDeleteGroupAlert), for: .primaryActionTriggered)
        
        return button
    }()

    
    // MARK: - Lifecycle Methods 
    override public func viewDidLoad() {
        super.viewDidLoad()
        connect()
        view.backgroundColor = CometChatTheme.backgroundColor01
        setupScrollView()
        setupLayout()
        addButtonActions()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        setupNavigationBar()
    }
    
    deinit {
        disconnect()
    }
    
    // MARK: - Setup Navigation Bar
    public func setupNavigationBar() {
        navigationItem.title = "Group Info"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = CometChatTheme.iconColorPrimary
    }
    
    @objc public func didTapBackButton() {
        // Handle back button tap
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Setup ScrollView and ContentView
    public func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
    }
    
    // MARK: - Setup Layout
    public func setupLayout() {
        [topStackView, groupImageView, groupNameLabel, memberCountLabel, sepearatorView, bottomContainerStackView].forEach { contentView.addSubview($0) }
        
        topStackView.addArrangedSubview(groupErrorView)
        topStackView.addArrangedSubview(groupImageView)
        groupErrorView.addSubview(errorstackView)
        errorstackView.addArrangedSubview(iconImageView)
        errorstackView.addArrangedSubview(messageLabel)
        
        errorstackView.leadingAnchor.constraint(equalTo: groupErrorView.leadingAnchor, constant: 16).isActive = true
        errorstackView.trailingAnchor.constraint(equalTo: groupErrorView.trailingAnchor, constant: -16).isActive = true
        errorstackView.topAnchor.constraint(equalTo: groupErrorView.topAnchor).isActive = true
        errorstackView.bottomAnchor.constraint(equalTo: groupErrorView.bottomAnchor).isActive = true
        
        groupImageView.translatesAutoresizingMaskIntoConstraints = false
        topStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20).isActive = true
        topStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        topStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        
        groupErrorView.leadingAnchor.constraint(equalTo: topStackView.leadingAnchor).isActive = true
        groupErrorView.trailingAnchor.constraint(equalTo: topStackView.trailingAnchor).isActive = true
        groupImageView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        groupImageView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        
        groupNameLabel.translatesAutoresizingMaskIntoConstraints = false
        groupNameLabel.topAnchor.constraint(equalTo: groupImageView.bottomAnchor, constant: 20).isActive = true
        groupNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        groupNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        
        memberCountLabel.translatesAutoresizingMaskIntoConstraints = false
        memberCountLabel.topAnchor.constraint(equalTo: groupNameLabel.bottomAnchor, constant: 8).isActive = true
        memberCountLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        
        // Create stack view for the buttons
        let buttonStackView = UIStackView(arrangedSubviews: [viewMembersView, addMembersView, bannedMembersView])
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 8
        contentView.addSubview(buttonStackView)
        
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.topAnchor.constraint(equalTo: memberCountLabel.bottomAnchor, constant: 20).isActive = true
        buttonStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        buttonStackView.trailingAnchor.constraint(greaterThanOrEqualTo: contentView.trailingAnchor, constant: -16).isActive = true
        buttonStackView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        sepearatorView.translatesAutoresizingMaskIntoConstraints = false
        sepearatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        sepearatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        sepearatorView.trailingAnchor.constraint(greaterThanOrEqualTo: contentView.trailingAnchor).isActive = true
        sepearatorView.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant: 20).isActive = true
        
        bottomContainerStackView.topAnchor.constraint(equalTo: sepearatorView.bottomAnchor, constant: 12).isActive = true
        bottomContainerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30).isActive = true
        bottomContainerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        bottomContainerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20).isActive = true
        bottomContainerStackView.addArrangedSubview(leaveButton)
        bottomContainerStackView.addArrangedSubview(deleteAndExitButton)
        
        groupNameLabel.text = group?.name
        memberCountLabel.text = "\(group?.membersCount ?? 0) \("MEMBERS".localize())"
        groupImageView.setAvatar(avatarUrl: group?.icon ?? "", with: group?.name ?? "")
        
        if let group = group { updateGroupInfo(group) }
        
        if let _ = group?.hasJoined{
            groupErrorView.isHidden = true
        }else{
            groupErrorView.isHidden = false
        }
    }
    
    @objc func showDeleteGroupAlert(){
        self.showAlert("Delete and Exit?", "Are you sure you want to delete this chat and exit the group? This action cannot be undone.", "Cancel", "Delete & Exit", onActionsTriggered: {
            if let group = self.group {
                CometChat.deleteGroup(GUID: group.guid) { deleteSuccess in
                    DispatchQueue.main.async { [weak self] in
                        CometChatGroupEvents.ccGroupDeleted(group: group)
                        self?.navigationController?.popToViewController(ofClass: HomeScreenViewController.self)
                        self?.onExitGroup?(group)
                    }
                } onError: { error in
                    print("Something want wrong")
                }
            }
        })
    }
    @objc func showLeaveGroupAlert(){
        if group?.owner == CometChat.getLoggedInUser()?.uid && (group?.membersCount ?? 0) > 1 {
            self.showAlert("Ownership Transfer", "You need to transfer ownership of this group to another group member before leaving this ground.", "Cancel", "Transfer", onActionsTriggered: {
                if let group = self.group {
                    let transferOwnership = TransferOwnership()
                    transferOwnership.set(group: group)
                    self.present(UINavigationController(rootViewController: transferOwnership), animated: true)
                }
            })
        } else {
            self.showAlert("Leave this group?", "Are you sure you want to leave this group? You won't receive any more messages from this chat.", "Cancel", "Leave", onActionsTriggered: {
                if let group = self.group {
                    CometChat.leaveGroup(GUID: group.guid) { leaveSuccess in
                        DispatchQueue.main.async { [weak self] in
                            print("group left")
                            self?.navigationController?.popToViewController(ofClass: HomeScreenViewController.self, animated: true)
                            if let user = CometChat.getLoggedInUser(), let group = self?.group {
                                
                                let actionMessage = ActionMessage()
                                actionMessage.action = .scopeChanged
                                actionMessage.conversationId = "group_\(group.guid)"
                                actionMessage.message = "\(user.name ?? "") left"
                                actionMessage.muid = "\(NSDate().timeIntervalSince1970)"
                                actionMessage.sender = user
                                actionMessage.receiver = group
                                actionMessage.actionBy = user
                                actionMessage.actionOn = user
                                actionMessage.receiverUid = group.guid
                                actionMessage.messageType = .groupMember
                                actionMessage.messageCategory = .action
                                actionMessage.receiverType = .group
                                actionMessage.sentAt = Int(Date().timeIntervalSince1970)
                                
                                group.hasJoined = false
                                group.membersCount = group.membersCount - 1
                                CometChatGroupEvents.ccGroupLeft(action: actionMessage, leftUser: user, leftGroup: group)
                            }
                            self?.onExitGroup?(group)
                        }
                    } onError: { error in
                        print("Something want wrong")
                    }
                }
            })
        }
    }
    
    public func showHideOptions(hideViewMembers:Bool, hideAddMembers:Bool, hideBannMembers: Bool, hideLeaveGroup: Bool, hideDeleteGroup: Bool){
        self.viewMembersView.isHidden = hideViewMembers
        self.addMembersView.isHidden = hideAddMembers
        self.bannedMembersView.isHidden = hideBannMembers
        self.leaveButton.isHidden = hideLeaveGroup
        self.deleteAndExitButton.isHidden = hideDeleteGroup
    }
    
    func connect() {
        CometChat.addGroupListener("group-info-groups-sdk-listner-\(listenerRandomID)", self)
        CometChatGroupEvents.addListener("group-info-groups-event-listner-\(listenerRandomID)", self)
    }
    
    func disconnect() {
        CometChat.removeGroupListener("group-info-groups-sdk-listner-\(listenerRandomID)")
        CometChatGroupEvents.removeListener("group-info-groups-event-listner-\(listenerRandomID)")
    }
}

extension GroupDetailsViewController{
    
    public func addButtonActions(){
        viewMembersView.onActionButtonTapped = {
            self.viewMembers()
        }
        addMembersView.onActionButtonTapped = {
            self.addMembers()
        }
        bannedMembersView.onActionButtonTapped = {
            self.bannMembers()
        }
    }
    
    public func viewMembers(){
        if let group = self.group {
            let groupMembers = CometChatGroupMembers()
            groupMembers.set(group: group)
            let navController = UINavigationController(rootViewController: groupMembers)
            self.present(navController, animated: true, completion: nil)
        }
    }
    
    public func bannMembers(){
        if let group = self.group {
            let bannedMembers = BannedMembersVC(group: group)
            let navController = UINavigationController(rootViewController: bannedMembers)
            self.present(navController, animated: true, completion: nil)
        }
    }
    
    public func addMembers(){
        if let group = self.group {
            let addMemberController = AddMembersVC(group: group)
            let navController = UINavigationController(rootViewController: addMemberController)
            self.present(navController, animated: true, completion: nil)
        }
    }
}

// MARK: - Custom View for Group Action Buttons
class GroupActionView: UIView {
    // Closure for button action
    var onActionButtonTapped: (() -> Void)?
    
    var actionButton = UIButton(type: .system)
    var imageView = UIImageView()
    var titleLabel = UILabel()
    
    init(title: String, image: UIImage?) {
        super.init(frame: .zero)
        setup(title: title, image: image)
        configureButtonAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup(title: String, image: UIImage?) {
        // Configure image view
        imageView.image = image
        imageView.tintColor = CometChatTheme.iconColorHighlight
        imageView.contentMode = .scaleAspectFit
        
        // Configure title label
        titleLabel.text = title
        titleLabel.textColor = CometChatTheme.textColorSecondary
        titleLabel.font = CometChatTypography.Caption1.regular
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.adjustsFontSizeToFitWidth = true
        
        // Configure action button
        actionButton.setTitle("", for: .normal) // Button is here just for interaction purposes
        
        // Add subviews
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(actionButton)
        
        // Add border to the view
        layer.borderWidth = 1
        layer.borderColor = CometChatTheme.borderColorDefault.cgColor
        layer.cornerRadius = 8
        
        // Layout constraints
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 24),
            imageView.widthAnchor.constraint(equalToConstant: 24),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            
            actionButton.topAnchor.constraint(equalTo: topAnchor),
            actionButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            actionButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            actionButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            widthAnchor.constraint(equalToConstant: 113)
        ])
    }
    
    // Configure button action
    public func configureButtonAction() {
        actionButton.addTarget(self, action: #selector(didTapActionButton), for: .touchUpInside)
    }
    
    // Button action handler
    @objc private func didTapActionButton() {
        onActionButtonTapped?() // Trigger the closure when the button is tapped
    }
}

//MARK: - Group Event Listeners for real time updates
extension GroupDetailsViewController: CometChatGroupDelegate, CometChatGroupEventListener{
    
    func onGroupMemberJoined(action: ActionMessage, joinedUser: User, joinedGroup: Group) {
        if joinedGroup.guid == self.group?.guid {
            updateGroupInfo(joinedGroup) //updating group count
        }
    }
    
    func onMemberAddedToGroup(action: ActionMessage, addedBy: User, addedUser: User, addedTo: Group) {
        if addedTo.guid == self.group?.guid {
            updateGroupInfo(addedTo) //updating group count
        }
    }
    
    func onGroupMemberLeft(action: ActionMessage, leftUser: User, leftGroup: Group) {
        if leftGroup.guid == self.group?.guid {
            if CometChat.getLoggedInUser()?.uid == leftUser.uid{
                groupErrorView.isHidden = false
                self.view.isUserInteractionEnabled = false
                self.showHideOptions(hideViewMembers: true, hideAddMembers: true, hideBannMembers: true, hideLeaveGroup: true, hideDeleteGroup: true) //hiding all the options
            } else {
                updateGroupInfo(leftGroup)
            }
        }
    }
    
    func onGroupMemberKicked(action: ActionMessage, kickedUser: User, kickedBy: User, kickedFrom: Group) {
        if kickedFrom.guid == self.group?.guid {
            if CometChat.getLoggedInUser()?.uid == kickedUser.uid{
                groupErrorView.isHidden = false
                self.view.isUserInteractionEnabled = false
                self.showHideOptions(hideViewMembers: true, hideAddMembers: true, hideBannMembers: true, hideLeaveGroup: true, hideDeleteGroup: true) //hiding all the options
            } else {
                updateGroupInfo(kickedFrom)
            }
        }
    }
    
    public func onGroupMemberBanned(action: ActionMessage, bannedUser: User, bannedBy: User, bannedFrom: Group) {
        if bannedFrom.guid == self.group?.guid {
            if CometChat.getLoggedInUser()?.uid == bannedUser.uid{
                groupErrorView.isHidden = false
                self.view.isUserInteractionEnabled = false
                self.showHideOptions(hideViewMembers: true, hideAddMembers: true, hideBannMembers: true, hideLeaveGroup: true, hideDeleteGroup: true) //hiding all the options
            } else {
                updateGroupInfo(bannedFrom)
            }
        }
    }
    
    public func onGroupMemberUnbanned(action: CometChatSDK.ActionMessage, unbannedUser: CometChatSDK.User, unbannedBy: CometChatSDK.User, unbannedFrom: CometChatSDK.Group) {
        if CometChat.getLoggedInUser()?.uid == unbannedUser.uid{
            groupErrorView.isHidden = true
            self.view.isUserInteractionEnabled = true
        }
    }
    
    func onGroupMemberScopeChanged(action: ActionMessage, scopeChangeduser: User, scopeChangedBy: User, scopeChangedTo: String, scopeChangedFrom: String, group: Group) {
        if group.guid == self.group?.guid {
            
            //THIS NEED TO BE FIXED FROM THE BACKEND
            if scopeChangeduser.uid == CometChat.getLoggedInUser()?.uid {
                group.scope = CometChat.GroupMemberScopeType.from(string: scopeChangedTo) ?? group.scope
                action.receiver = group
                updateGroupInfo(group)
            }
            
        }
    }
    
    public func ccGroupMemberAdded(messages: [ActionMessage], usersAdded: [User], groupAddedIn: Group, addedBy: User) {
        if self.group?.guid == groupAddedIn.guid{
            updateGroupInfo(groupAddedIn)
        }
    }
    
    public func ccGroupMemberJoined(joinedUser: User, joinedGroup: Group) {
        if self.group?.guid == joinedGroup.guid{
            updateGroupInfo(joinedGroup)
        }
    }
    
    public func ccGroupMemberKicked(action: ActionMessage, kickedUser: User, kickedBy: User, kickedFrom: Group) {
        if self.group?.guid == kickedFrom.guid{
            updateGroupInfo(kickedFrom)
        }
    }
    
    func ccGroupMemberBanned(action: ActionMessage, bannedUser: User, bannedBy: User, bannedFrom: Group) {
        if self.group?.guid == bannedFrom.guid{
            updateGroupInfo(bannedFrom)
        }
    }
    
    public func ccGroupMemberUnbanned(action: ActionMessage, unbannedUser: User, unbannedBy: User, unbannedFrom: Group) {
        if self.group?.guid == unbannedFrom.guid {
            updateGroupInfo(unbannedFrom)
        }
    }
    
    public func ccGroupMemberScopeChanged(action: ActionMessage, updatedUser: User, scopeChangedTo: String, scopeChangedFrom: String, group: Group) {
        if self.group?.guid == group.guid {
            updateGroupInfo(group)
        }
    }
    
    public func ccOwnershipChanged(group: Group, newOwner: GroupMember) {
        if self.group?.guid == group.guid {
            updateGroupInfo(group)
        }
    }
    
    public func updateGroupInfo(_ group: Group){
        if group.guid != self.group?.guid { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.group = group
            self.memberCountLabel.text = "\(group.membersCount) \("MEMBERS".localize())"
            if group.owner == CometChat.getLoggedInUser()?.uid{
                if group.membersCount == 1 {
                    self.showHideOptions(hideViewMembers: false, hideAddMembers: false, hideBannMembers: false, hideLeaveGroup: true, hideDeleteGroup: false)
                } else {
                    self.showHideOptions(hideViewMembers: false, hideAddMembers: false, hideBannMembers: false, hideLeaveGroup: false, hideDeleteGroup: false)
                }
            }else{
                switch group.scope{
                case .admin:
                    if group.membersCount == 1 {
                        self.showHideOptions(hideViewMembers: false, hideAddMembers: false, hideBannMembers: false, hideLeaveGroup: true, hideDeleteGroup: false)
                    } else {
                        self.showHideOptions(hideViewMembers: false, hideAddMembers: false, hideBannMembers: false, hideLeaveGroup: false, hideDeleteGroup: true)
                    }
                case .moderator:
                    self.showHideOptions(hideViewMembers: false, hideAddMembers: true, hideBannMembers: false, hideLeaveGroup: false, hideDeleteGroup: true)
                case .participant:
                    self.showHideOptions(hideViewMembers: false, hideAddMembers: true, hideBannMembers: true, hideLeaveGroup: false, hideDeleteGroup: true)
                
                @unknown default:
                    break
                }
            }
        }
    }
}
