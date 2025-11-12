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
    public func set(suggestedMessages: [String]) ->  Self {
        self.suggestedMessages = suggestedMessages
        return self
    }
    
    @discardableResult
    public func set(emptyChatAIGreetingView: UIView) ->  Self {
        self.emptyChatAIGreetingView = emptyChatAIGreetingView
        return self
    }
    
    @discardableResult
    public func set(streamingSpeed: Int) ->  Self {
        self.streamingSpeed = streamingSpeed
        return self
    }
    
    //MARK: Data
    @discardableResult
    public func set(user: User, parentMessage: BaseMessage? = nil, withParent: Bool = false) -> Self {
        self.viewModel.set(user: user, messagesRequestBuilder: self.messagesRequestBuilder, parentMessage: parentMessage, withParent: withParent)
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
        self.viewModel.set(messagesRequestBuilder: messagesRequestBuilder)
        return self
    }
    
    @discardableResult
    public func set(templates: [CometChatMessageTemplate]) -> Self {
        viewModel.templates.removeAll()
        for template in (templates) {
            viewModel.templates["\(template.category)_\(template.type)"] = template
        }
        return self
    }
    
    @discardableResult
    public func add(templates: [CometChatMessageTemplate]) -> Self {
        for template in (templates) {
            viewModel.templates["\(template.category)_\(template.type)"] = template
        }
        return self
    }
    
    @discardableResult
    public func set(reactionsRequestBuilder: ReactionsRequestBuilder) -> Self {
        self.reactionsRequestBuilder = reactionsRequestBuilder
        return self
    }
    
    @discardableResult
    public func set(parentMessageId: Int) ->  Self {
        viewModel.parentMessage?.id = parentMessageId
        if let user = viewModel.user{
            viewModel.set(user: user, messagesRequestBuilder: self.messagesRequestBuilder)
        }else{
            viewModel.set(group: viewModel.group!, messagesRequestBuilder: self.messagesRequestBuilder)
        }
        
        return self
    }
    
    
    //MARK: Event
    @discardableResult
    public func set(onReactionClick: ((_ reaction: ReactionCount, _ baseMessage: BaseMessage?) -> ())?) -> Self {
        self.onReactionClick = onReactionClick
        return self
    }
    
    @discardableResult
    public func set(onReactionListItemClick: ((_ messageReaction: CometChatSDK.Reaction, _ baseMessage: BaseMessage?) -> ())?) -> Self {
        self.onReactionListItemClick = onReactionListItemClick
        return self
    }
    
    @discardableResult
    public func set(onThreadRepliesClick: ((_ message: BaseMessage, _ template: CometChatMessageTemplate) -> ())?) -> Self {
        self.onThreadRepliesClick = onThreadRepliesClick
        return self
    }
    
    @discardableResult
    public func set(onError: @escaping ((_ error: CometChatException) -> Void)) -> Self {
        self.onError = onError
        return self
    }
    
    @discardableResult
    public func set(onLoad: @escaping (([BaseMessage]) -> Void)) -> Self {
        self.onLoad = onLoad
        return self
    }
    
    @discardableResult
    public func set(onEmpty: @escaping (() -> Void)) -> Self {
        self.onEmpty = onEmpty
        return self
    }
    
    
    //MARK: Configurations
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
    public func set(datePattern: ((_ timestamp: Int?) -> String)?) -> Self {
        self.datePattern = datePattern
        return self
    }
    
    @discardableResult
    public func set(timePattern: ((_ timestamp: Int?) -> String)?) -> Self {
        self.timePattern = timePattern
        return self
    }
    
    @discardableResult
    public func set(dateSeparatorPattern: ((_ timestamp: Int?) -> String)?) -> Self {
        self.dateSeparatorPattern = dateSeparatorPattern
        return self
    }
    
    @discardableResult
    public func scrollToBottom(isAnimated: Bool = true) -> Self {
        if tableView.numberOfSections > 0 && tableView.numberOfRows(inSection: 0) > 0 {
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: isAnimated)
        }
        return self
    }
    
    @discardableResult
    public func set(messageAlignment: MessageListAlignment) -> Self {
        self.messageAlignment = messageAlignment
        return self
    }
    
    @discardableResult
    public func set(smartRepliesKeywords: [String]) -> Self {
        self.smartRepliesKeywords = smartRepliesKeywords
        return self
    }
    
    @discardableResult
    public func set(smartRepliesDelayDuration: Int) -> Self {
        self.smartRepliesDelayDuration = smartRepliesDelayDuration  
        return self
    }
    
    
    
    //MARK: Overrides
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
    public func set(loadingView: UIView) ->  Self {
        self.loadingStateView = loadingView
        return self
    }
    
    @discardableResult
    public func set(errorView: UIView) ->  Self {
        self.errorStateView = errorView
        return self
    }
    
    @discardableResult
    public func set(emptyView: UIView) ->  Self {
        self.emptyStateView = emptyView
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
        messageInformationController.dateTimeFormatter = dateTimeFormatter
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
    public func isEmpty() -> Bool {
        return viewModel.messages.isEmpty ? true : false
    }
    
    public func scrollToLastVisibleCell() {
        if let lastCell = self.tableView.indexPathsForVisibleRows, let lastIndex = lastCell.last {
            self.tableView.scrollToLastVisibleCell(lastIndex: lastIndex)
        }
    }
    
    public func getAdditionalConfiguration() -> AdditionalConfiguration {
        return viewModel.additionalConfiguration
    }
    
}
