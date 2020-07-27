 //
 //  UserGroupViewController.swift
 //  PanModal
 //
 //  Created by Tosin Afolabi on 2/26/19.
 //  Copyright © 2019 PanModal. All rights reserved.
 //

 import UIKit
 import SafariServices

 public enum MessageAction {
     case reply
     case edit
     case forward
     case delete
     case thread
     case share
 }
 
 protocol RowPresentable {
     var string: String { get }
     var rowVC: UIViewController & PanModalPresentable { get }
 }
 
 protocol MessageActionsDelegate {
     func didStartThreadPressed()
     func didEditPressed()
     func didDeletePressed()
     func didReplyPressed()
     func didSharePressed()
     func didForwardPressed()
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
         let actionsCell  = UINib.init(nibName: "ActionsCell", bundle: nil)
         self.tableView.register(actionsCell, forCellReuseIdentifier: "actionsCell")
     }
     
     // MARK: - UITableViewDataSource
     
     override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actions?.count ?? 0
     }
     
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         
         guard let cell = tableView.dequeueReusableCell(withIdentifier: "actionsCell", for: indexPath) as? ActionsCell
             else { return UITableViewCell() }
        
        if let currentActions = actions {
            switch currentActions[indexPath.row] {
            case .edit:
                cell.name.text = "Edit Message"
                if #available(iOS 13.0, *) {
                    cell.name.textColor = .label
                }else{
                    cell.name.textColor = .black
                }
                cell.icon.image = #imageLiteral(resourceName: "edit")
                cell.fullScreenSwitch.isHidden = true
                cell.badgeCountSwitch.isHidden = true
            case .delete:
                cell.name.text = "Delete Message"
                if #available(iOS 13.0, *) {
                    cell.name.textColor = .label
                }else{
                    cell.name.textColor = .black
                }
                cell.icon.image = #imageLiteral(resourceName: "delete")
                cell.fullScreenSwitch.isHidden = true
                cell.badgeCountSwitch.isHidden = true
            case .reply:
                cell.name.text = "Reply Message"
                if #available(iOS 13.0, *) {
                    cell.name.textColor = .label
                }else{
                    cell.name.textColor = .black
                }
                cell.icon.image = #imageLiteral(resourceName: "reply")
                cell.fullScreenSwitch.isHidden = true
                cell.badgeCountSwitch.isHidden = true
            case .forward:
                cell.name.text = "Forward Message"
                if #available(iOS 13.0, *) {
                    cell.name.textColor = .label
                }else{
                    cell.name.textColor = .black
                }
                cell.icon.image = #imageLiteral(resourceName: "forward1")
                cell.fullScreenSwitch.isHidden = true
                cell.badgeCountSwitch.isHidden = true
            case .thread:
                cell.name.text = "Start Thread"
                cell.icon.image = #imageLiteral(resourceName: "thread")
                if #available(iOS 13.0, *) {
                    cell.name.textColor = .label
                }else{
                    cell.name.textColor = .black
                }
                cell.fullScreenSwitch.isHidden = true
                cell.badgeCountSwitch.isHidden = true
                
            case .share:
                cell.icon.image = #imageLiteral(resourceName: "share")
                cell.name.text = "Share Message"
                if #available(iOS 13.0, *) {
                    cell.name.textColor = .label
                }else{
                    cell.name.textColor = .black
                }
                cell.fullScreenSwitch.isHidden = true
                cell.badgeCountSwitch.isHidden = true
            }
        }
         return cell
     }
     
     override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         return 65.0
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
     public static var actionsDelegate: MessageActionsDelegate?
 }
