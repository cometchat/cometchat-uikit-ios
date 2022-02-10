//
//  CometChatFileBubble.swift
//  CometChatSwift
//
//  Created by Pushpsen Airekar on 27/08/21.
//  Copyright © 2021 MacMini-03. All rights reserved.
//

import UIKit
import CometChatPro
import CoreLocation

protocol LocationDelegate: NSObject {
    func didOpenLocation(forMessage: CustomMessage, cell: UITableViewCell)
    func didLongPressedOnLocationMessage(message: CustomMessage,cell: UITableViewCell)
}

class CometChatLocationBubble: UITableViewCell {
    
    @IBOutlet weak var alightmentStack: UIStackView!
    @IBOutlet weak var avatar: CometChatAvatar!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var background: CometChatGradientView!
    @IBOutlet weak var spacer: UIView!
    @IBOutlet weak var topTime: CometChatDate!
    @IBOutlet weak var time: CometChatDate!
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var leadingReplyButton: UIButton!
    @IBOutlet weak var trailingReplyButton: UIButton!
    @IBOutlet weak var receipt: CometChatMessageReceipt!
    @IBOutlet weak var receiptStack: UIStackView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var type: UILabel!
    
    var bubbleType: BubbleType = CometChatTheme.messageList.bubbleType
    weak var locationDelegate: LocationDelegate?
    
    unowned var selectionColor: UIColor {
        set {
            let view = UIView()
            view.backgroundColor = newValue
            self.selectedBackgroundView = view
        }
        get {
            return self.selectedBackgroundView?.backgroundColor ?? UIColor.white
        }
    }
    
    @discardableResult
    @objc public func set(title: String) -> CometChatLocationBubble {
        self.title.text = title
        return self
    }
    
    @discardableResult
    @objc public func set(titleFont: UIFont) -> CometChatLocationBubble {
        self.title.font = titleFont
        return self
    }
    
    
    @discardableResult
    @objc public func set(titleColor: UIColor) -> CometChatLocationBubble {
        self.title.textColor = titleColor
        return self
    }
    
    @discardableResult
    @objc public func set(subTitle: String) -> CometChatLocationBubble {
        self.subtitle.text = subTitle
        return self
    }
    
    @discardableResult
    @objc public func set(subTitleFont: UIFont) -> CometChatLocationBubble {
        self.subtitle.font = subTitleFont
        return self
    }
    
    
    @discardableResult
    @objc public func set(subTitleColor: UIColor) -> CometChatLocationBubble {
        self.subtitle.textColor = subTitleColor
        return self
    }
    
    @discardableResult
    @objc public func set(corner: CometChatCorner) -> CometChatLocationBubble {
        switch corner.corner {
        case .leftTop:
            self.background.roundViewCorners([.layerMinXMaxYCorner,.layerMaxXMinYCorner,.layerMaxXMaxYCorner], radius: corner.radius)
        case .rightTop:
            self.background.roundViewCorners([.layerMinXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMaxYCorner], radius: corner.radius)
        case .leftBottom:
            self.background.roundViewCorners([.layerMinXMinYCorner,.layerMaxXMinYCorner,.layerMaxXMaxYCorner], radius: corner.radius)
        case .rightBottom:
            self.background.roundViewCorners([.layerMinXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMinYCorner], radius: corner.radius)
        case .none:
            self.background.roundViewCorners([.layerMinXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMinYCorner,.layerMaxXMaxYCorner], radius: corner.radius)
        }
        self.background.clipsToBounds = true
        return self
    }
    

    
    @discardableResult
    public func set(backgroundColor: [Any]?) ->  CometChatLocationBubble {
        if let backgroundColors = backgroundColor as? [CGColor] {
            if backgroundColors.count == 1 {
                self.background.backgroundColor = UIColor(cgColor: backgroundColors.first ?? UIColor.blue.cgColor)
            }else{
                self.background.set(backgroundColorWithGradient: backgroundColor)
            }
        }
        return self
    }
    
    
    @discardableResult
    @objc func set(borderColor : UIColor) -> CometChatLocationBubble {
        self.background.layer.borderColor = borderColor.cgColor
        return self
    }
    
    @discardableResult
    @objc func set(borderWidth : CGFloat) -> CometChatLocationBubble {
        self.background.layer.borderWidth = borderWidth
        return self
    }
    
    
    @discardableResult
    @objc public func set(avatar: CometChatAvatar) -> CometChatLocationBubble {
        self.avatar = avatar
        return self
    }
    
    @discardableResult
    @objc public func set(userName: String) -> CometChatLocationBubble {
        if bubbleType == .leftAligned {
            self.name.text = userName
        }else{
            self.name.text = userName + ":"
        }
        
        return self
    }
    
    @discardableResult
    @objc public func set(userNameFont: UIFont) -> CometChatLocationBubble {
        self.name.font = userNameFont
        return self
    }
    
    @discardableResult
    @objc public func set(userNameColor: UIColor) -> CometChatLocationBubble {
        self.name.textColor = userNameColor
        return self
    }
    
    @discardableResult
    @objc public func set(receipt: CometChatMessageReceipt) -> CometChatLocationBubble {
        self.receipt = receipt
        return self
    }
    
    
    @discardableResult
    @objc public func set(time: CometChatDate) -> CometChatLocationBubble {
        switch  bubbleType {
        case .standard:
            self.topTime.isHidden = true
            self.time.isHidden = false
            self.topTime = time
            self.time = time
        case .leftAligned:
            self.topTime.isHidden = false
            self.time.isHidden = true
            self.topTime = time
            self.time = time
        }
        return self
    }
    
    @discardableResult
    @objc public func set(messageAlignment: MessageAlignment) -> CometChatLocationBubble {
        switch messageAlignment {
        case .left:
            name.isHidden = false
            alightmentStack.alignment = .leading
            spacer.isHidden = false
            avatar.isHidden = false
            receipt.isHidden = true
            leadingReplyButton.isHidden = true
            trailingReplyButton.isHidden = true
            
        case .right:
            alightmentStack.alignment = .trailing
            spacer.isHidden = true
            avatar.isHidden = true
            name.isHidden = true
            receipt.isHidden = false
            leadingReplyButton.isHidden = true
            trailingReplyButton.isHidden = true
        }
        return self
    }
    
    @discardableResult
    @objc public func set(messageObject: BaseMessage) -> CometChatLocationBubble {
        self.locationMessage = messageObject
        return self
    }
    
    @discardableResult
    @objc fileprivate func isMyMessage() -> Bool {
        if let message = locationMessage {
            if message.sender?.uid == CometChatMessages.loggedInUser?.uid {
                return true
            }else{
                return false
            }
        }
        return false
    }
    
    private func enableLongPress(bool: Bool) {
        if bool == true {
            let longPressOnMessage = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressedOnMessage))
            background.addGestureRecognizer(longPressOnMessage)
        }
    }
    
    @objc func didLongPressedOnMessage(sender: UILongPressGestureRecognizer){
        if sender.state == .began {
            if let locationMessage = locationMessage as? CustomMessage {
                locationDelegate?.didLongPressedOnLocationMessage(message: locationMessage, cell: self)
            }
        }
    }
    
    @objc fileprivate func enable(tap: Bool) {
        if tap == true {
            let tapOnThumbnail = UITapGestureRecognizer(target: self, action: #selector(self.didLocationMessagePressed(tapGestureRecognizer:)))
            let tapOnBackground = UITapGestureRecognizer(target: self, action: #selector(self.didLocationMessagePressed(tapGestureRecognizer:)))
            self.background.isUserInteractionEnabled = true
            self.background.addGestureRecognizer(tapOnBackground)
            self.thumbnail.isUserInteractionEnabled = true
            self.thumbnail.addGestureRecognizer(tapOnThumbnail)
        }
    }
    
    
    var locationMessage: BaseMessage? {
        didSet {
            if let locationMessage = locationMessage as? CustomMessage {
                
                if let data = locationMessage.customData , let latitude = data["latitude"] as? Double, let longitude =  data["longitude"] as? Double {
                    
                    self.getAddressFromLocatLon(from: latitude, and: longitude, googleApiKey: CometChatUIKit.googleApiKey) { address in
                        self.set(title: address)
                    }
                    
                    if let url = self.getMapFromLocatLon(from: latitude, and: longitude, googleApiKey: CometChatUIKit.googleApiKey) {
                        
                        thumbnail.cf.setImage(with: url, placeholder: UIImage(named: "messages-location-map.png", in: CometChatUIKit.bundle, compatibleWith: nil))
                    }else{
                        thumbnail.image = UIImage(named: "messages-location-map.png", in: CometChatUIKit.bundle, compatibleWith: nil)
                    }
                   
                }
             
                self.set(userName: locationMessage.sender?.name ?? "")
                self.set(receipt: self.receipt.set(receipt: locationMessage))
                self.topTime.set(time: locationMessage.sentAt, forType: .MessageBubbleDate)
                self.time.set(time: locationMessage.sentAt, forType: .MessageBubbleDate)
                self.set(avatar: self.avatar.setAvatar(avatarUrl: locationMessage.sender?.avatar ?? "", with: locationMessage.sender?.name ?? ""))
                self.set(borderColor: .clear)
                self.set(borderWidth: 1.0)
                set(time: self.time)
                if isMyMessage() {
                    switch bubbleType {
                    case .standard:
                        self.set(messageAlignment: .right)
                        self.set(titleColor: CometChatTheme.messageList.rightBubbleTextColor)
                        self.set(subTitleColor: CometChatTheme.messageList.rightBubbleTextColor)
                        self.set(corner: CometChatTheme.messageList.rightBubbleCorners)
                        self.set(backgroundColor: CometChatTheme.messageList.rightBubbleBackgroundColor)
                    case .leftAligned:
                        self.set(messageAlignment: .left)
                        self.set(corner: CometChatTheme.messageList.leftBubbleCorners)
                        self.set(titleColor: CometChatTheme.messageList.leftBubbleTextColor)
                        self.set(subTitleColor: CometChatTheme.messageList.leftBubbleTextColor)
                        self.set(backgroundColor: CometChatTheme.messageList.leftBubbleBackgroundColor)
                    }
                }else{
                    switch bubbleType {
                    case .standard:
                        self.set(messageAlignment: .left)
                        self.set(corner: CometChatTheme.messageList.leftBubbleCorners)
                        self.set(titleColor: CometChatTheme.messageList.leftBubbleTextColor)
                        self.set(subTitleColor: CometChatTheme.messageList.leftBubbleTextColor)
                        self.set(backgroundColor: CometChatTheme.messageList.leftBubbleBackgroundColor)
                    case .leftAligned:
                        self.set(messageAlignment: .left)
                        self.set(corner: CometChatTheme.messageList.leftBubbleCorners)
                        self.set(titleColor: CometChatTheme.messageList.leftBubbleTextColor)
                        self.set(subTitleColor: CometChatTheme.messageList.leftBubbleTextColor)
                        self.set(backgroundColor: CometChatTheme.messageList.leftBubbleBackgroundColor)
                    }
                }
                self.enable(tap: true)
                self.enableLongPress(bool: true)
            }
        }
    }
    
    @objc func didLocationMessagePressed(tapGestureRecognizer: UITapGestureRecognizer)
    {
        if let locationMessage = locationMessage as? CustomMessage {
            locationDelegate?.didOpenLocation(forMessage: locationMessage, cell: self)
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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    private func getMapFromLocatLon(from latitude: Double ,and longitude: Double, googleApiKey: String) -> URL? {
        
        if googleApiKey == "" ||   googleApiKey == "ENTER YOUR GOOGLE API KEY HERE" {
            let url = URL(string: "")
            return url
        }else{
            let url = URL(string: "https://maps.googleapis.com/maps/api/staticmap?center=\(latitude),\(longitude)&markers=color:red%7Clabel:S%7C\(latitude),\(longitude)&zoom=14&size=230x150&key=\(googleApiKey.trimmingCharacters(in: .whitespacesAndNewlines))")
            return url
        }
        
    }
    
    private func getAddressFromLocatLon(from latitude: Double ,and longitude: Double, googleApiKey: String, handler: @escaping (String) -> ()) {
        
        var addressString : String = ""
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = latitude
        center.longitude = longitude
        
        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
        
        ceo.reverseGeocodeLocation(loc, completionHandler:
                                    {(placemarks, error) in
            if let error = error {
                handler("UNKNOWN_LOCATION".localize())
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
                        handler("UNKNOWN_LOCATION".localize())
                    }
                    
                }
                
            }else{
                handler("UNKNOWN_LOCATION".localize())
            }
        })
    }
    
}
