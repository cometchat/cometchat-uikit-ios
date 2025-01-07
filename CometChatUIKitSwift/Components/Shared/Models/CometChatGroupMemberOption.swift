//
//  File.swift
//
//
//  Created by Pushpsen Airekar on 20/09/22.
//

import Foundation
import UIKit
import CometChatSDK

public class CometChatUserOption: CometChatOption {
    
    var titleColor: UIColor?
    var titleFont: UIFont?
    var iconTint: UIColor?
    var backgroundColor: UIColor?
    var onClick: ((_ user: User?, _ section: Int, _ option: CometChatUserOption, _ controller: UIViewController?) -> ())?
    
    public init(titleColor: UIColor? , titleFont: UIFont?, iconTint: UIColor?, backgroundColor: UIColor?, onClick: ( (_: User?, _: Int, _: CometChatUserOption, _: UIViewController?) -> Void)?) {
        self.titleColor = titleColor
        self.titleFont = titleFont
        self.iconTint = iconTint
        self.backgroundColor = backgroundColor
        self.onClick = onClick
    }
    
}

public class CometChatConversationOption: CometChatOption {
    
    var titleColor: UIColor?
    var titleFont: UIFont?
    var iconTint: UIColor?
    var backgroundColor: UIColor?
    var onClick: ((_ user: User?, _ section: Int, _ option: CometChatConversationOption, _ controller: UIViewController?) -> ())?
    
    public init(title : String, titleColor: UIColor?, icon: UIImage? , titleFont: UIFont?, iconTint: UIColor?, backgroundColor: UIColor?, onClick: ( (_: User?, _: Int, _: CometChatConversationOption, _: UIViewController?) -> Void)?) {
        super.init()
        self.titleColor = titleColor
        self.titleFont = titleFont
        self.iconTint = iconTint
        self.backgroundColor = backgroundColor
        self.onClick = onClick
        self.icon = icon
        self.title = title
    }
    
}

public class CometChatGroupOption: CometChatOption {
    
    var titleColor: UIColor?
    var titleFont: UIFont?
    var iconTint: UIColor?
    var backgroundColor: UIColor?
    var onClick: ((_ group: Group?, _ section: Int, _ option: CometChatGroupOption, _ controller: UIViewController?) -> ())?
    
    public init(titleColor: UIColor?, titleFont: UIFont?, iconTint: UIColor?, backgroundColor: UIColor?, onClick: ( (_: Group?, _: Int, _: CometChatGroupOption, _: UIViewController?) -> Void)?) {
        self.titleColor = titleColor
        self.titleFont = titleFont
        self.iconTint = iconTint
        self.backgroundColor = backgroundColor
        self.onClick = onClick
    }
}

public class CometChatCallOption: CometChatOption {
    
    var titleColor: UIColor?
    var titleFont: UIFont?
    var iconTint: UIColor?
    var backgroundColor: UIColor?
    var onClick: ((_ call: BaseMessage?, _ section: Int, _ option: CometChatCallOption, _ controller: UIViewController?) -> ())?
    
    public init(titleColor: UIColor?, titleFont: UIFont?, iconTint: UIColor?, backgroundColor: UIColor?, onClick: ( (_: BaseMessage?, _: Int, _: CometChatCallOption, _: UIViewController?) -> Void)?) {
        self.titleColor = titleColor
        self.titleFont = titleFont
        self.iconTint = iconTint
        self.backgroundColor = backgroundColor
        self.onClick = onClick
    }
}



public class CometChatGroupMemberOption: CometChatOption {
    
    public var titleColor: UIColor?
    public var titleFont: UIFont?
    public var backgroundColor: UIColor?
    
    public var onClick: ((_ groupMember: GroupMember?, _ group: Group?, _ section: Int, _ option: CometChatGroupMemberOption, _ controller: UIViewController?) -> ())?

    public init(id: String?, title: String?, icon: UIImage?, backgroundColor: UIColor?, onClick: ((_ groupMember: GroupMember?, _ group: Group?, _ section: Int, _ option: CometChatGroupMemberOption, _ controller: UIViewController?) -> ())?) {
        super.init()
        self.id = id
        self.title = title
        self.onClick = onClick
        self.icon = icon
        self.backgroundColor = backgroundColor
    }
}



        
       
