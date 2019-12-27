//
//  Avtar.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 23/09/19.
//  Copyright © 2019 Pushpsen Airekar. All rights reserved.
//

import Foundation
import  UIKit
import  CometChatPro


//////////////////////////////   COMETCHATPRO : AVTAR  //////////////////////////////
@IBDesignable

@objc public class Avtar: UIImageView {
    @IBInspectable var cornerRadius: CGFloat = 0  // This parameter specifies the corner radius for Avtar class
    @IBInspectable var borderColor: UIColor = UIColor.lightGray  // This parameter specifies the border color for Avtar class
    @IBInspectable var borderWidth: CGFloat = 0.5  // This parameter specifies the border width for Avtar class
    
    override init(image: UIImage?) { super.init(image: image) }  
    override init(frame: CGRect) { super.init(frame: frame) }
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = cornerRadius
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = borderWidth
        self.clipsToBounds = true
    }
    
    
    // This function used to ser the cornerRadius for Avtar class
    @objc public func set(cornerRadius : CGFloat) -> Avtar {
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
        return self
    }
    
    // This function used to ser the borderColor for Avtar class
    @objc public func set(borderColor : UIColor) -> Avtar {
           self.layer.borderColor = borderColor.cgColor
           return self
    }
    
    // This function used to ser the borderWidth for Avtar class
    @objc public func set(borderWidth : CGFloat) -> Avtar {
              self.layer.borderWidth = borderWidth
              return self
    }
    
    // This function used to ser the image with URL for Avtar class
    @objc public func set(image: String) {
        
        let url = URL(string: image)
        self.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "defaultAvtar.jpg"))
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
