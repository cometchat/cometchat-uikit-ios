//
//  CometChatMessageList + Properties.swift
//  CometChatUIKitSwift
//
//  Created by Suryansh on 18/06/24.
//

import Foundation
import CometChatSDK


extension CometChatMessageList {
    
    @discardableResult
    public func set(user: User, parentMessage: BaseMessage? = nil) -> Self {
        self.viewModel.set(user: user, messagesRequestBuilder: self.messagesRequestBuilder, parentMessage: parentMessage)
        return self
    }
    
    @discardableResult
    public func set(group: Group, parentMessage: BaseMessage? = nil) -> Self {
        self.viewModel.set(group: group, messagesRequestBuilder: self.messagesRequestBuilder, parentMessage: parentMessage)
        return self
    }
    
    @discardableResult
    public func set(messagesRequestBuilder: MessagesRequest.MessageRequestBuilder) -> Self {
        self.messagesRequestBuilder = messagesRequestBuilder
        return self
    }
    
    @discardableResult
    public func set(templates: [CometChatMessageTemplate]) -> Self {
        for template in (templates) {
            viewModel.templates["\(template.category)_\(template.type)"] = template
        }
        return self
    }
    
    @discardableResult
    public func disable(mentions: Bool) -> Self {
        if mentions == true {
            viewModel.textFormatters.enumerated().forEach { (index, formatter) in
                if formatter.formatterID == CometChatMentionsFormatter().formatterID {
                    viewModel.textFormatters.remove(at: index)
                }
            }
        }
        return self
    }
    
    @discardableResult
    public func set(textFormatters: [CometChatTextFormatter]) -> Self {
        self.viewModel.textFormatters = textFormatters
        return self
    }
    
    @discardableResult
    public func set(customSoundForMessages: URL) -> Self {
        self.customSoundForMessages = customSoundForMessages
        return self
    }
    
    @discardableResult
    public func setDatePattern(datePattern: ((_ timestamp: Int?) -> String)?) -> Self {
        self.datePattern = datePattern
        return self
    }
    
    @discardableResult
    public func setDateSeparatorPattern(dateSeparatorPattern: ((_ timestamp: Int?) -> String)?) -> Self {
        self.dateSeparatorPattern = dateSeparatorPattern
        return self
    }
    
    @discardableResult
    public func set(newMessageIndicatorStyle: NewMessageIndicatorStyle) -> Self {
        self.newMessageIndicatorStyle = newMessageIndicatorStyle
        return self
    }
    
    @discardableResult
    public func set(messageInformationConfiguration: MessageInformationConfiguration)  ->  Self {
        self.messageInformationConfiguration = messageInformationConfiguration
        return self
    }
    
    @discardableResult
    public func setOnThreadRepliesClick(onThreadRepliesClick: ((_ message: BaseMessage, _ template: CometChatMessageTemplate) -> ())?) -> Self {
        self.onThreadRepliesClick = onThreadRepliesClick
        return self
    }
    
    @discardableResult
    public func set(headerView: UIView?) ->  Self {
        headerViewContainer.subviews.forEach({ $0.removeFromSuperview() })
        if headerView != nil {
            self.headerViewContainer.isHidden = false
            if let headerView = headerView {
                self.headerViewContainer.addArrangedSubview(headerView)
            }
        }else{
            self.headerViewContainer.isHidden = true
        }
        return self
    }
    
    @discardableResult
    public func clear(headerView: Bool) ->  Self {
        if headerView {
            self.hideHeaderView = headerView
            headerViewContainer.subviews.forEach({ $0.removeFromSuperview() })
            self.headerViewContainer.isHidden = headerView
        }
        return self
    }
    
    @discardableResult
    public func set(footerView: UIView) ->  Self {
        footerViewContainer.subviews.forEach({ $0.removeFromSuperview() })
        footerViewContainer.isHidden = false
        footerViewContainer.addArrangedSubview(footerView)
        return self
    }
    
    @discardableResult
    public func clear(footerView: Bool) ->  Self {
        self.hideFooterView = footerView
        self.footerViewContainer.isHidden = true
        footerViewContainer.subviews.forEach({ $0.removeFromSuperview() })
        self.layoutIfNeeded()
        return self
    }
    
    @discardableResult
    public func disable(reactions: Bool) -> Self {
        self.disableReactions = reactions
        self.viewModel.disable(reactions: reactions)
        return self
    }
    
    @discardableResult
    public func set(reactionsConfiguration: ReactionsConfiguration?) -> Self {
        self.reactionsConfiguration = reactionsConfiguration
        return self
    }
    
    @discardableResult
    public func set(reactionListConfiguration: ReactionListConfiguration?) -> Self {
        self.reactionListConfiguration = reactionListConfiguration
        return self
    }
    
    @discardableResult
    public func set(quickReactionsConfiguration: QuickReactionsConfiguration?) -> Self {
        self.quickReactionsConfiguration = quickReactionsConfiguration
        return self
    }
    
    @discardableResult
    public func set(controller: UIViewController) -> Self {
        self.controller = controller
        return self
    }
    
    @discardableResult
    public func connect() -> Self {
        viewModel.connect()
        addKeyboardDismissGesture()
        return self
    }
    
    @discardableResult
    public func disconnect() -> Self {
        viewModel.disconnect()
        removeKeyboardDismissGesture()
        return self
    }
    
    @discardableResult
    public func add(message: BaseMessage) -> Self {
        viewModel.add(message: message)
        return self
    }
    
    @discardableResult
    public func update(message: BaseMessage) -> Self {
        viewModel.update(message: message)
        return self
    }
    
    @discardableResult
    public func remove(message: BaseMessage) -> Self {
        viewModel.remove(message: message)
        return self
    }
    
    @discardableResult
    public func delete(message: BaseMessage) -> Self {
        viewModel.delete(message: message)
        return self
    }
    
    @discardableResult
    public func didMessageInformationClicked(message: BaseMessage) -> Self {
        let messageInformationController = CometChatMessageInformation()
        let navigationController = UINavigationController(rootViewController: messageInformationController)
        
        if let messageInformationConfiguration = self.messageInformationConfiguration {
            configureMessageInformation(configuration: messageInformationConfiguration, messageInformation: messageInformationController)
        }
        
        messageInformationController.set(message: message)
        
        if let indexPath = viewModel.getIndexPath(for: message), let cell = tableView.cellForRow(at: indexPath) as? CometChatMessageBubble {
            messageInformationController.bubbleSnapshotView = cell.bubbleStackView.snapshotView(afterScreenUpdates: true)
        }
        
        if #available(iOS 15.0, *) {
            if let presentationController = navigationController.presentationController as? UISheetPresentationController {
                presentationController.detents = [.medium(), .large()]
                presentationController.prefersGrabberVisible = true
                controller?.present(navigationController, animated: true)
            }
        } else {
            controller?.present(navigationController, animated: true)
        }
                
        return self
    }
    
    @discardableResult
    public func clearList() -> Self {
        viewModel.clearList()
        return self
    }
    
    @discardableResult
    public func scrollToBottom(isAnimated: Bool = true) -> Self {
        if tableView.numberOfSections > 0 && tableView.numberOfRows(inSection: 0) > 0 {
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: isAnimated)
        }
        return self
    }
    
    @discardableResult
    public func isEmpty() -> Bool {
        return viewModel.messages.isEmpty ? true : false
    }
    
    public func scrollToLastVisibleCell() {
        if let lastCell = self.tableView.indexPathsForVisibleRows, let lastIndex = lastCell.last {
            self.tableView.scrollToLastVisibleCell(lastIndex: lastIndex)
        }
    }
    
}
