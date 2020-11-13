
//  CometChatCreatePoll.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.

import UIKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */

class CometChatCreatePoll: UIViewController {
    
    // MARK: - Declaration of Outlets
    var items:[Int] = [Int]()
    static let QUESTION_CELL = 0
    static let OPTION_CELL = 1
    static let ADD_NEW_OPTION_CELL = 2
    
    @IBOutlet weak var createPoll: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var backgroundView: UIView!
    
    
    // MARK: - Declaration of Variables
    
    let modelName = UIDevice.modelName
    var user : User?
    var group : Group?
    var documentsUrl: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    // MARK: - View controller lifecycle methods
    override func loadView() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "CometChatCreatePoll", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view  = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        set(title: "Create a Poll", mode: .always)
        setupTableView()
        registerCells()
        setupItems()
        setupNavigationBar()
        addObservers()
        hideKeyboardWhenTappedArround()
    }
    
     // MARK: - Public Instance methods
    
    /**
    This method specifies the navigation bar title for CometChatCreatePoll.
    - Parameters:
    - title: This takes the String to set title for CometChatGroupList.
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
    
    
    // MARK: - Private Instance methods
    
    private func setupItems(){
        items = [CometChatCreatePoll.OPTION_CELL, CometChatCreatePoll.OPTION_CELL]
    }
    
    private func setupTableView() {
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        self.tableView.tableFooterView = UIView(frame: .zero)
    }
    
    private func registerCells(){
        
        let createPollQuestionView  = UINib.init(nibName: "CreatePollQuestionView", bundle: UIKitSettings.bundle)
        self.tableView?.register(createPollQuestionView, forCellReuseIdentifier: "createPollQuestionView")
        
        let createPollOptionView  = UINib.init(nibName: "CreatePollOptionView", bundle: UIKitSettings.bundle)
        self.tableView?.register(createPollOptionView, forCellReuseIdentifier: "createPollOptionView")
        
        let addNewOptionView  = UINib.init(nibName: "AddNewOptionView", bundle: UIKitSettings.bundle)
        self.tableView?.register(addNewOptionView, forCellReuseIdentifier: "addNewOptionView")
        
    }
    
    /**
        This method setup navigationBar for createGroup viewController.
        - Author: CometChat Team
        - Copyright:  ©  2020 CometChat Inc.
    */
    private func setupNavigationBar(){
        if navigationController != nil{
            // NavigationBar Appearance
            if #available(iOS 13.0, *) {
                let navBarAppearance = UINavigationBarAppearance()
                navBarAppearance.configureWithOpaqueBackground()
                navBarAppearance.shadowColor = .clear
                navigationController?.navigationBar.standardAppearance = navBarAppearance
                navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
                self.navigationController?.navigationBar.isTranslucent = true
            }
            let closeButton = UIBarButtonItem(title: NSLocalizedString("CLOSE",bundle: UIKitSettings.bundle, comment: ""), style: .plain, target: self, action: #selector(closeButtonPressed))
            self.navigationItem.rightBarButtonItem = closeButton
        }
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
            let keyboardHeight = (userinfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue?.size.height
            
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
    
    
   
    
    
    
    /**
    This method triggeres when  create group button pressed.
    - Author: CometChat Team
    - Copyright:  ©  2020 CometChat Inc.
    */
    @IBAction func didCreatePollPressed(_ sender: Any) {
        if let question = (tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as? CreatePollQuestionView)?.question.text {
            print("question is: \(question)")
            var options = [String]()
            
            for item in 0...items.count {
                if let option = (tableView.cellForRow(at: IndexPath(item: item, section: 1)) as? CreatePollOptionView)?.options.text {
                    print("option is: \(option)")
                    options.append(option)
                }
            }
            
            var body = ["question": question,"options": options] as [String : Any]
            if user != nil {
                body.append(with: ["receiver":user?.uid ?? "","receiverType":"user"])
            }else if group != nil {
                body.append(with: ["receiver":group?.guid ?? "","receiverType":"group"])
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
            
            CometChat.callExtension(slug: "polls", type: .post, endPoint: "v1/create", body: body, onSuccess: { (response) in
                print("callExtension onSuccess:\(String(describing: response))")
                
                DispatchQueue.main.async {
                    self.dismiss(animated: true) {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }) { (error) in
                print("callExtension error:\(error?.errorDescription)")
            }
        }
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
        if section == 0 {
            return 1
        }else if section == 1 {
            return items.count
        }else if section == 2 {
            return 1
        }else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension 
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        if indexPath.section == 0 {
            
            let  questionView = tableView.dequeueReusableCell(withIdentifier: "createPollQuestionView", for: indexPath) as! CreatePollQuestionView
            return questionView
            
        }else if indexPath.section == 1 {
            
            switch items[indexPath.row] {
            case CometChatCreatePoll.QUESTION_CELL: break

            case CometChatCreatePoll.OPTION_CELL:
                
                let  optionView = tableView.dequeueReusableCell(withIdentifier: "createPollOptionView", for: indexPath) as! CreatePollOptionView
                if indexPath.row == 0 {
                    optionView.optionsLabel.text = "Options  "
                }else{
                    optionView.optionsLabel.text = "                 "
                }
                return optionView
                
            case CometChatCreatePoll.ADD_NEW_OPTION_CELL:  break
            default: break
            }
            
        } else if indexPath.section == 2 {
            let  addNewOptionView = tableView.dequeueReusableCell(withIdentifier: "addNewOptionView", for: indexPath) as! AddNewOptionView
            addNewOptionView.newOptionDelegate = self
            return addNewOptionView
        }
        return cell
    }
    
    //trailingSwipeActionsConfigurationForRowAt indexPath -->
      @available(iOS 11.0, *)
      func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
         
        if indexPath.section == 1 && indexPath.row > 1 {
            let deleteAction =  UIContextualAction(style: .normal, title: "", handler: { (action,view,completionHandler ) in
              if (tableView.cellForRow(at: indexPath) as? CreatePollOptionView) != nil {
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
              deleteAction.title = "Delete"
          }
          deleteAction.backgroundColor = .red
          let confrigation:UISwipeActionsConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
          return confrigation
        }else{
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
        if items.count <= 5 {
            tableView.beginUpdates()
            items.append(CometChatCreatePoll.OPTION_CELL)
            tableView.insertRows(at: [IndexPath(row: items.count - 1, section: 1)], with: .automatic)
            tableView.endUpdates()
        }else{
            DispatchQueue.main.async {
                let snackbar = CometChatSnackbar(message: "You cannot add more than 5 options at a time.", duration: .short)
                snackbar.show()
            }
        }
       
        
    }
    
}
