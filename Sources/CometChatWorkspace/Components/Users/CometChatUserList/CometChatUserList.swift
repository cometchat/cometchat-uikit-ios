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
    var filteredUsers: [User] = [User]()
    var activityIndicator:UIActivityIndicatorView?
    var sectionTitle : UILabel?
    var sections = [String]()
    var sortedKeys = [String]()
    var controller: UIViewController?
    var isSearching: Bool = false
    var globalGroupedUsers: [String : [User]] = [:]
    var headerBackground: UIColor?
    var headerTextColor: UIColor?
    var headerTextFont: UIFont?
    
    var configuration: UserListConfiguration?
    
    @discardableResult
    @objc public func set(configuration: UserListConfiguration) -> CometChatUserList {
        self.configuration = configuration
        self.set(background: configuration.background)
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
        Bundle.main.loadNibNamed("CometChatUserList", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        setuptTableView()
        registerCells()
        setupDelegates()
        if users.isEmpty {
            refreshUsers()
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
        self.tableView.backgroundColor = .clear
        self.tableView.tableFooterView = UIView(frame: .zero)
        self.registerCells()
        
    }
    
    
    fileprivate func registerCells() {
        self.registerCellWith(title: "CometChatUserListItem")
    }
    
    private func registerCellWith(title: String){
        let cell = UINib(nibName: title, bundle: Bundle.main)
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
            DispatchQueue.main.async {
                if let error = error {
                    CometChatSnackBoard.showErrorMessage(for: error)
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
            DispatchQueue.main.async {
                if let error = error {
                    CometChatSnackBoard.showErrorMessage(for: error)
                }
            }
        }
    }
    
    private func groupUsers(users: [User]){
        DispatchQueue.main.async {  [weak self] in
            guard let strongSelf = self else { return }
            if strongSelf.users.isEmpty { strongSelf.tableView?.setEmptyMessage("NO_USERS_FOUND".localize())
            }else{ strongSelf.tableView?.restore() }
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
        
        userRequest = UsersRequest.UsersRequestBuilder(limit: 20).build()
        
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
            DispatchQueue.main.async {
                if let error = error {
                    CometChatSnackBoard.showErrorMessage(for: error)
                }
            }
        }
    }
    
    
    public func filterUsers(forText: String?) {
        if let text = forText {
            if !text.isEmpty {
                userRequest = UsersRequest.UsersRequestBuilder(limit: 20).set(searchKeyword: text).build()
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
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            self.activityIndicator?.stopAnimating()
                            self.tableView.tableFooterView?.isHidden = true
                            self.tableView?.setEmptyMessage("NO_USERS_FOUND".localize())
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
        return 25
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
        return 60
    }
    
    /// This method specifies the view for user  in CometChatUserList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let section = indexPath.section as? Int else { return UITableViewCell() }
        if isSearching {
            
            if let user = filteredUsers[safe: indexPath.row] , let userCell = tableView.dequeueReusableCell(withIdentifier: "CometChatUserListItem", for: indexPath) as? CometChatUserListItem {
                userCell.user = user
                return userCell
            }
        } else {
            
            if let user = users[safe: section]?[safe: indexPath.row] , let userCell = tableView.dequeueReusableCell(withIdentifier: "CometChatUserListItem", for: indexPath) as? CometChatUserListItem {
                userCell.user = user
                return userCell
            }
        }
        
        return UITableViewCell()
    }
    
    
    
    /// This method triggers when particulatr cell is clicked by the user .
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - indexPath: specifies current index for TableViewCell.
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let selectedUser = tableView.cellForRow(at: indexPath) as? CometChatUserListItem, let user = selectedUser.user {
            CometChatUsers.comethatUsersDelegate?.onItemClick?(user: user)
            let cometChatMessages: CometChatMessages = CometChatMessages()
            cometChatMessages.set(user: user)
            cometChatMessages.hidesBottomBarWhenPushed = true
            controller?.navigationController?.pushViewController(cometChatMessages, animated: true)
            tableView.deselectRow(at: indexPath, animated: true)
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
                if let userListItem = strongSelf.tableView.cellForRow(at: indexpath) as? CometChatUserListItem {
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
        
        print("user status: \(user.status)")
        if let indexpath = users.indexPath(where: {$0.uid == user.uid}){
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                if let userListItem = strongSelf.tableView.cellForRow(at: indexpath) as? CometChatUserListItem {
                    strongSelf.tableView.beginUpdates()
                    userListItem.set(statusIndicator: .offline)
                    strongSelf.tableView.endUpdates()
                }
            }
        }
    }
}

/*  ----------------------------------------------------------------------------------------- */
