
import Foundation
import UIKit
import CometChatSDK

extension CometChatMessageList {
    
    public func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return makeTargetedPreview(for: configuration)
    }
    
    public func tableView(_ tableView: UITableView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return makeTargetedPreview(for: configuration)
    }
    
    private func makeTargetedPreview(for configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath else { return nil }
        guard let cell = tableView.cellForRow(at: indexPath) as? CometChatMessageBubble else { return nil }
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        parameters.visiblePath = UIBezierPath(roundedRect: cell.background.bounds, cornerRadius: cell.background.layer.cornerRadius)
        return UITargetedPreview(view: cell.background, parameters: parameters)
    }

    public func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let message = viewModel?.messages[safe: indexPath.section]?.messages[safe: indexPath.row] else {
            return nil
        }
        return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { suggestedActions in
            return message.deletedAt == 0 ? self.configureMessageOptions(message: message, indexPath: indexPath) : nil
        }
    }
    
    private func configureMessageOptions(message: BaseMessage, indexPath: IndexPath) -> UIMenu {
        var menuElements = [UIMenuElement]()
        if let messageTemplates = templates {
            for template in messageTemplates {
                if template.type == MessageUtils.getDefaultMessageTypes(message: message){
                    if let currentOptions = template.template.options?(message, viewModel?.group ,controller) {
                        for option in currentOptions {
                            let action = UIAction(title: option.title, image: option.icon) { action in
                                if let parentMessageView = self.configureParentView(template: template.template, message: message) {
                                    CometChatMessageOption.messageOptionDelegate?.onItemClick(messageOption: option, forMessage: message, indexPath: indexPath, view: parentMessageView)
                                    if option.id == MessageOptionConstants.replyInThread {
                                        self.onThreadRepliesClick?(message, parentMessageView)
                                    }
                                }
                            }
                            menuElements.append(action)
                        }
                    }
                }
            }
        }
        return UIMenu(title: "", children: menuElements)
    }
}

