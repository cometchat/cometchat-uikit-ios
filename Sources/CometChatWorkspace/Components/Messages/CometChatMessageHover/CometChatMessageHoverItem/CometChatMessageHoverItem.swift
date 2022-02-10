
//  CometChatSmartRepliesPreviewItem.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2022 CometChat Inc. All rights reserved.


// MARK: - Importing Frameworks.
import UIKit
import CometChatPro

// MARK: - Importing Protocols.



/*  ----------------------------------------------------------------------------------------- */

class CometChatMessageHoverItem: UICollectionViewCell {
    
    // MARK: - Declaration of IBOutlets
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var buttonView: UIView!
    // MARK: - Declaration of Variables
  
    
    
    @discardableResult
    @objc public func set(title: String?) -> CometChatMessageHoverItem {
        self.title.text = title
        return self
    }
    

    /**
     This method will set the title color for `CometChatMessageHoverItem`
     - Parameters:
     - titleColor: This method will set the title color for ConversationListItem
     - Returns: This method will return `CometChatMessageHoverItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(titleColor: UIColor) -> CometChatMessageHoverItem {
        self.title.textColor = titleColor
        return self
    }
    
    /**
     This method will set the title font for `CometChatMessageHoverItem`
     - Parameters:
     - titleFont: This method will set the title font for ConversationListItem
     - Returns: This method will return `CometChatMessageHoverItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(titleFont: UIFont) -> CometChatMessageHoverItem{
        self.title.font = titleFont
        return self
    }
    
    @discardableResult
    @objc public func set(icon: UIImage) -> CometChatMessageHoverItem {
        let image = icon.withRenderingMode(.alwaysTemplate)
        self.icon.image = image
        return self
    }

    @discardableResult
    @objc public func set(iconTintColor: UIColor) -> CometChatMessageHoverItem {
        self.icon.tintColor = iconTintColor
        return self
    }
    
    // MARK: - Initialization of required Methods
    var messageHover: MessageHover? {
        didSet {
            switch messageHover {
            case .edit:
                self.title.text = "Edit"
                self.icon.image = UIImage(named: "messages-edit.png")
            case .delete:
                self.title.text = "Delete"
                self.icon.image = UIImage(named: "messages-delete.png")
            case .share:
                self.title.text = "Share"
                self.icon.image = UIImage(named: "messages-share.png")
            case .copy:
                self.title.text = "Copy"
                self.icon.image = UIImage(named: "copy-paste.png")
            case .forward:
                self.title.text = "Forward"
                self.icon.image = UIImage(named: "messages-forward-message.png")
            case .reply:
                self.title.text = "Reply"
                self.icon.image = UIImage(named: "reply-message.png")
            case .reply_in_thread:
                self.title.text = "Start Thread"
                self.icon.image = UIImage(named: "threaded-message.png")
            case .reaction:
                self.title.text = "Reaction"
                self.icon.image = UIImage(named: "messages-edit.png")
            case .translate:
                self.title.text = "Translate"
                self.icon.image = UIImage(named: "message-translate.png")
            case .messageInfo:
                self.title.text = "Message Info"
                self.icon.image = UIImage(named: "messages-info.png")
            case .none:
                self.title.text = ""
                self.icon.image = UIImage(named: "messages-edit.png")
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        buttonView.layer.masksToBounds = false
        buttonView.layer.shadowColor = UIColor.gray.cgColor
        buttonView.layer.shadowOpacity = 0.3
        buttonView.layer.shadowOffset = CGSize.zero
        buttonView.layer.shadowRadius = 3
        buttonView.layer.shouldRasterize = true
        buttonView.layer.rasterizationScale = UIScreen.main.scale
    }
    
    
    /// This method will trigger when user pressed button on smart reply cell.
    /// - Parameter sender: specifies a sender of the button.
}

/*  ----------------------------------------------------------------------------------------- */
