//
//  CometChatConversations.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 22/12/21.
//  Copyright ©  2022 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.
import UIKit
import CometChatPro


/**
 `CometChatMemberList` is a subclass of `UIView` which internally uses a 0 and reusable cell i.e `CometChatMemberListItem` which forms a list of recent conversations as per the data coming from the server.
 - Author: CometChat Team
 - Copyright:  ©  2022 CometChat Inc.
 */
@IBDesignable public final class CometChatMemberList: UIView {
   
    
    
    // MARK: - Declaration of IBInspectable
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var background: CometChatGradientView!
    @IBOutlet weak var tableView: UITableView!
    
    
    //MARK: - Declaration of Variables
    var groupMemberRequest : GroupMembersRequest?
    var safeArea: UILayoutGuide!
    var group: Group?
    var selectedMember: GroupMember?
    var groupMembers: [GroupMember] = [GroupMember]()
    var filteredGroupMembers: [GroupMember] = [GroupMember]()
    var activityIndicator:UIActivityIndicatorView?
    var controller: UIViewController?
    var isSearching: Bool = false
    var limit: Int = 30
    var searchKeyword: String = ""
    var allowKickMembers: Bool = true
    var allowBanMembers: Bool = true
    var allowSelection: Bool = false
    var allowPromoteDemoteMembers: Bool = true
    var scopes: [String] = [String]()
    var emptyView: UIView?
    var errorView: UIView?
    var hideError: Bool = false
    var errorText: String = ""
    var emptyText: String = "NO_USERS_FOUND".localize()
    var emptyStateTextFont: UIFont = UIFont.systemFont(ofSize: 34, weight: .bold)
    var emptyStateTextColor: UIColor = UIColor.gray
    var errorStateTextFont: UIFont?
    var errorStateTextColor: UIColor?
    var configurations: [CometChatConfiguration]?
    
    
    
    
    /**
     The` background` is a `UIView` which is present in the backdrop for `CometChatMemberList`.
     - Parameters:
     - background: This method will set the background color for CometChatMemberList, it can take an array of multiple colors for the gradient background.
     - Returns: This method will return `CometChatMemberList`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    public func set(background: [Any]?) ->  CometChatMemberList {
        if let backgroundColors = background as? [CGColor] {
            if backgroundColors.count == 1 {
                self.background.backgroundColor = UIColor(cgColor: backgroundColors.first ?? UIColor.blue.cgColor)
            }else{
                self.background.set(backgroundColorWithGradient: background)
            }
        }
        return self
    }
    
    @discardableResult
    @objc public func set(group: Group?) -> CometChatMemberList {
        if let group = group {
            self.group = group
            refreshGroupMembers()
        }
        return self
    }
    
    @discardableResult
    @objc public func set(limit: Int) -> CometChatMemberList {
        self.limit = limit
        return self
    }
    
    @discardableResult
    @objc public func set(searchKeyword: String) -> CometChatMemberList {
        self.searchKeyword = searchKeyword
        return self
    }
    
    @discardableResult
    @objc public func allow(kickMembers: Bool) -> CometChatMemberList {
        self.allowKickMembers = kickMembers
        return self
    }
    
    @discardableResult
    @objc public func allow(banMembers: Bool) -> CometChatMemberList {
        self.allowBanMembers = banMembers
        return self
    }
    
    @discardableResult
    @objc public func allow(promoteDemoteMembers: Bool) -> CometChatMemberList {
        self.allowPromoteDemoteMembers = promoteDemoteMembers
        return self
    }
    
    @discardableResult
    @objc public func allow(selection: Bool) -> CometChatMemberList {
        self.allowSelection = selection
        return self
    }
    
    @discardableResult
    @objc public func set(scopes:[String]) -> CometChatMemberList {
        self.scopes = scopes
        return self
    }
    
  
    @discardableResult
    public func set(emptyView: UIView?) -> CometChatMemberList {
        self.emptyView = emptyView
        return self
    }
    
    @discardableResult
    public func set(errorView: UIView?) -> CometChatMemberList {
        self.errorView = errorView
        return self
    }
    
    @discardableResult
    public func set(emptyStateMessage: String) -> CometChatMemberList {
        self.emptyText = emptyStateMessage
        return self
    }
    
    @discardableResult
    public func set(errorMessage: String) -> CometChatMemberList {
        self.errorText = errorMessage
        return self
    }
    
    @discardableResult
    public func hide(errorMessage: Bool) -> CometChatMemberList {
        self.hideError = errorMessage
        return self
    }
    
    
    @discardableResult
    public func set(emptyStateTextFont: UIFont) -> CometChatMemberList {
        self.emptyStateTextFont = emptyStateTextFont
        return self
    }
    
    @discardableResult
    public func set(emptyStateTextColor: UIColor) -> CometChatMemberList {
        self.emptyStateTextColor = emptyStateTextColor
        return self
    }
    
    @discardableResult
    public func set(errorStateTextFont: UIFont) -> CometChatMemberList {
        self.errorStateTextFont = errorStateTextFont
        return self
    }
    
    @discardableResult
    public func set(errorStateTextColor: UIColor) -> CometChatMemberList {
        self.errorStateTextColor = errorStateTextColor
        return self
    }
    
 
    @discardableResult
    public func clearList() -> CometChatMemberList {
        DispatchQueue.main.async {  [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.groupMembers.removeAll()
            strongSelf.tableView.reloadData()
        }
        return self
    }
    
    
    @discardableResult
    public func size() -> Int {
        return  groupMembers.count
    }
    
    @discardableResult
    public func add(groupMember: GroupMember) -> CometChatMemberList {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.tableView?.beginUpdates()
            strongSelf.groupMembers.append(groupMember)
            strongSelf.tableView?.endUpdates()
        }
        return self
    }
    
    @discardableResult
    public func update(groupMember: GroupMember) -> CometChatMemberList {
        if let row = self.groupMembers.firstIndex(where: {$0.uid == groupMember.uid}) {
            let indexPath = IndexPath(row: row, section: 0)
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                    strongSelf.tableView?.beginUpdates()
                    strongSelf.groupMembers[row] = groupMember
                    strongSelf.tableView?.reloadRows(at: [indexPath], with: .automatic)
                    strongSelf.tableView?.endUpdates()
                }
            }
        return self
    }
    
    
    @discardableResult
    public func remove(groupMember: GroupMember) -> CometChatMemberList {
        DispatchQueue.main.async {  [weak self] in
            guard let strongSelf = self else { return }
            if let row = strongSelf.groupMembers.firstIndex(where: {$0.uid == groupMember.uid}) {
                let indexPath = IndexPath(row: row, section: 0)
                strongSelf.tableView.beginUpdates()
                strongSelf.groupMembers.remove(at: row)
                strongSelf.tableView?.deleteRows(at: [indexPath], with: .automatic)
                strongSelf.tableView.endUpdates()
            }
        }
        return self
    }
    
    

    @discardableResult
    public func set(style: Style) -> CometChatMemberList {
        self.set(background: [style.background?.cgColor ?? UIColor.systemBackground.cgColor])
        self.set(emptyStateTextFont: style.emptyStateTextFont ?? UIFont.systemFont(ofSize: 20, weight: .bold))
        self.set(emptyStateTextColor: style.emptyStateTextColor ?? UIColor.gray)
        self.set(errorStateTextFont: style.errorStateTextFont ?? UIFont.systemFont(ofSize: 20, weight: .bold))
        self.set(errorStateTextColor: style.errorStateTextColor ?? UIColor.gray)
        return self
    }
    
    @discardableResult
    @objc public func set(configurations: [CometChatConfiguration]?) -> CometChatMemberList {
        self.configurations = configurations
        configureGroupMemberList()
        return self
    }
    
    private func configureGroupMemberList() {
        if let configurations = configurations {
            let currentConfigurations = configurations.filter{ $0 is GroupListConfiguration }
//            if let configuration = currentConfigurations.last as? GroupListConfiguration {
//                set(background: configuration.background)
//                set(emptyView: configuration.emptyView)
//                set(joinedOnly: configuration.isJoinedOnly)
//                hide(errorMessage: configuration.hideError)
//                set(searchKeyword: configuration.searchKeyWord)
//                set(limit: configuration.limit)
//                set(tags: configuration.tags)
//
//            }
        }
     }
    
    /**
     This method will set the instance of the view controller from which the `CometChatMemberList` is presented. This method is mandatory to call when the conversation list is presented.
     - Parameters:
     - controller: This method will set the instance of the view controller from which the `CometChatMemberList` is presented. This method is mandatory to call when the conversation list is presented.
     - Returns: This method will return `CometChatMemberList`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(controller: UIViewController) -> CometChatMemberList {
        self.controller = controller
        return self
    }
    
  
    // MARK: - Instance Methods
    
    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        let loadedNib = Bundle.module.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)
        if let contentView = loadedNib?.first as? UIView  {
            contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            contentView.frame = bounds
            addSubview(contentView)
        }
        setuptTableView()
        registerCells()
        setupDelegates()
        configureGroupMemberList()
        self.backgroundColor = .red
    }
    
    private  func setupDelegates(){
        
        
    }
    
    fileprivate func setuptTableView() {
        if #available(iOS 13.0, *) {
            activityIndicator = UIActivityIndicatorView(style: .medium)
        } else {
            activityIndicator = UIActivityIndicatorView(style: .gray)
        }
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = .clear
        self.tableView.allowsSelection = true
        self.tableView.tableFooterView = UIView(frame: .zero)
        self.registerCells()
    }
    
 
    fileprivate func registerCells() {
        self.registerCellWith(title: "CometChatDataItem")
    }
    
    private func registerCellWith(title: String){
        let cell = UINib(nibName: title, bundle: Bundle.module)
        self.tableView.register(cell, forCellReuseIdentifier: title)
    }
    
    
    // MARK: - Private instance methods.
    
    /**
     This method fetches the list of groups from  Server using **groupRequest** Class.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMemberList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-1-comet-chat-group-list)
     */
    private func fetchNextGroupMembers(){
        activityIndicator?.startAnimating()
        activityIndicator?.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
        tableView.tableFooterView = activityIndicator
        tableView.tableFooterView?.isHidden = false

        groupMemberRequest?.fetchNext(onSuccess: { (fetchedGroupMembers) in
            if fetchedGroupMembers.count != 0{
                self.groupMembers.append(contentsOf: fetchedGroupMembers)
                DispatchQueue.main.async {
                    self.activityIndicator?.stopAnimating()
                    self.tableView.tableFooterView?.isHidden = true
                    self.tableView.reloadData()
                }
            }
            DispatchQueue.main.async {
                self.activityIndicator?.stopAnimating()
                self.tableView.tableFooterView?.isHidden = true}
        }) { (error) in
            if let error = error, let group = self.group {
                CometChatGroupEvents.emitOnError(group: group, error: error)
                if !self.hideError {
                    let confirmDialog = CometChatDialog()
                    confirmDialog.set(confirmButtonText: "TRY_AGAIN".localize())
                    confirmDialog.set(cancelButtonText: "CANCEL".localize())
                    if self.errorText.isEmpty {
                        confirmDialog.set(error: CometChatServerError.get(error: error))
                    }else{
                        confirmDialog.set(messageText: self.errorText)
                    }
                    confirmDialog.open(onConfirm: { [weak self] in
                        guard let strongSelf = self else { return }
                        // Referesh list
                        strongSelf.tableView.reloadData()
                    })
                }
            }
        }
    }
    
    
    
    // MARK: - Private instance methods.
    /**
     This method fetches the list of groups from  Server using **groupRequest** Class.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMemberList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-1-comet-chat-group-list)
     */
    private func refreshGroupMembers(){
        print(#function)
        groupMembers.removeAll()
        activityIndicator?.startAnimating()
        activityIndicator?.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
        tableView.tableFooterView = activityIndicator
        tableView.tableFooterView = activityIndicator
        tableView.tableFooterView?.isHidden = false
        groupMemberRequest = GroupMembersRequest.GroupMembersRequestBuilder(guid: group?.guid ?? "").set(limit: limit).set(scopes: scopes).build()
        groupMemberRequest?.fetchNext(onSuccess: { [weak self] (fetchedGroupMembers) in
            self?.set(configurations: self?.configurations)
            
            print(#function, fetchedGroupMembers)
            
            guard let this = self else {
                return
            }
            if fetchedGroupMembers.count != 0 {
                this.groupMembers = fetchedGroupMembers
                DispatchQueue.main.async {
                    this.activityIndicator?.stopAnimating()
                    this.tableView.tableFooterView?.isHidden = true
                    this.tableView.reloadData()
                }
            }else{
                DispatchQueue.main.async {
                    this.activityIndicator?.stopAnimating()
                    this.tableView.tableFooterView?.isHidden = true
                    this.tableView.reloadData()
                }
            }
            DispatchQueue.main.async {
                this.activityIndicator?.stopAnimating()
                this.tableView.tableFooterView?.isHidden = true}
        }) { (error) in
            
            if let error = error {
                if !self.hideError {
                    let confirmDialog = CometChatDialog()
                    confirmDialog.set(confirmButtonText: "TRY_AGAIN".localize())
                    confirmDialog.set(cancelButtonText: "CANCEL".localize())
                    if self.errorText.isEmpty {
                        confirmDialog.set(error: CometChatServerError.get(error: error))
                    }else{
                        confirmDialog.set(messageText: self.errorText)
                    }
                    confirmDialog.open(onConfirm: { [weak self] in
                        guard let strongSelf = self else { return }
                        // Referesh list
                        strongSelf.refreshGroupMembers()
                    })
                }
            }
        }
    }
    
    public func filterGroupMembers(forText: String?) {
        if let text = forText {
            if !text.isEmpty {
                groupMemberRequest = GroupMembersRequest.GroupMembersRequestBuilder(guid: group?.guid ?? "").set(limit: limit).set(scopes: scopes).set(searchKeyword: text).build()
                
                groupMemberRequest?.fetchNext(onSuccess: { (groupMembers) in
                   
                    
                    if groupMembers.count != 0 {
                        
                        print("groupMembers: \(groupMembers.count)")
                        
                        self.filteredGroupMembers = groupMembers
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            self.tableView?.restore()
                            self.activityIndicator?.stopAnimating()
                            self.tableView.tableFooterView?.isHidden = true
                        }
                    }else{
                        self.filteredGroupMembers = []
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            self.activityIndicator?.stopAnimating()
                            self.tableView.tableFooterView?.isHidden = true
                            if let emptyView = self.emptyView {
                                self.tableView.set(customView: emptyView)
                            }else{
                                self.tableView?.setEmptyMessage(self.emptyText , color: self.emptyStateTextColor, font: self.emptyStateTextFont)
                            }
                        }
                    }
                }) { (error) in
                    
                    print("error: \(String(describing: error?.errorDescription))")
                }
            }else{
                self.tableView.reloadData()
            }
        }
    }
}


extension CometChatMemberList: UITableViewDelegate, UITableViewDataSource {
    
    
    /// This method specifies the number of sections to display list of Conversations.
    /// - Parameter tableView: An object representing the table view requesting this information.
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /// This method specifies height for section in CometChatMemberList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
   
    
    /// This method specifiesnumber of rows in CometChatMemberList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if groupMembers.isEmpty {
            if let emptyView = self.emptyView {
                self.tableView.set(customView: emptyView)
            }else{
                self.tableView?.setEmptyMessage(self.emptyText , color: self.emptyStateTextColor, font: self.emptyStateTextFont)
            }
        } else{
            self.tableView.restore()
        }
        if isSearching {
            return filteredGroupMembers.count
        }else{
            return groupMembers.count
        }
    }
    
    
    /// This method specifies the height for row in CometChatMemberList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 67
    }
    
    /// This method specifies the view for group  in CometChatMemberList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
        if isSearching {
    
            if let groupMember = filteredGroupMembers[safe: indexPath.row] , let cometChatDataItem = tableView.dequeueReusableCell(withIdentifier: "CometChatDataItem", for: indexPath) as? CometChatDataItem {
                cometChatDataItem.set(configurations: configurations)
                cometChatDataItem.set(parentGroup: group)
                cometChatDataItem.allow(selection: allowSelection)
                cometChatDataItem.allow(pramoteDemoteModerators: allowPromoteDemoteMembers)
                cometChatDataItem.set(groupMember: groupMember)
                return cometChatDataItem
            }
        } else {

            if let groupMember = groupMembers[safe: indexPath.row] , let cometChatDataItem = tableView.dequeueReusableCell(withIdentifier: "CometChatDataItem", for: indexPath) as? CometChatDataItem {
                cometChatDataItem.set(configurations: configurations)
                cometChatDataItem.set(parentGroup: group)
                cometChatDataItem.allow(selection: allowSelection)
                cometChatDataItem.allow(pramoteDemoteModerators: allowPromoteDemoteMembers)
                cometChatDataItem.set(groupMember: groupMember)

                return cometChatDataItem
            }
        }
        
        return UITableViewCell()
    }
    

    
    /// This method triggers when particulatr cell is clicked by the group .
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - indexPath: specifies current index for TableViewCell.
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if allowSelection == false {
        tableView.deselectRow(at: indexPath, animated: true)
        }else{
            if let row = tableView.cellForRow(at: indexPath) as? CometChatDataItem, let groupMember = row.groupMember {
                self.selectedMember = groupMember
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if allowSelection == true {
            if let row = tableView.cellForRow(at: indexPath) as? CometChatDataItem, let groupMember = row.groupMember {
                if selectedMember?.uid == groupMember.uid {
                    self.selectedMember = nil
                }
            }
        }
    }
   
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex && groupMembers.count > 10 {
            self.fetchNextGroupMembers()
        }
    }
    
    public func tableView(_ tableView: UITableView,
                          sectionForSectionIndexTitle title: String,
                          at index: Int) -> Int {
        return index
    }
    
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var actions = [UIContextualAction]()
        guard  let selectedCell = self.tableView.cellForRow(at: indexPath) as? CometChatDataItem  else { return nil }
        
        let banMemberAction =  UIContextualAction(style: .destructive, title: "", handler: { (action,view, completionHandler ) in
            if let groupMember = selectedCell.groupMember {
                CometChat.banGroupMember(UID: groupMember.uid ?? "", GUID: self.group?.guid ?? "") { bannedSuccess in
                    self.groupMembers.remove(at: indexPath.row)
                    if let group = self.group {
                        CometChatGroupEvents.emitOnGroupMemberBan(bannedUser: groupMember, bannedGroup: group)
                    }
                    DispatchQueue.main.async {
                        if !self.groupMembers.isEmpty{
                            tableView.deleteRows(at: [indexPath], with: .fade)
                        }
                        self.tableView.reloadData()
                    }
                } onError: { error in
                    
                }
            }
        })

        let kickMemberAction =  UIContextualAction(style: .destructive, title: "", handler: { (action,view, completionHandler ) in

            if let groupMember = selectedCell.groupMember {
                CometChat.kickGroupMember(UID: groupMember.uid ?? "", GUID: self.group?.guid ?? "") { bannedSuccess in
                    self.groupMembers.remove(at: indexPath.row)
                    DispatchQueue.main.async {
                        if !self.groupMembers.isEmpty{
                            tableView.deleteRows(at: [indexPath], with: .fade)
                        }
                        self.tableView.reloadData()
                    }
                } onError: { error in
                    
                }
            }
        })

        if self.allowKickMembers {
            let image =  UIImage(named: "groups-kick.png", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            kickMemberAction.image = image
            kickMemberAction.backgroundColor = #colorLiteral(red: 1, green: 0.231372549, blue: 0.1882352941, alpha: 1)
            actions.append(kickMemberAction)
        }
        
        if self.allowBanMembers {
            let image =  UIImage(named: "groups-ban.png", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            banMemberAction.image = image
            banMemberAction.backgroundColor = #colorLiteral(red: 1, green: 0.8, blue: 0, alpha: 1)
            actions.append(banMemberAction)
        }
        
        
        if let group = group , let groupMember = selectedCell.groupMember {
            switch group.scope {
            case .admin where groupMember.scope == .participant:
                return  UISwipeActionsConfiguration(actions: actions)
            case .admin where groupMember.scope == .moderator:
                return  UISwipeActionsConfiguration(actions: actions)
            case .admin where groupMember.scope == .admin: break
            case .moderator where groupMember.scope == .participant:
                return  UISwipeActionsConfiguration(actions: actions)
            case .moderator where groupMember.scope == .moderator: break
            case .moderator where groupMember.scope == .admin: break
            case .participant where groupMember.scope == .participant: break
            case .participant where groupMember.scope == .moderator: break
            case .participant where groupMember.scope == .admin: break
            @unknown default: break
            }
        }
        return  UISwipeActionsConfiguration(actions: [])
    }
}

/*  ----------------------------------------------------------------------------------------- */

