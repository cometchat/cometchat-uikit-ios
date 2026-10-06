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
        
    public static var style = StatusIndicatorStyle() //global styling
    public lazy var style = CometChatStatusIndicator.style //component level styling

    var imageView = UIImageView()
    
    // MARK: - Initialization of required Methods
    func setup() {
        self.backgroundColor =  style.backgroundColor
        // Drawn over the background colour and under any status icon; the corner rounding
        // below masks it to the dot.
        layer.contents = style.backgroundImage?.cgImage
        layer.contentsGravity = .resizeAspectFill
        borderWith(width: style.borderWidth)
        borderColor(color: style.borderColor)
        if let cornerRadius = style.cornerRadius, cornerRadius.cornerRadius != -1 {
            roundViewCorners(corner: cornerRadius)
        } else {
            roundViewCorners(corner: .init(cornerRadius: (bounds.width/2)))
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.setup()
    }
    
    @discardableResult
    public func set(status: CometChatSDK.UserStatus, backgroundColor: UIColor? = nil) -> Self {
        switch status {
        case .online, .available:
            self.isHidden = false
        case .offline:
            self.isHidden = true
        default: break
        }
        // Store the colour on the style: setup() repaints from style on every layout pass.
        if let backgroundColor = backgroundColor {
            style.backgroundColor = backgroundColor
            self.backgroundColor = backgroundColor
        }
        return self
    }
    
    @discardableResult
    @objc  public func set(icon: UIImage?, with tintColor: UIColor) -> CometChatStatusIndicator {
        self.addSubview(imageView)
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.pin(anchors: [.centerX, .centerY], to: self)
        self.imageView.widthAnchor.pin(equalTo: self.widthAnchor, multiplier: 0.6).isActive = true
        self.imageView.heightAnchor.pin(equalTo: self.heightAnchor, multiplier: 0.6).isActive = true
        self.imageView.image = icon?.withRenderingMode(.alwaysTemplate)
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.tintColor = tintColor
        return self
    }

    // MARK: - Accessibility

    private var explicitIsAccessibilityElement: Bool?
    private var explicitAccessibilityLabel: String?

    /// A visible plain dot (no glyph) is the presence dot, and it only shows while the
    /// user is online. Hosts toggle `isHidden` directly as well as through
    /// `set(status:)`, so this is read at the moment VoiceOver asks.
    private var showsPresenceDot: Bool {
        guard !isHidden else { return false }
        guard let glyph = imageView.image else { return true }
        return glyph.size == .zero
    }

    /// The dot is otherwise colour alone, so VoiceOver reads it as "Online".
    public override var isAccessibilityElement: Bool {
        get { explicitIsAccessibilityElement ?? showsPresenceDot }
        set { explicitIsAccessibilityElement = newValue }
    }

    public override var accessibilityLabel: String? {
        get { explicitAccessibilityLabel ?? (showsPresenceDot ? "ONLINE".localize() : nil) }
        set { explicitAccessibilityLabel = newValue }
    }
}

/*  ----------------------------------------------------------------------------------------- */


