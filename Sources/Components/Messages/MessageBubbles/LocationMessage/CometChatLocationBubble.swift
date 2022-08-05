//
//  CometChatLocationBubble.swift
//  CometChatUIKit
//
//  Created by Abdullah Ansari on 16/05/22.
//

import UIKit
import CometChatPro
import CoreLocation
import MapKit

class CometChatLocationBubble: UIView {

   // MARK: - Property
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var descriptionView: UIView!
    
    // MARK: - Initializers
    var controller: UIViewController?
    var locationMessage : CustomMessage?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    convenience init(frame: CGRect, message: CustomMessage, isStandard: Bool) {
        self.init(frame: frame)
       
        setupStyle(isStandard: isStandard)
        setAddress(message: message)
        set(subTitle: "SHARED_LOCATION".localize())
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    @discardableResult
    public func set(controller: UIViewController) -> Self {
        self.controller = controller
        return self
    }
    
    
    // MARK: - Helper Methods
    
    private func setupStyle(isStandard: Bool) {
        let locationStyle = LocationBubbleStyle(
            titleColor: CometChatTheme.palatte?.accent900,
            titleFont: CometChatTheme.typography?.Subtitle1,
            subTitleColor:CometChatTheme.palatte?.accent700,
            subTitleFont: CometChatTheme.typography?.Subtitle2,
            descriptionViewBackgroundColor: CometChatTheme.palatte?.secondary
        )
        set(style: locationStyle)
    }
    
    private func setAddress(message: CustomMessage) {
        self.locationMessage = message
        if let data = message.customData, let latitude = data["latitude"] as? Double, let longitude = data["longitude"] as? Double {
            self.getAddressFromLocatLon(from: latitude, and: longitude, googleApiKey: CometChatUIKit.googleApiKey) { address in
                self.set(title: address)
            }
        }
    }
    
    private func commonInit() {
        CometChatUIKit.bundle.loadNibNamed("CometChatLocationBubble", owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onLocationClick))
        thumbnail.addGestureRecognizer(tap)
        thumbnail.isUserInteractionEnabled = true
        
        let tap1: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onLocationClick))
        descriptionView.addGestureRecognizer(tap1)
        descriptionView.isUserInteractionEnabled = true
    }
    
    @objc  func onLocationClick() {
        if let data = locationMessage?.customData, let latitude = data["latitude"] as? Double, let longitude = data["longitude"] as? Double {
            
            
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            actionSheet.addAction(UIAlertAction(title: "OPEN_IN_APPLE_MAPS".localize(), style: .default, handler: { (alert:UIAlertAction!) -> Void in
                
                self.openMapsForPlace(latitude: latitude, longitude: longitude, title: "")
            }))
            
            actionSheet.addAction(UIAlertAction(title: "OPEN_IN_GOOGLE_MAPS".localize(), style: .default, handler: { (alert:UIAlertAction!) -> Void in
                
                self.openGoogleMapsForPlace(latitude: String(latitude), longitude: String(longitude))
            }))
            
            actionSheet.addAction(UIAlertAction(title: "CANCEL".localize(), style: .cancel, handler: nil))
            actionSheet.view.tintColor = CometChatTheme.palatte?.primary
            controller?.present(actionSheet, animated: true, completion: nil)
        }
    }
    
    @discardableResult
    public func set(style: LocationBubbleStyle) -> Self {
        self.set(titleColor: style.titleColor!)
        self.set(titleFont: style.titleFont!)
        self.set(subTitleColor: style.subTitleColor!)
        self.set(subTitleFont:  style.subTitleFont!)
        self.set(desctiptionView: style.descriptionViewBackgroundColor!)
        return self
    }
        
    @discardableResult
    @objc public func set(desctiptionView backgroundColor: UIColor) -> Self {
        self.descriptionView.backgroundColor = backgroundColor
        return self
    }
    
    
    @discardableResult
    @objc public func set(title: String) -> Self {
        self.title.text = title
        return self
    }
    
    @discardableResult
    @objc public func set(titleFont: UIFont) -> Self {
        self.title.font = titleFont
        return self
    }
    
    
    @discardableResult
    @objc public func set(titleColor: UIColor) -> Self {
        self.title.textColor = titleColor
        return self
    }
    
    @discardableResult
    @objc public func set(subTitle: String) -> Self {
        self.subTitle.text = subTitle
        return self
    }
    
    @discardableResult
    @objc public func set(subTitleFont: UIFont) -> Self {
        self.subTitle.font = subTitleFont
        return self
    }
    
    
    @discardableResult
    @objc public func set(subTitleColor: UIColor) -> Self {
        self.subTitle.textColor = subTitleColor
        return self
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
            if error != nil {
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
    
    private func openMapsForPlace(latitude: CLLocationDegrees, longitude: CLLocationDegrees, title: String) {
        
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        mapItem.openInMaps(launchOptions: options)
    }
    
    private func openGoogleMapsForPlace(latitude: String, longitude: String) {
        
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            UIApplication.shared.openURL(URL(string:
                                                "comgooglemaps://?center=\(latitude),\(longitude)&zoom=14&views=traffic")!)
        } else {
        }
    }

}

