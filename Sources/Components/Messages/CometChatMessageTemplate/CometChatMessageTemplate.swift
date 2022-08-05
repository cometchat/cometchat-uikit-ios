//
//  CometChatMessageTemplate.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 19/01/22.
//

import Foundation
import CometChatPro



public class CometChatMessageTemplate: NSObject {
    
    public enum DefaultTemplate {
      
       case text
     
       case imageFromCamera
    
       case imageFromGallery
        
        case audio
        
        case video
        
        case file

        case location
        
        case poll
        
        case collaborativeWhiteboard
        
        case collaborativeDocument
        
        case sticker
        
        case meet
        
        case groupActions
        
        case call
       
       /// Whether the cache type represents the image is already cached or not.
    var template: CometChatMessageTemplate {
            switch self {
           
            case .text: return CometChatMessageTemplate(type: UIKitConstants.MessageTypeConstants.text, name: "", icon: nil, customView: nil, options:
            [CometChatMessageOption(defaultOption: .reaction), CometChatMessageOption(defaultOption: .edit), CometChatMessageOption(defaultOption: .copy), CometChatMessageOption(defaultOption: .share), CometChatMessageOption(defaultOption: .translate), CometChatMessageOption(defaultOption: .delete)])
              
            case .imageFromCamera: return CometChatMessageTemplate(type: UIKitConstants.MessageTypeConstants.image, name: "TAKE_A_PHOTO".localize(), icon: UIImage(named: "messages-camera.png", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage(),  customView: nil, options:
               [CometChatMessageOption(defaultOption: .reaction), CometChatMessageOption(defaultOption: .share), CometChatMessageOption(defaultOption: .delete)])
                
            case .imageFromGallery: return CometChatMessageTemplate(type: UIKitConstants.MessageTypeConstants.image, name: "PHOTO_VIDEO_LIBRARY".localize(), icon: UIImage(named: "photo-library.png", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage() , customView: nil, options:
               [CometChatMessageOption(defaultOption: .reaction), CometChatMessageOption(defaultOption: .share), CometChatMessageOption(defaultOption: .delete)])
                
            case .audio:
                
                return CometChatMessageTemplate(type: UIKitConstants.MessageTypeConstants.audio, name: "", icon: nil,  customView: nil, options:
                [CometChatMessageOption(defaultOption: .reaction), CometChatMessageOption(defaultOption: .share), CometChatMessageOption(defaultOption: .delete)])
                
            case .video:
                
                return CometChatMessageTemplate(type: UIKitConstants.MessageTypeConstants.video, name: "", icon: nil,  customView: nil, options:
                [CometChatMessageOption(defaultOption: .reaction), CometChatMessageOption(defaultOption: .share), CometChatMessageOption(defaultOption: .delete)])
                
            case .file:
                
                return CometChatMessageTemplate(type: UIKitConstants.MessageTypeConstants.file, name: "DOCUMENT".localize(), icon:  UIImage(named: "messages-file-upload.png", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage(),  customView: nil, options:
                [CometChatMessageOption(defaultOption: .reaction), CometChatMessageOption(defaultOption: .share), CometChatMessageOption(defaultOption: .delete)])
                
            case .location:
                
                return CometChatMessageTemplate(type: UIKitConstants.MessageTypeConstants.location, name: "SHARE_LOCATION".localize(), icon:  UIImage(named: "messages-location.png", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage(),  customView: nil, options: [CometChatMessageOption(defaultOption: .reaction), CometChatMessageOption(defaultOption: .share),  CometChatMessageOption(defaultOption: .delete)])
                
            case .poll:
                return CometChatMessageTemplate(type: UIKitConstants.MessageTypeConstants.poll, name: "CREATE_A_POLL".localize(), icon:  UIImage(named: "messages-polls.png", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage(), customView: nil, options:
                [CometChatMessageOption(defaultOption: .reaction), CometChatMessageOption(defaultOption: .share), CometChatMessageOption(defaultOption: .delete)])
                
            case .collaborativeWhiteboard:
                
                return CometChatMessageTemplate(type: UIKitConstants.MessageTypeConstants.whiteboard, name: "COLLABORATIVE_WHITEBOARD".localize(), icon:  UIImage(named: "messages-collaborative-whiteboard.png", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage() , customView: nil, options: [CometChatMessageOption(defaultOption: .reaction),  CometChatMessageOption(defaultOption: .share), CometChatMessageOption(defaultOption: .delete)])
                
            case .collaborativeDocument:
                
                return CometChatMessageTemplate(type: UIKitConstants.MessageTypeConstants.document, name: "COLLABORATIVE_DOCUMENT".localize(), icon:  UIImage(named: "messages-collaborative-document.png", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage(),  customView: nil, options: [CometChatMessageOption(defaultOption: .reaction), CometChatMessageOption(defaultOption: .share), CometChatMessageOption(defaultOption: .delete)])
                
            case .sticker:
                
                return CometChatMessageTemplate(type: UIKitConstants.MessageTypeConstants.sticker, name: "", icon: nil, customView: nil, options:
                [CometChatMessageOption(defaultOption: .reaction), CometChatMessageOption(defaultOption: .share), CometChatMessageOption(defaultOption: .delete)])
                
            case .meet:
                
                return CometChatMessageTemplate(type: UIKitConstants.MessageTypeConstants.meeting, name: "", icon:  nil,  customView: nil, options:
                [CometChatMessageOption(defaultOption: .reaction), CometChatMessageOption(defaultOption: .share), CometChatMessageOption(defaultOption: .delete)])
                
            case .groupActions:
                
                return CometChatMessageTemplate(type: "groupActions", name: "", icon:  nil,   customView: nil, options: [])
                
            case .call:
                
                return CometChatMessageTemplate(type: UIKitConstants.MessageCategoryConstants.call, name: "", icon:  nil,  customView: nil, options: [])
            }
        }
    }
    
    var type: String
    var name: String?
    var icon: UIImage?
    var customView: ((BaseMessage) -> (UIView))?
    var options: [CometChatMessageOption]?
    var onActionClick: ((_ forUser: User?, _ forGroup: Group?) -> ())?
    
    
    public init(type: String, name: String, icon: UIImage? = UIImage(),  customView: ((BaseMessage) -> (UIView))?, options: [CometChatMessageOption]?, onActionClick: ((_ forUser: User?, _ forGroup: Group?) -> ())? = nil) {
        self.type = type
        self.name = name
        self.icon = icon
        self.customView = customView
        self.options = options
        self.options = options
        self.onActionClick = onActionClick
    }
    
    public init(type: DefaultTemplate) {
        self.type =  type.template.type
        self.name =  type.template.name
        self.icon =  type.template.icon
        self.customView =  type.template.customView
        self.options =  type.template.options
        self.onActionClick = type.template.onActionClick
    }
}

