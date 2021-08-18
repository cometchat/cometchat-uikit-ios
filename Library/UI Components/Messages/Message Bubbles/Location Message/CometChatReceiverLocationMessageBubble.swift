
//  CometChatSenderLinkPreviewBubble.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.

import UIKit
import EventKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */

class CometChatReceiverLocationMessageBubble: UITableViewCell {
    
    // MARK: - Declaration of IBOutlets
    
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var reactionView: CometChatMessageReactions!
    @IBOutlet weak var map: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var receiptStack: UIStackView!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var avatar: CometChatAvatar!
    
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
            if locationMessage.receiverType == .group {
                if let name = locationMessage.sender?.name {
                    userName.text = name + ":"
                }
                nameView.isHidden = false
            }else {
                nameView.isHidden = true
            }
            self.reactionView.parseMessageReactionForMessage(message: locationMessage) { (success) in
                if success == true {
                    self.reactionView.isHidden = false
                }else{
                    self.reactionView.isHidden = true
                }
            }
            if let data = locationMessage.customData , let latitude = data["latitude"] as? Double, let longitude =  data["longitude"] as? Double{
                
                if let url = self.getMapFromLocatLon(from: latitude, and: longitude, googleApiKey: UIKitSettings.googleApiKey) {
                    map.cf.setImage(with: url, placeholder: UIImage(named: "location-map.png", in: UIKitSettings.bundle, compatibleWith: nil))
                }else{
                    map.image = UIImage(named: "location-map.png", in: UIKitSettings.bundle, compatibleWith: nil)
                }
                self.getAddressFromLocatLon(from: latitude, and: longitude, googleApiKey: UIKitSettings.googleApiKey) { address in
                    self.title.text = address
                }
            }
            
            if let avatarURL = locationMessage.sender?.avatar  {
                avatar.set(image: avatarURL, with: locationMessage.sender?.name ?? "")
            }else{
                 avatar.set(image: "", with: locationMessage.sender?.name ?? "")
            }
            
            receiptStack.isHidden = true
            subTitle.text = "SHARED_LOCATION".localized()
            let tapOnMapView = UITapGestureRecognizer(target: self, action: #selector(didNavigatePressed))
            self.messageView.isUserInteractionEnabled = true
            self.messageView.addGestureRecognizer(tapOnMapView)
            receiptStack.isHidden = true
            timeStamp.text = String().setMessageTime(time: locationMessage.sentAt)
            messageView.clipsToBounds = true
    }
    }
        
    @objc func didNavigatePressed() {

        if let data = locationMessage.customData , let latitude = data["latitude"] as? Double, let longitude =  data["longitude"] as? Double {
            locationDelegate?.didPressedOnLocation(latitude: latitude, longitude: longitude, title: title.text ?? "")
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
    
    func getMapFromLocatLon(from latitude: Double ,and longitude: Double, googleApiKey: String) -> URL? {
        
        if googleApiKey == "" ||   googleApiKey == "ENTER YOUR GOOGLE API KEY HERE" {
            let url = URL(string: "")
            return url
        }else{
            let url = URL(string: "https://maps.googleapis.com/maps/api/staticmap?center=\(latitude),\(longitude)&markers=color:red%7Clabel:S%7C\(latitude),\(longitude)&zoom=14&size=230x150&key=\(googleApiKey.trimmingCharacters(in: .whitespacesAndNewlines))")
            return url
        }
      
    }
    
    func getAddressFromLocatLon(from latitude: Double ,and longitude: Double, googleApiKey: String, handler: @escaping (String) -> ()) {
        
        var addressString : String = ""
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = latitude
        center.longitude = longitude
        
        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
        
        ceo.reverseGeocodeLocation(loc, completionHandler:
                                    {(placemarks, error) in
                                        if let error = error {
                                            handler("UNKNOWN_LOCATION".localized())
                                        }else if let placemarks = placemarks {
                                            if   let pm = placemarks as? [CLPlacemark] {
                                                if pm.count > 0 {
                                                    let place = pm[0]
                                                    var addressString : String = ""
                                                    if place.subLocality != nil {
                                                        addressString = addressString + place.subLocality! + ", "
                                                    }
                                                    if place.thoroughfare != nil {
                                                        addressString = addressString + place.thoroughfare! + ", "
                                                    }
                                                    if place.locality != nil {
                                                        addressString = addressString + place.locality! + ", "
                                                    }
                                                    if place.country != nil {
                                                        addressString = addressString + place.country! + ", "
                                                    }
                                                    if place.postalCode != nil {
                                                        addressString = addressString + place.postalCode! + " "
                                                    }
                                                    
                                                    handler(addressString)
                                                }else{
                                                    handler("UNKNOWN_LOCATION".localized())
                                                }
                                                
                                            }
                                            
                                        }else{
                                            handler("UNKNOWN_LOCATION".localized())
                                        }
                                    })
    }
}

/*  ----------------------------------------------------------------------------------------- */
