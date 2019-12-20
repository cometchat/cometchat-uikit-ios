//
//  UnreadBadgeCount.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 23/09/19.
//  Copyright © 2019 Pushpsen Airekar. All rights reserved.
//

import Foundation
import  UIKit
import CometChatPro

/////////////////////////   COMETCHATPRO : UNREAD COUNT BADGE  ////////////////////////////

@objc @IBDesignable public class BadgeCount: UILabel {
   
    @IBInspectable var borderColor: UIColor = UIColor.clear
    @IBInspectable var borderWidth: CGFloat = 0.5
    @IBInspectable var radius: CGFloat = 25
    @IBInspectable var setBackgroundColor: UIColor? {
           didSet {
               layer.backgroundColor = setBackgroundColor?.cgColor
           }
       }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setup()
    }
    
    override init(frame: CGRect){
        super.init(frame: frame)
        self.setup()
    }
    
    public override func drawText(in rect: CGRect) {
        super.drawText(in: rect)
        self.setup()
    }
    
    func setup(){
        self.textColor = UIColor.white
        self.layer.cornerRadius = radius
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = borderWidth
        self.clipsToBounds = true
    }
  
    @objc public func set(borderColor : UIColor) -> BadgeCount {
           self.borderColor = borderColor
           return self
    }
    
    @objc public func set(borderWidth : CGFloat) -> BadgeCount {
              self.borderWidth = borderWidth
              return self
    }
    
    @objc public func set(backgroundColor : UIColor) -> BadgeCount {
              self.setBackgroundColor  = backgroundColor
              return self
    }
    
    @objc public func set(cornerRadius : CGFloat) -> BadgeCount {
        self.radius = cornerRadius
        return self
    }
    
    @objc public func set(count : Int) -> BadgeCount {
        if count >=  1 && count < 999 {
               self.isHidden = false
                self.text = "\(count)"
        }else if count > 999 {
            self.isHidden = false
            self.text = "999+"
        }else{
            self.isHidden = true
        }
        
        return self
    }
}

//////////////////////////////////////////////////////////////////////////////////////////
