//
//  File.swift
//
//
//  Created by Pushpsen Airekar on 20/09/22.
//

import Foundation
import UIKit
import CometChatSDK

public struct CometChatDetailsTemplate: Hashable {
    
    var id: String?
    var title: String?
    var titleFont: UIFont?
    var titleColor: UIColor?
    var itemSeparatorColor: UIColor?
    var hideItemSeparator: Bool?
    var customView: UIView?
    var options: ((_ user: User?, _ group: Group?) -> [CometChatDetailsOption])?
    
    public init() {}
    
    public init(id: String?, title: String?, titleFont: UIFont?, titleColor: UIColor?, itemSeparatorColor: UIColor?,
                hideItemSeparator: Bool?, customView: UIView?, options: ((_ user: User?, _ group: Group?) -> [CometChatDetailsOption])?) {
        self.id = id
        self.title = title
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.itemSeparatorColor = itemSeparatorColor
        self.hideItemSeparator = hideItemSeparator
        self.customView = customView
        self.options = options
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
}
