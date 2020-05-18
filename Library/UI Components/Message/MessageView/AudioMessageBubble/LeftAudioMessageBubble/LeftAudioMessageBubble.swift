//  LeftaudioMessageBubble.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.


// MARK: - Importing Frameworks.

import UIKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */

class LeftAudioMessageBubble: UITableViewCell {
    
    // MARK: - Declaration of IBOutlets
    
    @IBOutlet weak var tintedView: UIView!
    @IBOutlet weak var fileName: UILabel!
    @IBOutlet weak var size: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var avatar: Avatar!
    @IBOutlet weak var receiptStack: UIStackView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var nameView: UIView!
    
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
    
    var audioMessage: MediaMessage! {
        didSet {
            receiptStack.isHidden = true
            if audioMessage.receiverType == .group {
              nameView.isHidden = false
            }else {
                nameView.isHidden = true
            }
            if let userName = audioMessage.sender?.name {
                name.text = userName + ":"
            }
            
            timeStamp.text = String().setMessageTime(time: Int(audioMessage?.sentAt ?? 0))
            fileName.text = "Audio File"
            if let fileSize = audioMessage.attachment?.fileSize {
                print(Units(bytes: Int64(fileSize)).getReadableUnit())
                size.text = Units(bytes: Int64(fileSize)).getReadableUnit()
            }
            if let avatarURL = audioMessage.sender?.avatar  {
                avatar.set(image: avatarURL, with: audioMessage.sender?.name ?? "")
            }
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
