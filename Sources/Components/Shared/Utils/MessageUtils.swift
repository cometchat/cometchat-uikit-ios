//
//  File.swift
//  
//
//  Created by Pushpsen Airekar on 26/12/22.
//

import Foundation
import CometChatSDK
import UIKit

public class MessageUtils {
    
//    static var textTemplate =
//    CometChatMessageTemplate(category: MessageCategoryConstants.message, type: MessageTypeConstants.text,
//                             contentView: { message, alignment, controller in
//
//        guard let message = message as? TextMessage else { return UIView()}
//        let textBubble = CometChatTextBubble()
//        textBubble.set(text: message.text)
//        textBubble.set(textFont: message.text.applyLargeSizeEmoji())
//        switch alignment {
//        case .right:
//            textBubble.set(textColor: .white)
//        case .left:
//            textBubble.set(textColor: CometChatTheme.palatte.accent)
//        default: break
//        }
//        return textBubble
//    }, footerView: nil) { message, group, controller in
//        if LoggedInUserInformation.isLoggedInUser(uid: message?.sender?.uid) {
//            var  options = [CometChatMessageOption(defaultOption: .start_thread),
//                            CometChatMessageOption(defaultOption: .edit),  CometChatMessageOption(defaultOption: .delete),
//                            CometChatMessageOption(defaultOption: .copy),
//                            CometChatMessageOption(defaultOption: .share)]
//            return options
//
//        } else {
//            var options = [CometChatMessageOption(defaultOption: .start_thread)]
//            if let group = group, group.scope == .admin || group.scope == .moderator {
//                options.append(CometChatMessageOption(defaultOption: .delete))
//            }
//            options.append(CometChatMessageOption(defaultOption: .copy))
//            options.append(CometChatMessageOption(defaultOption: .share))
//            return options
//        }
//    }
    
//    static var imageTemplate =
//    CometChatMessageTemplate(type: MessageTypeConstants.image,
//                             category: MessageCategoryConstants.message,
//                             headerView: nil,
//                             contentView: { message, alignment, controller in
//
//        if let mediaMessage = message as? MediaMessage {
//            let imageBubble = CometChatImageBubble()
//            imageBubble.set(imageUrl: mediaMessage.attachment?.fileUrl ?? "" )
//            imageBubble.set(caption: mediaMessage.caption ?? "")
//            if let controller = controller {
//                imageBubble.set(controller: controller)
//            }
//            return imageBubble
//        }
//        return UIView()
//    }, footerView: nil) { message, group, controller in
//        if LoggedInUserInformation.isLoggedInUser(uid: message?.sender?.uid) {
//            var  options = [CometChatMessageOption(defaultOption: .start_thread),
//                            CometChatMessageOption(defaultOption: .delete)]
//            return options
//
//        } else {
//            var options = [CometChatMessageOption(defaultOption: .start_thread)]
//            if let group = group, group.scope == .admin || group.scope == .moderator {
//                options.append(CometChatMessageOption(defaultOption: .delete))
//            }
//            return options
//        }
//    }
    
//    static var videoTemplate =
//    CometChatMessageTemplate(type: MessageTypeConstants.video,
//                             category: MessageCategoryConstants.message,
//                             headerView: nil,
//                             contentView: { message, alignment, controller in
//
//        if let mediaMessage = message as? MediaMessage {
//            let videoBubble = CometChatVideoBubble()
//            videoBubble.set(videoURL: mediaMessage.attachment?.fileUrl ?? "")
//            if let controller = controller {
//                videoBubble.set(controller: controller)
//            }
//            return videoBubble
//        }
//        return UIView()
//    }, footerView: nil) { message, group, controller in
//        if LoggedInUserInformation.isLoggedInUser(uid: message?.sender?.uid) {
//            var  options = [CometChatMessageOption(defaultOption: .start_thread), CometChatMessageOption(defaultOption: .delete)]
//            return options
//
//        } else {
//            var options = [CometChatMessageOption(defaultOption: .start_thread)]
//            if let group = group, group.scope == .admin || group.scope == .moderator {
//                options.append(CometChatMessageOption(defaultOption: .delete))
//            }
//            return options
//        }
//    }
//
//    static var audioTemplate =
//    CometChatMessageTemplate(type: MessageTypeConstants.audio,
//                             category: MessageCategoryConstants.message,
//                             headerView: nil,
//                             contentView: { message, alignment, controller in
//
//        if let mediaMessage = message as? MediaMessage {
//            let audioBubble = CometChatAudioBubble()
//            audioBubble.set(title: mediaMessage.attachment?.fileName.capitalized ?? "")
//            audioBubble.set(subTitle: mediaMessage.attachment?.fileExtension.capitalized ?? "")
//            audioBubble.set(fileURL: mediaMessage.attachment?.fileUrl ?? "")
//            if let controller = controller {
//                audioBubble.set(controller: controller)
//            }
//            return audioBubble
//        }
//        return UIView()
//    }, footerView: nil) { message, group, controller  in
//        if LoggedInUserInformation.isLoggedInUser(uid: message?.sender?.uid) {
//            var  options = [CometChatMessageOption(defaultOption: .start_thread), CometChatMessageOption(defaultOption: .delete)]
//            return options
//
//        } else {
//            var options = [CometChatMessageOption(defaultOption: .start_thread)]
//            if let group = group, group.scope == .admin || group.scope == .moderator {
//                options.append(CometChatMessageOption(defaultOption: .delete))
//            }
//            return options
//        }
//    }
//
//
//    static var fileTemplate =
//    CometChatMessageTemplate(type: MessageTypeConstants.file,
//                             category: MessageCategoryConstants.message,
//                             headerView: nil,
//                             contentView: { message, alignment, controller in
//
//        if let mediaMessage = message as? MediaMessage {
//            let fileBubble = CometChatFileBubble()
//            fileBubble.set(title: mediaMessage.attachment?.fileName.capitalized ?? "")
//            fileBubble.set(subTitle: mediaMessage.attachment?.fileExtension.capitalized ?? "")
//            fileBubble.set(fileUrl: mediaMessage.attachment?.fileUrl ?? "")
//            if let controller = controller {
//                fileBubble.set(controller: controller)
//            }
//            return fileBubble
//        }
//        return UIView()
//    }, footerView: nil) { message, group, controller  in
//        if LoggedInUserInformation.isLoggedInUser(uid: message?.sender?.uid) {
//            var  options = [CometChatMessageOption(defaultOption: .start_thread), CometChatMessageOption(defaultOption: .delete)]
//            return options
//
//        } else {
//            var options = [CometChatMessageOption(defaultOption: .start_thread)]
//            if let group = group, group.scope == .admin || group.scope == .moderator {
//                options.append(CometChatMessageOption(defaultOption: .delete))
//            }
//            return options
//        }
//    }
//
//    static var groupActionsTemplate =  CometChatMessageTemplate(type: MessageTypeConstants.groupMember, category: MessageCategoryConstants.action, bubbleView: { message, alignment, controller in
//        let stackView = UIStackView()
//        let view = CometChatMessageDateHeader()
//        view.text = (message as? ActionMessage)?.message ?? ""
//        stackView.addArrangedSubview(view)
//        stackView.layoutMargins = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
//        stackView.isLayoutMarginsRelativeArrangement = true
//        return stackView
//
//    }, options: nil)
//
    public static func getDefaultMessageTypes() -> [CometChatMessageTemplate] {
      //  return [textTemplate, imageTemplate, videoTemplate, fileTemplate, audioTemplate, groupActionsTemplate]
        return []
    }
    
    public static func getMessageTemplate(type: String) -> CometChatMessageTemplate? {
      //  switch type {
//        case MessageTypeConstants.text: return textTemplate
//        case MessageTypeConstants.image: return imageTemplate
//        case MessageTypeConstants.audio: return audioTemplate
//        case MessageTypeConstants.video: return videoTemplate
//        case MessageTypeConstants.file: return fileTemplate
//        case MessageTypeConstants.groupMember: return groupActionsTemplate
//        default: break
//        }
        return nil
    }
    
    public static func getMessageOptions(message: BaseMessage, group: Group?) -> [CometChatMessageOption]? {
        let messageType = getDefaultMessageTypes(message: message)
        if let template = getMessageTemplate(type: messageType) {
            return template.options?(message, group, nil)
        }
        return nil
    }
    
    public static func getDefaultMessageTypes(message: BaseMessage) -> String {
        switch message.messageCategory {
        case .message:
            switch message.messageType {
            case .text: return "text"
            case .image: return "image"
            case .audio: return "audio"
            case .groupMember: return "groupMember"
            case .file: return "file"
            case .video: return "video"
            case .custom: return (message as? CustomMessage)?.type ?? ""
            default: return (message as? CustomMessage)?.type ?? ""
            }
        case .custom: return (message as? CustomMessage)?.type ?? ""
        case .call:
            if let call = message as? Call {
                switch call.callType {
                case .audio: return "audio"
                case .video: return "video"
                @unknown default: return "call"
                }
            }
            return "call"
        case .action: return message.messageType == .groupMember ? "groupMember" : "action"
        default: return (message as? CustomMessage)?.type ?? ""
        }
    }
    
    public static func getDefaultMessageCategories(message: BaseMessage) -> String {
        switch message.messageCategory {
        case .message: return "message"
        case .custom:  return "custom"
        case .call: return "call"
        case .action: return "action"
        default: return "message"
        }
    }
    
    public static func getDefaultAttachmentOptions() -> [CometChatMessageComposerAction] {
        let composerActions = [
            CometChatMessageComposerAction(id: MessageTypeConstants.image, text: "TAKE_A_PHOTO".localize(), startIcon: UIImage(named: "messages-camera.png", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage(), endIcon: nil, startIconTint: nil, endIconTint: nil, textColor: nil, textFont: nil),
            
            CometChatMessageComposerAction(id: MessageTypeConstants.image, text: "PHOTO_VIDEO_LIBRARY".localize(), startIcon:  UIImage(named: "photo-library.png", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage(), endIcon: nil, startIconTint: nil, endIconTint: nil, textColor: nil, textFont: nil),
            
            CometChatMessageComposerAction(id: MessageTypeConstants.file, text: "DOCUMENT".localize(), startIcon: UIImage(named: "messages-file-upload.png", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage(), endIcon: nil, startIconTint: nil, endIconTint: nil, textColor: nil, textFont: nil)
        ]
        return composerActions
    }
    
    public static func bubbleBackgroundAppearance(bubbleView: UIView, senderUid: String, message: BaseMessage, controller: UIViewController ) {
        if (senderUid == CometChat.getLoggedInUser()?.uid)  && (message.messageType == .text) {
            bubbleView.backgroundColor =  CometChatTheme.palatte.primary
        } else {
            bubbleView.backgroundColor = (controller.traitCollection.userInterfaceStyle == .dark) ? CometChatTheme.palatte.accent100 :  CometChatTheme.palatte.secondary
        }
        
    }
    
}
