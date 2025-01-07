//
//  CometChatMessageTemplate.swift
 
//
//  Created by Pushpsen Airekar on 19/01/22.
//

import Foundation
import CometChatSDK
import UIKit

public struct CometChatMessageTemplate {
    
    public var category: String
    public var type: String
    public var contentView: ((_ message: BaseMessage?, _ alignment: MessageBubbleAlignment, _ controller: UIViewController?) -> (UIView)?)?
    public var bubbleView: ((_ message: BaseMessage?, _ alignment: MessageBubbleAlignment, _ controller: UIViewController?) -> (UIView)?)? = nil
    public var headerView: ((_ message: BaseMessage?, _ alignment:  MessageBubbleAlignment, _ controller: UIViewController?) -> (UIView)?)? = nil
    public var footerView: ((_ message: BaseMessage?, _ alignment: MessageBubbleAlignment, _ controller: UIViewController?) -> (UIView)?)? = nil
    public var bottomView: ((_ message: BaseMessage?, _ alignment: MessageBubbleAlignment, _ controller: UIViewController?) -> (UIView)?)? = nil
    public var options: ((_ message: BaseMessage?, _ group: Group?, _ controller: UIViewController?) -> ([CometChatMessageOption]?))? = nil
    public var statusInfoView: ((_ message: BaseMessage?, _ alignment:  MessageBubbleAlignment, _ controller: UIViewController?) -> UIView?)? = nil
    
    public init(
        category: String,
        type: String,
        contentView: ( (_: BaseMessage?, _: MessageBubbleAlignment, _: UIViewController?) -> UIView?)?,
        bubbleView: ( (_: BaseMessage?, _: MessageBubbleAlignment, _: UIViewController?) -> UIView?)?,
        headerView: ( (_: BaseMessage?, _: MessageBubbleAlignment, _: UIViewController?) -> UIView?)? ,
        footerView: ( (_: BaseMessage?, _: MessageBubbleAlignment, _: UIViewController?) -> UIView?)?,
        bottomView: ( (_: BaseMessage?, _: MessageBubbleAlignment, _: UIViewController?) -> UIView?)?,
        options: ( (_: BaseMessage?, _: Group?, _: UIViewController?) -> [CometChatMessageOption]?)?,
        statusInfoView: ((_ : BaseMessage?, _:  MessageBubbleAlignment, _: UIViewController?) -> UIView?)? = nil
    ) {
        self.category = category
        self.type = type
        self.contentView = contentView
        self.bubbleView = bubbleView
        self.headerView = headerView
        self.footerView = footerView
        self.bottomView = bottomView
        self.options = options
        self.statusInfoView = statusInfoView
    }
    
    func toString() -> String {
        return "CometChatMessageTemplate{type: \(type), category: \(category), bubbleView: \(String(describing: bubbleView)), headerView: \(String(describing: headerView)), footerView: \(String(describing: footerView)), contentView: \(String(describing: contentView)), bottomView: ,\(String(describing: bottomView)),options: \(String(describing: options)), statusInfoView: \(String(describing: statusInfoView))}"
    }
}

