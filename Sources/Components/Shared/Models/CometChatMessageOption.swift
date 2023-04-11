//
//  CometChatMessageOption.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 27/01/22.
//

import UIKit
import CometChatPro


protocol CometChatMessageOptionDelegate: AnyObject {
    func onItemClick(messageOption: CometChatMessageOption, forMessage: BaseMessage?, indexPath: IndexPath?, view: UIView?)
}

public struct  CometChatMessageOption: Hashable {
    
    let id: String
    let title: String
    let icon: UIImage?
    let packageName: String? = UIConstants.packageName
    let overrideDefaultAction: Bool? = false
    var onItemClick: ((_ message: BaseMessage?) -> Void)?
    static var messageOptionDelegate: CometChatMessageOptionDelegate?
    
    public static func == (lhs: CometChatMessageOption, rhs: CometChatMessageOption) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
}

