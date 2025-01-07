//
//  CometChatScopeChange.swift
//  CometChatUIKitSwift
//
//  Created by Suryansh on 22/10/24.
//

import CometChatSDK

open class CometChatScopeChange: UIViewController {
    
    public var options = [(String, CometChat.MemberScope)]()
    
    public lazy var titleLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints()
        label.textAlignment = .center
        label.text = "Change Scope"
        return label
    }()
    
    public lazy var subtitleLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints()
        label.textAlignment = .center
        label.numberOfLines = 2
        label.text = "You can change roles to manage group permissions and responsibilities."
        return label
    }()
    
    public lazy var imageView: UIImageView = {
        let imageView = UIImageView().withoutAutoresizingMaskConstraints()
        return imageView
    }()
    
    public lazy var optionsContainerView: UIStackView = {
        let stackView = UIStackView().withoutAutoresizingMaskConstraints()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    public lazy var imageContainerView: UIView = {
        let containerView = UIView().withoutAutoresizingMaskConstraints()
        containerView.pin(anchors: [.width, .height], to: 80)
        containerView.roundViewCorners(corner: .init(cornerRadius: 40))
        containerView.embed(imageView, insets: .init(top: 16, leading: 16, bottom: 16, trailing: 16))
        containerView.backgroundColor = CometChatTheme.backgroundColor02
        return containerView
    }()
    
    public lazy var saveButton: UIButton = {
        let button = UIButton().withoutAutoresizingMaskConstraints()
        button.setTitle("Save", for: .normal)
        button.addTarget(self, action: #selector(onSaveButtonClicked), for: .primaryActionTriggered)
        button.setTitleColor(CometChatTheme.white, for: .normal)
        button.backgroundColor = CometChatTheme.primaryColor
        button.heightAnchor.pin(equalToConstant: 48).isActive = true
        button.roundViewCorners(corner: .init(cornerRadius: 8))
        return button
    }()
    
    public lazy var cancelButton: UIButton = {
        let button = UIButton().withoutAutoresizingMaskConstraints()
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(CometChatTheme.black, for: .normal)
        button.addTarget(self, action: #selector(onCancelButtonClicked), for: .primaryActionTriggered)
        button.backgroundColor = CometChatTheme.backgroundColor04
        button.heightAnchor.pin(equalToConstant: 48).isActive = true
        button.roundViewCorners(corner: .init(cornerRadius: 8))
        return button
    }()
    
    private var selectedOptions: Int?
    public static var style = ScopeChangeStyle()
    public lazy var style = CometChatScopeChange.style
    public var group: Group?
    public var groupMember: GroupMember?
    
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
        setupStyle()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    open func buildUI() {
                    
        var containersToActive = [NSLayoutConstraint]()
        
        let containerView = UIView().withoutAutoresizingMaskConstraints()
        view.embed(containerView, insets: .init(
            top: CometChatSpacing.Padding.p7,
            leading: CometChatSpacing.Padding.p6,
            bottom: CometChatSpacing.Padding.p6,
            trailing: CometChatSpacing.Padding.p5)
        )
        
        containerView.addSubview(imageContainerView)
        containersToActive += [
            imageContainerView.centerXAnchor.pin(equalTo: containerView.centerXAnchor),
            imageContainerView.topAnchor.pin(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: CometChatSpacing.Padding.p5)
        ]
        
        view.addSubview(titleLabel)
        containersToActive += [
            titleLabel.leadingAnchor.pin(equalTo: view.leadingAnchor, constant: CometChatSpacing.Padding.p6),
            titleLabel.trailingAnchor.pin(equalTo: view.trailingAnchor, constant: -CometChatSpacing.Padding.p6),
            titleLabel.topAnchor.pin(equalTo: imageContainerView.bottomAnchor, constant: CometChatSpacing.Padding.p2)
        ]
        
        view.addSubview(subtitleLabel)
        containersToActive += [
            subtitleLabel.leadingAnchor.pin(equalTo: view.leadingAnchor, constant: CometChatSpacing.Padding.p6),
            subtitleLabel.trailingAnchor.pin(equalTo: view.trailingAnchor, constant: -CometChatSpacing.Padding.p6),
            subtitleLabel.topAnchor.pin(equalTo: titleLabel.bottomAnchor, constant: CometChatSpacing.Padding.p2)
        ]
        
        view.addSubview(optionsContainerView)
        buildOptionsView()
        containersToActive += [
            optionsContainerView.leadingAnchor.pin(equalTo: view.leadingAnchor, constant: CometChatSpacing.Padding.p6),
            optionsContainerView.trailingAnchor.pin(equalTo: view.trailingAnchor, constant: -CometChatSpacing.Padding.p6),
            optionsContainerView.topAnchor.pin(equalTo: subtitleLabel.bottomAnchor, constant: CometChatSpacing.Padding.p6)
        ]
        
        view.addSubview(saveButton)
        containersToActive += [
            saveButton.leadingAnchor.pin(equalTo: view.leadingAnchor, constant: CometChatSpacing.Padding.p6),
            saveButton.trailingAnchor.pin(equalTo: view.trailingAnchor, constant: -CometChatSpacing.Padding.p6),
        ]
        
        view.addSubview(cancelButton)
        containersToActive += [
            cancelButton.topAnchor.pin(equalTo: saveButton.bottomAnchor, constant: CometChatSpacing.Padding.p2),
            cancelButton.leadingAnchor.pin(equalTo: view.leadingAnchor, constant: CometChatSpacing.Padding.p6),
            cancelButton.trailingAnchor.pin(equalTo: view.trailingAnchor, constant: -CometChatSpacing.Padding.p6),
            cancelButton.bottomAnchor.pin(equalTo: view.bottomAnchor, constant: -CometChatSpacing.Padding.p8)
        ]
        
        NSLayoutConstraint.activate(containersToActive)
        
        if #available(iOS 15.0, *) {
            manageSheetHeight(height: CGFloat(345 + (48 * options.count)))
        }
        
    }
    
    open func buildOptionsView() {
        for index in 0...(options.count-1) {
            
            let option = options[index]
            let optionView = UIView().withoutAutoresizingMaskConstraints()
            optionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onOptionSelected(_ :))))
            optionView.heightAnchor.pin(equalToConstant: 48).isActive = true
            optionView.backgroundColor = style.optionBackgroundColor
            optionView.tag = index
            
            let optionLabel = UILabel().withoutAutoresizingMaskConstraints()
            optionLabel.textColor = style.optionTextColor
            optionLabel.font = style.optionFont
            optionLabel.text = option.0
            optionView.addSubview(optionLabel)
            NSLayoutConstraint.activate([
                optionLabel.leadingAnchor.pin(equalTo: optionView.leadingAnchor, constant: CometChatSpacing.Padding.p4),
                optionLabel.centerYAnchor.pin(equalTo: optionView.centerYAnchor),
            ])
            
            let optionImageView = UIImageView().withoutAutoresizingMaskConstraints()
            optionImageView.image = style.optionImage
            optionImageView.tintColor = CometChatTheme.borderColorDefault
            optionView.addSubview(optionImageView)
            optionImageView.pin(anchors: [.height, .width], to: 24)
            NSLayoutConstraint.activate([
                optionImageView.trailingAnchor.pin(equalTo: optionView.trailingAnchor, constant: -CometChatSpacing.Padding.p4),
                optionImageView.centerYAnchor.pin(equalTo: optionView.centerYAnchor),
            ])
            
            optionsContainerView.addArrangedSubview(optionView)
        }
    }
    
    @objc open func onOptionSelected(_ sender : UITapGestureRecognizer) {
        
        //resetting non selected views
        self.optionsContainerView.subviews.forEach { view in
            view.backgroundColor = style.optionBackgroundColor
            view.subviews.forEach { view in
                (view as? UILabel)?.textColor = style.optionTextColor
                (view as? UIImageView)?.image = style.optionImage
            }
        }
        
        guard let optionView = sender.view else { return }
        selectedOptions = optionView.tag
        
        optionView.backgroundColor = style.selectedOptionBackgroundColor
        optionView.subviews.forEach { view in
            (view as? UILabel)?.textColor = style.selectedOptionTextColor
            (view as? UIImageView)?.image = style.selectedOptionImage
        }
    }
    
    open func setupStyle() {
        
        view.backgroundColor = style.backgroundColor
        view.borderWith(width: style.borderWidth)
        view.borderColor(color: style.borderColor)
        if let cornerRadius = style.cornerRadius { view.roundViewCorners(corner: cornerRadius) }
        
        imageView.image = style.changeImage
        imageView.tintColor = style.changeImageTintColor
        
        titleLabel.textColor = style.titleTextColor
        titleLabel.font = style.titleFont
        
        subtitleLabel.textColor = style.subtitleTextColor
        subtitleLabel.font = style.subtitleFont

        saveButton.tintColor = style.saveButtonTintColor
        cancelButton.tintColor = style.cancelButonTintColor
        
        optionsContainerView.borderWith(width: style.optionContainerBorderWidth)
        optionsContainerView.borderColor(color: style.optionContainerBorderColor)
        optionsContainerView.roundViewCorners(corner: style.optionsContainerCornerRadius)
    }

    @objc open func onSaveButtonClicked() {
        if let selectedOptions = selectedOptions, let guid = group?.guid, let uid = groupMember?.uid {
            
            let activityIndicator = UIActivityIndicatorView(style: .medium).withoutAutoresizingMaskConstraints()
            activityIndicator.color = CometChatTheme.white
            activityIndicator.startAnimating()
            saveButton.setTitle("", for: .normal)
            saveButton.addSubview(activityIndicator)
            activityIndicator.centerXAnchor.pin(equalTo: saveButton.centerXAnchor).isActive = true
            activityIndicator.centerYAnchor.pin(equalTo: saveButton.centerYAnchor).isActive = true

            CometChat.updateGroupMemberScope(UID: uid, GUID: guid, scope: options[selectedOptions].1, onSuccess: { [weak self] (response) in
                
                guard let this = self else { return }
                
                let loggedInUser = CometChat.getLoggedInUser()
                let oldScope = this.groupMember?.scope.toString(isLocalised: false)
                switch this.options[selectedOptions].1 {
                case .admin:
                    this.groupMember?.scope = .admin
                case .moderator:
                    this.groupMember?.scope = .moderator
                case .participant:
                    this.groupMember?.scope = .participant
                @unknown default:
                    break
                }
                
                let actionMessage = ActionMessage()
                actionMessage.action = .scopeChanged
                actionMessage.conversationId = "group_\(guid)"
                actionMessage.message = "\(loggedInUser?.name ?? "") made \(this.groupMember?.name ?? "") \(this.options[selectedOptions].0)"
                actionMessage.muid = "\(NSDate().timeIntervalSince1970)"
                actionMessage.sender = loggedInUser
                actionMessage.receiver = this.group
                actionMessage.actionBy = loggedInUser
                actionMessage.actionOn = this.groupMember
                actionMessage.receiverUid = guid
                actionMessage.messageType = .groupMember
                actionMessage.messageCategory = .action
                actionMessage.receiverType = .group
                actionMessage.newScope = this.groupMember?.scope ?? .participant
                actionMessage.sentAt = Int(Date().timeIntervalSince1970)
                
                CometChatGroupEvents.ccGroupMemberScopeChanged(action: actionMessage, updatedUser: this.groupMember!, scopeChangedTo: this.options[selectedOptions].1.toString(isLocalised: false), scopeChangedFrom: oldScope ?? "", group: this.group!)
                
                DispatchQueue.main.async {
                    activityIndicator.removeFromSuperview()
                    self?.dismiss(animated: true)
                }
                
            }) { (error) in
                print("Update group member scope failed with error: " + error!.errorDescription);
            }
        }
    }
    
    @objc open func onCancelButtonClicked() {
        self.dismiss(animated: true)
    }
    
    @discardableResult
    public func set(group: Group, groupMember: GroupMember) -> Self {
        if group.scope == .moderator {
            options = [("Moderator", .moderator), ("Participant", .participant)
            ]
        } else {
            options = [("Admin", .admin), ("Moderator", .moderator), ("Participant", .participant) ]
        }
        
        options.enumerated().forEach { index, option in
            if option.1.toString() == groupMember.scope.toString() {
                options.remove(at: index)
                return
            }
        }
        
        self.group = group
        self.groupMember = groupMember
        return self
    }
    
    private func manageSheetHeight(height: CGFloat){
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
