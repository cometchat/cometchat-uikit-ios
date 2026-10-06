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
    var imageRequest: Cancellable?
    private lazy var imageService = ImageService()
    
    //MARK: Styling
    public static var style = AvatarStyle() //global styling
    public lazy var style = CometChatAvatar.style //component level styling
    
    // MARK: - Initialization of required Methods
    public convenience init() {
        self.init(frame: .zero)
    }
    
    public override init(image: UIImage?) { 
        super.init(image: image)
        hasSuppliedImage = image != nil
        setupThemeObserver()
    }
    
    public override init(frame: CGRect) { 
        super.init(frame: frame)
        setupThemeObserver()
    }
    
    required init?(coder aDecoder: NSCoder) { 
        super.init(coder: aDecoder)
        setupThemeObserver()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("CometChatThemeChanged"), object: nil)
    }
    
    private func setupThemeObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleThemeChange),
            name: NSNotification.Name("CometChatThemeChanged"),
            object: nil
        )
    }
    
    @objc private func handleThemeChange() {
        // Directly update visual properties from the current style
        // The style's computed properties will fetch the latest theme colors
        self.backgroundColor = style.backgroundColor
        if !hasSuppliedImage && (avatarURL == nil || avatarURL?.isEmpty == true) {
            setAvatar(avatarUrl: avatarURL, with: name)
        }
    }
    
    
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
        // A caller-supplied image has no url or name to redraw from, so leave it alone.
        // Everything else redraws, including an avatar given nothing, whose placeholder
        // must pick up the current theme's colour.
        if !hasSuppliedImage {
            setAvatar(avatarUrl: avatarURL, with: name)
        }
    }
    
    /// True while the image on screen came from `set(image:)` or `init(image:)`.
    private var hasSuppliedImage = false
    
    @discardableResult
    @objc public func set(image: UIImage) -> Self {
        imageRequest?.cancel()
        avatarURL = nil
        name = nil
        hasSuppliedImage = true
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
        hasSuppliedImage = false
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
            // A cancelled or cached load still completes; drop it if the avatar moved on.
            guard let this = self, this.avatarURL == avatarUrl else { return }
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
        
        var attributes = textAttributes
        
        // Text
        if let text = text?.initials {
            var textSize = text.size(withAttributes: attributes)
            let bounds = view.bounds
            // Dynamic Type can grow the font past the avatar; shrink the initials to fit.
            let fitWidth = bounds.width * 0.75, fitHeight = bounds.height * 0.75
            if let font = attributes[.font] as? UIFont, textSize.width > fitWidth || textSize.height > fitHeight {
                let ratio = min(fitWidth / max(textSize.width, 1), fitHeight / max(textSize.height, 1))
                attributes[.font] = font.withSize(max(1, font.pointSize * ratio))
                textSize = text.size(withAttributes: attributes)
            }
            let rect = CGRect(x: bounds.size.width/2 - textSize.width/2, y: bounds.size.height/2 - textSize.height/2, width: textSize.width, height: textSize.height)
            
            text.draw(in: rect, withAttributes: attributes)
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }


}

/*  ----------------------------------------------------------------------------------------- */

