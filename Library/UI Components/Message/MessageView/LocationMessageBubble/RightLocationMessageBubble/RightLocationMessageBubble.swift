
//  RightLinkPreviewBubble.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.

import UIKit
import MapKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */
protocol  LocationCellDelegate: NSObject {
    
    func didPressedOnLocation(latitude: Double, longitude : Double, name: String)
    
}


class RightLocationMessageBubble: UITableViewCell {
    
    // MARK: - Declaration of IBOutlets
    
    @IBOutlet weak var locationTitle: UILabel!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var receipt: UIImageView!
    @IBOutlet weak var receiptStack: UIStackView!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var map: UIImageView!
    @IBOutlet weak var navigateButton: UIButton!
    
    // MARK: - Declaration of Variables
    weak var locationDelegate: LocationCellDelegate?
    
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
    var locationMessage: CustomMessage! {
        didSet{
            receiptStack.isHidden = true
            if let data = locationMessage.customData {
                if let title = data["name"] as? String {
                    
                    self.locationTitle.text = title
                }
                
                if let data = locationMessage.customData , let latitude = data["latitude"] as? Double, let longitude =  data["longitude"] as? Double, let locationURL = URL(string: "https://maps.googleapis.com/maps/api/staticmap?center=\(latitude),\(longitude)&markers=color:red%7Clabel:S%7C\(latitude),\(longitude)&zoom=14&size=230x150&key=AIzaSyAa8HeLH2lQMbPeOiMlM9D1VxZ7pbGQq8o"){
                    map.cf.setImage(with: locationURL)
                }
                
                
            receiptStack.isHidden = true
            timeStamp.text = String().setMessageTime(time: locationMessage.sentAt)
                messageView.layer.cornerRadius = 20
                messageView.clipsToBounds = true
                
                if locationMessage.readAt > 0 {
                 receipt.image = #imageLiteral(resourceName: "read.png")
                 timeStamp.text = String().setMessageTime(time: Int(locationMessage?.readAt ?? 0))
                 }else if locationMessage.deliveredAt > 0 {
                receipt.image = #imageLiteral(resourceName: "delivered.png")
                 timeStamp.text = String().setMessageTime(time: Int(locationMessage?.deliveredAt ?? 0))
                 }else if locationMessage.sentAt > 0 {
                 receipt.image = #imageLiteral(resourceName: "sent.png")
                 timeStamp.text = String().setMessageTime(time: Int(locationMessage?.sentAt ?? 0))
                 }else if locationMessage.sentAt == 0 {
                    receipt.image = #imageLiteral(resourceName: "wait.png")
                    timeStamp.text = NSLocalizedString("SENDING", comment: "")
                 }
                receipt.contentMode = .scaleAspectFit
        }
    }
    }

    
    @IBAction func didNavigatePressed(_ sender: Any) {
        if let data = locationMessage.customData , let latitude = data["latitude"] as? Double, let longitude =  data["longitude"] as? Double , let title = data["name"] as? String{
        locationDelegate?.didPressedOnLocation(latitude: latitude, longitude: longitude, name: title)
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

    
}

/*  ----------------------------------------------------------------------------------------- */
