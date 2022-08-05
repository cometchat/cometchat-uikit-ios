
//  CometChatCreatePoll.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.

import UIKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */

class CometChatCreatePoll: CometChatListBase {
    
    // MARK: - Declaration of Outlets
    var items:[Int] = [Int]()
    static let QUESTION_CELL = 0
    static let OPTION_CELL = 1
    static let ADD_NEW_OPTION_CELL = 2
    
    private var sendButton: UIBarButtonItem?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var backgroundView: UIView!
    var sectionTitle : UILabel?
    var headerBackground: UIColor = CometChatTheme.palatte?.secondary ?? UIColor.tertiarySystemBackground
    var headerTextColor: UIColor = CometChatTheme.palatte?.accent600 ?? UIColor.black
    var headerTextFont: UIFont = CometChatTheme.typography?.Caption1 ?? UIFont.systemFont(ofSize: 13, weight: .medium)
    
    
    // MARK: - Declaration of Variables
    
    let modelName = UIDevice.modelName
    var user : User?
    var group : Group?
    var documentsUrl: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    // MARK: - View controller lifecycle methods
    override func loadView() {
        let loadedNib = Bundle.module.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)
        if let contentView = loadedNib?.first as? UIView  {
            contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.view = contentView
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupTableView()
        registerCells()
        setupItems()
        addObservers()
        hideKeyboardWhenTappedArround()
        
    }
    
    @discardableResult
    @objc public func set(user: User) -> CometChatCreatePoll {
        self.user = user
        return self
    }
    
    
    @discardableResult
    @objc public func set(group: Group) -> CometChatCreatePoll {
        self.group = group
        return self
    }
    
    @discardableResult
    @objc public func set(sectionHeaderTextFont: UIFont) -> CometChatCreatePoll {
        self.headerTextFont = sectionHeaderTextFont
        return self
    }
    
    @discardableResult
    @objc public func set(sectionHeaderTextColor: UIColor) -> CometChatCreatePoll {
        self.headerTextColor = sectionHeaderTextColor
        return self
    }
    
    @discardableResult
    @objc public func set(sectionHeaderBackground: UIColor) -> CometChatCreatePoll {
        self.headerBackground = sectionHeaderBackground
        return self
    }
    
    @discardableResult
    public func hide(send: Bool) ->  CometChatCreatePoll {
        if !send {
            sendButton = UIBarButtonItem(title: "SEND".localize(), style: .done, target: self, action: #selector(self.didSendPressed))
            set(sendButtonFont: CometChatTheme.typography?.Name2 ?? UIFont.systemFont(ofSize: 17))
            set(sendButtonTint: CometChatTheme.palatte?.primary ?? .blue)
            self.navigationItem.rightBarButtonItem = sendButton
        }
        return self
    }
    
    @discardableResult
    public func set(sendButtonTint: UIColor) ->  CometChatCreatePoll  {
        sendButton?.tintColor = sendButtonTint
        return self
    }
    
    @discardableResult
    public func set(sendButtonFont: UIFont) ->  CometChatCreatePoll {
        sendButton?.setTitleTextAttributes([NSAttributedString.Key.font: sendButtonFont], for: .normal)
        return self
    }
    
    @objc func didSendPressed(){
        
        
        if let question = (tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as? CometChatCreatePollQuestions)?.question.text {
            
            var options = [String]()
            
            for item in 0...items.count {
                if let option = (tableView.cellForRow(at: IndexPath(item: item, section: 1)) as? CometChatCreatePollOptions)?.options.text {
                    
                    options.append(option)
                }
            }
            var body = ["question": question,"options": options] as [String : Any]
            if user != nil {
                body.append(with: ["receiver":user?.uid ?? "","receiverType": UIKitConstants.ReceiverTypeConstants.user])
            }else if group != nil {
                body.append(with: ["receiver":group?.guid ?? "","receiverType": UIKitConstants.ReceiverTypeConstants.group])
            }
            
            DispatchQueue.main.async {
                let alert = UIAlertController(title: nil, message: "Creating Poll...", preferredStyle: .alert)
                let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
                loadingIndicator.hidesWhenStopped = true
                loadingIndicator.style = UIActivityIndicatorView.Style.gray
                loadingIndicator.startAnimating()
                alert.view.addSubview(loadingIndicator)
                self.present(alert, animated: true, completion: nil)
            }
            
            CometChat.callExtension(slug: ExtensionConstants.polls, type: .post, endPoint: "v2/create", body: body, onSuccess: { (response) in
                
                DispatchQueue.main.async {
                    self.dismiss(animated: true) {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }) { (error) in
                DispatchQueue.main.async {
                    self.dismiss(animated: true) {
                        if let error = error {
                            let confirmDialog = CometChatDialog()
                            confirmDialog.set(confirmButtonText: "TRY_AGAIN".localize())
                            confirmDialog.set(cancelButtonText: "CANCEL".localize())
                            confirmDialog.set(error: CometChatServerError.get(error: error))
                            confirmDialog.open(onConfirm: { [weak self] in
                                guard let strongSelf = self else { return }
                                // Referesh view
                                strongSelf.viewDidLoad()
                                strongSelf.viewWillAppear(true)
                            })
                        }
                    }
                }
            }
        }
    }
    
    private func setupAppearance() {
        self.set(background: [CometChatTheme.palatte?.secondary?.cgColor ?? UIColor.systemFill.cgColor])
            .set(title: "CREATE_POLLS".localize(), mode: .never)
            .set(titleColor: CometChatTheme.palatte?.accent ?? UIColor.black)
            .hide(search: true)
            .set(backButtonTitle: "CANCEL".localize())
            .set(backButtonTint: CometChatTheme.palatte?.primary ?? UIColor.clear)
            .show(backButton: true)
        self.hide(send: false)
        tableView.backgroundColor = CometChatTheme.palatte?.secondary ?? .white
    }
    
    private func setupItems() {
        items = [CometChatCreatePoll.OPTION_CELL, CometChatCreatePoll.OPTION_CELL, CometChatCreatePoll.ADD_NEW_OPTION_CELL]
    }
    
    private func setupTableView() {
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        self.tableView.tableFooterView = UIView(frame: .zero)
    }
    
    private func registerCells() {
        
        let CometChatCreatePollQuestions  = UINib.init(nibName: "CometChatCreatePollQuestions", bundle: CometChatUIKit.bundle)
        self.tableView?.register(CometChatCreatePollQuestions, forCellReuseIdentifier: "CometChatCreatePollQuestions")
        
        let CometChatCreatePollOptions  = UINib.init(nibName: "CometChatCreatePollOptions", bundle: CometChatUIKit.bundle)
        self.tableView?.register(CometChatCreatePollOptions, forCellReuseIdentifier: "CometChatCreatePollOptions")
        
        let CometChatCreatePollAddNewOption  = UINib.init(nibName: "CometChatCreatePollAddNewOption", bundle: CometChatUIKit.bundle)
        self.tableView?.register(CometChatCreatePollAddNewOption, forCellReuseIdentifier: "CometChatCreatePollAddNewOption")
        
    }
    
    /**
     This method observes for perticular events such as `didGroupDeleted`, `keyboardWillShow`, `dismissKeyboard` in CometChatCreatePoll..
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
    fileprivate func addObservers(){
        //Register Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dismissKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(self.didGroupDeleted(_:)), name: NSNotification.Name(rawValue: "didGroupDeleted"), object: nil)
        self.hideKeyboardWhenTappedArround()
        self.cometChatListBaseDelegate = self
    }
    
    /**
     This method triggers when  group is deleted.
     - Parameter notification: Specifies the `NSNotification` Object.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
    @objc func didGroupDeleted(_ notification: NSNotification) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    /**
     This method triggers when  keyboard is shown.
     - Parameter notification: Specifies the `NSNotification` Object.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
    @objc func keyboardWillShow(notification: NSNotification) {
        if let userinfo = notification.userInfo
        {
            _ = (userinfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue?.size.height
            
            if (modelName == "iPhone X" || modelName == "iPhone XS" || modelName == "iPhone XR" || modelName == "iPhone12,1"){
                //  createGroupBtnBottomConstraint.constant = (keyboardHeight)! - 10
                UIView.animate(withDuration: 0.5) {
                    self.view.layoutIfNeeded()
                }
            }else{
                // createGroupBtnBottomConstraint.constant = (keyboardHeight)! + 20
                UIView.animate(withDuration: 0.5) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    /**
     This method triggers when  user taps arround the view.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
    private func hideKeyboardWhenTappedArround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        tableView.addGestureRecognizer(tap)
    }
    
    /**
     This method dismiss the  keyboard
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
    @objc  func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    /**
     This method when user clicks on Close button.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
    @objc func closeButtonPressed(){
        self.dismiss(animated: true, completion: nil)
    }
}


/*  ----------------------------------------------------------------------------------------- */

extension CometChatCreatePoll: UITableViewDataSource , UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : items.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 1 ? 30 : 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension 
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            if  let  questionView = tableView.dequeueReusableCell(withIdentifier: "CometChatCreatePollQuestions", for: indexPath) as? CometChatCreatePollQuestions {
                return questionView
            }
            
        } else if indexPath.section == 1 {
            
            switch items[indexPath.row] {
            case CometChatCreatePoll.QUESTION_CELL: break
                
            case CometChatCreatePoll.OPTION_CELL:
                
                if  let  optionView = tableView.dequeueReusableCell(withIdentifier: "CometChatCreatePollOptions", for: indexPath) as? CometChatCreatePollOptions {
                    optionView.options.placeholder = "ANSWER".localize()
                    return optionView
                }
                
                
            case CometChatCreatePoll.ADD_NEW_OPTION_CELL:
                
                if  let  addNewOptionView = tableView.dequeueReusableCell(withIdentifier: "CometChatCreatePollAddNewOption", for: indexPath) as? CometChatCreatePollAddNewOption {
                    addNewOptionView.newOptionDelegate = self
                    return addNewOptionView
                }
            default: break
            }
        }
        return UITableViewCell()
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width - 20, height: 25))
        sectionTitle = UILabel(frame: CGRect(x: 10, y: 2, width: returnedView.frame.size.width, height: 25))
        sectionTitle?.text = "SET_THE_ANSWERS".localize()
        if #available(iOS 13.0, *) {
            sectionTitle?.textColor = headerTextColor
            sectionTitle?.font = headerTextFont
            returnedView.backgroundColor = headerBackground
        } else {}
        returnedView.addSubview(sectionTitle!)
        return returnedView
    }
    
    //trailingSwipeActionsConfigurationForRowAt indexPath -->
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if indexPath.section == 1 && indexPath.row > 1 {
            let deleteAction =  UIContextualAction(style: .normal, title: "", handler: { (action,view,completionHandler ) in
                if (tableView.cellForRow(at: indexPath) as? CometChatCreatePollOptions) != nil {
                    DispatchQueue.main.async {
                        self.tableView.beginUpdates()
                        self.items.remove(at: indexPath.row)
                        self.tableView.deleteRows(at: [indexPath], with: .automatic)
                        self.tableView.endUpdates()
                    }
                }
                completionHandler(true)
            })
            if #available(iOS 13.0, *) {
                deleteAction.image = UIImage(systemName: "trash")
            } else {
                deleteAction.title = "DELETE".localize()
            }
            deleteAction.backgroundColor = .red
            let confrigation:UISwipeActionsConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
            return confrigation
        } else {
            let confrigation:UISwipeActionsConfiguration = UISwipeActionsConfiguration(actions: [])
            return confrigation
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension CometChatCreatePoll : AddNewOptionDelegate {
    
    func didNewOptionPressed() {
            tableView.beginUpdates()
            items.insert(CometChatCreatePoll.OPTION_CELL, at: items.count - 1)
            tableView.insertRows(at: [IndexPath(row: items.count - 2, section: 1)], with: .automatic)
            tableView.endUpdates()
    }
    
}



extension CometChatCreatePoll : CometChatListBaseDelegate {
    
    func onSearch(state: SearchState, text: String) {}
    
    func onBack() {
        self.dismiss(animated: true)
    }
}
