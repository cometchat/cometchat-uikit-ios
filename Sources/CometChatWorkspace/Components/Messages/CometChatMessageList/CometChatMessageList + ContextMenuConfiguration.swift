//
//  CometChatMessageList + ContextMenuConfiguration.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 30/01/22.
//

import Foundation
import UIKit
import CometChatPro

extension CometChatMessageList {

    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        var  hovers = [MessageHover]()
        guard let message = chatMessages[safe: indexPath.section]?[safe: indexPath.row], let id = message.id as? Int else {
            return nil
        }
        
        print("hovers: \(messageHovers)")
        if message.messageCategory == .action {
            return nil
        }

        
        switch message.messageType {
        case .text:  hovers = messageHovers["text"] ?? []
        case .image: hovers = messageHovers["image"] ?? []
        case .video: hovers = messageHovers["video"] ?? []
        case .audio: hovers = messageHovers["audio"] ?? []
        case .file: hovers = messageHovers["file"] ?? []
        case .custom: hovers = messageHovers[(message as? CustomMessage)?.type ?? ""] ?? []
        case .groupMember: break
        @unknown default: break
        }
        
        return UIContextMenuConfiguration(identifier: String(id) as? NSCopying,  previewProvider: nil) { suggestedActions in
            
            return self.configureHoverItem(forMessageHovers: hovers, message: message, indexPath: indexPath)
            
        }
    }
    
    func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
      return makeTargetedPreview(for: configuration)
    }

    func tableView(_ tableView: UITableView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
       return makeTargetedPreview(for: configuration)
    }

    private func makeTargetedPreview(for configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        
        // Ensure we can get the expected identifier
        guard let identifier = configuration.identifier as? String else { return nil }
        
        guard let indexPath = self.chatMessages.indexPath(where: {$0.id == Int(identifier)}) else {
            return nil
        }

        guard let view = ifCellIsAt(indexPath: indexPath) as? UIView else {return nil}
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        return UITargetedPreview(view: view, parameters: parameters)
    }
    
    private func ifCellIsAt(indexPath: IndexPath) -> UIView? {
        
        if let cell = tableView.cellForRow(at: indexPath) as? CometChatTextBubble {
            return cell.background
        }else  if let cell = tableView.cellForRow(at: indexPath) as? CometChatTextBubble {
            return cell.background
        } else if let cell = tableView.cellForRow(at: indexPath) as? CometChatImageBubble {
            return cell.background
        } else if let cell = tableView.cellForRow(at: indexPath) as? CometChatVideoBubble {
            return cell.background
        } else if let cell = tableView.cellForRow(at: indexPath) as? CometChatFileBubble {
            return cell.background
        } else if let cell = tableView.cellForRow(at: indexPath) as? CometChatLocationBubble {
            return cell.background
        } else if let cell = tableView.cellForRow(at: indexPath) as? CometChatPollsBubble {
            return cell.background
        }else  if let cell = tableView.cellForRow(at: indexPath) as? CometChatStickerBubble {
            return cell.background
        }else  if let cell = tableView.cellForRow(at: indexPath) as? CometChatMeetingBubble {
            return cell.background
        }else  if let cell = tableView.cellForRow(at: indexPath) as? CometChatAudioBubble {
            return cell.background
        }else  if let cell = tableView.cellForRow(at: indexPath) as? CometChatWhiteboardBubble {
            return cell.background
        }else  if let cell = tableView.cellForRow(at: indexPath) as? CometChatDocumentBubble {
            return cell.background
        }else  if let cell = tableView.cellForRow(at: indexPath) as? CometChatDocumentBubble {
            return cell.background
        }else  if let cell = tableView.cellForRow(at: indexPath) as? CometChatCallActionBubble {
            return cell.background
        }else  if let cell = tableView.cellForRow(at: indexPath) as? CometChatCustomBubble {
            return cell.background
        }else{
            return UIView()
        }
    }
    
    private func configureHoverItem(forMessageHovers: [MessageHover], message: BaseMessage, indexPath: IndexPath) -> UIMenu {
        var menuElements =  [UIMenuElement]()
        for messageHover in forMessageHovers {
            switch messageHover {
            case .edit:
                let editAction = UIAction(title: "EDIT_MESSAGE".localize(), image: UIImage(named: "messages-edit.png")) { action in
                    CometChatMessageHover.messageHoverDelegate?.onItemClick(messageHover: messageHover, forMessage: message, indexPath: indexPath)
                }
                menuElements.append(editAction)
            case .delete:
                let deleteAction = UIAction(title: "DELETE_MESSAGE".localize(), image: UIImage(named: "messages-delete.png"), attributes: .destructive) { action in
                    CometChatMessageHover.messageHoverDelegate?.onItemClick(messageHover: messageHover, forMessage: message, indexPath: indexPath)
                }
                menuElements.append(deleteAction)
            case .share:
                let shareAction = UIAction(title: "SHARE_MESSAGE".localize(), image: UIImage(named: "messages-share.png")) { action in
                    CometChatMessageHover.messageHoverDelegate?.onItemClick(messageHover: messageHover, forMessage: message, indexPath: indexPath)
                }
                menuElements.append(shareAction)
            case .copy:
                let copyAction = UIAction(title: "COPY_MESSAGE".localize(), image: UIImage(named: "copy-paste.png")) { action in
                    CometChatMessageHover.messageHoverDelegate?.onItemClick(messageHover: messageHover, forMessage: message, indexPath: indexPath)
                }
                menuElements.append(copyAction)
            case .forward:
                let forwardAction = UIAction(title: "FORWARD_MESSAGE".localize(), image: UIImage(named: "messages-forward-message.png")) { action in
                    CometChatMessageHover.messageHoverDelegate?.onItemClick(messageHover: messageHover, forMessage: message, indexPath: indexPath)
                }
                menuElements.append(forwardAction)

            case .reply:
                
                let replyAction = UIAction(title: "REPLY_MESSAGE".localize(), image: UIImage(named: "reply-message.png")) { action in
                    CometChatMessageHover.messageHoverDelegate?.onItemClick(messageHover: messageHover, forMessage: message, indexPath: indexPath)
                }
                menuElements.append(replyAction)
                
            case .reply_in_thread:
                
                let replyInThreadAction = UIAction(title: "START_THREAD".localize(), image: UIImage(named: "threaded-message.png")) { action in
                    CometChatMessageHover.messageHoverDelegate?.onItemClick(messageHover: messageHover, forMessage: message, indexPath: indexPath)
                }
                menuElements.append(replyInThreadAction)
            case .reaction:
                let reactionAction = UIAction(title: "ADD_REACTION".localize(), image: UIImage(named: "messages-reaction.png")) { action in
                    CometChatMessageHover.messageHoverDelegate?.onItemClick(messageHover: messageHover, forMessage: message, indexPath: indexPath)
                }
                menuElements.append(reactionAction)
            case .translate:
                let translateAction = UIAction(title: "TRANSLATE_MESSAGE".localize(), image: UIImage(named: "message-translate.png")) { action in
                    CometChatMessageHover.messageHoverDelegate?.onItemClick(messageHover: messageHover, forMessage: message, indexPath: indexPath)
                }
                menuElements.append(translateAction)
            case .messageInfo:
                let messageInfoAction = UIAction(title: "MESSAGE_INFORMATION".localize(), image: UIImage(named: "messages-info.png")) { action in
                    CometChatMessageHover.messageHoverDelegate?.onItemClick(messageHover: messageHover, forMessage: message, indexPath: indexPath)
                }
                menuElements.append(messageInfoAction)
            }
        }
  
        return UIMenu(title: "", children: menuElements)
    }

    
}
