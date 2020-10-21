//  StatusIndicator.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
 StatusIndicator: This component will be the class of UImageView which is customizable to display the status of the user.
 
 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  */

// MARK: - Importing Frameworks.

import Foundation
import  UIKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */

@objc @IBDesignable  class StatusIndicator: UIView {
    
    // MARK: - Declaration of IBInspectable
    
    @IBInspectable var cornerRadius: CGFloat = 0.0
    @IBInspectable var borderColor: UIColor = UIColor.black
    @IBInspectable var borderWidth: CGFloat = 0.5
    private var customBackgroundColor = UIColor.white
    override  var backgroundColor: UIColor?{
        didSet {
            customBackgroundColor = backgroundColor!
            super.backgroundColor = UIColor.clear
        }
    }
    
    // MARK: - Initialization of required Methods
    
    func setup() {
        super.backgroundColor = UIColor.clear
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup() }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup() }
    
    override  func draw(_ rect: CGRect) {
        customBackgroundColor.setFill()
        UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).fill()
        let borderRect = bounds.insetBy(dx: borderWidth/2, dy: borderWidth/2)
        let borderPath = UIBezierPath(roundedRect: borderRect, cornerRadius: cornerRadius - borderWidth/2)
        borderColor.setStroke()
        borderPath.lineWidth = borderWidth
        borderPath.stroke()
    }
    
    // MARK: -  instance methods
    
    /**
     This method used to set the cornerRadius for StatusIndicator class
     - Parameter cornerRadius: This specifies a float value  which sets corner radius.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [StatusIndicator Documentation](https://prodocs.cometchat.com/docs/ios-ui-components#section-2-status-indicator)
     */
    @objc  func set(cornerRadius: CGFloat) -> StatusIndicator {
        self.cornerRadius = cornerRadius
        return self
    }
    
    /**
     This method used to set the borderColor for StatusIndicator class
     - Parameter borderColor: This specifies a `UIColor` for border of the StatusIndicator.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [StatusIndicator Documentation](https://prodocs.cometchat.com/docs/ios-ui-components#section-2-status-indicator)
     */
    @objc  func set(borderColor: UIColor) -> StatusIndicator {
        self.borderColor = borderColor
        return self
    }
    
    /**
     This method used to set the borderWidth for StatusIndicator class
     - Parameter borderWidth: This specifies a `CGFloat` for border width of the StatusIndicator.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [StatusIndicator Documentation](https://prodocs.cometchat.com/docs/ios-ui-components#section-2-status-indicator)
     */
    @objc  func set(borderWidth: CGFloat) -> StatusIndicator {
        self.borderWidth = borderWidth
        return self
    }
    
    /**
     This method used to set the Color for StatusIndicator class
     - Parameter color: This specifies a `UIColor` for  of the StatusIndicator.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [StatusIndicator Documentation](https://prodocs.cometchat.com/docs/ios-ui-components#section-2-status-indicator)
     */
    @objc  func set(color: UIColor) -> StatusIndicator {
        self.backgroundColor = color
        return self
    }
    
    
    /**
     This method used to set the Color according to the status of the user for StatusIndicator class
     -  - Parameter status:  This specifies a `UserStatus` such as `.online` or `.offline`.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [StatusIndicator Documentation](https://prodocs.cometchat.com/docs/ios-ui-components#section-2-status-indicator)
     */
    @objc  func set(status: CometChatPro.CometChat.UserStatus) -> StatusIndicator {
        switch status {
        case .online:
            self.backgroundColor = #colorLiteral(red: 0.6039215686, green: 0.8039215686, blue: 0.1960784314, alpha: 1)
        case .offline:
            self.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        case .available: break
        @unknown default:
            break
        }
        return self
    }
}

/*  ----------------------------------------------------------------------------------------- */
