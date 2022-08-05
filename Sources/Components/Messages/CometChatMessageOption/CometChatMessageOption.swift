//
//  CometChatMessageOptions.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 27/01/22.
//

import UIKit
import CometChatPro

public enum OptionFor {
    
    case sent
    case received
    case both
}

protocol CometChatMessageOptionDelegate: AnyObject {
  func onItemClick(messageOption: CometChatMessageOption, forMessage: BaseMessage?, indexPath: IndexPath?)
}

public class  CometChatMessageOption : Hashable {
    
    public static func == (lhs: CometChatMessageOption, rhs: CometChatMessageOption) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
         return hasher.combine(id)
     }

    public enum DefaultOption {
        
        case reaction
        
        case edit
        
        case reply
        
        case start_thread
        
        case copy
        
        case translate
        
        case forward
        
        case share
        
        case messageInfo
        
        case delete

        
        /// Whether the cache type represents the image is already cached or not.
        var option: CometChatMessageOption {

            switch self {
            case .reaction:
                
                return CometChatMessageOption(id: UIKitConstants.MessageOptionConstants.reactToMessage, title: "ADD_REACTION".localize(), image: UIImage(named: "messages-add-reaction.png", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage(), optionFor: .both)
                
            case .edit:
                
                return CometChatMessageOption(id: UIKitConstants.MessageOptionConstants.editMessage, title: "EDIT_MESSAGE".localize(), image: UIImage(named: "messages-edit.png", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage(), optionFor: .sent)
                
                
            case .delete:
                
                return CometChatMessageOption(id: UIKitConstants.MessageOptionConstants.deleteMessage, title: "DELETE_MESSAGE".localize(), image: UIImage(named: "messages-delete.png", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage(), optionFor: .sent)
                
            case .copy:
                
                return  CometChatMessageOption(id: UIKitConstants.MessageOptionConstants.copyMessage, title: "COPY_MESSAGE".localize(), image: UIImage(named: "copy-paste.png", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage(), optionFor: .both)
           
            case .forward:
                
                return CometChatMessageOption(id: UIKitConstants.MessageOptionConstants.forwardMessage, title: "FORWARD_MESSAGE".localize(), image: UIImage(named: "messages-forward-message.png", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage(), optionFor: .both)
            
            case .share:
                
                return  CometChatMessageOption(id: UIKitConstants.MessageOptionConstants.shareMessage, title: "SHARE_MESSAGE".localize(), image: UIImage(named: "messages-share.png", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage(), optionFor: .both)
            case .translate:
                
                return CometChatMessageOption(id: UIKitConstants.MessageOptionConstants.translateMessage, title: "TRANSLATE_MESSAGE".localize(), image: UIImage(named: "message-translate.png", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage(), optionFor: .both)
            
            case .messageInfo:
                
                return CometChatMessageOption(id: UIKitConstants.MessageOptionConstants.messageInformation, title: "MESSAGE_INFORMATION".localize(), image: UIImage(named: "messages-info.png", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage(), optionFor: .both)
            case .reply:
                
                return CometChatMessageOption(id: UIKitConstants.MessageOptionConstants.replyMessage, title: "REPLY".localize(), image: UIImage(named: "reply-message.png", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage(), optionFor: .both)
           
            case .start_thread:
                
                return CometChatMessageOption(id: UIKitConstants.MessageOptionConstants.replyInThread, title: "START_THREAD".localize(), image: UIImage(named: "threaded-message.png", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage(), optionFor: .both)
            
            }
        }
    }
    
    
    static var messageOptionDelegate: CometChatMessageOptionDelegate?
    
    let id: String
    let title: String
    let image: UIImage
    var optionFor: OptionFor = .both
    var onClick: ((_ message: BaseMessage?) -> ())?
    
    public init(id: String, title: String, image: UIImage,  optionFor: OptionFor, onClick: ((_ message: BaseMessage?) -> ())? = nil) {
        self.id = id
        self.title = title
        self.image = image
        self.optionFor = optionFor
        self.onClick = onClick
    }
    
    public init(defaultOption: DefaultOption) {
        self.id = defaultOption.option.id
        self.title = defaultOption.option.title
        self.image = defaultOption.option.image
        self.optionFor = defaultOption.option.optionFor
        self.onClick = defaultOption.option.onClick
    }
    
}

