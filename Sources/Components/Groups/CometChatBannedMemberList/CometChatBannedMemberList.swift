//
//  CometChatConversations.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 22/12/21.
//  Copyright ©  2022 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.
import UIKit
import CometChatPro


/**
 `CometChatBannedMemberList` is a subclass of `UIView` which internally uses a 0 and reusable cell i.e `CometChatBannedMemberListItem` which forms a list of recent conversations as per the data coming from the server.
 - Author: CometChat Team
 - Copyright:  ©  2022 CometChat Inc.
 */
@IBDesignable public final class CometChatBannedMemberList: UIView , NibLoadable {
   
    
    
    // MARK: - Declaration of IBInspectable
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var background: CometChatGradientView!
    @IBOutlet weak var tableView: UITableView!
    
    
    //MARK: - Declaration of Variables
    var bannedGroupMembersRequest : BannedGroupMembersRequest?
    var safeArea: UILayoutGuide!
    var group: Group?
    var bannedGroupMembers: [GroupMember] = [GroupMember]()
    var filteredBannedGroupMembers: [GroupMember] = [GroupMember]()
    var activityIndicator:UIActivityIndicatorView?
    var controller: UIViewController?
    var isSearching: Bool = false
    var limit: Int = 30
    var searchKeyword: String = ""
    var allowUnbanMembers: Bool = true
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
     The` background` is a `UIView` which is present in the backdrop for `CometChatBannedMemberList`.
     - Parameters:
     - background: This method will set the background color for CometChatBannedMemberList, it can take an array of multiple colors for the gradient background.
     - Returns: This method will return `CometChatBannedMemberList`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    public func set(background: [Any]?) ->  CometChatBannedMemberList {
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
    @objc public func set(group: Group?) -> CometChatBannedMemberList {
        if let group = group {
            self.group = group
            refreshBannedGroupMembers()
        }
        return self
    }
    
    @discardableResult
    @objc public func set(limit: Int) -> CometChatBannedMemberList {
        self.limit = limit
        return self
    }
    
    @discardableResult
    @objc public func set(searchKeyword: String) -> CometChatBannedMemberList {
        self.searchKeyword = searchKeyword
        return self
    }
    
    @discardableResult
    @objc public func allow(unbanMembers: Bool) -> CometChatBannedMemberList {
        self.allowUnbanMembers = unbanMembers
        return self
    }

    
    @discardableResult
    @objc public func set(scopes:[String]) -> CometChatBannedMemberList {
        self.scopes = scopes
        return self
    }
    
  
    @discardableResult
    public func set(emptyView: UIView?) -> CometChatBannedMemberList {
        self.emptyView = emptyView
        return self
    }
    
    @discardableResult
    public func set(errorView: UIView?) -> CometChatBannedMemberList {
        self.errorView = errorView
        return self
    }
    
    @discardableResult
    public func set(emptyStateMessage: String) -> CometChatBannedMemberList {
        self.emptyText = emptyStateMessage
        return self
    }
    
    @discardableResult
    public func set(errorMessage: String) -> CometChatBannedMemberList {
        self.errorText = errorMessage
        return self
    }
    
    @discardableResult
    public func hide(errorMessage: Bool) -> CometChatBannedMemberList {
        self.hideError = errorMessage
        return self
    }
    
    
    @discardableResult
    public func set(emptyStateTextFont: UIFont) -> CometChatBannedMemberList {
        self.emptyStateTextFont = emptyStateTextFont
        return self
    }
    
    @discardableResult
    public func set(emptyStateTextColor: UIColor) -> CometChatBannedMemberList {
        self.emptyStateTextColor = emptyStateTextColor
        return self
    }
    
    @discardableResult
    public func set(errorStateTextFont: UIFont) -> CometChatBannedMemberList {
        self.errorStateTextFont = errorStateTextFont
        return self
    }
    
    @discardableResult
    public func set(errorStateTextColor: UIColor) -> CometChatBannedMemberList {
        self.errorStateTextColor = errorStateTextColor
        return self
    }
    
 
    @discardableResult
    public func clearList() -> CometChatBannedMemberList {
        DispatchQueue.main.async {  [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.bannedGroupMembers.removeAll()
            strongSelf.tableView.reloadData()
        }
        return self
    }
    
    
    @discardableResult
    public func size() -> Int {
        return  bannedGroupMembers.count
    }
    
    @discardableResult
    public func add(groupMember: GroupMember) -> CometChatBannedMemberList {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.tableView?.beginUpdates()
            strongSelf.bannedGroupMembers.append(groupMember)
            strongSelf.tableView?.endUpdates()
        }
        return self
    }
    
    @discardableResult
    public func update(groupMember: GroupMember) -> CometChatBannedMemberList {
        if let row = self.bannedGroupMembers.firstIndex(where: {$0.uid == groupMember.uid}) {
            let indexPath = IndexPath(row: row, section: 0)
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                    strongSelf.tableView?.beginUpdates()
                    strongSelf.bannedGroupMembers[row] = groupMember
                    strongSelf.tableView?.reloadRows(at: [indexPath], with: .automatic)
                    strongSelf.tableView?.endUpdates()
                }
            }
        return self
    }
    
    
    @discardableResult
    public func remove(groupMember: GroupMember) -> CometChatBannedMemberList {
        DispatchQueue.main.async {  [weak self] in
            guard let strongSelf = self else { return }
            if let row = strongSelf.bannedGroupMembers.firstIndex(where: {$0.uid == groupMember.uid}) {
                let indexPath = IndexPath(row: row, section: 0)
                strongSelf.tableView.beginUpdates()
                strongSelf.bannedGroupMembers.remove(at: row)
                strongSelf.tableView?.deleteRows(at: [indexPath], with: .automatic)
                strongSelf.tableView.endUpdates()
            }
        }
        return self
    }
    
    

    @discardableResult
    public func set(style: Style) -> CometChatBannedMemberList {
        self.set(background: [style.background?.cgColor ?? UIColor.systemBackground.cgColor])
        self.set(emptyStateTextFont: style.emptyStateTextFont ?? UIFont.systemFont(ofSize: 20, weight: .bold))
        self.set(emptyStateTextColor: style.emptyStateTextColor ?? UIColor.gray)
        self.set(errorStateTextFont: style.errorStateTextFont ?? UIFont.systemFont(ofSize: 20, weight: .bold))
        self.set(errorStateTextColor: style.errorStateTextColor ?? UIColor.gray)
        return self
    }
    
    @discardableResult
    @objc public func set(configurations: [CometChatConfiguration]?) -> CometChatBannedMemberList {
        self.configurations = configurations
        configureGroupMemberList()
        return self
    }
    
    private func configureGroupMemberList() {
        if let configurations = configurations {
            _ = configurations.filter{ $0 is GroupListConfiguration }
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
     This method will set the instance of the view controller from which the `CometChatBannedMemberList` is presented. This method is mandatory to call when the conversation list is presented.
     - Parameters:
     - controller: This method will set the instance of the view controller from which the `CometChatBannedMemberList` is presented. This method is mandatory to call when the conversation list is presented.
     - Returns: This method will return `CometChatBannedMemberList`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(controller: UIViewController) -> CometChatBannedMemberList {
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
        self.tableView.tableFooterView = UIView(frame: .zero)
        self.registerCells()
    }
    
 
    fileprivate func registerCells() {
        self.registerCellWith(title: "CometChatDataItem")
    }
    
    private func registerCellWith(title: String){
        let cell = UINib(nibName: title, bundle: CometChatUIKit.bundle)
        self.tableView.register(cell, forCellReuseIdentifier: title)
    }
    
    
    // MARK: - Private instance methods.
    
    /**
     This method fetches the list of groups from  Server using **groupRequest** Class.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatBannedMemberList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-1-comet-chat-group-list)
     */
    private func fetchNextBannedGroupMembers(){
        activityIndicator?.startAnimating()
        activityIndicator?.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
        tableView.tableFooterView = activityIndicator
        tableView.tableFooterView?.isHidden = false

        bannedGroupMembersRequest?.fetchNext(onSuccess: { (fetchedBannedGroupMembers) in
            if fetchedBannedGroupMembers.count != 0{
                self.bannedGroupMembers.append(contentsOf: fetchedBannedGroupMembers)
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
     [CometChatBannedMemberList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-1-comet-chat-group-list)
     */
    private func refreshBannedGroupMembers(){
        bannedGroupMembers.removeAll()
        activityIndicator?.startAnimating()
        activityIndicator?.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
        tableView.tableFooterView = activityIndicator
        tableView.tableFooterView = activityIndicator
        tableView.tableFooterView?.isHidden = false

        bannedGroupMembersRequest =  BannedGroupMembersRequest.BannedGroupMembersRequestBuilder(guid: group?.guid ?? "").set(limit: limit).build()
        
        bannedGroupMembersRequest?.fetchNext(onSuccess: { [weak self] (fetchedBannedGroupMembers) in
            self?.set(configurations: self?.configurations)
            guard let this = self else {
                return
            }
            if fetchedBannedGroupMembers.count != 0 {
                this.bannedGroupMembers = fetchedBannedGroupMembers
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
            if let error = error ,  !self.hideError {
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
    
    public func filterBannedGroupMembers(forText: String?) {
        if let text = forText {
            if !text.isEmpty {
                bannedGroupMembersRequest =  BannedGroupMembersRequest.BannedGroupMembersRequestBuilder(guid: group?.guid ?? "").set(limit: limit).set(searchKeyword: text).build()
                
                bannedGroupMembersRequest?.fetchNext(onSuccess: { (fetchedBannedGroupMembers) in
                    
                    if fetchedBannedGroupMembers.count != 0 {
                        
                        print("groupMembers: \(fetchedBannedGroupMembers.count)")
                        
                        self.filteredBannedGroupMembers = fetchedBannedGroupMembers
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            self.tableView?.restore()
                            self.activityIndicator?.stopAnimating()
                            self.tableView.tableFooterView?.isHidden = true
                        }
                    }else{
                        self.filteredBannedGroupMembers = []
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            self.activityIndicator?.stopAnimating()
                            self.tableView.tableFooterView?.isHidden = true
                            if let emptyView = self.emptyView {
                                self.tableView.set(customView: emptyView)
                            }else{
                                self.tableView?.setEmptyMessage(self.emptyText ?? "", color: self.emptyStateTextColor, font: self.emptyStateTextFont)
                            }
                        }
                    }
                }) { (error) in
                    
                    print("error: \(error?.errorDescription)")
                }
            }else{
                self.tableView.reloadData()
            }
        }
    }
}


extension CometChatBannedMemberList: UITableViewDelegate, UITableViewDataSource {
    
    
    /// This method specifies the number of sections to display list of Conversations.
    /// - Parameter tableView: An object representing the table view requesting this information.
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /// This method specifies height for section in CometChatBannedMemberList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
   
    
    /// This method specifiesnumber of rows in CometChatBannedMemberList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if bannedGroupMembers.isEmpty {
            if let emptyView = self.emptyView {
                self.tableView.set(customView: emptyView)
            }else{
                self.tableView?.setEmptyMessage(self.emptyText , color: self.emptyStateTextColor, font: self.emptyStateTextFont)
            }
        } else{
            self.tableView.restore()
        }
        if isSearching {
            return filteredBannedGroupMembers.count
        }else{
            return bannedGroupMembers.count
        }
    }
    
    
    /// This method specifies the height for row in CometChatBannedMemberList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 67
    }
    
    /// This method specifies the view for group  in CometChatBannedMemberList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
        if isSearching {
    
            if let groupMember = filteredBannedGroupMembers[safe: indexPath.row] , let cometChatDataItem = tableView.dequeueReusableCell(withIdentifier: "CometChatDataItem", for: indexPath) as? CometChatDataItem {
                cometChatDataItem.set(configurations: configurations)
                cometChatDataItem.set(parentGroup: group)
                cometChatDataItem.set(bannedGroupMember: groupMember)
                return cometChatDataItem
            }
        } else {

            if let groupMember = bannedGroupMembers[safe: indexPath.row] , let cometChatDataItem = tableView.dequeueReusableCell(withIdentifier: "CometChatDataItem", for: indexPath) as? CometChatDataItem {
                cometChatDataItem.set(configurations: configurations)
                cometChatDataItem.set(parentGroup: group)
                cometChatDataItem.set(bannedGroupMember: groupMember)
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
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
   
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex && bannedGroupMembers.count > 10 {
            self.fetchNextBannedGroupMembers()
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
        
        let unbanMemberAction =  UIContextualAction(style: .destructive, title: "", handler: { (action,view, completionHandler ) in

            if let groupMember = selectedCell.bannedGroupMember {
                CometChat.unbanGroupMember(UID: groupMember.uid ?? "", GUID: self.group?.guid ?? "") { bannedSuccess in
                    self.bannedGroupMembers.remove(at: indexPath.row)
                    DispatchQueue.main.async {
                        if !self.bannedGroupMembers.isEmpty{
                            tableView.deleteRows(at: [indexPath], with: .fade)
                        }
                        self.tableView.reloadData()
                    }
                } onError: { error in
                    
                }
            }
        })

        if self.allowUnbanMembers {
            let image =  UIImage(named: "groups-kick.png", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            unbanMemberAction.image = image
            unbanMemberAction.backgroundColor = #colorLiteral(red: 1, green: 0.231372549, blue: 0.1882352941, alpha: 1)
            actions.append(unbanMemberAction)
        }
        
        if let group = group , let groupMember = selectedCell.bannedGroupMember {
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

