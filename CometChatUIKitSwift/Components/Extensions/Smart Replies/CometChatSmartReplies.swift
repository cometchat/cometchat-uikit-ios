
//  CometChatSmartReplies.swift
 
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.

import UIKit
import Foundation
import CometChatSDK

// MARK: - Importing Protocols.

protocol CometChatSmartRepliesDelegate: AnyObject {
    func didSendButtonPressed(title: String)
}

/*  ----------------------------------------------------------------------------------------- */

@IBDesignable public  class CometChatSmartReplies: UIView {
    
    // MARK: - Declaration of Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionLayout: UICollectionViewFlowLayout! {
        didSet{
            collectionLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
    }
    // MARK: - Declaration of Variables
    var user: User?
    var group: Group?
    var onClick:((_ title: String) -> Void)?
    var view: UIView!
    var buttontitles: [String] = []
    weak var smartRepliesDelegate: CometChatSmartRepliesDelegate?
    
    
    
    // MARK: - Public instance Methods
    
    /**
     This method set the array of titles for smart replies view.
     - Parameter sender: This specifies an user who is pressing this button
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
    @discardableResult
    @objc public func set(titles: [String]) -> CometChatSmartReplies {
        buttontitles = titles
        collectionView.reloadData()
        return self
    }
    
    @discardableResult
    @objc  public func set(user : User) -> CometChatSmartReplies {
        self.user = user
        return self
    }
    
    @discardableResult
    @objc  public func set(group: Group) -> CometChatSmartReplies {
        self.group = group
        return self
    }
    
    @discardableResult
    @objc  public func set(message: BaseMessage) -> CometChatSmartReplies {
        parseSmartReplies(forMessage: message)
        return self
    }
    
    @discardableResult
    public func setOnClick(onClick: @escaping (_ title: String) -> Void) -> Self {
        self.onClick = onClick
        return self
    }
    
    private func parseSmartReplies(forMessage: BaseMessage)  {
        var messages : [String] = [String]()
        if forMessage.sender?.uid != CometChat.getLoggedInUser()?.uid {
            if  let metaData = forMessage.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected[ExtensionConstants.extensions] as? [String : Any], let smartReply = cometChatExtension[ExtensionConstants.smartReply] as? [String : Any] {
                
                if let positive = smartReply["reply_positive"] {
                    messages.append(positive as! String)
                }
                if let neutral = smartReply["reply_neutral"] {
                    messages.append(neutral as! String)
                }
                if let negative = smartReply["reply_negative"] {
                    messages.append(negative as! String)
                }
                messages.append("")
                DispatchQueue.main.async { [weak self] in
                    if messages.isEmpty {
                        self?.isHidden = true
                    } else {
                        self?.isHidden = false
                        
                        self?.set(titles: messages)
                    }
                }
            } else {
                DispatchQueue.main.async { [weak self] in
                    self?.isHidden = true
                }
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.isHidden = true
            }
        }
        
    }
    
    // MARK: - Initialization of required Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        
    }
    
    //    public override func draw(_ rect: CGRect) {
    //        setupCollectionView()
    //        collectionView.showsHorizontalScrollIndicator = false
    //    }
    
    private func commonInit() {
        let loadedNib = CometChatUIKit.bundle.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)
        if let contentView = loadedNib?.first as? UIView  {
            contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            contentView.frame = bounds
            addSubview(contentView)
        }
        setupCollectionView()
        collectionView.showsHorizontalScrollIndicator = false
        
    }
    
    // MARK: - Private instance Methods
    
    /// This method will setup the collection view for smart replies
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        let cometChatSmartRepliesItem = UINib(nibName: "CometChatSmartRepliesItem", bundle: CometChatUIKit.bundle)
        collectionView.register(cometChatSmartRepliesItem, forCellWithReuseIdentifier: "CometChatSmartRepliesItem")
        collectionView.backgroundColor = SmartRepliesStyle().background
        collectionView.roundViewCorners(corner: SmartRepliesStyle().cornerRadius)
    }
    
    private func sendTextMessage(for message: String, _ forEntity: AppEntity) {
        if !message.isEmpty {
            var textMessage: TextMessage?
            if let uid = (forEntity as? User)?.uid {
                textMessage =  TextMessage(receiverUid: uid, text: message, receiverType: .user)
            }else if  let guid = (forEntity as? Group)?.guid {
                textMessage =  TextMessage(receiverUid: guid, text: message, receiverType: .group)
            }
            textMessage?.muid = "\(Int(Date().timeIntervalSince1970 * 1000))"
            textMessage?.senderUid = CometChat.getLoggedInUser()?.uid ?? ""
            textMessage?.sender = CometChat.getLoggedInUser()
            
            if let textMessage = textMessage {
                CometChatMessageEvents.ccMessageSent(message: textMessage, status: .inProgress)
                
                CometChat.sendTextMessage(message: textMessage) { updatedTextMessage in
                    CometChatMessageEvents.ccMessageSent(message: updatedTextMessage, status: .success)
                    
                } onError: { error in
                    if let error = error {
                        textMessage.metaData = ["error": true]
                        CometChatMessageEvents.ccMessageSent(message: textMessage, status: .error)
                    }
                }
            }
        }
    }
}

/*  ----------------------------------------------------------------------------------------- */

// MARK: - CollectionView Delegate Methods

extension CometChatSmartReplies: UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    /// Asks your data source object for the number of items in the specified section.
    /// - Parameters:
    ///   - collectionView: An object that manages an ordered collection of data items and presents them using customizable layouts.
    ///   - section: A signed integer value type.
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return buttontitles.count
    }
    
    
    /// Asks your data source object for the cell that corresponds to the specified item in the collection view.
    /// - Parameters:
    ///   - collectionView: An object that manages an ordered collection of data items and presents them using customizable layouts.
    ///   - indexPath: A list of indexes that together represent the path to a specific location in a tree of nested arrays.
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let title = buttontitles[safe: indexPath.row]
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CometChatSmartRepliesItem", for: indexPath) as? CometChatSmartRepliesItem {
            cell.title = title
            cell.smartRepliesItemDelegate = self
            return cell
        }
        return UICollectionViewCell()
    }
}


/*  ----------------------------------------------------------------------------------------- */

// MARK: - SmartReplyCell Delegate Method

extension CometChatSmartReplies: CometChatSmartRepliesItemDelegate {
    
    /// This method will trigger when user tap on button in smart replies view.
    /// - Parameters:
    ///   - title: Specifies a string value
    ///   - sender: Specifies a sender of the button.
    func didSendButtonPressed(title: String, sender: UIButton) {
        onClick?(title)
        self.isHidden = true
    }
}

/*  ----------------------------------------------------------------------------------------- */
