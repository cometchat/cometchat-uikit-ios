
 
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
 
 protocol CometChatActionPresentable {
    var string: String { get }
    var rowVC: UIViewController & PanModalPresentable { get }
 }
 
protocol CometChatActionSheetDelegate: AnyObject {
     func onActionItemClick(item: ActionItem)
 }

 
public class CometChatActionSheet: UIViewController{
     
    var isShortFormEnabled = true
    var actionItems: [ActionItem]?
    weak var actionSheetDelegate: CometChatActionSheetDelegate? = nil
    
    public static var style = ActionSheetStyle() //global styling
    public lazy var style = CometChatActionSheet.style //component level styling
    
    private var tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        setupStyle()
    }
    
    @discardableResult
    public func set(tableViewStyle: UITableView.Style) -> Self {
        self.setupTableView(tableViewStyle: tableViewStyle)
        return self
    }
    
    @discardableResult
    public func hide(footerView: Bool) -> Self {
        if footerView {
            tableView.sectionFooterHeight = .leastNormalMagnitude
        }
        return self
    }
    
    @discardableResult
    public func set(actionItems: [ActionItem]) -> Self {
        self.actionItems = actionItems
        return self
    }
         
    // MARK: - View Configurations
    func setupTableView(tableViewStyle: UITableView.Style = .insetGrouped) {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        self.view.embed(tableView, insets: .init(
            top: CometChatSpacing.Padding.p3,
            leading: 0,
            bottom: CometChatSpacing.Padding.p3,
            trailing: 0
        )
        )
        self.tableView.backgroundColor = .clear
        self.registerCells()
    }
    
    func setupStyle(){
        view.backgroundColor = style.backgroundColor
        view.borderWith(width: style.borderWidth)
        view.borderColor(color: style.borderColor)
        view.roundViewCorners(corner: style.cornerRadius ?? .init(cornerRadius: CometChatSpacing.Radius.r4))
    }
    
    private func registerCells() {
        self.tableView.register(CometChatActionItem.self, forCellReuseIdentifier: "CometChatActionItem")
    }
    
    private func configureCell(withTitle: String, icon: UIImage, forIndexPath: IndexPath) -> UITableViewCell {
        if let cometChatActionItem = tableView.dequeueReusableCell(withIdentifier: "CometChatActionItem") as? CometChatActionItem,
           let actionItem = actionItems?[safe: forIndexPath.row] {
            cometChatActionItem.set(actionItem: actionItem)
            return cometChatActionItem
        }
        return UITableViewCell()
    }
}

extension CometChatActionSheet: UITableViewDataSource, UITableViewDelegate{
    // MARK: - UITableViewDataSource
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actionItems?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let staticCell = UITableViewCell()
        if let actionItem = actionItems?[safe: indexPath.row] {
            if let cell = configureCell(withTitle: actionItem.text ?? "", icon: actionItem.leadingIcon ?? UIImage(), forIndexPath: indexPath) as? CometChatActionItem {
                return cell
            }
            return UITableViewCell()
        }
        return staticCell
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let currentAction = actionItems?[safe: indexPath.row] {
            self.dismiss(animated: true) { [weak self] in
                self?.actionSheetDelegate?.onActionItemClick(item: currentAction)
            }
        }
    }
}

extension CometChatActionSheet: PanModalPresentable{
    // MARK: - Pan Modal Presentable
    var panScrollable: UIScrollView? {
        return tableView
    }
    
    var shortFormHeight: PanModalHeight {
        let height = (actionItems?.count ?? 0) * 65 + 80
        return isShortFormEnabled ? .contentHeight(CGFloat(height)) : longFormHeight
    }
    
    var anchorModalToLongForm: Bool {
        return false
    }
    
    func willTransition(to state: PanModalPresentationController.PresentationState) {
        guard isShortFormEnabled, case .longForm = state
        else { return }
        
        isShortFormEnabled = false
        panModalSetNeedsLayoutUpdate()
    }
}

extension CometChatActionSheet {
    
    func didTapOnAction(action: ActionItem) {
        self.dismiss(animated: true) { [weak self] in
            self?.actionSheetDelegate?.onActionItemClick(item: action)
        }
    }
}
