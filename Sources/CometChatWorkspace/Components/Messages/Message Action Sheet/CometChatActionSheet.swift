
 
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

public class ActionItem: NSObject {
    
    var id: String
    var title: String
    var icon: UIImage
    
    init(id: String, title: String, icon: UIImage) {
        self.id = id
        self.title = title
        self.icon = icon
    }
}

 
 class CometChatActionSheet: UITableViewController, PanModalPresentable {
    
    var isShortFormEnabled = true
    var layoutMode: LayoutMode = .gridMode
     
    static var backgroundColor : UIColor =  #colorLiteral(red: 0.9058460593, green: 0.9195671678, blue: 0.9193262458, alpha: 1)
     
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
         if #available(iOS 13.0, *) {
             tableView.backgroundColor = .systemBackground
         } else {
             tableView.backgroundColor = .white
         }
         self.registerCells()
     }
     
     private func registerCells(){
         self.registerCellWith(title: "AddReactionsCell")
         self.registerCellWith(title: "ListModeCell")
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
         
         if let cell = tableView.dequeueReusableCell(withIdentifier: "ListModeCell") as? ListModeCell {
             cell.name.text =  withTitle
             cell.icon.image = icon.withRenderingMode(.alwaysTemplate)
             cell.icon.tintColor = tintColor
             return cell
         }
         
         return UITableViewCell()
     }
     
     override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
             if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) {
                 cell.separatorInset.left = cell.bounds.size.width
             }
         }
     
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let staticCell = UITableViewCell()
         switch layoutMode {
         case .listMode:
             if let actionItem = actionItems?[safe: indexPath.row] {
                 
                 if let cell  = configureCell(withTitle: actionItem.title, icon: actionItem.icon, tintColor: .white, forIndexPath: indexPath) as? ListModeCell {
                     
                     if indexPath.row == 0 {
                         
                         cell.background.roundViewCorners([.layerMinXMinYCorner,.layerMaxXMinYCorner], radius: 15)
                     }else if indexPath.row == (actionItems?.count ?? 0) - 1 {
                         cell.background.roundViewCorners([.layerMinXMaxYCorner,.layerMaxXMaxYCorner], radius: 15)
                     }
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
         case .listMode: return 56.0
         case .gridMode: return CGFloat((actionItems?.count ?? 0/2) * 52)
         }
     }
    
    // MARK: - UITableViewDelegate
    
   
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let actionSheetHeaderView = ActionSheetHeaderView()
        switch layoutMode {
        case .listMode:
            let image = UIImage(named: "actionsheet-change-layout.png")?.withRenderingMode(.alwaysTemplate)
            actionSheetHeaderView.layoutMode.setImage(image, for: .normal)
            actionSheetHeaderView.layoutMode.tintColor = .white
        case .gridMode:
            
            let image = UIImage(named: "actionsheet-grid.png")?.withRenderingMode(.alwaysTemplate)
            actionSheetHeaderView.layoutMode.setImage(image, for: .normal)
            actionSheetHeaderView.layoutMode.tintColor = .white
        }
        actionSheetHeaderView.actionSheetHeaderViewDelegate = self
        return actionSheetHeaderView
    }
     
     override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
         return UITableView.automaticDimension
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
        let height = (actionItems?.count ?? 0) * 65 + 40
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
        switch self.layoutMode {
        case .listMode:
            set(layoutMode: .gridMode)
        case .gridMode:
            set(layoutMode: .listMode)
        }
        updateViewConstraints()
    }
    
}


 extension CometChatActionSheet {
    static var actionsSheetDelegate: CometChatActionSheetDelegate?
 }

