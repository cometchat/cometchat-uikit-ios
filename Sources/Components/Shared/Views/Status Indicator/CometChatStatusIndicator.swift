//  CometChatStatusIndicator.swift
 
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2022 CometChat Inc. All rights reserved.

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
 CometChatStatusIndicator: This component will be the class of UImageView which is customizable to display the status of the user.
 
 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  */

// MARK: - Importing Frameworks.

import Foundation
import  UIKit
import CometChatSDK

/*  ----------------------------------------------------------------------------------------- */

@objc @IBDesignable public class CometChatStatusIndicator: UIView {
    
    // MARK: - Declaration of IBInspectable
    
    var cornerRadius: CometChatCornerStyle?
    @IBInspectable var borderColor: UIColor = UIColor.black
    @IBInspectable var borderWidth: CGFloat = 0.0
    private var customBackgroundColor = UIColor.white
    public override  var backgroundColor: UIColor?{
        didSet {
            customBackgroundColor = backgroundColor!
            super.backgroundColor = UIColor.clear
        }
    }
    var imageView = UIImageView()
    
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
    
    public override  func draw(_ rect: CGRect) {
        customBackgroundColor.setFill()
        if let cornerRadius = cornerRadius, cornerRadius.cornerRadius != -1 {
            UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius.cornerRadius).fill()
            let borderRect = bounds.insetBy(dx: borderWidth/2, dy: borderWidth/2)
            let borderPath = UIBezierPath(roundedRect: borderRect, cornerRadius: cornerRadius.cornerRadius - borderWidth/2)
            borderColor.setStroke()
            borderPath.lineWidth = borderWidth
            borderPath.stroke()
        } else {
            UIBezierPath(roundedRect: bounds, cornerRadius: bounds.width / 2).fill()
            let borderRect = bounds.insetBy(dx: borderWidth/2, dy: borderWidth/2)
            let borderPath = UIBezierPath(roundedRect: borderRect, cornerRadius: bounds.width / 2 - borderWidth/2)
            borderColor.setStroke()
            borderPath.lineWidth = borderWidth
            borderPath.stroke()
        }
        
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
    public func set(cornerRadius: CometChatCornerStyle) -> CometChatStatusIndicator {
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
    @objc public func set(borderColor: UIColor) -> CometChatStatusIndicator {
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
    @objc public func set(borderWidth: CGFloat) -> CometChatStatusIndicator {
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
    @objc public func set(backgroundColor: UIColor) -> CometChatStatusIndicator {
        self.backgroundColor = backgroundColor
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
    public func set(status: CometChatSDK.UserStatus, backgroundColor: UIColor? = nil) -> Self {
        switch status {
        case .online, .available:
            self.isHidden = false
            self.backgroundColor = StatusIndicatorConfiguration().backgroundColorForOnlineState
        case .offline:
            self.isHidden = true
            self.backgroundColor = StatusIndicatorConfiguration().backgroundColorForOfflineState
        default: break
        }
        return self
    }
    
    @discardableResult
    @objc  func set(configuration : StatusIndicatorConfiguration?) -> Self {
        if let configuration = configuration {
            self.set(borderWidth: configuration.borderWidth)
            self.set(cornerRadius: configuration.cornerRadius!)
            self.set(status: .online, backgroundColor: configuration.backgroundColorForOnlineState)
            self.set(status: .offline, backgroundColor: configuration.backgroundColorForOfflineState)
        }
        return self
    }
    
    @discardableResult
    @objc  public func set(icon: UIImage, with tintColor: UIColor) -> CometChatStatusIndicator {
        self.imageView.frame = CGRect(x: self.frame.size.width/2 - 5, y: self.frame.size.height/2 - 5, width: 10, height: 10)
        self.addSubview(imageView)
        self.imageView.image = icon.withRenderingMode(.alwaysTemplate)
        self.imageView.contentMode = .scaleAspectFit
        self.tintColor = tintColor
        return self
    }

    
}

/*  ----------------------------------------------------------------------------------------- */


