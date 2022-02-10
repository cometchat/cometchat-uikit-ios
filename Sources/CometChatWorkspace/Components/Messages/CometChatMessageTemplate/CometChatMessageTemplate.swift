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
           
            case .text: return CometChatMessageTemplate(id: "text", name: "", icon: nil, title: nil, description: nil, customView: nil, onLongPress: [.edit, .delete, .share, .copy, .reply, .translate])
              
            case .imageFromCamera: return CometChatMessageTemplate(id: "image", name: "TAKE_A_PHOTO".localize(), icon: UIImage(named: "messages-camera.png", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage(), title: nil, description: nil, customView: nil, onLongPress: [.delete, .share,.forward, .reply])
                
            case .imageFromGallery: return CometChatMessageTemplate(id: "image", name: "PHOTO_VIDEO_LIBRARY".localize(), icon: UIImage(named: "photo-library.png", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage(), title: nil, description: nil, customView: nil, onLongPress: [.delete, .share,.forward, .reply])
                
            case .audio:
                
                return CometChatMessageTemplate(id: "audio", name: "", icon: nil, title: nil, description: nil, customView: nil, onLongPress: [.delete, .share,.forward, .reply])
                
            case .video:
                
                return CometChatMessageTemplate(id: "video", name: "", icon: nil, title: nil, description: nil, customView: nil, onLongPress: [.delete, .share,.forward, .reply])
                
            case .file:
                
                return CometChatMessageTemplate(id: "file", name: "DOCUMENT".localize(), icon:  UIImage(named: "messages-file-upload.png", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage(), title: nil, description: nil, customView: nil, onLongPress: [.delete, .share,.forward, .reply])
                
            case .location:
                
                return CometChatMessageTemplate(id: "location", name: "SHARE_LOCATION".localize(), icon:  UIImage(named: "messages-location.png", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage(), title: "", description: nil, customView: nil, onLongPress: [.delete, .share,.forward, .reply])
                
            case .poll:
                return CometChatMessageTemplate(id: "extension_poll", name: "CREATE_A_POLL".localize(), icon:  UIImage(named: "messages-polls.png", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage(), title: nil, description: nil, customView: nil, onLongPress: [.delete, .share,.forward, .reply])
            case .collaborativeWhiteboard:
                
                return CometChatMessageTemplate(id: "extension_whiteboard", name: "COLLABORATIVE_WHITEBOARD".localize(), icon:  UIImage(named: "messages-collaborative-whiteboard.png", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage(), title: nil, description: nil, customView: nil, onLongPress: [.delete, .share,.forward, .reply])
                
            case .collaborativeDocument:
                
                return CometChatMessageTemplate(id: "extension_document", name: "COLLABORATIVE_DOCUMENT".localize(), icon:  UIImage(named: "messages-collaborative-document.png", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage(), title: nil, description: nil, customView: nil, onLongPress: [.delete, .share,.forward, .reply])
                
            case .sticker:
                
                return CometChatMessageTemplate(id: "extension_sticker", name: "SEND_STICKER".localize(), icon:  UIImage(named: "messages-stickers.png", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage(), title: nil, description: nil, customView: nil, onLongPress: [.delete, .share,.forward, .reply])
                
            case .meet:
                
                return CometChatMessageTemplate(id: "meeting", name: "", icon:  nil, title: nil, description: nil, customView: nil, onLongPress: [.delete, .share,.forward, .reply])
                
            case .groupActions:
                
                return CometChatMessageTemplate(id: "groupActions", name: "", icon:  nil, title: nil, description: nil, customView: nil, onLongPress: nil)
                
            case .call:
                
                return CometChatMessageTemplate(id: "call", name: "", icon:  nil, title: nil, description: nil, customView: nil, onLongPress: nil)
            }
        }
    }
    
    var id: String
    var name: String?
    var icon: UIImage?
    var title: String?
    var localDescription: String?
    var customView: UIView?
    var onLongPress: [MessageHover]?
    
    
    public init(id: String, name: String, icon: UIImage? = UIImage(), title: String? = "", description: String? = "",  customView: UIView?, onLongPress: [MessageHover]? = [.reaction, .share, .delete]) {
        self.id = id
        self.name = name
        self.icon = icon
        self.title = title
        self.localDescription = description
        self.customView = customView
        self.onLongPress = onLongPress
    }
    
    public init(defaultTemplate: DefaultTemplate) {
        self.id =  defaultTemplate.template.id
        self.name =  defaultTemplate.template.name
        self.icon =  defaultTemplate.template.icon
        self.title =  defaultTemplate.template.title
        self.localDescription =  defaultTemplate.template.description
        self.customView =  defaultTemplate.template.customView
        self.onLongPress =  defaultTemplate.template.onLongPress
    }
}



