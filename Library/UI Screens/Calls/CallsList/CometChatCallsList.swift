
//  CometChatCallsList.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.


/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
 CometChatCallsList: CometChatCallsList is a view controller with a list of recent calls. The view controller has all the necessary delegates and methods.
 
 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

// MARK: - Importing Frameworks.

import UIKit
import CometChatPro

// MARK: - Declaring Protocol.


public protocol CallsListDelegate: AnyObject {
    /**
     This method triggers when user taps perticular conversation in CometChatCallsList
     - Parameters:
     - conversation: Specifies the `conversation` Object for selected cell.
     - indexPath: Specifies the indexpath for selected conversation.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
    
     */
    func didSelectCallsAtIndexPath(call: BaseMessage, indexPath: IndexPath)
}

/*  ----------------------------------------------------------------------------------------- */

public class CometChatCallsList: UIViewController {
    
    // MARK: - Declaration of Variables
    
    var callsRequest:MessagesRequest?
    var tableView: UITableView! = nil
    var safeArea: UILayoutGuide!
    var calls: [BaseMessage] = [BaseMessage]()
    var missedCalls: [BaseMessage] = [BaseMessage]()
    weak var delegate : CallsListDelegate?
    var activityIndicator:UIActivityIndicatorView?
    var segmentControl = UISegmentedControl()
    
    // MARK: - View controller lifecycle methods
    
    override public func loadView() {
        super.loadView()
        view.backgroundColor = .white
        safeArea = view.layoutMarginsGuide
        self.setupTableView()
        self.setupDelegates()
        self.refreshCalls()
        self.setupNavigationBar()
    }

    public override func viewWillAppear(_ animated: Bool) {
        self.setupDelegates()
        refreshCalls()
    }
    
    deinit {
      
    }
    
    // MARK: - Public instance methods
    
    /**
     This method specifies the navigation bar title for CometChatCallsList.
     - Parameters:
     - title: This takes the String to set title for CometChatCallsList.
     - mode: This specifies the TitleMode such as :
     * .automatic : Automatically use the large out-of-line title based on the state of the previous item in the navigation bar.
     *  .never: Never use a larger title when this item is topmost.
     * .always: Always use a larger title when this item is topmost.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
    
     */
    @objc public func set(title : String, mode: UINavigationItem.LargeTitleDisplayMode){
        if navigationController != nil{
            navigationItem.title = NSLocalizedString(title, bundle: UIKitSettings.bundle, comment: "")
            navigationItem.largeTitleDisplayMode = mode
            switch mode {
            case .automatic:
                navigationController?.navigationBar.prefersLargeTitles = true
            case .always:
                navigationController?.navigationBar.prefersLargeTitles = true
            case .never:
                navigationController?.navigationBar.prefersLargeTitles = false
            @unknown default:break }
        }
    }
    
    
    
    // MARK: - Private instance methods
    
    /**
     This method fetches the list of recent calls from  Server using **MessageRequest** Class.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
    private func refreshCalls(){
        DispatchQueue.main.async {
            self.tableView.setEmptyMessage(NSLocalizedString("", bundle: UIKitSettings.bundle, comment: ""))
            self.activityIndicator?.startAnimating()
            self.activityIndicator?.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: self.tableView.bounds.width, height: CGFloat(44))
            self.tableView.tableFooterView = self.activityIndicator
            self.tableView.tableFooterView = self.activityIndicator
            self.tableView.tableFooterView?.isHidden = false
        }
        callsRequest = MessagesRequest.MessageRequestBuilder().set(limit: 20).hideMessagesFromBlockedUsers(true).set(categories: ["call"]).build()
        
        callsRequest?.fetchPrevious(onSuccess: { (fetchedCalls) in
            guard let filteredCalls = fetchedCalls?.filter({
                ($0 as? Call != nil && ($0 as? Call)?.callStatus == .initiated)  ||
                    ($0 as? Call != nil && ($0 as? Call)?.callStatus == .unanswered)
            }) else { return }
            self.calls = filteredCalls.reversed()
            let currentMissedCalls = self.calls.filter({ ($0 as? Call != nil && ($0 as? Call)?.callStatus == .unanswered)})
            self.missedCalls = currentMissedCalls
            DispatchQueue.main.async {
                self.activityIndicator?.stopAnimating()
                self.tableView.tableFooterView?.isHidden = true
                self.tableView.reloadData()
            }
            
        }, onError: { (error) in
            DispatchQueue.main.async {
                if let errorMessage = error?.errorDescription {
                    let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: errorMessage, duration: .short)
                    snackbar.show()
                }
            }
            
        })
    }
    
    /**
        This method fetches the list of previous calls from  Server using **MessageRequest** Class.
        - Author: CometChat Team
        - Copyright:  ©  2020 CometChat Inc.
        */
    private func fetchPreviousCalls(){
        DispatchQueue.main.async {
            self.activityIndicator?.startAnimating()
            self.activityIndicator?.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: self.tableView.bounds.width, height: CGFloat(44))
            self.tableView.tableFooterView = self.activityIndicator
            self.tableView.tableFooterView = self.activityIndicator
            self.tableView.tableFooterView?.isHidden = false
        }
        callsRequest?.fetchPrevious(onSuccess: { (fetchedCalls) in
            if fetchedCalls?.count != 0 {
                guard let filteredCalls = fetchedCalls?.filter({
                    ($0 as? Call != nil && ($0 as? Call)?.callStatus == .initiated)  ||
                        ($0 as? Call != nil && ($0 as? Call)?.callStatus == .unanswered)
                }) else { return }
                self.calls.append(contentsOf: filteredCalls.reversed())
                let currentMissedCalls = self.calls.filter({ ($0 as? Call != nil && ($0 as? Call)?.callStatus == .unanswered)})
                for missCall in currentMissedCalls {
                    if !self.missedCalls.contains(missCall) {
                        self.missedCalls.append(missCall)
                    }
                }
                DispatchQueue.main.async {
                    self.activityIndicator?.stopAnimating()
                    self.tableView.tableFooterView?.isHidden = true
                    self.tableView.reloadData()
                }
            }else{
                DispatchQueue.main.async {
                    self.activityIndicator?.stopAnimating()
                    self.tableView.tableFooterView?.isHidden = true
                }
            }
        }, onError: { (error) in
            DispatchQueue.main.async {
                if let errorMessage = error?.errorDescription {
                    self.activityIndicator?.stopAnimating()
                    self.tableView.tableFooterView?.isHidden = true
                    let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: errorMessage, duration: .short)
                    snackbar.show()
                }
            }
           
        })
    }
    
    /**
     This method register the delegate for real time events from CometChatPro SDK.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
    
     */
    private  func setupDelegates(){
        CometChat.messagedelegate = self
    }
    
    /**
     This method setup the tableview to load CometChatCallsList.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
    
     */
    private func setupTableView() {
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
            activityIndicator = UIActivityIndicatorView(style: .medium)
        } else {
            activityIndicator = UIActivityIndicatorView(style: .gray)
        }
        tableView = UITableView()
        self.view.addSubview(self.tableView)
        self.tableView.tableFooterView = UIView(frame: .zero)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.topAnchor.constraint(equalTo: self.safeArea.topAnchor).isActive = true
        self.tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.registerCells()
    }
    
    
    
    
    /**
     This method register 'CometChatCallsView' cell in tableView.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatUserList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-1-comet-chat-user-list)
     */
    private func registerCells(){
        let CometChatCallsView  = UINib.init(nibName: "CometChatCallsView", bundle: UIKitSettings.bundle)
        self.tableView.register(CometChatCallsView, forCellReuseIdentifier: "callsView")
    }
    
    /**
     This method setup navigationBar for conversationList viewController.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
    
     */
    private func setupNavigationBar(){
        if navigationController != nil{
            if #available(iOS 13.0, *) {
                let navBarAppearance = UINavigationBarAppearance()
                navBarAppearance.configureWithOpaqueBackground()
                navBarAppearance.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 20, weight: .regular) as Any]
                navBarAppearance.largeTitleTextAttributes = [.font: UIFont.systemFont(ofSize: 35, weight: .bold) as Any]
                navBarAppearance.shadowColor = .clear
                navigationController?.navigationBar.standardAppearance = navBarAppearance
                navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
                self.navigationController?.navigationBar.isTranslucent = true
            }
            self.addSegmentControl(bool: true)
            self.addEditButton(bool: true)
            self.addNewCallButton(bool: true)
        }
    }
    
    /**
     This method setup adds the segment control  for callsList viewController.
     - Parameter bool: This specifies an boolean value.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
     private func addSegmentControl(bool: Bool) {
        let titles = ["All", "Missed"]
        segmentControl = UISegmentedControl(items: titles)
        segmentControl.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 14, weight: .medium) as Any], for: .normal)
        segmentControl.setWidth(70, forSegmentAt: 0)
        segmentControl.setWidth(70, forSegmentAt: 1)
        segmentControl.selectedSegmentIndex = 0
        segmentControl.sizeToFit()
        segmentControl.addTarget(self, action: #selector(segmentControlPressed), for: .valueChanged)
        segmentControl.sendActions(for: .valueChanged)
        navigationItem.titleView = segmentControl
    }
    
    /**
    This method triggers when segment controller pressed.
    - Parameter bool: This specifies an boolean value.
    - Author: CometChat Team
    - Copyright:  ©  2020 CometChat Inc.
    */
    @objc func segmentControlPressed(_ sender: UISegmentedControl) {
        self.tableView.reloadData()
    }

    /**
    This method setup adds the edit/done button  for callsList viewController.
    - Parameter bool: This specifies an boolean value.
    - Author: CometChat Team
    - Copyright:  ©  2020 CometChat Inc.
    */
    private func addEditButton(bool: Bool){
        if bool == true {
            let edit = UIBarButtonItem(title: "Edit", style: .done, target: self, action: #selector(didEditButtonPressed))
            edit.tintColor = UIKitSettings.primaryColor
            self.navigationItem.leftBarButtonItem  = edit
        }else{
            let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(didDoneButtonPressed))
            self.navigationItem.leftBarButtonItem  = done
            done.tintColor = UIKitSettings.primaryColor
        }
    }
    
    /**
    This method setup adds the new call button  for callsList viewController.
    - Parameter bool: This specifies an boolean value.
    - Author: CometChat Team
    - Copyright:  ©  2020 CometChat Inc.
    */
    private func addNewCallButton(bool: Bool){
        if bool == true {
            var newCall = UIBarButtonItem()
            newCall =  UIBarButtonItem(image: UIImage(named: "newCall", in: UIKitSettings.bundle, compatibleWith: nil), style: .done, target: self, action: #selector(didNewCallPressed))
            newCall.tintColor = UIKitSettings.primaryColor
            self.navigationItem.rightBarButtonItem  = newCall
        }
    }
    
    /**
    This method triggers when edit button  pressed.
    - Parameter bool: This specifies an boolean value.
    - Author: CometChat Team
    - Copyright:  ©  2020 CometChat Inc.
    */
    @objc func didEditButtonPressed(){
        self.addEditButton(bool: false)
        tableView.isEditing = true
    }
    
    /**
       This method triggers when done button  pressed.
       - Parameter bool: This specifies an boolean value.
       - Author: CometChat Team
       - Copyright:  ©  2020 CometChat Inc.
       */
    @objc func didDoneButtonPressed(){
        self.addEditButton(bool: true)
        tableView.isEditing = false
    }
    
    /**
          This method triggers when new call button  pressed.
          - Parameter bool: This specifies an boolean value.
          - Author: CometChat Team
          - Copyright:  ©  2020 CometChat Inc.
          */
    @objc func didNewCallPressed(){
        let newCallList = CometChatNewCallList()
        let navigationController = UINavigationController(rootViewController: newCallList)
         navigationController.modalPresentationStyle = .popover
        newCallList.set(title: "New Call", mode: .never)
        self.present(navigationController, animated: true, completion: nil)
    }
}

/*  ----------------------------------------------------------------------------------------- */

// MARK: - Table view Methods

extension CometChatCallsList: UITableViewDelegate , UITableViewDataSource {
    
    /// This method specifies height for section in CometChatCallsList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 0
    }
    
    /// This method specifies the view for header  in CometChatCallsList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 0.5))
        return returnedView
    }
    
    /// This method loads the upcoming groups coming inside the tableview
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - indexPath: specifies current index for TableViewCell.
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex {
            self.fetchPreviousCalls()
        }
    }
    
    /// This method specifies the number of sections to display list of Conversations.
    /// - Parameter tableView: An object representing the table view requesting this information.
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /// This method specifiesnumber of rows in CometChatCallsList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if calls.isEmpty  {
            self.tableView.setEmptyMessage(NSLocalizedString("No History Found.", bundle: UIKitSettings.bundle, comment: ""))
        } else{
            self.tableView.restore()
        }
        switch segmentControl.selectedSegmentIndex {
        case 0:  return calls.count
        case 1:  return missedCalls.count
        default: break
        }
        return 0
    }
    
    /// This method specifies the height for row in CometChatCallsList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    /// This method specifies the view for user  in CometChatCallsList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView.
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        
        switch segmentControl.selectedSegmentIndex {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "callsView", for: indexPath) as! CometChatCallsView
            let call = calls[safe:indexPath.row]
            cell.call = call
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "callsView", for: indexPath) as! CometChatCallsView
            let call = missedCalls[safe:indexPath.row]
            cell.call = call
            return cell
        default: break
        }
        return cell
    }
    
    /// This method triggers when particulatr cell is clicked by the user .
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - indexPath: specifies current index for TableViewCell.
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let selectedCall = tableView.cellForRow(at: indexPath) as? CometChatCallsView else{
            return
        }
        switch selectedCall.call.receiverType {
        case .user:
            if ((selectedCall.call as? Call)?.callInitiator as? User)?.uid == LoggedInUser.uid {
                if let user = ((selectedCall.call as? Call)?.callReceiver as? User) {
                    let callDetail = CometChatCallDetail()
                    callDetail.set(title: "", mode: .never)
                    callDetail.set(user: user)
                    self.navigationController?.pushViewController(callDetail, animated: true)
                }
            }else{
                if let user = ((selectedCall.call as? Call)?.callInitiator as? User) {
                    let callDetail = CometChatCallDetail()
                    callDetail.set(title: "", mode: .never)
                    callDetail.set(user: user)
                    self.navigationController?.pushViewController(callDetail, animated: true)
                }
            }
        case .group:
            if let group = selectedCall.call.receiver as? Group {
                let callDetail = CometChatCallDetail()
                callDetail.set(title: "", mode: .never)
                callDetail.set(group: group)
                self.navigationController?.pushViewController(callDetail, animated: true)
            }
        @unknown default: break
        }
        delegate?.didSelectCallsAtIndexPath(call: selectedCall.call!, indexPath: indexPath)
    }

    
    
    /// Asks the data source to verify that the given row is editable.
    /// - Parameters:
    ///   - tableView: A view that presents data using rows arranged in a single column.
    ///   - indexPath: A list of indexes that together represent the path to a specific location in a tree of nested arrays.
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    /// Asks the data source to commit the insertion or deletion of a specified row in the receiver.
    /// - Parameters:
    ///   - tableView: A view that presents data using rows arranged in a single column.
    ///   - editingStyle: The visual representation of a single row in a table view.
    ///   - indexPath: A list of indexes that together represent the path to a specific location in a tree of nested arrays.
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let selectedCall = tableView.cellForRow(at: indexPath) as? CometChatCallsView {
                CometChat.delete(messageId: selectedCall.call.id, onSuccess: { (success) in
                    DispatchQueue.main.async {
                        if self.segmentControl.selectedSegmentIndex == 0 {
                            self.calls.remove(at: indexPath.row)
                        }else {
                            self.missedCalls.remove(at: indexPath.row)
                        }
                        self.tableView.beginUpdates()
                        self.tableView.deleteRows(at: [indexPath], with: .automatic)
                        self.tableView.endUpdates()
                        
                        let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "Call Deleted", duration: .short)
                        snackbar.show()
                    }
                }) { (error) in
                    DispatchQueue.main.async {
                    let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: error.errorDescription, duration: .short)
                    snackbar.show()
                    }
                }
            }
        }
    }
}


/*  ----------------------------------------------------------------------------------------- */

// MARK: - CometChatMessageDelegate Delegate

extension CometChatCallsList : CometChatMessageDelegate {
    
    /**
     This method triggers when real time text message message arrives from CometChat Pro SDK
     - Parameter textMessage: This Specifies TextMessage Object.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
    public func onTextMessageReceived(textMessage: TextMessage) {
        refreshCalls()
    }
    
    /**
     This method triggers when real time media message arrives from CometChat Pro SDK
     - Parameter mediaMessage: This Specifies MediaMessage Object.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
    public func onMediaMessageReceived(mediaMessage: MediaMessage) {
        refreshCalls()
    }
}


