//  CometChatAvatar.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
 CometChatAvatar: This component will be the class of UIImageView which is customizable to display CometChatAvatar.
 
 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  */


// MARK: - Importing Frameworks.

import Foundation
import  UIKit
import  CometChatPro


/*  ----------------------------------------------------------------------------------------- */

@IBDesignable
@objc class CometChatAvatar: UIImageView {
    
    // MARK: - Declaration of IBInspectable
    
    @IBInspectable var cornerRadius: CGFloat = 0
    @IBInspectable var borderColor: UIColor = UIColor.lightGray
    @IBInspectable var borderWidth: CGFloat = 0.5
    
    // MARK: - Initialization of required Methods
    
    override init(image: UIImage?) { super.init(image: image) }  
    override init(frame: CGRect) { super.init(frame: frame) }
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    // MARK: - Variable declaration.
    private var imageRequest: Cancellable?
    private lazy var imageService = ImageService()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = cornerRadius
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = borderWidth
        self.backgroundColor = UIKitSettings.primaryColor.withAlphaComponent(0.5)
        self.clipsToBounds = true
    }
    
    // MARK: - instance methods
    
    /**
     This method used to set the cornerRadius for CometChatAvatar class
     - Parameter cornerRadius: This specifies a float value  which sets corner radius.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatAvatar Documentation](https://prodocs.cometchat.com/docs/ios-ui-components#section-1-avatar)
     */
    @objc func set(cornerRadius : CGFloat) -> CometChatAvatar {
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
        return self
    }
    
    /**
     This method used to set the borderColor for CometChatAvatar class
     - Parameter borderColor: This specifies a `UIColor` for border of the CometChatAvatar.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatAvatar Documentation](https://prodocs.cometchat.com/docs/ios-ui-components#section-1-avatar)
     */
    @objc func set(borderColor : UIColor) -> CometChatAvatar {
        self.layer.borderColor = borderColor.cgColor
        return self
    }
    
    /**
     This method used to set the backgroundColor for Avatar class
     - Parameter borderColor: This specifies a `UIColor` for border of the Avatar.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [Avatar Documentation](https://prodocs.cometchat.com/docs/ios-ui-components#section-1-avatar)
     */
    @objc func set(backgroundColor : UIColor) -> CometChatAvatar {
        self.backgroundColor = backgroundColor
        return self
    }
    
    /**
     This method used to set the borderWidth for CometChatAvatar class
     - Parameter borderWidth: This specifies a `CGFloat` for border width of the CometChatAvatar.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [Avatar Documentation](https://prodocs.cometchat.com/docs/ios-ui-components#section-1-avatar)
     */
    @objc func set(borderWidth : CGFloat) -> CometChatAvatar {
        self.layer.borderWidth = borderWidth
        return self
    }
    
    
    /**
     This method used to set the image for CometChatAvatar class
     - Parameter image: This specifies a `URL` for  the CometChatAvatar.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [Avatar Documentation](https://prodocs.cometchat.com/docs/ios-ui-components#section-1-avatar)
     */
    @objc func set(image: String?, with name: String? = nil) {
        /// This method is for set the name label to the image view.
        setImage(string: name?.uppercased() ?? "")
        if let urlString = image, let url = URL(string: urlString) {
            /// This method will fetch the image from remote.
            imageRequest = imageService.image(for: url) { [weak self] image in
                guard let strongSelf = self else { return }
                // Update Thumbnail Image View
                if let image = image {
                    strongSelf.image = image
                }else{
                    strongSelf.setImage(string: name?.uppercased() ?? "")
                }
            }
        }
    }

    @objc func cancel() {
        /// This method will cancel the request.
        imageRequest?.cancel()
    }
    
    @objc func set(entity: AppEntity) {
        
        if let user = entity as? CometChatPro.User {
            setImage(string: user.name?.uppercased() ?? "")
            if  let url = URL(string: user.avatar ?? "") {
                /// This method will fetch the image from remote.
                imageRequest = imageService.image(for: url) { [weak self] image in
                    guard let strongSelf = self else { return }
                    // Update Thumbnail Image View
                    if let image = image {
                        strongSelf.image = image
                    }else{
                        strongSelf.setImage(string: user.name?.uppercased() ?? "")
                    }
                }
            }
        }
        
        if let group = entity as? CometChatPro.Group {
            setImage(string: group.name?.uppercased() ?? "")
            if let url = URL(string: group.icon ?? "") {
                /// This method will fetch the image from remote.
                imageRequest = imageService.image(for: url) { [weak self] image in
                    guard let strongSelf = self else { return }
                    // Update Thumbnail Image View
                    if let image = image {
                        strongSelf.image = image
                    }else{
                        strongSelf.setImage(string: group.name?.uppercased() ?? "")
                    }
                }
            }
        }
    }
}

/*  ----------------------------------------------------------------------------------------- */
