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
 }


 class MessageActions: UITableViewController, PanModalPresentable {
     
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
                cell.name.text = "Take a Photo"
                cell.icon.image = UIImage(named: "􀌞.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                cell.fullScreenSwitch.isHidden = true
                cell.badgeCountSwitch.isHidden = true
                    return cell
                }
            case .photoAndVideoLibrary:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "actionsCell", for: indexPath) as? ActionsCell {
                cell.name.text = "Photo & Video Library"
                cell.icon.image = UIImage(named: "􀣵.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                cell.fullScreenSwitch.isHidden = true
                cell.badgeCountSwitch.isHidden = true
                    return cell
                }
            case .document:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "actionsCell", for: indexPath) as? ActionsCell {
                cell.name.text = "Document"
                cell.icon.image = UIImage(named: "􀈕.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                cell.fullScreenSwitch.isHidden = true
                cell.badgeCountSwitch.isHidden = true
                    return cell
                }
            case .shareLocation:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "actionsCell", for: indexPath) as? ActionsCell {
                cell.name.text = "Share Location"
                cell.icon.image = UIImage(named: "􀋑.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                cell.fullScreenSwitch.isHidden = true
                cell.badgeCountSwitch.isHidden = true
                    return cell
                }
            case .edit:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "actionsCell", for: indexPath) as? ActionsCell {
                cell.name.text = "Edit Message"
                if #available(iOS 13.0, *) {
                    cell.name.textColor = .label
                }else{
                    cell.name.textColor = .black
                }
                cell.icon.image = UIImage(named: "􀈎.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                cell.fullScreenSwitch.isHidden = true
                cell.badgeCountSwitch.isHidden = true
                    return cell
                }
            case .delete:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "actionsCell", for: indexPath) as? ActionsCell {
                cell.name.text = "Delete Message"
                if #available(iOS 13.0, *) {
                    cell.name.textColor = .label
                }else{
                    cell.name.textColor = .black
                }
                cell.icon.image = UIImage(named: "􀈑.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                cell.icon.tintColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
                cell.fullScreenSwitch.isHidden = true
                cell.badgeCountSwitch.isHidden = true
                    return cell
                }
            case .reply:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "actionsCell", for: indexPath) as? ActionsCell {
                cell.name.text = "Reply Message"
                cell.icon.image = UIImage(named: "reply1.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                if #available(iOS 13.0, *) {
                    cell.icon.tintColor = .label
                    cell.name.textColor = .label
                }else{
                    cell.icon.tintColor = .black
                    cell.name.textColor = .black
                }
                cell.fullScreenSwitch.isHidden = true
                cell.badgeCountSwitch.isHidden = true
                    return cell
                }
            case .forward:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "actionsCell", for: indexPath) as? ActionsCell {
                cell.name.text = "Forward Message"
                if #available(iOS 13.0, *) {
                    cell.name.textColor = .label
                }else{
                    cell.name.textColor = .black
                }
                cell.icon.image = UIImage(named: "􀉐.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                if #available(iOS 13.0, *) {
                    cell.icon.tintColor = .label
                    cell.name.textColor = .label
                }else{
                    cell.icon.tintColor = .black
                    cell.name.textColor = .black
                }
                cell.fullScreenSwitch.isHidden = true
                cell.badgeCountSwitch.isHidden = true
                    return cell
                }
            case .thread:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "actionsCell", for: indexPath) as? ActionsCell {
                cell.name.text = "Start Thread"
                cell.icon.image = UIImage(named: "􀌤.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                if #available(iOS 13.0, *) {
                    cell.name.textColor = .label
                }else{
                    cell.name.textColor = .black
                }
                cell.fullScreenSwitch.isHidden = true
                cell.badgeCountSwitch.isHidden = true
                    return cell
                }
            case .share:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "actionsCell", for: indexPath) as? ActionsCell {
                cell.icon.image = UIImage(named: "􀈂.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                cell.name.text = "Share Message"
                if #available(iOS 13.0, *) {
                    cell.name.textColor = .label
                }else{
                    cell.name.textColor = .black
                }
                cell.fullScreenSwitch.isHidden = true
                cell.badgeCountSwitch.isHidden = true
                    return cell
                }
            case .messageInfo:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "actionsCell", for: indexPath) as? ActionsCell {
                cell.icon.image = UIImage(named: "􀅴.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                cell.name.text = "Message Information"
                if #available(iOS 13.0, *) {
                    cell.name.textColor = .label
                }else{
                    cell.name.textColor = .black
                }
                cell.fullScreenSwitch.isHidden = true
                cell.badgeCountSwitch.isHidden = true
                    return cell
                }
            case .copy:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "actionsCell", for: indexPath) as? ActionsCell {
                cell.name.text = "Copy Message"
                cell.icon.image = UIImage(named: "􀉁.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                cell.fullScreenSwitch.isHidden = true
                cell.badgeCountSwitch.isHidden = true
                    return cell
                }
            case .createAPoll:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "actionsCell", for: indexPath) as? ActionsCell {
                cell.name.text = "Create a Poll"
                cell.icon.image = UIImage(named: "􀌶.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                cell.fullScreenSwitch.isHidden = true
                cell.badgeCountSwitch.isHidden = true
                    return cell
                }
            case .sticker:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "actionsCell", for: indexPath) as? ActionsCell {
                cell.name.text = "Send Sticker"
                cell.icon.image = UIImage(named: "sticker1.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                cell.fullScreenSwitch.isHidden = true
                cell.badgeCountSwitch.isHidden = true
                    return cell
                }
            case .reaction:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "addReactionsCell", for: indexPath) as? AddReactionsCell {
                    return cell
                }
            case .whiteboard:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "actionsCell", for: indexPath) as? ActionsCell {
                cell.name.text = "Collaborative Whiteboard"
                cell.icon.image = UIImage(named: "whiteboard.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                cell.fullScreenSwitch.isHidden = true
                cell.badgeCountSwitch.isHidden = true
                    return cell
                }
            case .writeboard:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "actionsCell", for: indexPath) as? ActionsCell {
                cell.name.text = "Collaborative Writeboard"
                cell.icon.image = UIImage(named: "writeboard.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                cell.fullScreenSwitch.isHidden = true
                cell.badgeCountSwitch.isHidden = true
                    return cell
                }
            }
        }
        return staticCell
    }
     
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if UIKitSettings.messageReaction == .enabled {
            if indexPath.row == 0 {
                return 65.0
            }else{
                return 55.0
            }
        }else{
            return 55.0
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
            }
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
