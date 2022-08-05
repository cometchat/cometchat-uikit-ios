
import Foundation
import UIKit
import CometChatPro

extension CometChatMessageList {

    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let message = chatMessages[safe: indexPath.section]?[safe: indexPath.row], let id = message.id as? Int else {
          return nil
        }
        if let cell = tableView.cellForRow(at: indexPath) as? CometChatMessageBubble {
          return UIContextMenuConfiguration(identifier: String(id) as? NSCopying, previewProvider: nil) { suggestedActions in
            return self.configureMessageOptions(options: cell.messageOptions, message: message, indexPath: indexPath)
          }
        }
        if let cell = tableView.cellForRow(at: indexPath) as? CometChatTextAutoSizeBubble {
          return UIContextMenuConfiguration(identifier: String(id) as? NSCopying, previewProvider: nil) { suggestedActions in
            return self.configureMessageOptions(options: cell.messageOptions, message: message, indexPath: indexPath)
          }
        }
        return nil
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
        if let cell = tableView.cellForRow(at: indexPath) as? CometChatTextAutoSizeBubble {
          return cell.containerStackView
        }
        
        if let cell = tableView.cellForRow(at: indexPath) as? CometChatMessageBubble {
            if let view = cell.customView {
                return cell.containerStackView
            }
          return cell.background
        }
        return UIView()
      }
    
    private func configureMessageOptions(options: [CometChatMessageOption], message: BaseMessage, indexPath: IndexPath) -> UIMenu {
        var menuElements = [UIMenuElement]()
        
        for option in options {
            
            let action = UIAction(title: option.title, image: option.image) { action in
                CometChatMessageOption.messageOptionDelegate?.onItemClick(messageOption: option, forMessage: message, indexPath: indexPath)
            }
            switch option.optionFor {
            case .sent:
                if message.sender?.uid == CometChat.getLoggedInUser()?.uid {
                    menuElements.append(action)
                }
            case .received:
                if message.sender?.uid != CometChat.getLoggedInUser()?.uid {
                    menuElements.append(action)
                }
            case .both:
                menuElements.append(action)
            }
        }
        return UIMenu(title: "", children: menuElements)
    }
    
}
