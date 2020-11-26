
//  RightLinkPreviewBubble.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.

import UIKit
import EventKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */

class LeftLocationMessageBubble: UITableViewCell {
    
    // MARK: - Declaration of IBOutlets
    
    @IBOutlet weak var reactionView: ReactionView!
    @IBOutlet weak var map: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var receiptStack: UIStackView!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var avatar: Avatar!
    
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
    weak var locationDelegate: LocationCellDelegate?
    var locationMessage: CustomMessage! {
        didSet{
            self.reactionView.parseMessageReactionForMessage(message: locationMessage) { (success) in
                if success == true {
                    self.reactionView.isHidden = false
                }else{
                    self.reactionView.isHidden = true
                }
            }
            if let data = locationMessage.customData , let latitude = data["latitude"] as? Double, let longitude =  data["longitude"] as? Double, let locationURL = URL(string: "https://maps.googleapis.com/maps/api/staticmap?center=\(latitude),\(longitude)&markers=color:red%7Clabel:S%7C\(latitude),\(longitude)&zoom=14&size=230x150&key=AIzaSyAa8HeLH2lQMbPeOiMlM9D1VxZ7pbGQq8o"){
                map.cf.setImage(with: locationURL)
            }
            
            if let avatarURL = locationMessage.sender?.avatar  {
                avatar.set(image: avatarURL, with: locationMessage.sender?.name ?? "")
            }else{
                 avatar.set(image: "", with: locationMessage.sender?.name ?? "")
            }
            
            receiptStack.isHidden = true
            if let data = locationMessage.customData {
                if let title = data["name"] as? String {
                    self.title.text = title
            }

            receiptStack.isHidden = true
            timeStamp.text = String().setMessageTime(time: locationMessage.sentAt)
            messageView.clipsToBounds = true
        }
    }
    }
   
    
    @IBAction func didNAvigatePRessed(_ sender: Any) {
        if let data = locationMessage.customData , let latitude = data["latitude"] as? Double, let longitude =  data["longitude"] as? Double , let title = data["name"] as? String{
        locationDelegate?.didPressedOnLocation(latitude: latitude, longitude: longitude, name: title)
        }
    }
        
    
    // MARK: - Initialization of required Methods
    
      override func setHighlighted(_ highlighted: Bool, animated: Bool) {
          super.setHighlighted(highlighted, animated: animated)
          if #available(iOS 13.0, *) {
              
          } else {
              messageView.backgroundColor =  .lightGray
          }
          
      }

      override func setSelected(_ selected: Bool, animated: Bool) {
          super.setSelected(selected, animated: animated)
          if #available(iOS 13.0, *) {
              
          } else {
              messageView.backgroundColor =  .lightGray
          }
      }
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        if #available(iOS 13.0, *) {
           selectionColor = .systemBackground
        } else {
            selectionColor = .white
        }
        
    }
}

/*  ----------------------------------------------------------------------------------------- */
