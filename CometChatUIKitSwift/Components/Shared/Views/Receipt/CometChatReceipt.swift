//  CometChatAvatar.swift
 
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2022 CometChat Inc. All rights reserved.

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
 CometChatAvatar: This component will be the class of UIImageView which is customizable to display CometChatReceipt.
 
 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  */


// MARK: - Importing Frameworks.

import Foundation
import  UIKit

/*  ----------------------------------------------------------------------------------------- */

@IBDesignable
@objc public final class CometChatReceipt: UIImageView {
    
    public static var style = ReceiptStyle() //global styling
    public lazy var style = CometChatReceipt.style //component level styling
    
    var disableReceipt: Bool = false

    // MARK: - Initializers
    override public init(image: UIImage?) {
        super.init(image: image)
    }

    public init() {
        super.init(image: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.pin(anchors: [.height, .width], to: 16)
    }

    @discardableResult
    public func disable(receipt: Bool) -> Self {
        disableReceipt = receipt
        return self
    }

    @discardableResult
    public func set(receipt status: ReceiptStatus, tintColor: UIColor? = nil) -> Self {
        guard !disableReceipt else {
            self.isHidden = true
            return self
        }
        
        self.isHidden = false
        switch status {
        case .failed:
            self.image = style.errorImage
            self.tintColor = style.errorImageTintColor
        case .delivered:
            self.image = style.deliveredImage
            self.tintColor = style.deliveredImageTintColor
        case .inProgress:
            self.image = style.waitImage
            self.tintColor = style.waitImageTintColor
        case .read:
            self.image = style.readImage
            self.tintColor = style.readImageTintColor
        case .sent:
            self.image = style.sentImage
            self.tintColor = style.sentImageTintColor
        }
        self.contentMode = .scaleAspectFit
        return self
    }
}

