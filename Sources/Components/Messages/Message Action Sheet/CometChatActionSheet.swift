
 
 import UIKit
 import SafariServices
 
struct CometChatDefaultAction {
    var takeAPhoto =  "takeAPhoto"
    var photoAndVideoLibrary = "photoAndVideoLibrary"
    var document = "document"
    var location = "location"
    var poll = "poll"
    var sticker = "sticker"
    var whiteboard = "whiteboard"
    var writeboard = "writeboard"
 }

enum LayoutMode {
    case listMode
    case gridMode
}
 
 protocol CometChatActionPresentable {
    var string: String { get }
    var rowVC: UIViewController & PanModalPresentable { get }
 }
 
 protocol CometChatActionSheetDelegate {
     func onActionItemClick(item: ActionItem)
 }

 
 class CometChatActionSheet: UITableViewController, PanModalPresentable {
    
    var isShortFormEnabled = true
    var layoutMode: LayoutMode = .gridMode
     
     static var backgroundColor : UIColor =  CometChatTheme.palatte?.secondary ?? .systemFill
     
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    let headerView = UserGroupHeaderView()
     
    var actionItems: [ActionItem]?
     
    let headerPresentable = UserGroupHeaderPresentable.init(handle: "Message Actions", description: "Select action to perform.", memberCount: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

     @discardableResult
     public func set(actionItems: [ActionItem]) -> CometChatActionSheet {
         self.actionItems = actionItems
         return self
     }
     
     @discardableResult
     public func set(layoutMode: LayoutMode) -> CometChatActionSheet {
         self.layoutMode = layoutMode
         self.tableView.reloadData()
         return self
     }
         
    // MARK: - View Configurations
    
     func setupTableView() {
         self.tableView = UITableView(frame: self.tableView.frame, style: .insetGrouped)
         tableView.backgroundColor = CometChatTheme.palatte?.secondary
         self.registerCells()
     }
     
     private func registerCells(){
         self.registerCellWith(title: "AddReactionsCell")
         self.registerCellWith(title: "CometChatActionItem")
         self.registerCellWith(title: "GridModeCell")
     }
     
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch layoutMode {
        case .listMode:
            return actionItems?.count ?? 0
        case .gridMode:
            return 1
        }
    }
    
     private func registerCellWith(title: String){
         let cell = UINib(nibName: title, bundle: CometChatUIKit.bundle)
         self.tableView?.register(cell, forCellReuseIdentifier: title)
     }
     
     private func configureCell(withTitle: String, icon: UIImage, tintColor: UIColor, forIndexPath: IndexPath) -> UITableViewCell {
         
         if let cometChatActionItem = tableView.dequeueReusableCell(withIdentifier: "CometChatActionItem") as? CometChatActionItem,  let actionItem = actionItems?[safe: forIndexPath.row] {
             cometChatActionItem.set(actionItem: actionItem)
             return cometChatActionItem
         }
         
         return UITableViewCell()
     }
     
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let staticCell = UITableViewCell()
         switch layoutMode {
         case .listMode:
             if let actionItem = actionItems?[safe: indexPath.row] {
                 
                 if let cell  = configureCell(withTitle: actionItem.text ?? "", icon: actionItem.startIcon ?? UIImage(), tintColor: .white, forIndexPath: indexPath) as? CometChatActionItem {
                     return cell
                 }
                 
                return UITableViewCell()

             }
         case .gridMode:
             
             if let cell = tableView.dequeueReusableCell(withIdentifier: "GridModeCell", for: indexPath) as? GridModeCell {
                 cell.gridDelegate = self
                 cell.set(actionsItems: actionItems ?? [])
                 cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.width)
                 return cell
             }
         }
         return staticCell
     }
    
     override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         switch layoutMode {
         case .listMode: return UITableView.automaticDimension
         case .gridMode: return CGFloat((actionItems?.count ?? 0/2) * 52)
         }
     }
    
    // MARK: - UITableViewDelegate
    
   
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let actionSheetHeaderView = ActionSheetHeaderView()
        switch layoutMode {
        case .listMode:
            let image = UIImage(named: "actionsheet-list.png", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            actionSheetHeaderView.layoutMode.setImage(image, for: .normal)
            actionSheetHeaderView.layoutMode.tintColor = CometChatTheme.palatte?.primary
        case .gridMode:
            
            let image = UIImage(named: "actionsheet-grid.png", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            actionSheetHeaderView.layoutMode.setImage(image, for: .normal)
            actionSheetHeaderView.layoutMode.tintColor = CometChatTheme.palatte?.primary
        }
        actionSheetHeaderView.actionSheetHeaderViewDelegate = self
        return actionSheetHeaderView
    }
     
     override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
         return 55
     }
    
     override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         tableView.deselectRow(at: indexPath, animated: true)
         if let currentAction = actionItems?[safe: indexPath.row] {
             self.dismiss(animated: true) {
                 CometChatActionSheet.actionsSheetDelegate?.onActionItemClick(item: currentAction)
             }
         }
     }
    
    // MARK: - Pan Modal Presentable
    
    var panScrollable: UIScrollView? {
        return tableView
    }
    
    var shortFormHeight: PanModalHeight {
        let height = (actionItems?.count ?? 0) * 65
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
 

extension CometChatActionSheet : GridModeDelegate {
    
    func didTapOnAction(action: ActionItem) {
        self.dismiss(animated: true) {
            CometChatActionSheet.actionsSheetDelegate?.onActionItemClick(item: action)
        }
    }
}

extension CometChatActionSheet : ActionSheetHeaderViewDelegate {
    
    func didCloseButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func didChangeLayoutPressed() {
        UIView.transition(with: tableView, duration: 0.4,
                          options: .autoreverse,
                          animations: {
        switch self.layoutMode {
        case .listMode:
            self.set(layoutMode: .gridMode)
        case .gridMode:
            self.set(layoutMode: .listMode)
        }
        self.tableView.reloadData()
        })
    }
}

 extension CometChatActionSheet {
    static var actionsSheetDelegate: CometChatActionSheetDelegate?
 }

