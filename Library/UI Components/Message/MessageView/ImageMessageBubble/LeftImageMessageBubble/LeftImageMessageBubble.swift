//
//  LeftImageMessageBubble.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.

import UIKit
import CometChatPro


/*  ----------------------------------------------------------------------------------------- */

class LeftImageMessageBubble: UITableViewCell {
    
    
    // MARK: - Declaration of IBInspectable
    
    @IBOutlet weak var avatar: Avatar!
    @IBOutlet weak var imageMessage: UIImageView!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var receiptStack: UIStackView!
    @IBOutlet weak var tintedView: UIView!
    @IBOutlet weak var imageModerationView: UIView!
    @IBOutlet weak var unsafeContentView: UIImageView!
    
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
    
    var mediaMessage: MediaMessage!{
        didSet {
            if let userName = mediaMessage.sender?.name {
                name.text = userName + ":"
            }
            if mediaMessage.receiverType == .group {
                nameView.isHidden = false
            }else {
                nameView.isHidden = true
            }
            self.receiptStack.isHidden = true
            timeStamp.text = String().setMessageTime(time: mediaMessage.sentAt)
            if let avatarURL = mediaMessage.sender?.avatar  {
                avatar.set(image: avatarURL, with: mediaMessage.sender?.name ?? "")
            }
            if let mediaURL = mediaMessage.metaData, let imageUrl = mediaURL["fileURL"] as? String {
                  let url = URL(string: imageUrl)
                  if (url?.checkFileExist())! {
                      do {
                          let imageData = try Data(contentsOf: url!)
                          let image = UIImage(data: imageData as Data)
                          imageMessage.image = image
                      } catch {
                          print("Error loading image : \(error)")
                      }
                  }else{
                      parseThumbnailForImage(forMessage: mediaMessage)
                  }
              }else{
                  parseThumbnailForImage(forMessage: mediaMessage)
              }
              parseImageForModeration(forMessage: mediaMessage)
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
    
    /**
     This method used to set the image for LeftImageMessageBubble class
     - Parameter image: This specifies a `URL` for  the Avatar.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
    public func set(Image: UIImageView, forURL url: String) {
        let url = URL(string: url)
        Image.cf.setImage(with: url)
    }
    
    private func parseThumbnailForImage(forMessage: MediaMessage?) {
         imageMessage.image = nil
         if let metaData = forMessage?.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let thumbnailGenerationDictionary = cometChatExtension["thumbnail-generation"] as? [String : Any] {
             if let url = URL(string: thumbnailGenerationDictionary["url_medium"] as? String ?? "") {
                 imageMessage.cf.setImage(with: url)
             }
         }else{
             if let url = URL(string: mediaMessage.attachment?.fileUrl ?? "") {
                 imageMessage.cf.setImage(with: url)
             }
         }
     }
     
     private func parseImageForModeration(forMessage: MediaMessage?) {
         if let metaData = forMessage?.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let imageModerationDictionary = cometChatExtension["image-moderation"] as? [String : Any] {
             if let unsafeContent = imageModerationDictionary["unsafe"] as? String {
                 if unsafeContent == "yes" {
                     imageModerationView.addBlur()
                     imageModerationView.roundViewCorners([.layerMaxXMaxYCorner,.layerMaxXMinYCorner,.layerMinXMaxYCorner,.layerMinXMinYCorner], radius: 15)
                     imageModerationView.isHidden = false
                     unsafeContentView.isHidden = false
                 }else{
                     imageModerationView.isHidden = true
                     unsafeContentView.isHidden = true
                 }
                
             }
         }
     }
    
}

/*  ----------------------------------------------------------------------------------------- */
