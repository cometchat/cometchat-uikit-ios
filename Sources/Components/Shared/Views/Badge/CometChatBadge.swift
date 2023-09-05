//  CometChatBadge.swift
 
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2022 CometChat Inc. All rights reserved.

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
 CometChatBadge: This component will be the class of UILabel which is customizable to display the unread message count for conversations.
 
 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  */


// MARK: - Importing Frameworks.

import Foundation
import  UIKit
import CometChatSDK

/*  ----------------------------------------------------------------------------------------- */

@objc @IBDesignable public final class CometChatBadge: UILabel {
    
    // MARK: - Declaration of IBInspectable
    @IBInspectable var radius: CGFloat = BadgeConfiguration().cornerRadius
    @IBInspectable var borderColor: UIColor = UIColor.clear
    @IBInspectable var setBackgroundColor: UIColor = CometChatTheme.palatte.background
    @IBInspectable var borderWidth: CGFloat = 0.5
    @IBInspectable var setTextColor: UIColor = .white
    var getCount: Int {
        get {
            return Int(self.text ?? "0") ?? 0
        }
    }

    // MARK: - Initialization of required Methods
    
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
    
    func setup() {
        self.textColor = setTextColor
        self.layer.cornerRadius = radius
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = borderWidth
        self.backgroundColor = setBackgroundColor
        self.clipsToBounds = true
    }
    
    // MARK: -  instance methods
    
    /**
     This method used to set the borderColor for CometChatBadge class
     - Parameter borderColor: This specifies a `UIColor` for border of the CometChatBadge.
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     - See Also:
     [CometChatBadge Documentation](https://prodocs.cometchat.com/docs/ios-ui-components#section-3-badge-count)
     */
    @discardableResult
    @objc public func set(borderColor : UIColor) -> Self {
        self.borderColor = borderColor
        return self
    }
    
    /**
     This method used to set the borderWidth for CometChatBadge class
     - Parameter borderWidth: This specifies a `CGFloat` for border width of the CometChatBadge.
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     - See Also:
     [CometChatBadge Documentation](https://prodocs.cometchat.com/docs/ios-ui-components#section-3-badge-count)
     */
    @discardableResult
    @objc public func set(borderWidth : CGFloat) -> Self {
        self.borderWidth = borderWidth
        return self
    }
    
    /**
     This method used to set the backgroundColor for CometChatBadge class
     - Parameter borderColor: This specifies a `UIColor` for background  of the CometChatBadge.
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     - See Also:
     [CometChatBadge Documentation](https://prodocs.cometchat.com/docs/ios-ui-components#section-3-badge-count)
     */
    @discardableResult
    public func set(backgroundColor : UIColor) -> Self {
        self.backgroundColor  = backgroundColor
        return self
    }
    
    @discardableResult
    public func set(textColor : UIColor) -> Self {
        self.textColor  = textColor
        return self
    }
    
    @discardableResult
    public func set(textFont : UIFont) -> Self {
        self.font  = textFont
        return self
    }

    /**
     This method used to set the cornerRadius for CometChatBadge class
     - Parameter cornerRadius: This specifies a float value  which sets corner radius.
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     - See Also:
     [CometChatBadge Documentation](https://prodocs.cometchat.com/docs/ios-ui-components#section-3-badge-count)
     */
    @discardableResult
    public func set(cornerRadius : CGFloat) -> Self {
        self.radius = cornerRadius
        return self
    }
    
    /**
     This method used to set the count for CometChatBadge class
     - Parameter count: This specifies a Int value  which sets count .
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     - See Also:
     [CometChatBadge Documentation](https://prodocs.cometchat.com/docs/ios-ui-components#section-3-badge-count)
     */
    @discardableResult
    public func set(count : Int) -> Self {
        if count >=  1 && count < 999 {
            self.isHidden = false
            self.text = "\(count)"
            
        }else if count > 999 {
            self.isHidden = false
            self.text = "999+"
            
         } else {
            self.text = "0"
            self.isHidden = true
            
        }
        return self
    }
    
    /**
        This method used to increment the count for CometChatBadge class
        - Parameter count: This specifies a Int value  which sets count .
        - Author: CometChat Team
        - Copyright:  ©  2022 CometChat Inc.
        - See Also:
        [CometChatBadge Documentation](https://prodocs.cometchat.com/docs/ios-ui-components#section-3-badge-count)
        */
    @discardableResult
    public func incrementCount() -> Self {
        let currentCount = self.getCount
        self.set(count: currentCount + 1)
        self.isHidden = false
       return self
    }
    
    @discardableResult
    public func removeCount() -> Self {
        self.text = "0"
        self.isHidden = true
        return self
    }
    
    @discardableResult
    func set(configuration : BadgeConfiguration) -> Self {
        self.set(cornerRadius: configuration.cornerRadius)
        return self
    }

}
