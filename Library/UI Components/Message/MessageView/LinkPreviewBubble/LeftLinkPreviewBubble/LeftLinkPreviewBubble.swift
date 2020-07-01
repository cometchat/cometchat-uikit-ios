
//  LeftLinkPreviewBubble.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.

import UIKit
import WebKit
import CometChatPro

// MARK: - Importing Protocols.

public protocol LinkPreviewDelegate {
    func didVisitButtonPressed(link: String,sender: UIButton)
    func didPlayButtonPressed(link: String,sender: UIButton)
}

/*  ----------------------------------------------------------------------------------------- */

class LeftLinkPreviewBubble: UITableViewCell, WKNavigationDelegate {
    
    // MARK: - Declaration of IBOutlets
    
    @IBOutlet weak var avatar: Avatar!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var linkDescription: UILabel!
    @IBOutlet weak var visitButton: UIButton!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var messageStack: UIStackView!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var receiptStack: UIStackView!
    @IBOutlet weak var playbutton: UIButton!
    @IBOutlet weak var iconView: UIView!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var tintedView: UIView!
    
    
    // MARK: - Declaration of Variables
    var selectionColor: UIColor {
        set {
            let view = UIView()
            view.backgroundColor = newValue
            self.selectedBackgroundView = view
        }
        get {
            return self.selectedBackgroundView?.backgroundColor ?? UIColor.clear
        }
    }
    
    var url:String?
    var linkPreviewDelegate: LinkPreviewDelegate?
    var linkPreviewMessage: TextMessage! {
        didSet{
            if let avatarURL = linkPreviewMessage.sender?.avatar  {
                avatar.set(image: avatarURL, with: linkPreviewMessage.sender?.name ?? "")
            }
            if let userName = linkPreviewMessage.sender?.name {
                name.text = userName + ":"
            }
            if linkPreviewMessage.receiverType == .group {
              nameView.isHidden = false
            }else {
                nameView.isHidden = true
            }
            receiptStack.isHidden = true
            message.text = linkPreviewMessage.text
            parseLinkPreviewForMessage(message: linkPreviewMessage)
            if let url = url {
                if url.contains("youtube")  ||  url.contains("youtu.be") {
                    visitButton.setTitle(NSLocalizedString("VIEW_ON_YOUTUBE", comment: ""), for: .normal)
                    playbutton.isHidden = false
                }else{
                    visitButton.setTitle(NSLocalizedString("Visit", comment: ""), for: .normal)
                    playbutton.isHidden = true
                }
            }
            if message.text?.count == 0 {
                messageStack.isHidden = true
            }else{
                messageStack.isHidden = false
            }
            timeStamp.text = String().setMessageTime(time: linkPreviewMessage.sentAt)
            if message.text?.count == 0 { messageStack.isHidden = true
            }else{ messageStack.isHidden = false }
            icon.roundViewCorners([.layerMinXMinYCorner,.layerMaxXMinYCorner], radius: 15)
            iconView.roundViewCorners([.layerMinXMinYCorner,.layerMaxXMinYCorner], radius: 15)
            visitButton.roundViewCorners([.layerMinXMaxYCorner,.layerMaxXMaxYCorner], radius: 15)
        }
    }
    
     // MARK: - Private Instance Methods
    
    /**
    This method used to parse the linkPreview data from TextMessage Object
     - Parameter message: This specifies `TextMessage` Object.
    - Author: CometChat Team
    - Copyright:  ©  2020 CometChat Inc.
      */
    private func parseLinkPreviewForMessage(message: TextMessage){
        if let metaData = linkPreviewMessage.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let linkPreviewDictionary = cometChatExtension["link-preview"] as? [String : Any], let linkArray = linkPreviewDictionary["links"] as? [[String: Any]] {
            
            guard let linkPreview = linkArray[safe: 0] else {
              return
            }
            
            if let linkTitle = linkPreview["title"] as? String {
                title.text = linkTitle
            }

            if let description = linkPreview["description"] as? String {
                linkDescription.text = description
            }
            
            if let thumbnail = linkPreview["image"] as? String {
                let url = URL(string: thumbnail)
                icon.cf.setImage(with: url, placeholder: #imageLiteral(resourceName: "default-image.png"))
            }
            
            if let linkURL = linkPreview["url"] as? String {
                self.url = linkURL
            }
        }
    }
    
    /**
    This method will trigger when user pressed on visit button.
     - Parameter sender: This specifies an user who is pressing this button
    - Author: CometChat Team
    - Copyright:  ©  2020 CometChat Inc.
      */
    @IBAction func visitButtonPressed(_ sender: Any) {
        if let url = url {
            linkPreviewDelegate?.didVisitButtonPressed(link: url,sender: sender as! UIButton)
        }
    }
    
    /**
    This method will trigger when user pressed on play button.
     - Parameter sender: This specifies an user who is pressing this button
    - Author: CometChat Team
    - Copyright:  ©  2020 CometChat Inc.
      */
    @IBAction func didPlaybuttonPressed(_ sender: Any) {
        if let url = url {
            linkPreviewDelegate?.didPlayButtonPressed(link: url, sender: sender as! UIButton)
        }
    }
    
    // MARK: - Initialization of required Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if #available(iOS 13.0, *) {
            selectionColor = .systemBackground
        } else {
            selectionColor = .white
        }
    }
    
     override func setSelected(_ selected: Bool, animated: Bool) {
           super.setSelected(selected, animated: animated)
           switch isEditing {
           case true:
               switch selected {
               case true: self.tintedView.isHidden = false
               case false: self.tintedView.isHidden = true
               }
           case false: break
           }
       }
    
}



/*  ----------------------------------------------------------------------------------------- */
