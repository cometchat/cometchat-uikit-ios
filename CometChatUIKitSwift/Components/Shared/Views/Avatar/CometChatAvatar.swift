//  CometChatAvatar.swift
 
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2022 CometChat Inc. All rights reserved.

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
 CometChatAvatar: This component will be the class of UIImageView which is customizable to display CometChatAvatar.
 
 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  */


// MARK: - Importing Frameworks.

import Foundation
import  UIKit
import AVFAudio


/*  ----------------------------------------------------------------------------------------- */

@IBDesignable
@objc public class CometChatAvatar: UIImageView {
    
    // MARK: - Declaration of IBInspectable
    let context = UIGraphicsGetCurrentContext()
    var rectangle : CGRect?
    
    // MARK: - Variable declaration.
    private var avatarURL: String?
    private var name: String?
    private var imageRequest: Cancellable?
    private lazy var imageService = ImageService()
    
    //MARK: Styling
    public static var style = AvatarStyle() //global styling
    public lazy var style = CometChatAvatar.style //component level styling
    
    // MARK: - Initialization of required Methods
    public override init(image: UIImage?) { super.init(image: image) }
    public override init(frame: CGRect) { super.init(frame: frame) }
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    
    public override func layoutSubviews() {
        setUpStyle()
        super.layoutSubviews()
    }
    
    open func setUpStyle() {
        self.layer.borderColor = style.borderColor.cgColor
        self.backgroundColor = style.backgroundColor
        if let cornerRadius = style.cornerRadius, cornerRadius.cornerRadius != -1 {
            self.roundViewCorners(corner: cornerRadius)
        } else {
            self.layer.cornerRadius = self.bounds.width / 2
        }
        self.layer.borderWidth = style.borderWidth
        self.clipsToBounds = true
        setAvatar(avatarUrl: avatarURL, with: name)
    }
    
    @discardableResult
    @objc public func set(image: UIImage) -> Self {
        self.image = image
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
    public func setAvatar(avatarUrl: String? = nil, with name: String? = nil) -> CometChatAvatar {
        self.avatarURL = avatarUrl
        self.name = name
        
        guard  let url = URL(string: avatarURL ?? "") else {
            setImageSnap(
               text: name?.uppercased(),
               color: style.backgroundColor,
               textAttributes: [
                   NSAttributedString.Key.font: style.textFont,
                   NSAttributedString.Key.foregroundColor: style.textColor
               ]
            )
            return self
        }
        
        imageRequest?.cancel()
        imageRequest = imageService.image(for: url, cacheType: .avatar) { [weak self] image in
            guard let this = self else { return }
            // Update Thumbnail Image View
            if let image = image {
                this.image = image
             } else {
                 this.setImageSnap(
                    text: this.name?.uppercased(),
                    color: this.style.backgroundColor,
                    textAttributes: [
                        NSAttributedString.Key.font: this.style.textFont,
                        NSAttributedString.Key.foregroundColor: this.style.textColor
                    ]
                 )
            }
        }
        
        return self
    }
    
    //Setting Names initials as avatar
    private func setImageSnap(text: String?,
                           color: UIColor,
                           textAttributes: [NSAttributedString.Key: Any]) {
        self.image = AvatarUtils.setImageSnap(text: text, color: color, textAttributes: textAttributes, view: self)
    }
    
    public func cancel() {
        /// This method will cancel the request.
        imageRequest?.cancel()
    }
    
    public func reset() {
        image = nil
        name = nil
        avatarURL = nil
        imageRequest?.cancel()
    }
    
}


extension String {
    
    var initials: String {
        
        let words = components(separatedBy: .whitespacesAndNewlines)
        
        //to identify letters
        let letters = CharacterSet.alphanumerics
        var firstChar : String = ""
        var secondChar : String = ""
        var firstCharFoundIndex : Int = -1
        var firstCharFound : Bool = false
        var secondCharFound : Bool = false
        
        for (index, item) in words.enumerated() {
            
            if item.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                continue
            }
            
            //browse through the rest of the word
            for (_, char) in item.unicodeScalars.enumerated() {
                
                //check if its a aplha
                if letters.contains(char) {
                    
                    if !firstCharFound {
                        firstChar = String(char)
                        firstCharFound = true
                        firstCharFoundIndex = index
                        
                    } else if !secondCharFound {
                        
                        secondChar = String(char)
                        if firstCharFoundIndex != index {
                            secondCharFound = true
                        }
                        
                        break
                    } else {
                        break
                    }
                }
            }
        }
        if firstChar.isEmpty && secondChar.isEmpty {
            firstChar = "\(self.first ?? "?")"
        }
        return firstChar + secondChar
    }
}

public class AvatarUtils {
    
    public static func setImageSnap(
        text: String?,
        color: UIColor,
        textAttributes: [NSAttributedString.Key: Any],
        view: UIImageView
    ) -> UIImage? {
        guard view.bounds.size.width > 0 && view.bounds.size.height > 0 else { return nil }
        
        let scale = Float(UIScreen.main.scale)
        var size = view.bounds.size
        if view.contentMode == .scaleToFill || view.contentMode == .scaleAspectFill || view.contentMode == .scaleAspectFit || view.contentMode == .redraw {
            size.width = CGFloat(floorf((Float(size.width) * scale) / scale))
            size.height = CGFloat(floorf((Float(size.height) * scale) / scale))
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, CGFloat(scale))
        
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        let attributes = textAttributes
        
        // Text
        if let text = text?.initials {
            let textSize = text.size(withAttributes: attributes)
            let bounds = view.bounds
            let rect = CGRect(x: bounds.size.width/2 - textSize.width/2, y: bounds.size.height/2 - textSize.height/2, width: textSize.width, height: textSize.height)
            
            text.draw(in: rect, withAttributes: attributes)
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }

}

/*  ----------------------------------------------------------------------------------------- */

