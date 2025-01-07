//
//  CometChatMessageComposerAction.swift
//  
//
//  Created by Ajay Verma on 22/12/22.
//

import Foundation
import UIKit

public class CometChatMessageComposerAction: NSObject {
    
    public var id: String?
    public var text: String?
    public var startIcon: UIImage?
    public var endIcon: UIImage?
    public var startIconTint: UIColor?
    public var endIconTint: UIColor?
    public var textColor: UIColor?
    public var textFont: UIFont?
    public var backgroundColour: UIColor?
    public var borderRadius: CometChatCornerStyle?
    public var borderWidth: CGFloat?
    public var borderColor: UIColor?
    public var onActionClick: (() -> ())?
        
    //Initialiser for default options
    public init(
        id: String?,
        text: String?,
        startIcon: UIImage?,
        endIcon: UIImage? = nil,
        startIconTint: UIColor? ,
        endIconTint: UIColor? = nil,
        textColor: UIColor?,
        textFont: UIFont?,
        backgroundColour: UIColor? = nil,
        borderRadius: CometChatCornerStyle? = nil,
        borderWidth: CGFloat? = nil,
        borderColor: UIColor? = nil,
        onActionClick: (() -> ())? = nil
    ) {
        self.id = id
        self.text = text
        self.startIcon = startIcon
        self.endIcon = endIcon
        self.startIconTint = startIconTint
        self.endIconTint = endIconTint
        self.textColor = textColor
        self.textFont = textFont
        self.backgroundColour = backgroundColour
        self.borderRadius = borderRadius
        self.borderWidth = borderWidth
        self.borderColor = borderColor
        self.onActionClick = onActionClick
    }
}
