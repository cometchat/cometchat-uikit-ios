//
//  AiAssistViewC.swift
//  
//
//  Created by SuryanshBisen on 01/11/23.
//

import UIKit
import CometChatSDK

open class AIAssistViewController: CometChatListBase {
    
    private let messageComposer = AIMessageComposer()
    private var titleMain: String?
    private var closeIcon = UIImage(named: "multiply", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    private var messageDataSource = [TextMessage]()
    private (set) var cell: CometChatMessageBubble?
    private var bot: User?
    private var configuration = AIAssistBotConfiguration()
    private var sendButton = UIButton()
    private var onSendButtonClick: ((BaseMessage) -> ())?
    private var sendButtonIcon = UIImage(named: "message-composer-send.png", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    private let dividerView = UIView()
    private let titleLabel = UILabel()
    private let headerView = UIView()
    
    private var composerBottomAnchor: NSLayoutConstraint?
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        buildUI()
        setupKeyboardEvent()
    }
    
    func setupKeyboardEvent() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification , object:nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification , object:nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let keyboardHeight = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        UIView.animate(withDuration: 0.2) {
            self.composerBottomAnchor?.constant = -keyboardHeight - 10
            self.view.layoutIfNeeded()
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.2) {
            self.composerBottomAnchor?.constant = -30
            self.view.layoutIfNeeded()
        }
    }
    
    open override func buildUI() {
        super.buildUI()
        self.view.backgroundColor = CometChatTheme_v4.palatte.background
        
        
        self.view.addSubview(headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        headerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        headerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        headerView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        buildNavigationBar()
        
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0).isActive = true
        tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        
        self.view.addSubview(dividerView)
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        dividerView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        dividerView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 5).isActive = true
        dividerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        dividerView.backgroundColor = configuration.messageInputStyle?.dividerColor ?? CometChatTheme_v4.palatte.accent500
        dividerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        
        self.view.addSubview(messageComposer)
        messageComposer.translatesAutoresizingMaskIntoConstraints = false
        composerBottomAnchor = messageComposer.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -30)
        composerBottomAnchor?.isActive = true
        messageComposer.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10).isActive = true
        messageComposer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -5).isActive = true
        messageComposer.topAnchor.constraint(equalTo: dividerView.bottomAnchor, constant: 7).isActive = true
        
        buildTableView()
        buildComposer()
    }
    
    func buildNavigationBar() {
        
        //adding avatar Image
        let avatarImageView = CometChatAvatar(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        avatarImageView.setAvatar(avatarUrl: self.bot?.avatar ?? "", with: self.bot?.name ?? "")
        
        //TODO: AVATAR
//        avatarImageView.set(backgroundColor: configuration.avatarStyle?.background ?? CometChatTheme_v4.palatte.accent400)
//        avatarImageView.set(font: configuration.avatarStyle?.textFont ?? CometChatTheme_v4.typography.name)
//        avatarImageView.set(fontColor: configuration.avatarStyle?.textColor ?? CometChatTheme_v4.palatte.accent900)
//        avatarImageView.set(borderColor: configuration.avatarStyle?.borderColor ?? .systemFill)
//        avatarImageView.set(borderWidth: configuration.avatarStyle?.borderWidth ?? 0)
//        avatarImageView.set(cornerRadius: configuration.avatarStyle?.cornerRadius ?? CometChatCornerStyle(cornerRadius: 17.5))
        avatarImageView.widthAnchor.constraint(equalToConstant: 35).isActive = true
        avatarImageView.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        let avatarNameView = UIStackView()
        avatarNameView.axis = .vertical
        avatarNameView.distribution = .fill
        avatarNameView.alignment = .fill
        avatarNameView.addArrangedSubview(titleLabel)
        
        titleLabel.textColor = configuration.style?.titleColor ?? CometChatTheme_v4.palatte.accent
        titleLabel.text = titleMain
        titleLabel.font = configuration.style?.titleFont ?? CometChatTheme_v4.typography.name
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = configuration.subtitle ?? "AI_BOT".localize()
        subtitleLabel.font = configuration.style?.subtitleFont ?? CometChatTheme_v4.typography.subtitle2
        subtitleLabel.textColor = configuration.style?.subtitleColor ?? CometChatTheme_v4.palatte.accent500
        
        avatarNameView.addArrangedSubview(subtitleLabel)

        let avatarMainView = UIStackView()
        avatarMainView.axis = .horizontal
        avatarMainView.spacing = 10
        avatarMainView.distribution = .fill
        avatarNameView.alignment = .fill
        avatarMainView.addArrangedSubview(avatarImageView)
        avatarMainView.addArrangedSubview(avatarNameView)
        
        headerView.addSubview(avatarMainView)
        avatarMainView.translatesAutoresizingMaskIntoConstraints = false
        avatarMainView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 10).isActive = true
        avatarMainView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        
        let closeButton = UIButton()
        closeButton.setImage(closeIcon, for: .normal)
        closeButton.addTarget(self, action: #selector(onCloseButtonClicked), for: .touchUpInside)
        closeButton.tintColor = configuration.style?.closeIconTint ?? CometChatTheme_v4.palatte.accent
        
        headerView.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.leadingAnchor.constraint(equalTo: avatarMainView.trailingAnchor, constant: 0).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -10).isActive = true
        closeButton.centerYAnchor.constraint(equalTo: avatarMainView.centerYAnchor).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        closeButton.imageView?.contentMode = .scaleAspectFill
        
    }
    
    func buildComposer() {
        messageComposer.set(user: bot)
    }
        
    func buildTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = CometChatTheme_v4.palatte.background
        
        self.registerCellWith(title: CometChatMessageBubble.identifier)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func onCloseButtonClicked() {
        self.view.endEditing(true)
        self.dismiss(animated: true)
    }

}

extension AIAssistViewController {
    
    public override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageDataSource.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messageDataSource[indexPath.row]
        guard let sender = message.sender, let uid = sender.uid else { return UITableViewCell() }
        let isLoggedInUser = LoggedInUserInformation.isLoggedInUser(uid: uid)
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: CometChatMessageBubble.identifier , for: indexPath) as? CometChatMessageBubble {
            
            //setting cell alignment & background colour according to the sender
            if isLoggedInUser {
                cell.set(bubbleAlignment: .right)
                cell.set(backgroundColor: CometChatTheme_v4.palatte.primary)
            } else {
                cell.set(bubbleAlignment: .left)
                if (self.traitCollection.userInterfaceStyle == .dark) {
                    cell.set(backgroundColor: CometChatTheme_v4.palatte.accent100)
                } else {
                    cell.set(backgroundColor: CometChatTheme_v4.palatte.secondary)
                }
            }
            
            //adding message text
            let textBubble = CometChatTextBubble()
            textBubble.set(text: message.text)
            textBubble.style.textFont = CometChatTheme_v4.typography.text1
            switch cell.alignment {
            case .right:
                textBubble.style.textColor = .white
            case .left:
                textBubble.style.textColor = CometChatTheme_v4.palatte.accent
            default: break
            }
            
            if let senderMessageBubbleStyle = configuration.senderMessageBubbleStyle, isLoggedInUser {
                textBubble.style = senderMessageBubbleStyle
            } else if let botMessageBubbleStyle = configuration.botMessageBubbleStyle {
                textBubble.style = botMessageBubbleStyle
            }
            
            cell.set(contentView: textBubble)
            
            let footerStackView = UIStackView(frame: CGRect(x: 0, y: 0, width: 200, height: 25))
            
            let date = CometChatDate()
                .set(pattern: .time)
                .set(timestamp: message.sentAt)
            footerStackView.addArrangedSubview(date)
            
            if (message.metaData?["error"] as? Bool) == true {
                let reciept = CometChatReceipt()
                //TODO: ui changes
                reciept.set(receipt: .failed)
                footerStackView.addArrangedSubview(reciept)
            }
            
            if (message.metaData?["isProcessing"] as? Bool) == true {
                let reciept = CometChatReceipt()
                reciept.set(receipt: .inProgress)
                footerStackView.addArrangedSubview(reciept)
            }
            
            cell.set(footerView: footerStackView)
            
            if !isLoggedInUser {
                cell.hide(avatar: true)
            }
            
            return cell
        }
        
        return UITableViewCell()
    }
}

extension AIAssistViewController {
    
    @discardableResult
    public func add(message: TextMessage) -> Self {
        DispatchQueue.main.async {
            self.messageDataSource.append(message)
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: [IndexPath(row: self.messageDataSource.count-1, section: 0)], with: .bottom)
            self.tableView.endUpdates()
            self.tableView.scrollToBottomRow()
        }
        return self
    }
    
    @discardableResult
    public func set(onMessageSent: ((BaseMessage) -> ())?) -> Self {
        self.messageComposer.set(onMessageSent: onMessageSent)
        return self
    }
    
    @discardableResult
    public func set(configuration: AIAssistBotConfiguration?) -> Self {
        
        guard let configuration = configuration else { return self }
        
        self.configuration = configuration
        
        if let title = configuration.title {
            self.set(title: title)
        }
        
        if let sendIcon = configuration.sendIcon {
            self.set(sendIcon: sendIcon)
        }
        
        if let closeIcon = configuration.closeIcon {
            self.set(closeIcon: closeIcon)
        }
        
        if let closeIconTint = configuration.style?.closeIconTint {
            self.set(closeIconTint: closeIconTint)
        }
        
        if let sendIconTint = configuration.style?.sendIconTint {
            self.set(sendIconTint: sendIconTint)
        }
        
        if let messageInputStyle = configuration.messageInputStyle {
            self.set(messageInputStyle: messageInputStyle)
        }
        
        return self
    }

    
    @discardableResult
    public func set(title: String) -> Self {
        self.titleMain = title
        return self
    }
    
    @discardableResult
    public func set(closeIcon: UIImage) -> Self {
        self.closeIcon = closeIcon.withRenderingMode(.alwaysTemplate)
        return self
    }
    
    @discardableResult
    public func set(closeIconTint: UIColor) -> Self {
        self.closeIcon.withTintColor(closeIconTint)
        return self
    }
    
    @discardableResult
    public func set(bot: User?) -> Self {
        self.bot = bot
        return self
    }
    
    @discardableResult
    public func set(sendIcon: UIImage) -> Self {
        messageComposer.set(sendIcon: sendIcon)
        return self
    }
    
    @discardableResult
    public func set(sendIconTint: UIColor) -> Self {
        messageComposer.set(sendIconTint: sendIconTint)
        return self
    }
    
    @discardableResult
    public func set(messageInputStyle: MessageInputStyle) -> Self {
        messageComposer.set(messageInputStyle: messageInputStyle)
        return self
    }
    
    @discardableResult
    public func update(message: TextMessage) -> Self {
        
        DispatchQueue.main.async {
            let index = self.messageDataSource.lastIndex{ $0.text == message.text }
            
            if let index = index {
                self.messageDataSource[index] = message
                self.tableView.beginUpdates()
                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                self.tableView.endUpdates()
            }
        }
        
        return self
    }
}
