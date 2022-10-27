
//  CometChatSenderLinkPreviewBubble.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.

import UIKit
import MapKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */
protocol  LocationCellDelegate: NSObject {
    
    func didPressedOnLocation(latitude: Double, longitude : Double, title: String)
    
}


class CometChatSenderLocationMessageBubble: UITableViewCell {
    
    // MARK: - Declaration of IBOutlets
    
    @IBOutlet weak var reactionView: CometChatMessageReactions!
    @IBOutlet weak var heightReactions: NSLayoutConstraint!
    @IBOutlet weak var locationTitle: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var receipt: UIImageView!
    @IBOutlet weak var receiptStack: UIStackView!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var map: UIImageView!
    
    // MARK: - Declaration of Variables
    weak var locationDelegate: LocationCellDelegate?
    private var imageRequest: Cancellable?
    private lazy var imageService = ImageService()
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
            messageView.backgroundColor = UIKitSettings.primaryColor
            if let data = locationMessage.customData {
                
                self.reactionView.parseMessageReactionForMessage(message: locationMessage) { (success) in
                    if success == true {
                        self.reactionView.isHidden = false
                    }else{
                        self.reactionView.isHidden = true
                    }
                }
                if let latitude = data["latitude"] as? Double, let longitude =  data["longitude"] as? Double{
                    
                    if let url = self.getMapFromLocatLon(from: latitude, and: longitude, googleApiKey: UIKitSettings.googleApiKey) {
                        imageRequest = imageService.image(for: url) { [weak self] image in
                            guard let strongSelf = self else { return }
                            // Update Thumbnail Image View
                            if let image = image {
                                strongSelf.map.image = image
                            }else{
                                strongSelf.map.image = UIImage(named: "location-map.png", in: UIKitSettings.bundle, compatibleWith: nil)
                            }
                        }
                    }else{
                        map.image = UIImage(named: "location-map.png", in: UIKitSettings.bundle, compatibleWith: nil)
                    }
                    self.getAddressFromLocatLon(from: latitude, and: longitude, googleApiKey: UIKitSettings.googleApiKey) { address in
                        self.locationTitle.text = address
                    }
                }
                
                
                receiptStack.isHidden = true
                timeStamp.text = String().setMessageTime(time: locationMessage.sentAt)
                messageView.layer.cornerRadius = 12
                messageView.clipsToBounds = true
                
                if locationMessage.readAt > 0 {
                    receipt.image = UIImage(named: "message-read", in: UIKitSettings.bundle, compatibleWith: nil)
                    timeStamp.text = String().setMessageTime(time: Int(locationMessage?.readAt ?? 0))
                }else if locationMessage.deliveredAt > 0 {
                    receipt.image = UIImage(named: "message-delivered", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                    timeStamp.text = String().setMessageTime(time: Int(locationMessage?.deliveredAt ?? 0))
                }else if locationMessage.sentAt > 0 {
                    receipt.image = UIImage(named: "message-sent", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                    timeStamp.text = String().setMessageTime(time: Int(locationMessage?.sentAt ?? 0))
                }else if locationMessage.sentAt == 0 {
                    receipt.image = UIImage(named: "messages-wait", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                    timeStamp.text = "SENDING".localized()
                }
                receipt.contentMode = .scaleAspectFit
                subtitle.text = "SHARED_LOCATION".localized()
                let tapOnMapView = UITapGestureRecognizer(target: self, action: #selector(didNavigatePressed))
                self.messageView.isUserInteractionEnabled = true
                self.messageView.addGestureRecognizer(tapOnMapView)
                
            }
            calculateHeightForReactions(reactionView: reactionView, heightReactions: heightReactions)
        }
    }
    
    
    @objc func didNavigatePressed() {
        if let data = locationMessage.customData , let latitude = data["latitude"] as? Double, let longitude =  data["longitude"] as? Double {
            locationDelegate?.didPressedOnLocation(latitude: latitude, longitude: longitude, title: locationTitle.text ?? "")
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
    
    override func prepareForReuse() {
        imageRequest?.cancel()
        reactionView.reactions.removeAll()
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
        
        var _ : String = ""
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = latitude
        center.longitude = longitude
        
        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
        
        ceo.reverseGeocodeLocation(loc, completionHandler:
                                    {(placemarks, error) in
            if error != nil {
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
