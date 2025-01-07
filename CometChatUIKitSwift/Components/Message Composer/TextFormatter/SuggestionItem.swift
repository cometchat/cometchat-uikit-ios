//
//  ListItemModel.swift
//  CometChatUIKitSwift
//
//  Created by SuryanshBisen on 04/03/24.
//

import Foundation
import CometChatSDK

open class SuggestionItem {
    
    public var id: String?
    public var name: String?
    public var visibleText: String?
    public var underlyingText: String?
    public var status: UserStatus = .offline
    public var visibleTextAttributes: [NSAttributedString.Key : Any]?
    public var data: [String: Any]?
    public var listItemStyle: ListItemStyle?
    public var leftIconStyle: AvatarStyle?
    public var hideLeftIcon = false
    public var leftIconUrl: String?
    public var leftIconImage: UIImage?
    public var statusIndicatorStyle: StatusIndicatorStyle = CometChatStatusIndicator.style
        
    public init(
        id: String? = nil,
        name: String? = nil,
        leftIconUrl: String? = nil,
        visibleText: String? = nil,
        underlyingText: String? = nil,
        data: [String : Any]? = nil,
        listItemStyle: ListItemStyle? = nil,
        visibleTextAttributes: [NSAttributedString.Key : Any]? = nil,
        status: UserStatus = .offline,
        hideLeftIcon: Bool = false,
        leftIconImage: UIImage? = nil
    ) {
        self.id = id
        self.name = name
        self.leftIconUrl = leftIconUrl
        self.visibleText = visibleText
        self.underlyingText = underlyingText
        self.data = data
        self.visibleTextAttributes = visibleTextAttributes
        self.status = status
        self.hideLeftIcon = hideLeftIcon
        self.leftIconImage = leftIconImage
    }
}
