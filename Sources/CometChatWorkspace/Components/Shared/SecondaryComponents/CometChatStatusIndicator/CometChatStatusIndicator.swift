//  CometChatStatusIndicator.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2022 CometChat Inc. All rights reserved.

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
 CometChatStatusIndicator: This component will be the class of UImageView which is customizable to display the status of the user.
 
 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  */

// MARK: - Importing Frameworks.

import Foundation
import  UIKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */

@objc @IBDesignable  class CometChatStatusIndicator: UIView {
    
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
     This method used to set the cornerRadius for CometChatCometChatStatusIndicator class
     - Parameter cornerRadius: This specifies a float value  which sets corner radius.
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     - See Also:
     [CometChatStatusIndicator Documentation](https://prodocs.cometchat.com/docs/ios-ui-components#section-2-status-indicator)
     */
    @discardableResult
    @objc  func set(cornerRadius: CGFloat) -> CometChatStatusIndicator {
        self.cornerRadius = cornerRadius
        return self
    }
    
    /**
     This method used to set the borderColor for CometChatStatusIndicator class
     - Parameter borderColor: This specifies a `UIColor` for border of the CometChatStatusIndicator.
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     - See Also:
     [CometChatStatusIndicator Documentation](https://prodocs.cometchat.com/docs/ios-ui-components#section-2-status-indicator)
     */
    @discardableResult
    @objc  func set(borderColor: UIColor) -> CometChatStatusIndicator {
        self.borderColor = borderColor
        return self
    }
    
    /**
     This method used to set the borderWidth for CometChatStatusIndicator class
     - Parameter borderWidth: This specifies a `CGFloat` for border width of the CometChatStatusIndicator.
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     - See Also:
     [CometChatStatusIndicator Documentation](https://prodocs.cometchat.com/docs/ios-ui-components#section-2-status-indicator)
     */
    @discardableResult
    @objc  func set(borderWidth: CGFloat) -> CometChatStatusIndicator {
        self.borderWidth = borderWidth
        return self
    }
    
    /**
     This method used to set the Color for CometChatStatusIndicator class
     - Parameter color: This specifies a `UIColor` for  of the CometChatStatusIndicator.
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     - See Also:
     [CometChatStatusIndicator Documentation](https://prodocs.cometchat.com/docs/ios-ui-components#section-2-status-indicator)
     */
    @discardableResult
    @objc  func set(color: UIColor) -> CometChatStatusIndicator {
        self.backgroundColor = color
        return self
    }
    
    
    /**
     This method used to set the Color according to the status of the user for CometChatStatusIndicator class
     -  - Parameter status:  This specifies a `UserStatus` such as `.online` or `.offline`.
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     - See Also:
     [CometChatStatusIndicator Documentation](https://prodocs.cometchat.com/docs/ios-ui-components#section-2-status-indicator)
     */
    @discardableResult
    @objc    public func set(status: CometChat.UserStatus, backgroundColor: UIColor? = nil) -> CometChatStatusIndicator {
        switch status {
        case .online:
            self.backgroundColor = StatusIndicatorConfiguration().backgroundColorForOnlineState
        case .offline:
            self.backgroundColor = StatusIndicatorConfiguration().backgroundColorForOfflineState
        case .available:
            self.backgroundColor = StatusIndicatorConfiguration().backgroundColorForOfflineState
        @unknown default:
            self.backgroundColor = StatusIndicatorConfiguration().backgroundColorForOfflineState
        }
        return self
    }

    
    @discardableResult
    @objc  func set(configuration : StatusIndicatorConfiguration) -> CometChatStatusIndicator {
        self.set(borderWidth: configuration.borderWidth)
        self.set(cornerRadius: configuration.cornerRadius)
        self.set(status: .online, backgroundColor: configuration.backgroundColorForOnlineState)
        self.set(status: .offline, backgroundColor: configuration.backgroundColorForOfflineState)
        return self
    }
    
}

/*  ----------------------------------------------------------------------------------------- */