//
//  ConversationHelper.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 27/09/24.
//

import UIKit
import Foundation

internal func addImageToText(text: String, image: String, additionalConfiguration: AdditionalConfiguration) -> NSMutableAttributedString{
    let text = text
    let imageName = image

    let image = UIImage(named: imageName, in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate).withTintColor(additionalConfiguration.conversationsStyle.messageTypeImageTint) ?? UIImage()

    let imageAttachment = NSTextAttachment()
    imageAttachment.image = image
    
    let imageOffsetY: CGFloat = -3.0
    imageAttachment.bounds = CGRect(x: 0, y: imageOffsetY, width: 16, height: 16)

    let imageString = NSAttributedString(attachment: imageAttachment)
    
    let textString = NSMutableAttributedString(string: text, attributes: [.font: additionalConfiguration.conversationsStyle.listItemSubTitleFont])
    
    let finalAttributedString = NSMutableAttributedString()
    finalAttributedString.append(imageString)
    finalAttributedString.append(NSAttributedString(string: " "))
    finalAttributedString.append(textString)

    return finalAttributedString
}
