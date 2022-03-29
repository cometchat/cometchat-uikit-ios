//  CometChatAvatar.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2022 CometChat Inc. All rights reserved.

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
 CometChatAvatar: This component will be the class of UIImageView which is customizable to display CometChatAvatar.
 
 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  */


// MARK: - Importing Frameworks.

import Foundation
import  UIKit
import  CometChatPro
import AVFAudio


/*  ----------------------------------------------------------------------------------------- */

@IBDesignable
@objc public class CometChatAvatar: UIImageView {
    
    // MARK: - Declaration of IBInspectable
    let context = UIGraphicsGetCurrentContext()
    var rectangle : CGRect?
    
    @IBInspectable var setOuterView: Bool = false
    @IBInspectable var cornerRadius: CGFloat = 0
    @IBInspectable var borderColor: UIColor = UIColor.clear
    @IBInspectable var borderWidth: CGFloat = 0.5
    @IBInspectable var setBackgroundColor: UIColor =  CometChatTheme.palatte?.primary ?? UIColor.clear
    
    @IBInspectable var setFont: UIFont = CometChatTheme.typography?.Name1 ?? UIFont.systemFont(ofSize: 20, weight: .medium)
    @IBInspectable var setFontColor: UIColor = CometChatTheme.palatte?.background ?? UIColor.white
    
    
    // MARK: - Initialization of required Methods
    override init(image: UIImage?) { super.init(image: image) }
    override init(frame: CGRect) { super.init(frame: frame) }
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.borderColor = borderColor.cgColor
        self.backgroundColor = setBackgroundColor
        self.layer.cornerRadius = cornerRadius
        self.layer.borderWidth = borderWidth
        self.clipsToBounds = true
    }
    // MARK: - instance methods
    
    /**
     This method used to set the cornerRadius for CometChatAvatar class
     - Parameter cornerRadius: This specifies a float value  which sets corner radius.
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     - See Also:
     [CometChatAvatar Documentation](https://prodocs.cometchat.com/docs/ios-ui-components#section-1-avatar)
     */
    @discardableResult
    @objc func set(cornerRadius : CGFloat) -> CometChatAvatar {
        self.cornerRadius = cornerRadius
        self.clipsToBounds = true
        return self
    }
    
    /**
     This method used to set the borderColor for CometChatAvatar class
     - Parameter borderColor: This specifies a `UIColor` for border of the CometChatAvatar.
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     - See Also:
     [CometChatAvatar Documentation](https://prodocs.cometchat.com/docs/ios-ui-components#section-1-avatar)
     */
    @discardableResult
    @objc func set(borderColor : UIColor) -> CometChatAvatar {
        self.borderColor = borderColor
        return self
    }
    
    @discardableResult
    @objc func set(font : UIFont) -> CometChatAvatar {
        self.setFont = font
        return self
    }
    
    @discardableResult
    @objc func set(fontColor: UIColor) -> CometChatAvatar {
        self.setFontColor = fontColor
        return self
    }
    
    
    /**
     This method used to set the backgroundColor for Avatar class
     - Parameter borderColor: This specifies a `UIColor` for border of the Avatar.
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     - See Also:
     [Avatar Documentation](https://prodocs.cometchat.com/docs/ios-ui-components#section-1-avatar)
     */
    @discardableResult
    @objc func set(backgroundColor : UIColor) -> CometChatAvatar {
        self.setBackgroundColor = backgroundColor
        return self
    }
    
    /**
     This method used to set the borderWidth for CometChatAvatar class
     - Parameter borderWidth: This specifies a `CGFloat` for border width of the CometChatAvatar.
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     - See Also:
     [Avatar Documentation](https://prodocs.cometchat.com/docs/ios-ui-components#section-1-avatar)
     */
    @discardableResult
    @objc func set(borderWidth : CGFloat) -> CometChatAvatar {
        self.borderWidth = borderWidth
        return self
    }
    
    
    /**
     This method used to set the image for CometChatAvatar class
     - Parameter image: This specifies a `URL` for  the CometChatAvatar.
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     - See Also:
     [Avatar Documentation](https://prodocs.cometchat.com/docs/ios-ui-components#section-1-avatar)
     */
    @discardableResult
    @objc func setAvatar(avatarUrl: String) -> CometChatAvatar {
        
        let url = URL(string: avatarUrl)
        self.cf.setImage(with: url, placeholder: UIImage(named: "defaultAvatar.jpg", in: Bundle.main , compatibleWith: nil))
        self.set(outerView: setOuterView)
        return self
    }
    
    @discardableResult
    @objc func setAvatar(avatarUrl: String, with name: String) -> CometChatAvatar {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            let url = URL(string: avatarUrl)
            let imageView  = UIImageView(frame: strongSelf.frame)
            imageView.setImage(string: name.uppercased(), color: strongSelf.setBackgroundColor, textAttributes: [ NSAttributedString.Key.font: strongSelf.setFont, NSAttributedString.Key.foregroundColor: strongSelf.setFontColor])
            strongSelf.cf.setImage(with: url, placeholder: imageView.image)
            strongSelf.set(outerView: strongSelf.setOuterView)
        }
        return self
    }
    
    @discardableResult
    @objc func setAvatar(user: User) -> CometChatAvatar {
        
        let url = URL(string: user.avatar ?? "")
        let imageView  = UIImageView(frame: self.frame)
        imageView.setImage(string: user.name?.uppercased())
        self.cf.setImage(with: url, placeholder: imageView.image)
        self.set(outerView: setOuterView)
        return self
    }
    
    @discardableResult
    @objc func setAvatar(group: Group) -> CometChatAvatar {
        let url = URL(string: group.icon ?? "")
        let imageView  = UIImageView(frame: self.frame)
        imageView.setImage(string: group.name?.uppercased())
        self.cf.setImage(with: url, placeholder: imageView.image)
        self.set(outerView: setOuterView)
        return self
    }
    
    @discardableResult
    @objc func set(outerView: Bool) -> CometChatAvatar {
        if outerView == true {
        self.layer.borderWidth = 5.0
        self.layer.borderColor = setBackgroundColor.cgColor
        self.layer.cornerRadius = self.frame.width / 2

        let borderLayer = CALayer()
        borderLayer.frame = self.bounds
        borderLayer.borderColor = UIColor.white.cgColor
        borderLayer.borderWidth = 5
        borderLayer.cornerRadius = borderLayer.frame.width / 2
        self.layer.insertSublayer(borderLayer, above: self.layer)
        }
        return self
    }
    
    @discardableResult
    public func set(configuration: AvatarConfiguration)  -> CometChatAvatar {
        self.set(cornerRadius: configuration.cornerRadius)
        self.set(borderWidth: configuration.borderWidth)
        return self
    }

    
    
  
}

/*  ----------------------------------------------------------------------------------------- */

