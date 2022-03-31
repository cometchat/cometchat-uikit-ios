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
    var joinedOnly: Bool = false
    var tags: [String] = [String]()
    var emptyView: UIView?
    var errorView: UIView?
    var hideError: Bool? = false
    var errorText: String = ""
    var emptyText: String = "NO_GROUPS_FOUND".localize()
    var emptyStateTextFont: UIFont = UIFont.systemFont(ofSize: 34, weight: .bold)
    var emptyStateTextColor: UIColor = UIColor.gray
    var errorStateTextFont: UIFont?
    var errorStateTextColor: UIColor?
    var configurations: [CometChatConfiguration]?
    
    
    @discardableResult
    @objc public func set(configurations: [CometChatConfiguration]?) -> CometChatGroupList {
        self.configurations = configurations
        configureGroupList()
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
        if let configurations = configurations {
            let currentConfigurations = configurations.filter{ $0 is GroupListConfiguration }
            if let configuration = currentConfigurations.last as? GroupListConfiguration {
                set(background: configuration.background)
                set(emptyView: configuration.emptyView)
                set(joinedOnly: configuration.isJoinedOnly)
                hide(errorMessage: configuration.hideError)
                set(searchKeyword: configuration.searchKeyWord)
                set(limit: configuration.limit)
                set(tags: configuration.tags)
               
            }
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
        Bundle.main.loadNibNamed("CometChatGroupList", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        setuptTableView()
        registerCells()
        setupDelegates()
        configureGroupList()
        if groups.isEmpty {
             refreshGroups()
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
        self.registerCellWith(title: "CometChatGroupListItem")
    }
    
    private func registerCellWith(title: String){
        let cell = UINib(nibName: title, bundle: Bundle.main)
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
        groupRequest?.fetchNext(onSuccess: { (groups) in
            if groups.count != 0{
                let joinedGroups = groups.filter({$0.hasJoined == true})
                self.groups.append(contentsOf: joinedGroups)
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
                if let error = error {
                    CometChatUsers.comethatUsersDelegate?.onError?(error: error)
                    if self.hideError == false {
                        if self.errorText.isEmpty {
                            CometChatSnackBoard.showErrorMessage(for: error)
                        }else{
                            CometChatSnackBoard.display(message: self.errorText ?? "", mode: .error, duration: .short)
                        }
                    }
                }
            }
        }
    }
    
    private func joinGroup(withGuid: String, name: String, groupType: CometChat.groupType, password: String, indexPath: IndexPath) {
        CometChat.joinGroup(GUID: withGuid, groupType: groupType, password: password, onSuccess: { (group) in
            DispatchQueue.main.async {

                let cometChatMessages: CometChatMessages = CometChatMessages()
                cometChatMessages.set(group: group)
                cometChatMessages.hidesBottomBarWhenPushed = true
                self.controller?.navigationController?.pushViewController(cometChatMessages, animated: true)
                self.tableView.deselectRow(at: indexPath, animated: true)
            
            }
            
        }) { (error) in
            DispatchQueue.main.async {
                if let error = error {
                    if self.hideError == false {
                        CometChatUsers.comethatUsersDelegate?.onError?(error: error)
                        if self.errorText.isEmpty {
                            CometChatSnackBoard.showErrorMessage(for: error)
                        }else{
                            CometChatSnackBoard.display(message: self.errorText ?? "", mode: .error, duration: .short)
                        }
                    }
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
     [CometChatGroupList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-1-comet-chat-group-list)
     */
    private func refreshGroups(){
        groups.removeAll()
        activityIndicator?.startAnimating()
        activityIndicator?.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
        tableView.tableFooterView = activityIndicator
        tableView.tableFooterView = activityIndicator
        tableView.tableFooterView?.isHidden = false
        groupRequest = GroupsRequest.GroupsRequestBuilder(limit: limit).set(searchKeyword: searchKeyword).set(joinedOnly: joinedOnly).set(tags: tags).build()
        groupRequest?.fetchNext(onSuccess: { [weak self] (fetchedGroups) in
            self?.set(configurations: self?.configurations)
            guard let this = self else {
                return
            }
            if fetchedGroups.count != 0 {
                let joinedGroups = fetchedGroups.filter({$0.hasJoined == true})
                this.groups = joinedGroups
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
            DispatchQueue.main.async {
                if let error = error {
                    CometChatUsers.comethatUsersDelegate?.onError?(error: error)
                    if self.hideError == false {
                        if self.errorText.isEmpty {
                            CometChatSnackBoard.showErrorMessage(for: error)
                        }else{
                            CometChatSnackBoard.display(message: self.errorText ?? "", mode: .error, duration: .short)
                        }
                    }
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
                                self.tableView?.setEmptyMessage(self.emptyText ?? "", color: self.emptyStateTextColor, font: self.emptyStateTextFont)
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

        guard let section = indexPath.section as? Int else { return UITableViewCell() }
        if isSearching {
    
            if let group = filteredgroups[safe: indexPath.row] , let cometChatGroupListItem = tableView.dequeueReusableCell(withIdentifier: "CometChatGroupListItem", for: indexPath) as? CometChatGroupListItem {
                cometChatGroupListItem.set(configurations: configurations)
                cometChatGroupListItem.set(group: group)
                return cometChatGroupListItem
            }
        } else {

            if let group = groups[safe: indexPath.row] , let cometChatGroupListItem = tableView.dequeueReusableCell(withIdentifier: "CometChatGroupListItem", for: indexPath) as? CometChatGroupListItem {
                cometChatGroupListItem.set(configurations: configurations)
                cometChatGroupListItem.set(group: group)
                return cometChatGroupListItem
            }
        }
        
        return UITableViewCell()
    }
    

    
    /// This method triggers when particulatr cell is clicked by the group .
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - indexPath: specifies current index for TableViewCell.
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let selectedGroup = (tableView.cellForRow(at: indexPath) as? CometChatGroupListItem)?.group else {
            return
        }
        CometChatGroups.comethatGroupsDelegate?.onItemClick?(group: selectedGroup)
        tableView.deselectRow(at: indexPath, animated: true)
        
        if selectedGroup.hasJoined == false {
           
            if selectedGroup.groupType == .private || selectedGroup.groupType == .public {

                self.joinGroup(withGuid: selectedGroup.guid, name: selectedGroup.name ?? "", groupType: selectedGroup.groupType, password: "", indexPath: indexPath)
                
            }else{
                
                let alert = UIAlertController(title: "ENTER_GROUP_PWD".localize(), message: "ENTER_PASSWORD_TO_JOIN".localize(), preferredStyle: .alert)
                let save = UIAlertAction(title: "JOIN".localize(), style: .default) { (alertAction) in
                    let textField = alert.textFields![0] as UITextField
                    
                    if textField.text != "" {
                        if let password = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
                                   self.joinGroup(withGuid: selectedGroup.guid, name: selectedGroup.name ?? "", groupType: selectedGroup.groupType, password: password, indexPath: indexPath)
                        }
                    } else {
                        self.controller?.showAlert(title: "WARNING".localize(), msg: "GROUP_PASSWORD_CANNOT_EMPTY".localize())
                    }
                }
                alert.addTextField { (textField) in
                    textField.placeholder = "ENTER_YOUR_NAME".localize()
                    textField.isSecureTextEntry = true
                }
                let cancel = UIAlertAction(title: "CANCEL".localize(), style: .default) { (alertAction) in }
                alert.addAction(save)
                alert.addAction(cancel)
                alert.view.tintColor = CometChatTheme.palatte?.primary
                controller?.present(alert, animated:true, completion: nil)
            }
        }else{
            let cometChatMessages: CometChatMessages = CometChatMessages()
            cometChatMessages.set(group: selectedGroup)
            cometChatMessages.hidesBottomBarWhenPushed = true
            self.controller?.navigationController?.pushViewController(cometChatMessages, animated: true)
            self.tableView.deselectRow(at: indexPath, animated: true)
        
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

