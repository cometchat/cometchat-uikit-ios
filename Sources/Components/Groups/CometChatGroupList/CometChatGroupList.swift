//
//  CometChatConversations.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 22/12/21.
//  Copyright ©  2022 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.
import UIKit
import CometChatPro


/**
 `CometChatGroupList` is a subclass of `UIView` which internally uses a 0 and reusable cell i.e `CometChatGroupListItem` which forms a list of recent conversations as per the data coming from the server.
 - Author: CometChat Team
 - Copyright:  ©  2022 CometChat Inc.
 */
@IBDesignable public final class CometChatGroupList: UIView , NibLoadable {
    
    // MARK: - Declaration of IBInspectable
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var background: CometChatGradientView!
    @IBOutlet weak var tableView: UITableView!
    
    
    //MARK: - Declaration of Variables
    var groupRequest : GroupsRequest?
    var safeArea: UILayoutGuide!
    var groups: [Group] = [Group]()
    var filteredgroups: [Group] = [Group]()
    var activityIndicator:UIActivityIndicatorView?
    var controller: UIViewController?
    var isSearching: Bool = false
    var limit: Int = 30
    var searchKeyword: String = ""
    var joinedOnly: Bool = true
    var tags: [String] = [String]()
    var emptyView: UIView?
    var errorView: UIView?
    var hideError: Bool = false
    var errorText: String = ""
    var emptyText: String = "NO_GROUPS_FOUND".localize()
    var emptyStateTextFont: UIFont = UIFont.systemFont(ofSize: 34, weight: .bold)
    var emptyStateTextColor: UIColor = UIColor.gray
    var errorStateTextFont: UIFont?
    var errorStateTextColor: UIColor?
    var configurations: [CometChatConfiguration] = [CometChatConfiguration]()
    
    
    @discardableResult
    @objc public func set(configurations: [CometChatConfiguration]) -> CometChatGroupList {
        self.configurations = configurations
        configureGroupList()
        refreshGroups()
        return self
    }
    
    /**
     The` background` is a `UIView` which is present in the backdrop for `CometChatGroupList`.
     - Parameters:
     - background: This method will set the background color for CometChatGroupList, it can take an array of multiple colors for the gradient background.
     - Returns: This method will return `CometChatGroupList`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    public func set(background: [Any]?) ->  CometChatGroupList {
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
    @objc public func refresh() -> CometChatGroupList {
        self.refreshGroups()
        return self
    }
    
    
    @discardableResult
    @objc public func set(limit: Int) -> CometChatGroupList {
        self.limit = limit
        return self
    }
    
    @discardableResult
    @objc public func set(searchKeyword: String) -> CometChatGroupList {
        self.searchKeyword = searchKeyword
        return self
    }
    
    @discardableResult
    @objc public func set(joinedOnly: Bool) -> CometChatGroupList {
        self.joinedOnly = joinedOnly
        return self
    }
    
    @discardableResult
    @objc public func set(tags:[String]) -> CometChatGroupList {
        self.tags = tags
        return self
    }
    
  
    @discardableResult
    public func set(emptyView: UIView?) -> CometChatGroupList {
        self.emptyView = emptyView
        return self
    }
    
    @discardableResult
    public func set(errorView: UIView?) -> CometChatGroupList {
        self.errorView = errorView
        return self
    }
    
    @discardableResult
    public func set(emptyStateMessage: String) -> CometChatGroupList {
        self.emptyText = emptyStateMessage
        return self
    }
    
    @discardableResult
    public func set(errorMessage: String) -> CometChatGroupList {
        self.errorText = errorMessage
        return self
    }
    
    @discardableResult
    public func hide(errorMessage: Bool) -> CometChatGroupList {
        self.hideError = errorMessage
        return self
    }
    
    
    @discardableResult
    public func set(emptyStateTextFont: UIFont) -> CometChatGroupList {
        self.emptyStateTextFont = emptyStateTextFont
        return self
    }
    
    @discardableResult
    public func set(emptyStateTextColor: UIColor) -> CometChatGroupList {
        self.emptyStateTextColor = emptyStateTextColor
        return self
    }
    
    @discardableResult
    public func set(errorStateTextFont: UIFont) -> CometChatGroupList {
        self.errorStateTextFont = errorStateTextFont
        return self
    }
    
    @discardableResult
    public func set(errorStateTextColor: UIColor) -> CometChatGroupList {
        self.errorStateTextColor = errorStateTextColor
        return self
    }
    
    @discardableResult
    public func set(groupList: [Group]) -> CometChatGroupList {
        self.groups = groupList
        return self
    }
    
    @discardableResult
    public func add(group: Group) -> CometChatGroupList {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.groups.append(group)
            strongSelf.tableView.reloadData()
        }
        return self
    }
    
    @discardableResult
    public func insert(group: Group, at: Int? = 0) -> CometChatGroupList {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.groups.insert(group, at: at ?? 0)
            strongSelf.tableView.reloadData()
        }
        return self
    }
    
    
    @discardableResult
    public func update(group: Group) -> CometChatGroupList {
        if let row = self.groups.firstIndex(where: {$0.guid == group.guid}) {
            let indexPath = IndexPath(row: row, section: 0)
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                    strongSelf.tableView?.beginUpdates()
                    strongSelf.groups[row] = group
                    strongSelf.tableView?.reloadRows(at: [indexPath], with: .automatic)
                    strongSelf.tableView?.endUpdates()
                }
            }
        return self
    }
    
    
    @discardableResult
    public func remove(group: Group) -> CometChatGroupList {
        DispatchQueue.main.async {  [weak self] in
            guard let strongSelf = self else { return }
            if let row = strongSelf.groups.firstIndex(where: {$0.guid == group.guid}) {
                let indexPath = IndexPath(row: row, section: 0)
                strongSelf.tableView.beginUpdates()
                strongSelf.groups.remove(at: row)
                strongSelf.tableView?.deleteRows(at: [indexPath], with: .automatic)
                strongSelf.tableView.endUpdates()
            }
        }
        return self
    }
    
    @discardableResult
    public func clearList() -> CometChatGroupList {
        DispatchQueue.main.async {  [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.groups.removeAll()
            strongSelf.tableView.reloadData()
        }
        return self
    }
    
    
    @discardableResult
    public func size() -> Int {
        return  groups.count
    }
    

    @discardableResult
    public func set(style: Style) -> CometChatGroupList {
        self.set(background: [style.background?.cgColor ?? UIColor.systemBackground.cgColor])
        self.set(emptyStateTextFont: style.emptyStateTextFont ?? UIFont.systemFont(ofSize: 20, weight: .bold))
        self.set(emptyStateTextColor: style.emptyStateTextColor ?? UIColor.gray)
        self.set(errorStateTextFont: style.errorStateTextFont ?? UIFont.systemFont(ofSize: 20, weight: .bold))
        self.set(errorStateTextColor: style.errorStateTextColor ?? UIColor.gray)
        return self
    }
    
    private func configureGroupList() {
            let currentConfigurations = configurations.filter{ $0 is GroupListConfiguration }
            if let configuration = currentConfigurations.last as? GroupListConfiguration {
                set(background: configuration.background)
                set(emptyView: configuration.emptyView)
                set(joinedOnly: configuration.isJoinedOnly)
                hide(errorMessage: configuration.hideError)
                set(searchKeyword: configuration.searchKeyWord)
                set(limit: configuration.limit)
                set(tags: configuration.tags)
                set(errorMessage: configuration.errorText)
                set(emptyStateMessage: configuration.emptyText)
            }
     }
    
    /**
     This method will set the instance of the view controller from which the `CometChatGroupList` is presented. This method is mandatory to call when the conversation list is presented.
     - Parameters:
     - controller: This method will set the instance of the view controller from which the `CometChatGroupList` is presented. This method is mandatory to call when the conversation list is presented.
     - Returns: This method will return `CometChatGroupList`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(controller: UIViewController) -> CometChatGroupList {
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
        
        if  groups.isEmpty && configurations.isEmpty {
            // refreshGroups()
        }
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
     [CometChatGroupList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-1-comet-chat-group-list)
     */
    private func fetchNextGroups(){
        activityIndicator?.startAnimating()
        activityIndicator?.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
        tableView.tableFooterView = activityIndicator
        tableView.tableFooterView?.isHidden = false
        groupRequest?.fetchNext(onSuccess: { (fetchedGroups) in
            if fetchedGroups.count != 0{
                self.groups.append(contentsOf: fetchedGroups)
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
            DispatchQueue.main.async {
                self.activityIndicator?.stopAnimating()
                self.tableView.tableFooterView?.isHidden = true}
            if let error = error , !self.hideError {
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
                    self?.tableView.reloadData()
                })
            }
        }
    }
    
    private func joinGroup(withGuid: String, name: String, groupType: CometChat.groupType, password: String, indexPath: IndexPath) {
        CometChat.joinGroup(GUID: withGuid, groupType: groupType, password: password, onSuccess: { (joinedGroup) in
            DispatchQueue.main.async {
                if let user = CometChat.getLoggedInUser() {
                    CometChatGroupEvents.emitOnGroupMemberJoin(joinedUser: user, joinedGroup: joinedGroup)
                }
            }
            
        }) { (error) in
            if let error = error , !self.hideError {
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
  
    
    // MARK: - Private instance methods.
    
    /**
     This method fetches the list of groups from  Server using **groupRequest** Class.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatGroupList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-1-comet-chat-group-list)
     */
    private func refreshGroups(){
        groups.removeAll()
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            if let emptyView = strongSelf.emptyView {
                strongSelf.tableView.set(customView: emptyView)
            }else{
                strongSelf.tableView?.setEmptyMessage(strongSelf.emptyText , color: strongSelf.emptyStateTextColor, font: strongSelf.emptyStateTextFont)
            }
            strongSelf.activityIndicator?.startAnimating()
            strongSelf.activityIndicator?.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: strongSelf.tableView.bounds.width, height: CGFloat(44))
            strongSelf.tableView.tableFooterView = strongSelf.activityIndicator
            strongSelf.tableView.tableFooterView = strongSelf.activityIndicator
            strongSelf.tableView.tableFooterView?.isHidden = false
        }
        
        groupRequest = GroupsRequest.GroupsRequestBuilder(limit: limit).set(searchKeyword: searchKeyword).set(joinedOnly: joinedOnly).set(tags: tags).build()
        
        groupRequest?.fetchNext(onSuccess: { [weak self] (fetchedGroups) in
            guard let this = self else {
                return
            }
            if fetchedGroups.count != 0 {
                this.groups = fetchedGroups
                DispatchQueue.main.async {
                    this.activityIndicator?.stopAnimating()
                    this.tableView.tableFooterView?.isHidden = true
                    this.tableView.reloadData()
                }
            }
        }) { (error) in
            DispatchQueue.main.async {
                self.activityIndicator?.stopAnimating()
                self.tableView.tableFooterView?.isHidden = true}
            if let error = error {
                CometChatGroupEvents.emitOnError(group: nil, error: error)
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
                        strongSelf.refreshGroups()
                    })
                }
            }
        }
    }
    
    public func filterGroups(forText: String?) {
        if let text = forText {
            if !text.isEmpty {
                groupRequest = GroupsRequest.GroupsRequestBuilder(limit: limit).set(searchKeyword: text).set(joinedOnly: joinedOnly).set(tags: tags).build()
                groupRequest?.fetchNext(onSuccess: { (groups) in
                    if groups.count != 0 {
                        self.filteredgroups = groups
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            self.tableView?.restore()
                            self.activityIndicator?.stopAnimating()
                            self.tableView.tableFooterView?.isHidden = true
                        }
                    }else{
                        self.filteredgroups = []
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
                }
            }else{
                self.tableView.reloadData()
            }
        }
    }
}


extension CometChatGroupList: UITableViewDelegate, UITableViewDataSource {
    
    
    /// This method specifies the number of sections to display list of Conversations.
    /// - Parameter tableView: An object representing the table view requesting this information.
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /// This method specifies height for section in CometChatGroupList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
   
    
    /// This method specifiesnumber of rows in CometChatGroupList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if groups.isEmpty {
            if let emptyView = self.emptyView {
                self.tableView.set(customView: emptyView)
            }else{
                self.tableView?.setEmptyMessage(self.emptyText , color: self.emptyStateTextColor, font: self.emptyStateTextFont)
            }
        } else{
            self.tableView.restore()
        }
        if isSearching {
            return filteredgroups.count
        }else{
            return groups.count
        }
    }
    
    
    /// This method specifies the height for row in CometChatGroupList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    /// This method specifies the view for group  in CometChatGroupList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

     
        if isSearching {
    
            if let group = filteredgroups[safe: indexPath.row] , let cometChatDataItem = tableView.dequeueReusableCell(withIdentifier: "CometChatDataItem", for: indexPath) as? CometChatDataItem {
                cometChatDataItem.set(configurations: configurations)
                cometChatDataItem.set(group: group)
                return cometChatDataItem
            }
        } else {

            if let group = groups[safe: indexPath.row] , let cometChatDataItem = tableView.dequeueReusableCell(withIdentifier: "CometChatDataItem", for: indexPath) as? CometChatDataItem {
                cometChatDataItem.set(configurations: configurations)
                cometChatDataItem.set(group: group)
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
        
        guard let selectedGroup = (tableView.cellForRow(at: indexPath) as? CometChatDataItem)?.group else {
            return
        }
        
        CometChatGroupEvents.emitOnItemClick(group: selectedGroup, index: indexPath)
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if selectedGroup.hasJoined == false {
            if selectedGroup.groupType == .private || selectedGroup.groupType == .public {
                
                self.joinGroup(withGuid: selectedGroup.guid, name: selectedGroup.name ?? "", groupType: selectedGroup.groupType, password: "", indexPath: indexPath)
                
            }else{
                let cometChatJoinGroup = CometChatJoinProtectedGroup()
                cometChatJoinGroup.set(group: selectedGroup)
                controller?.navigationController?.pushViewController(cometChatJoinGroup, animated: true)
            }
        }
    }
    
   
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex && groups.count > 10 {
            self.fetchNextGroups()
        }
    }
    
    public func tableView(_ tableView: UITableView,
                          sectionForSectionIndexTitle title: String,
                          at index: Int) -> Int{
        return index
    }
}

/*  ----------------------------------------------------------------------------------------- */

