 //
 //  UserGroupViewController.swift
 //  PanModal
 //
 //  Created by Tosin Afolabi on 2/26/19.
 //  Copyright © 2019 PanModal. All rights reserved.
 //
 
 import UIKit
 import SafariServices
 
 enum MessageAction {
    case takeAPhoto
    case photoAndVideoLibrary
    case document
    case shareLocation
    case createAPoll
    case messageInfo
    case copy
    case reply
    case edit
    case forward
    case delete
    case thread
    case share
    case sticker
    case reaction
    case whiteboard
    case writeboard
    case messageTranslate
    case createMeeting
    case messageInPrivate
    case replyInPrivate
 }
 
 protocol RowPresentable {
    var string: String { get }
    var rowVC: UIViewController & PanModalPresentable { get }
 }
 
 protocol MessageActionsDelegate {
    func takeAPhotoPressed()
    func copyPressed()
    func photoAndVideoLibraryPressed()
    func documentPressed()
    func shareLocationPressed()
    func createAPollPressed()
    func didMessageInfoPressed()
    func didStartThreadPressed()
    func didEditPressed()
    func didDeletePressed()
    func didReplyPressed()
    func didSharePressed()
    func didForwardPressed()
    func didStickerPressed()
    func didReactionPressed()
    func didCollaborativeWriteboardPressed()
    func didCollaborativeWhiteboardPressed()
    func didMessageTranslatePressed()
    func didAudioCallPressed()
    func didVideoCallPressed()
    func didMessageInPrivatePressed()
    func didReplyInPrivatePressed()
 }
 
 
 class MessageActions: UITableViewController, PanModalPresentable, CreateMeetingDelegate {
    
    var isShortFormEnabled = true
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    let headerView = UserGroupHeaderView()
    var actions: [MessageAction]?
    let headerPresentable = UserGroupHeaderPresentable.init(handle: "Message Actions", description: "Select action to perform.", memberCount: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        NotificationCenter.default.addObserver(self, selector:#selector(self.didWindowClosed(_:)), name: NSNotification.Name(rawValue: "didThreadOpened"), object: nil)
    }
    
    
    func set(actions: [MessageAction]) {
        self.actions = actions
    }
    
    @objc func didWindowClosed(_ notification: NSNotification) {
        //self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - View Configurations
    
    func setupTableView() {
        self.tableView.separatorStyle = .none
        if #available(iOS 13.0, *) {
            tableView.backgroundColor = .systemBackground
        } else {
            tableView.backgroundColor = .white
        }
        let actionsCell  = UINib.init(nibName: "ActionsCell", bundle: UIKitSettings.bundle)
        self.tableView.register(actionsCell, forCellReuseIdentifier: "actionsCell")
        
        let addReactionCell  = UINib.init(nibName: "AddReactionsCell", bundle: UIKitSettings.bundle)
        self.tableView.register(addReactionCell, forCellReuseIdentifier: "addReactionsCell")
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actions?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let staticCell = UITableViewCell()
        if let currentActions = actions {
            switch currentActions[indexPath.row] {
            case .takeAPhoto:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "actionsCell", for: indexPath) as? ActionsCell {
                    cell.name.text =  "TAKE_A_PHOTO".localized()
                    cell.icon.image = UIImage(named: "messages-camera.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                    cell.fullScreenSwitch.isHidden = true
                    cell.badgeCountSwitch.isHidden = true
                    cell.icon.tintColor = UIKitSettings.secondaryColor
                    return cell
                }
            case .photoAndVideoLibrary:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "actionsCell", for: indexPath) as? ActionsCell {
                    cell.name.text = "PHOTO_VIDEO_LIBRARY".localized()
                    cell.icon.image = UIImage(named: "photo-library.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                    cell.fullScreenSwitch.isHidden = true
                    cell.badgeCountSwitch.isHidden = true
                    cell.icon.tintColor = UIKitSettings.secondaryColor
                    return cell
                }
            case .document:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "actionsCell", for: indexPath) as? ActionsCell {
                    cell.name.text = "DOCUMENT".localized()
                    cell.icon.image = UIImage(named: "messages-file-upload.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                    cell.fullScreenSwitch.isHidden = true
                    cell.badgeCountSwitch.isHidden = true
                    cell.icon.tintColor = UIKitSettings.secondaryColor
                    return cell
                }
            case .shareLocation:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "actionsCell", for: indexPath) as? ActionsCell {
                    cell.name.text = "SHARE_LOCATION".localized()
                    cell.icon.image = UIImage(named: "messages-location.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                    cell.fullScreenSwitch.isHidden = true
                    cell.badgeCountSwitch.isHidden = true
                    cell.icon.tintColor = UIKitSettings.secondaryColor
                    return cell
                }
            case .edit:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "actionsCell", for: indexPath) as? ActionsCell {
                    cell.name.text = "EDIT_MESSAGE".localized()
                    if #available(iOS 13.0, *) {
                        cell.name.textColor = .label
                    }else{
                        cell.name.textColor = .black
                    }
                    cell.icon.image = UIImage(named: "messages-edit.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                    cell.fullScreenSwitch.isHidden = true
                    cell.badgeCountSwitch.isHidden = true
                    cell.icon.tintColor = UIKitSettings.secondaryColor
                    return cell
                }
            case .delete:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "actionsCell", for: indexPath) as? ActionsCell {
                    cell.name.text = "DELETE_MESSAGE".localized()
                    if #available(iOS 13.0, *) {
                        cell.name.textColor = .label
                    }else{
                        cell.name.textColor = .black
                    }
                    cell.icon.image = UIImage(named: "messages-delete.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                    cell.icon.tintColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
                    cell.fullScreenSwitch.isHidden = true
                    cell.badgeCountSwitch.isHidden = true
                    return cell
                }
            case .reply:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "actionsCell", for: indexPath) as? ActionsCell {
                    cell.name.text = "REPLY_MESSAGE".localized()
                    cell.icon.image = UIImage(named: "reply-message.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                    if #available(iOS 13.0, *) {
                        cell.name.textColor = .label
                    }else{
                        cell.name.textColor = .black
                    }
                    cell.fullScreenSwitch.isHidden = true
                    cell.badgeCountSwitch.isHidden = true
                    cell.icon.tintColor = UIKitSettings.secondaryColor
                    return cell
                }
            case .forward:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "actionsCell", for: indexPath) as? ActionsCell {
                    cell.name.text = "FORWARD_MESSAGE".localized()
                    if #available(iOS 13.0, *) {
                        cell.name.textColor = .label
                    }else{
                        cell.name.textColor = .black
                    }
                    cell.icon.image = UIImage(named: "messages-forward-message.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                    if #available(iOS 13.0, *) {
                        cell.name.textColor = .label
                    }else{
                        cell.name.textColor = .black
                    }
                    cell.fullScreenSwitch.isHidden = true
                    cell.badgeCountSwitch.isHidden = true
                    cell.icon.tintColor = UIKitSettings.secondaryColor
                    return cell
                }
            case .thread:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "actionsCell", for: indexPath) as? ActionsCell {
                    cell.name.text = "START_THREAD".localized()
                    cell.icon.image = UIImage(named: "threaded-message.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                    if #available(iOS 13.0, *) {
                        cell.name.textColor = .label
                    }else{
                        cell.name.textColor = .black
                    }
                    cell.fullScreenSwitch.isHidden = true
                    cell.badgeCountSwitch.isHidden = true
                    cell.icon.tintColor = UIKitSettings.secondaryColor
                    return cell
                }
            case .share:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "actionsCell", for: indexPath) as? ActionsCell {
                    cell.icon.image = UIImage(named: "messages-share.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                    cell.name.text = "SHARE_MESSAGE".localized()
                    if #available(iOS 13.0, *) {
                        cell.name.textColor = .label
                    }else{
                        cell.name.textColor = .black
                    }
                    cell.fullScreenSwitch.isHidden = true
                    cell.badgeCountSwitch.isHidden = true
                    cell.icon.tintColor = UIKitSettings.secondaryColor
                    return cell
                }
            case .messageInfo:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "actionsCell", for: indexPath) as? ActionsCell {
                    cell.icon.image = UIImage(named: "messages-info.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                    cell.name.text = "MESSAGE_INFORMATION".localized()
                    if #available(iOS 13.0, *) {
                        cell.name.textColor = .label
                    }else{
                        cell.name.textColor = .black
                    }
                    cell.fullScreenSwitch.isHidden = true
                    cell.badgeCountSwitch.isHidden = true
                    cell.icon.tintColor = UIKitSettings.secondaryColor
                    return cell
                }
            case .copy:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "actionsCell", for: indexPath) as? ActionsCell {
                    cell.name.text = "COPY_MESSAGE".localized()
                    cell.icon.image = UIImage(named: "copy-paste.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                    cell.fullScreenSwitch.isHidden = true
                    cell.badgeCountSwitch.isHidden = true
                    cell.icon.tintColor = UIKitSettings.secondaryColor
                    return cell
                }
            case .createAPoll:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "actionsCell", for: indexPath) as? ActionsCell {
                    cell.name.text = "CREATE_A_POLL".localized()
                    cell.icon.image = UIImage(named: "messages-polls.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                    cell.fullScreenSwitch.isHidden = true
                    cell.badgeCountSwitch.isHidden = true
                    cell.icon.tintColor = UIKitSettings.secondaryColor
                    return cell
                }
            case .sticker:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "actionsCell", for: indexPath) as? ActionsCell {
                    cell.name.text = "SEND_STICKER".localized()
                    cell.icon.image = UIImage(named: "messages-stickers.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                    cell.fullScreenSwitch.isHidden = true
                    cell.badgeCountSwitch.isHidden = true
                    cell.icon.tintColor = UIKitSettings.secondaryColor
                    return cell
                }
            case .reaction:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "addReactionsCell", for: indexPath) as? AddReactionsCell {
                    return cell
                }
            case .whiteboard:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "actionsCell", for: indexPath) as? ActionsCell {
                    cell.name.text = "COLLABORATIVE_WHITEBOARD".localized()
                    cell.icon.image = UIImage(named: "messages-collaborative-whiteboard.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                    cell.fullScreenSwitch.isHidden = true
                    cell.badgeCountSwitch.isHidden = true
                    cell.icon.tintColor = UIKitSettings.secondaryColor
                    return cell
                }
            case .writeboard:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "actionsCell", for: indexPath) as? ActionsCell {
                    cell.name.text = "COLLABORATIVE_DOCUMENT".localized()
                    cell.icon.image = UIImage(named: "messages-collaborative-document.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                    cell.fullScreenSwitch.isHidden = true
                    cell.badgeCountSwitch.isHidden = true
                    cell.icon.tintColor = UIKitSettings.secondaryColor
                    return cell
                }
            case .messageTranslate:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "actionsCell", for: indexPath) as? ActionsCell {
                    cell.name.text = "TRANSLATE_MESSAGE".localized()
                    cell.icon.image = UIImage(named: "message-translate.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                    cell.fullScreenSwitch.isHidden = true
                    cell.badgeCountSwitch.isHidden = true
                    cell.icon.tintColor = UIKitSettings.secondaryColor
                    return cell
                }
            case .createMeeting:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "actionsCell", for: indexPath) as? ActionsCell {
                    cell.name.text = "START_A_CALL".localized()
                    cell.icon.image = UIImage(named: "createMeeting.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                    cell.fullScreenSwitch.isHidden = true
                    cell.badgeCountSwitch.isHidden = true
                    cell.icon.tintColor = UIKitSettings.secondaryColor
                    return cell
                }
                
            case .messageInPrivate:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "actionsCell", for: indexPath) as? ActionsCell {
                    cell.name.text = "MESSAGE_IN_PRIVATE".localized()
                    cell.icon.image = UIImage(named: "send-message-in-private.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                    if #available(iOS 13.0, *) {
                        cell.name.textColor = .label
                    }else{
                        cell.name.textColor = .black
                    }
                    cell.fullScreenSwitch.isHidden = true
                    cell.badgeCountSwitch.isHidden = true
                    cell.icon.tintColor = UIKitSettings.secondaryColor
                    return cell
                }
            case .replyInPrivate:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "actionsCell", for: indexPath) as? ActionsCell {
                    cell.name.text = "REPLY_IN_PRIVATE".localized()
                    cell.icon.image = UIImage(named: "reply-message-in-private.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                    if #available(iOS 13.0, *) {
                        cell.name.textColor = .label
                    }else{
                        cell.name.textColor = .black
                    }
                    cell.fullScreenSwitch.isHidden = true
                    cell.badgeCountSwitch.isHidden = true
                    cell.icon.tintColor = UIKitSettings.secondaryColor
                    return cell
                }
            }
        }
        return staticCell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let currentActions = actions {
            switch currentActions[indexPath.row] {
            case .reaction:
                var height: CGFloat = 50
                FeatureRestriction.isReactionsEnabled { (success) in
                    switch success {
                    case .enabled :
                        if indexPath.row == 0 {
                            height = 60.0
                        }else{
                            height = 55.0
                        }
                    case.disabled :  height = 55.0
                    }
                }
                return height
                
            case .whiteboard, .writeboard, .messageTranslate, .sticker, .share, .thread, .delete, .forward, .edit, .reply, .copy ,.messageInfo ,.createAPoll ,.shareLocation ,.document , .photoAndVideoLibrary, .takeAPhoto, .createMeeting, .messageInPrivate, .replyInPrivate:  return 55.0
            }
        }else{
            return 0
        }
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        headerView.configure(with: headerPresentable)
        return headerView
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let currentActions = actions {
            switch currentActions[indexPath.row] {
            case .takeAPhoto:
                self.dismiss(animated: true) {
                    MessageActions.actionsDelegate?.takeAPhotoPressed()
                }
            case .photoAndVideoLibrary:
                self.dismiss(animated: true) {
                    MessageActions.actionsDelegate?.photoAndVideoLibraryPressed()
                }
            case .document:
                self.dismiss(animated: true) {
                    MessageActions.actionsDelegate?.documentPressed()
                }
            case .shareLocation:
                self.dismiss(animated: true) {
                    MessageActions.actionsDelegate?.shareLocationPressed()
                }
            case .reply:
                MessageActions.actionsDelegate?.didReplyPressed()
                self.dismiss(animated: true, completion: nil)
            case .edit:
                MessageActions.actionsDelegate?.didEditPressed()
                self.dismiss(animated: true, completion: nil)
            case .forward:
                MessageActions.actionsDelegate?.didForwardPressed()
                self.dismiss(animated: true, completion: nil)
            case .delete:
                MessageActions.actionsDelegate?.didDeletePressed()
                self.dismiss(animated: true, completion: nil)
            case .thread:
                self.dismiss(animated: true) {
                    MessageActions.actionsDelegate?.didStartThreadPressed()
                }
            case .share:
                self.dismiss(animated: true) {
                    MessageActions.actionsDelegate?.didSharePressed()
                }
            case .messageInfo:
                self.dismiss(animated: true) {
                    MessageActions.actionsDelegate?.didMessageInfoPressed()
                }
            case .copy:
                self.dismiss(animated: true) {
                    MessageActions.actionsDelegate?.copyPressed()
                }
            case .createAPoll:
                self.dismiss(animated: true) {
                    MessageActions.actionsDelegate?.createAPollPressed()
                }
            case .sticker:
                self.dismiss(animated: true) {
                    MessageActions.actionsDelegate?.didStickerPressed()
                }
            case .reaction:
                self.dismiss(animated: true) {
                    MessageActions.actionsDelegate?.didReactionPressed()
                }
            case .whiteboard:
                self.dismiss(animated: true) {
                    MessageActions.actionsDelegate?.didCollaborativeWhiteboardPressed()
                }
            case .writeboard:
                self.dismiss(animated: true) {
                    MessageActions.actionsDelegate?.didCollaborativeWriteboardPressed()
                }
            case .messageTranslate:
                self.dismiss(animated: true) {
                    MessageActions.actionsDelegate?.didMessageTranslatePressed()
                }
            case .createMeeting:
                self.dismiss(animated: true) {
                    MessageActions.actionsDelegate?.didVideoCallPressed()
                }
            case .messageInPrivate:
                self.dismiss(animated: true) {
                    MessageActions.actionsDelegate?.didMessageInPrivatePressed()
                }
            case .replyInPrivate:
                self.dismiss(animated: true) {
                    MessageActions.actionsDelegate?.didReplyInPrivatePressed()
                }
            }
        }
    }
    
    func didAudioCallPressed() {
        self.dismiss(animated: true) {
            MessageActions.actionsDelegate?.didAudioCallPressed()
        }
    }
    
    func didVideoCallPressed() {
        self.dismiss(animated: true) {
            MessageActions.actionsDelegate?.didVideoCallPressed()
        }
    }
    
    
    // MARK: - Pan Modal Presentable
    
    var panScrollable: UIScrollView? {
        return tableView
    }
    
    var shortFormHeight: PanModalHeight {
        let height = (actions?.count ?? 0) * 65 + 20
        return isShortFormEnabled ? .contentHeight(CGFloat(height)) : longFormHeight
    }
    
    var scrollIndicatorInsets: UIEdgeInsets {
        let bottomOffset = presentingViewController?.bottomLayoutGuide.length ?? 0
        return UIEdgeInsets(top: headerView.frame.size.height, left: 0, bottom: bottomOffset, right: 0)
    }
    
    var anchorModalToLongForm: Bool {
        return false
    }
    
    func shouldPrioritize(panModalGestureRecognizer: UIPanGestureRecognizer) -> Bool {
        let location = panModalGestureRecognizer.location(in: view)
        return headerView.frame.contains(location)
    }
    
    func willTransition(to state: PanModalPresentationController.PresentationState) {
        guard isShortFormEnabled, case .longForm = state
        else { return }
        
        isShortFormEnabled = false
        panModalSetNeedsLayoutUpdate()
    }
 }
 
 
 extension MessageActions {
    static var actionsDelegate: MessageActionsDelegate?
 }
