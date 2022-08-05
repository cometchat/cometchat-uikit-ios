//  CometChatBadgeCount.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2022 CometChat Inc. All rights reserved.

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
 CometChatBadgeCount: This component will be the class of UILabel which is customizable to display the unread message count for conversations.
 
 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  */


// MARK: - Importing Frameworks.

import Foundation
import  UIKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */

@objc @IBDesignable public final class CometChatBadgeCount: UILabel {
    
    // MARK: - Declaration of IBInspectable
    @IBInspectable var borderColor: UIColor = UIColor.clear
    @IBInspectable var borderWidth: CGFloat = 0.5
    @IBInspectable var radius: CGFloat = BadgeCountConfiguration().cornerRadius
    @IBInspectable var setBackgroundColor: UIColor = CometChatTheme.palatte?.background ?? UIColor.clear
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
    
    func setup(){
        self.textColor = setTextColor
        self.layer.cornerRadius = radius
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = borderWidth
        self.backgroundColor = setBackgroundColor
        self.clipsToBounds = true
    }
    
    // MARK: -  instance methods
    
    /**
     This method used to set the borderColor for CometChatBadgeCount class
     - Parameter borderColor: This specifies a `UIColor` for border of the CometChatBadgeCount.
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     - See Also:
     [CometChatBadgeCount Documentation](https://prodocs.cometchat.com/docs/ios-ui-components#section-3-badge-count)
     */
    @discardableResult
    @objc  func set(borderColor : UIColor) -> CometChatBadgeCount {
        self.borderColor = borderColor
        return self
    }
    
    /**
     This method used to set the borderWidth for CometChatBadgeCount class
     - Parameter borderWidth: This specifies a `CGFloat` for border width of the CometChatBadgeCount.
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     - See Also:
     [CometChatBadgeCount Documentation](https://prodocs.cometchat.com/docs/ios-ui-components#section-3-badge-count)
     */
    @discardableResult
    @objc  func set(borderWidth : CGFloat) -> CometChatBadgeCount {
        self.borderWidth = borderWidth
        return self
    }
    
    /**
     This method used to set the backgroundColor for CometChatBadgeCount class
     - Parameter borderColor: This specifies a `UIColor` for background  of the CometChatBadgeCount.
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     - See Also:
     [CometChatBadgeCount Documentation](https://prodocs.cometchat.com/docs/ios-ui-components#section-3-badge-count)
     */
    @discardableResult
    @objc  func set(backgroundColor : UIColor) -> CometChatBadgeCount {
        self.backgroundColor  = backgroundColor
        return self
    }
    
    @discardableResult
    @objc  func set(textColor : UIColor) -> CometChatBadgeCount {
        self.textColor  = textColor
        return self
    }
    
    @discardableResult
    @objc  func set(textFont : UIFont) -> CometChatBadgeCount {
        self.font  = textFont
        return self
    }
    

    
    /**
     This method used to set the cornerRadius for CometChatBadgeCount class
     - Parameter cornerRadius: This specifies a float value  which sets corner radius.
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     - See Also:
     [CometChatBadgeCount Documentation](https://prodocs.cometchat.com/docs/ios-ui-components#section-3-badge-count)
     */
    @discardableResult
    @objc  func set(cornerRadius : CGFloat) -> CometChatBadgeCount {
        self.radius = cornerRadius
        return self
    }
    
    /**
     This method used to set the count for CometChatBadgeCount class
     - Parameter count: This specifies a Int value  which sets count .
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     - See Also:
     [CometChatBadgeCount Documentation](https://prodocs.cometchat.com/docs/ios-ui-components#section-3-badge-count)
     */
    @discardableResult
    @objc  func set(count : Int) -> CometChatBadgeCount {
        if count >=  1 && count < 999 {
            self.isHidden = false
            self.text = "\(count)"
            
        }else if count > 999 {
            self.isHidden = false
            self.text = "999+"
            
        }else{
            self.text = "0"
            self.isHidden = true
            
        }
        return self
    }
    
    
    /**
        This method used to increment the count for CometChatBadgeCount class
        - Parameter count: This specifies a Int value  which sets count .
        - Author: CometChat Team
        - Copyright:  ©  2022 CometChat Inc.
        - See Also:
        [CometChatBadgeCount Documentation](https://prodocs.cometchat.com/docs/ios-ui-components#section-3-badge-count)
        */
    @discardableResult
    @objc  public func incrementCount() -> CometChatBadgeCount {
        let currentCount = self.getCount
        self.set(count: currentCount + 1)
        self.isHidden = false
       return self
    }
    
    @discardableResult
    @objc  public func removeCount() -> CometChatBadgeCount {
        self.text = "0"
        self.isHidden = true
        return self
    }
    
    @discardableResult
    @objc  func set(configuration : BadgeCountConfiguration) -> CometChatBadgeCount {
        self.set(cornerRadius: configuration.cornerRadius)
        return self
    }
    
    
    deinit {
       
    }
}

/*  ----------------------------------------------------------------------------------------- */



