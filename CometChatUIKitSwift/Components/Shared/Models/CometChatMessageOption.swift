//
//  CometChatMessageOption.swift
 
//
//  Created by Pushpsen Airekar on 27/01/22.
//

import UIKit
import CometChatSDK


protocol CometChatMessageOptionDelegate: AnyObject {
    func onItemClick(messageOption: CometChatMessageOption, forMessage: BaseMessage?, indexPath: IndexPath?)
}

public struct MessageOptionStyle {
    public var imageTintColor = CometChatTheme.iconColorPrimary
    public var backgroundColor = CometChatTheme.backgroundColor01.withAlphaComponent(0.8)
    public var titleColor: UIColor = CometChatTheme.textColorPrimary
    public var titleFont: UIFont = CometChatTypography.Body.regular
}

public struct  CometChatMessageOption: Hashable {
    
    public let id: String
    public let title: String
    public let icon: UIImage?
    public let packageName: String? = UIConstants.packageName
    public let overrideDefaultAction: Bool? = false
    public var onItemClick: ((_ message: BaseMessage?) -> Void)?
    public var style: MessageOptionStyle = MessageOptionStyle()
    
    public init(
        id: String,
        title: String,
        icon: UIImage?,
        style: MessageOptionStyle? = nil,
        onItemClick: ( (_: BaseMessage?) -> Void)? = nil
    ) {
        self.id = id
        self.title = title
        self.icon = icon
        self.onItemClick = onItemClick
        if let style = style { self.style = style }
    }
    
    public static func == (lhs: CometChatMessageOption, rhs: CometChatMessageOption) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
}

