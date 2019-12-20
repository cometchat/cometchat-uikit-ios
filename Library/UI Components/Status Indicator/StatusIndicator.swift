//
//  StatusIndicator.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 23/09/19.
//  Copyright © 2019 Pushpsen Airekar. All rights reserved.
//

import Foundation
import  UIKit
import CometChatPro


//////////////////////////////   COMETCHATPRO : STATUS INDICATOR //////////////////////////////
@objc @IBDesignable public class StatusIndicator: UIView {
    @IBInspectable var cornerRadius: CGFloat = 0.0
    @IBInspectable var borderColor: UIColor = UIColor.black
    @IBInspectable var borderWidth: CGFloat = 0.5
    private var customBackgroundColor = UIColor.white
    override public var backgroundColor: UIColor?{
        didSet {
            customBackgroundColor = backgroundColor!
            super.backgroundColor = UIColor.clear
        }
    }
    func setup() {
        super.backgroundColor = UIColor.clear
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup() }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup() }
    
    override public func draw(_ rect: CGRect) {
        customBackgroundColor.setFill()
        UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).fill()
        let borderRect = bounds.insetBy(dx: borderWidth/2, dy: borderWidth/2)
        let borderPath = UIBezierPath(roundedRect: borderRect, cornerRadius: cornerRadius - borderWidth/2)
        borderColor.setStroke()
        borderPath.lineWidth = borderWidth
        borderPath.stroke()
    }
    
    
    @objc public func set(cornerRadius: CGFloat) -> StatusIndicator {
        self.cornerRadius = cornerRadius
        return self
    }
    
    @objc public func set(borderColor: UIColor) -> StatusIndicator {
           self.borderColor = borderColor
           return self
    }
    
    @objc public func set(borderWidth: CGFloat) -> StatusIndicator {
              self.borderWidth = borderWidth
              return self
    }
    
    @objc public func set(color: UIColor) -> StatusIndicator {
        self.backgroundColor = color
              return self
    }
    
    @objc public func set(status: CometChatPro.CometChat.UserStatus) -> StatusIndicator {
        switch status {
        case .online:
             self.backgroundColor = #colorLiteral(red: 0.6039215686, green: 0.8039215686, blue: 0.1960784314, alpha: 1)
        case .offline:
             self.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        @unknown default:
            break
        }
        return self
       }
}
//////////////////////////////////////////////////////////////////////////////////////////
