//
//  CometChatConversations.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 22/12/21.
//  Copyright ©  2022 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.
import UIKit
import CometChatPro

/**
 `CometChatUserList` is a subclass of `UIView` which internally uses a 0 and reusable cell i.e `CometChatUserListItem` which forms a list of recent conversations as per the data coming from the server.
 - Author: CometChat Team
 - Copyright:  ©  2022 CometChat Inc.
 */
@IBDesignable public final class CometChatUserList: UIView , NibLoadable {
    
    // MARK: - Declaration of IBInspectable
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var background: CometChatGradientView!
    @IBOutlet weak var tableView: UITableView!
    
    
    //MARK: - Declaration of Variables
    var userRequest : UsersRequest?
    var safeArea: UILayoutGuide!
    var users: [[User]] = [[User]]()
    lazy var filteredUsers: [User] = [User]()
    lazy var selectedUsers: [User] = [User]()
    var activityIndicator:UIActivityIndicatorView?
    var sectionTitle : UILabel?
    var sections = [String]()
    var sortedKeys = [String]()
    var controller: UIViewController?
    var isSearching: Bool = false
    var globalGroupedUsers: [String : [User]] = [:]
    var headerBackground: UIColor?
    var headerTextColor: UIColor?
    var isSelectionEnabled: Bool = false
    var headerTextFont: UIFont?
    var limit: Int = 30
    var searchKeyword: String = ""
    var status: CometChat.UserStatus = .offline
    var friendsOnly: Bool = false
    var hideBlockedUsers: Bool = false
    var roles: [String] = [String]()
    var tags: [String] = [String]()
    var uids: [String] = [String]()
    var emptyView: UIView?
    var errorView: UIView?
    var hideError: Bool = false
    var hideSectionHeader: Bool? = false
    var errorText: String = ""
    var emptyStateText: String = "NO_USERS_FOUND".localize()
    var emptyStateTextFont: UIFont = UIFont.systemFont(ofSize: 34, weight: .bold)
    var emptyStateTextColor: UIColor = UIColor.gray
    var errorStateTextFont: UIFont?
    var errorStateTextColor: UIColor?
    var configurations: [CometChatConfiguration] = [CometChatConfiguration]()
    
    @discardableResult
    @objc public func set(configurations: [CometChatConfiguration]?) -> CometChatUserList {
        if let configurations = configurations {
            self.configurations = configurations
            configureUserList()
            refreshUsers()
        }
        return self
    }
    


    
    /**
     The` background` is a `UIView` which is present in the backdrop for `CometChatUserList`.
     - Parameters:
     - background: This method will set the background color for CometChatUserList, it can take an array of multiple colors for the gradient background.
     - Returns: This method will return `CometChatUserList`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    public func set(background: [Any]?) ->  CometChatUserList {
        if let backgroundColors = background as? [CGColor] {
            if backgroundColors.count == 1 {
                self.background.backgroundColor = UIColor(cgColor: backgroundColors.first ?? UIColor.blue.cgColor)
            }else{
                self.background.set(backgroundColorWithGradient: background)
            }
        }
        return self
    }
    
    /**
     This method will set the instance of the view controller from which the `CometChatUserList` is presented. This method is mandatory to call when the conversation list is presented.
     - Parameters:
     - controller: This method will set the instance of the view controller from which the `CometChatUserList` is presented. This method is mandatory to call when the conversation list is presented.
     - Returns: This method will return `CometChatUserList`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(controller: UIViewController) -> CometChatUserList {
        self.controller = controller
        return self
    }
    
  
    
    @discardableResult
    @objc public func set(sectionHeaderTextFont: UIFont) -> CometChatUserList {
        self.headerTextFont = sectionHeaderTextFont
        return self
    }
    
    @discardableResult
    @objc public func set(sectionHeaderTextColor: UIColor) -> CometChatUserList {
        self.headerTextColor = sectionHeaderTextColor
        return self
    }
    
    @discardableResult
    @objc public func set(sectionHeaderBackground: UIColor) -> CometChatUserList {
        self.headerBackground = sectionHeaderBackground
        return self
    }
    
    @discardableResult
    @objc public func set(limit: Int) -> CometChatUserList {
        self.limit = limit
        return self
    }
    
    @discardableResult
    @objc public func set(searchKeyword: String) -> CometChatUserList {
        self.searchKeyword = searchKeyword
        return self
    }
    
    @discardableResult
    @objc public func set(status: CometChat.UserStatus) -> CometChatUserList {
        self.status = status
        return self
    }
    
    @discardableResult
    @objc public func set(friendsOnly:Bool) -> CometChatUserList {
        self.friendsOnly = friendsOnly
        return self
    }
    
    @discardableResult
    @objc public func set(hideBlockedUsers:Bool) -> CometChatUserList {
        self.hideBlockedUsers = hideBlockedUsers
        return self
    }
    
    @discardableResult
    @objc public func isBlockedUsersHidden() -> Bool {
        return hideBlockedUsers
    }
    
  
    @discardableResult
    @objc public func set(roles:[String]) -> CometChatUserList {
        self.roles = roles
        return self
    }
    
    @discardableResult
    @objc public func set(tags:[String]) -> CometChatUserList {
        self.tags = tags
        return self
    }
    
    @discardableResult
    @objc public func set(uids:[String]) -> CometChatUserList {
        self.uids = uids
        return self
    }

    
    @discardableResult
    public func set(emptyView: UIView?) -> CometChatUserList {
        self.emptyView = emptyView
        return self
    }
    
    @discardableResult
    public func set(errorView: UIView?) -> CometChatUserList {
        self.errorView = errorView
        return self
    }
    
    @discardableResult
    public func set(emptyStateMessage: String) -> CometChatUserList {
        self.emptyStateText = emptyStateMessage
        return self
    }
    
    @discardableResult
    public func set(errorMessage: String) -> CometChatUserList {
        self.errorText = errorMessage
        return self
    }
    
    @discardableResult
    public func hide(errorMessage: Bool) -> CometChatUserList {
        self.hideError = errorMessage
        return self
    }
    
    
    
    @discardableResult
    public func set(emptyStateTextFont: UIFont) -> CometChatUserList {
        self.emptyStateTextFont = emptyStateTextFont
        return self
    }
    
    @discardableResult
    public func set(emptyStateTextColor: UIColor) -> CometChatUserList {
        self.emptyStateTextColor = emptyStateTextColor
        return self
    }
    
    @discardableResult
    public func set(errorStateTextFont: UIFont) -> CometChatUserList {
        self.errorStateTextFont = errorStateTextFont
        return self
    }
    
    @discardableResult
    public func set(errorStateTextColor: UIColor) -> CometChatUserList {
        self.errorStateTextColor = errorStateTextColor
        return self
    }
    
    @discardableResult
    public func set(userList: [User]) -> CometChatUserList {
        self.groupUsers(users: userList)
        return self
    }
    
    @discardableResult
    public func enable(selection: Bool) -> CometChatUserList {
        self.isSelectionEnabled = selection
        self.tableView.allowsMultipleSelection = true
        self.tableView.allowsMultipleSelectionDuringEditing = true
        return self
    }
    
    
    @discardableResult
    public func add(user: User) -> CometChatUserList {
        DispatchQueue.main.async {  [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.groupUsers(users: [user])
        }
        return self
    }
    
    
    @discardableResult
    public func update(user: User) -> CometChatUserList {
            DispatchQueue.main.async {  [weak self] in
                guard let strongSelf = self else { return }
                if let indexpath = strongSelf.users.indexPath(where: {$0.uid == user.uid}), let section = indexpath.section as? Int, let row = indexpath.row as? Int {
                    strongSelf.tableView?.beginUpdates()
                    strongSelf.users[section][row] = user
                    strongSelf.tableView?.reloadRows(at: [indexpath], with: .automatic)
                    strongSelf.tableView?.endUpdates()
                }
            }
        return self
    }
    
    
    @discardableResult
    public func remove(user: User) -> CometChatUserList {
        DispatchQueue.main.async {  [weak self] in
            guard let strongSelf = self else { return }
            if let indexpath = strongSelf.users.indexPath(where: {$0.uid == user.uid}), let section = indexpath.section as? Int, let row = indexpath.row as? Int {
                strongSelf.tableView.beginUpdates()
                strongSelf.users[section].remove(at: row)
                strongSelf.tableView?.deleteRows(at: [indexpath], with: .automatic)
                strongSelf.tableView.endUpdates()
            }
        }
        return self
    }
    
    @discardableResult
    public func clearList() -> CometChatUserList {
        DispatchQueue.main.async {  [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.users.removeAll()
            strongSelf.tableView.reloadData()
        }
        return self
    }
    
    
    @discardableResult
    public func size() -> Int {
        return  users.joined().count
    }
    
    @discardableResult
    public func hide(sectionHeader: Bool) -> CometChatUserList {
        self.hideSectionHeader = sectionHeader
        return self
    }
    

    @discardableResult
    public func set(style: Style) -> CometChatUserList {
        self.set(background: [style.background?.cgColor ?? UIColor.systemBackground.cgColor])
        self.set(emptyStateTextFont: style.emptyStateTextFont ?? UIFont.systemFont(ofSize: 20, weight: .bold))
        self.set(emptyStateTextColor: style.emptyStateTextColor ?? UIColor.gray)
        self.set(errorStateTextFont: style.errorStateTextFont ?? UIFont.systemFont(ofSize: 20, weight: .bold))
        self.set(errorStateTextColor: style.errorStateTextColor ?? UIColor.gray)
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
            addSubview(contentView)
            contentView.frame = bounds
            contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            setuptTableView()
            registerCells()
            setupDelegates()

            if users.isEmpty && configurations.isEmpty {
                refreshUsers()
            }
        }
    }
    
    
    
   private func configureUserList() {
           let currentConfigurations = configurations.filter{ $0 is UserListConfiguration }
           if let configuration = currentConfigurations.last as? UserListConfiguration {
               set(background: configuration.background)
               hide(sectionHeader: configuration.hideSectionHeader)
               set(friendsOnly: configuration.isFriendOnly)
               set(hideBlockedUsers: configuration.hideBlockedUsers)
               hide(errorMessage: configuration.hideError)
               set(searchKeyword: configuration.searchKeyword)
               set(status: configuration.status)
               set(limit: configuration.limit)
               set(tags: configuration.tags)
               set(roles: configuration.roles)
               set(uids: configuration.uids)
               set(emptyView: configuration.emptyView)
               set(errorMessage: configuration.errorText)
               set(emptyStateMessage: configuration.emptyText)
           }
    }
    
    private  func setupDelegates(){
        CometChat.userdelegate = self
    }
    
    fileprivate func setuptTableView() {
        if #available(iOS 13.0, *) {
            activityIndicator = UIActivityIndicatorView(style: .medium)
        } else {
            activityIndicator = UIActivityIndicatorView(style: .gray)
        }
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = CometChatTheme.palatte?.secondary
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
     This method fetches the list of users from  Server using **UserRequest** Class.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatUserList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-1-comet-chat-user-list)
     */
    private func fetchUsers(){
        
        activityIndicator?.startAnimating()
        activityIndicator?.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
        tableView.tableFooterView = activityIndicator
        tableView.tableFooterView?.isHidden = false
        
        userRequest?.fetchNext(onSuccess: { (users) in
            if users.count != 0 {
                self.groupUsers(users: users)
            }else{
                DispatchQueue.main.async {
                    self.tableView.restore()
                    self.activityIndicator?.stopAnimating()
                    self.tableView.tableFooterView?.isHidden = true
                }
            }
        }) { (error) in
            if let error = error  {
                CometChatUserEvents.emitOnError(user: nil, error: error)
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
    
    private func fetchNextUsers(){
        activityIndicator?.startAnimating()
        activityIndicator?.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
        tableView.tableFooterView = activityIndicator
        tableView.tableFooterView?.isHidden = false
        userRequest?.fetchNext(onSuccess: { (users) in
            if users.count != 0 {
                self.groupUsers(users: users)
            }else{
                DispatchQueue.main.async {
                    self.tableView.restore()
                    self.activityIndicator?.stopAnimating()
                    self.tableView.tableFooterView?.isHidden = true
                }
            }
        }) { (error) in
            if let error = error  {
                DispatchQueue.main.async {
                    self.activityIndicator?.stopAnimating()
                    self.tableView.tableFooterView?.isHidden = true}
                CometChatUserEvents.emitOnError(user: nil, error: error)
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
    
    private func groupUsers(users: [User]){
        DispatchQueue.main.async {  [weak self] in
            guard let strongSelf = self else { return }
            if strongSelf.users.isEmpty {
                if let emptyView = strongSelf.emptyView {
                    strongSelf.tableView.set(customView: emptyView)
                }else{
                    strongSelf.tableView?.setEmptyMessage(strongSelf.emptyStateText , color: strongSelf.emptyStateTextColor, font: strongSelf.emptyStateTextFont)
                }
            }else{
                strongSelf.tableView?.restore()
            }
        }
        
        let groupedUsers = Dictionary(grouping: users) { (element) -> String in
            guard let name = element.name?.capitalized.trimmingCharacters(in: .whitespacesAndNewlines) else {return ""}
            return (name as NSString).substring(to: 1)
        }
        globalGroupedUsers.merge(groupedUsers, uniquingKeysWith: +)
        for key in groupedUsers.keys {
            if !sortedKeys.contains(key) { sortedKeys.append(key) }
        }
        sortedKeys = sortedKeys.sorted{ $0.lowercased() < $1.lowercased()}
        var staticUsers: [[User]] = [[User]]()
        sortedKeys.forEach { (key) in
            if let value = globalGroupedUsers[key] {
                staticUsers.append(value)
            }
        }
        DispatchQueue.main.async {
            self.users = staticUsers
            self.activityIndicator?.stopAnimating()
            self.tableView.tableFooterView?.isHidden = true
            self.tableView?.restore()
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: - Private instance methods.
    
    /**
     This method fetches the list of users from  Server using **UserRequest** Class.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatUserList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-1-comet-chat-user-list)
     */
    private func refreshUsers(){
        self.globalGroupedUsers.removeAll()
        self.sections.removeAll()
        self.users.removeAll()
        activityIndicator?.startAnimating()
        activityIndicator?.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
        tableView.tableFooterView = activityIndicator
        tableView.tableFooterView = activityIndicator
        tableView.tableFooterView?.isHidden = false
        
        userRequest = UsersRequest.UsersRequestBuilder(limit: limit).set(tags: tags).set(roles: roles).set(UIDs: uids).set(status: status).set(searchKeyword: searchKeyword).friendsOnly(friendsOnly).hideBlockedUsers(hideBlockedUsers).build()
        
        userRequest?.fetchNext(onSuccess: { (users) in
            if users.count != 0 {
                self.groupUsers(users: users)
            }else{
               
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.tableView.restore()
                    strongSelf.activityIndicator?.stopAnimating()
                    strongSelf.tableView.tableFooterView?.isHidden = true
                    if let emptyView = strongSelf.emptyView {
                        strongSelf.tableView.set(customView: emptyView)
                    }else{
                        strongSelf.tableView?.setEmptyMessage(strongSelf.emptyStateText ?? "", color: strongSelf.emptyStateTextColor, font: strongSelf.emptyStateTextFont)
                    }
                }
               
            }
            
        }) { (error) in
            DispatchQueue.main.async {
                self.activityIndicator?.stopAnimating()
                self.tableView.tableFooterView?.isHidden = true}
            if let error = error  {
                CometChatUserEvents.emitOnError(user: nil, error: error)
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
    
    
    public func filterUsers(forText: String?) {
        self.tableView.reloadData()
        if let text = forText {
            self.set(searchKeyword: forText ?? "")
            if !text.isEmpty {
                userRequest = UsersRequest.UsersRequestBuilder(limit: limit).set(tags: tags).set(roles: roles).set(UIDs: uids).set(status: status).set(searchKeyword: forText ?? "").friendsOnly(friendsOnly).hideBlockedUsers(hideBlockedUsers).build()
                
                userRequest?.fetchNext(onSuccess: { (users) in
                    if users.count != 0 {
                        self.filteredUsers = users
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            self.tableView?.restore()
                            self.activityIndicator?.stopAnimating()
                            self.tableView.tableFooterView?.isHidden = true
                        }
                    }else{
                        self.filteredUsers = []
                        DispatchQueue.main.async { [weak self] in
                            guard let strongSelf = self else { return }
                            strongSelf.tableView.reloadData()
                            strongSelf.activityIndicator?.stopAnimating()
                            strongSelf.tableView.tableFooterView?.isHidden = true
                            if let emptyView = strongSelf.emptyView {
                                strongSelf.tableView.set(customView: emptyView)
                            }else{
                                strongSelf.tableView?.setEmptyMessage(strongSelf.emptyStateText ?? "", color: strongSelf.emptyStateTextColor, font: strongSelf.emptyStateTextFont)
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


extension CometChatUserList: UITableViewDelegate, UITableViewDataSource {
    
    
    /// This method specifies the number of sections to display list of Conversations.
    /// - Parameter tableView: An object representing the table view requesting this information.
    public func numberOfSections(in tableView: UITableView) -> Int {
        if isSearching {
            return 1
        }else{
            return users.count
        }
    }
    
    /// This method specifies height for section in CometChatUserList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if hideSectionHeader == false {
        return 25
        }else{
            return 0
        }
    }
    
    /// This method specifiesnumber of rows in CometChatUserList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return filteredUsers.count
        }else{
            return users[safe: section]?.count ?? 0
        }
    }
    
    
    /// This method specifies the height for row in CometChatUserList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    /// This method specifies the view for user  in CometChatUserList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        
        guard let section = indexPath.section as? Int else { return UITableViewCell() }
        
        if isSearching {
            
            if let user = filteredUsers[safe: indexPath.row] , let cometChatDataItem = tableView.dequeueReusableCell(withIdentifier: "CometChatDataItem", for: indexPath) as? CometChatDataItem {
                cometChatDataItem.set(configurations: configurations)
                cometChatDataItem.allow(selection: isSelectionEnabled)
                cometChatDataItem.set(user: user)
                return cometChatDataItem
            }
        } else {

            if let user = users[safe: section]?[safe: indexPath.row] , let cometChatDataItem = tableView.dequeueReusableCell(withIdentifier: "CometChatDataItem", for: indexPath) as? CometChatDataItem {
                cometChatDataItem.set(configurations: configurations)
                cometChatDataItem.allow(selection: isSelectionEnabled)
                cometChatDataItem.set(user: user)
                return cometChatDataItem
            }
        }
        
        return UITableViewCell()
    }
    
    
    
    /// This method triggers when particulatr cell is clicked by the user .
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - indexPath: specifies current index for TableViewCell.
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let selectedUser = tableView.cellForRow(at: indexPath) as? CometChatDataItem, let user = selectedUser.user {
            CometChatUserEvents.emitOnItemClick(user: user, index: indexPath)
            if !isSelectionEnabled {
               tableView.deselectRow(at: indexPath, animated: true)
            }else{
                if !selectedUsers.contains(user) {
                    self.selectedUsers.append(user)
                }
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let selectedUser = tableView.cellForRow(at: indexPath) as? CometChatDataItem, let user = selectedUser.user {
            if let foundUser = selectedUsers.firstIndex(of: user) {
                selectedUsers.remove(at: foundUser)
            }
        }
    }
  
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: contentView.frame.size.width - 20, height: 25))
        sectionTitle = UILabel(frame: CGRect(x: 10, y: 2, width: returnedView.frame.size.width, height: 25))
        if isSearching {
            sectionTitle?.text = ""
        }else{
            if let title = ((users[safe: section]?.first?.name?.capitalized ?? "") as? NSString)?.substring(to: 1) {
                sectionTitle?.text = title
            }
        }
        if #available(iOS 13.0, *) {
            sectionTitle?.textColor = headerTextColor
            sectionTitle?.font = headerTextFont
            returnedView.backgroundColor = headerBackground
        } else {}
        returnedView.addSubview(sectionTitle!)
        return returnedView
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex {
            self.fetchNextUsers()
        }
    }
    
    public func tableView(_ tableView: UITableView,
                          sectionForSectionIndexTitle title: String,
                          at index: Int) -> Int{
        return index
    }
    
  
}

/*  ----------------------------------------------------------------------------------------- */

// MARK: - CometChatUserDelegate Delegate

extension CometChatUserList : CometChatUserDelegate {
    /**
     This method triggers users comes online from user list.
     - Parameter user: This specifies `User` Object
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    public func onUserOnline(user: User) {
        if let indexpath = users.indexPath(where: {$0.uid == user.uid}){
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                if let userListItem = strongSelf.tableView.cellForRow(at: indexpath) as? CometChatDataItem {
                    strongSelf.tableView.beginUpdates()
                    userListItem.set(statusIndicator: .online)
                    strongSelf.tableView.endUpdates()
                }
            }
        }
    }
    
    /**
     This method triggers users goes offline from user list.
     - Parameter user: This specifies `User` Object
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    public func onUserOffline(user: User) {
        if let indexpath = users.indexPath(where: {$0.uid == user.uid}){
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                if let userListItem = strongSelf.tableView.cellForRow(at: indexpath) as? CometChatDataItem {
                    strongSelf.tableView.beginUpdates()
                    userListItem.set(statusIndicator: .offline)
                    strongSelf.tableView.endUpdates()
                }
            }
        }
    }
}

/*  ----------------------------------------------------------------------------------------- */
