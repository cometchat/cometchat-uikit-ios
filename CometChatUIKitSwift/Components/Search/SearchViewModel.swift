//
//  SearchViewModel.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 08/08/25.
//

import Foundation
import CometChatSDK

open class SearchViewModel: NSObject {
    
    public var isLoadingMessages = false
    public var hasMoreMessages = true
    public let pageLimit = 30
    
    public var displayedMessageCount = 3
    public var displayedConversationCount = 3
    
    public var filterConversationRequest: ConversationRequest?
    public var filterMessageRequest: MessagesRequest?
    
    public var filteredConversations: [Conversation] = []
    public var filteredMessages: [BaseMessage] = []
    
    private var searchWorkItem: DispatchWorkItem? = nil
    private var currentSearchText: String = ""
    var listenerRandomID = Date().timeIntervalSince1970
    
    var onSearch: ((SearchState, String) -> ())?
    var reloadAtIndex: ((IndexPath) -> Void)?
    var reload: (() -> Void)?
    
    var user: User?
    var group: Group?
    
    public var activeScopes: [SearchScope] = []
    
    public override init() {
        super.init()
        connect()
    }
    
    deinit {
        disconnect()
    }
    
    /// Filters conversations and messages based on text, filters, attachmentTypes, or links
    public func filterContentForSearchText(
        _ searchText: String?,
        selectedFilters: [FilterItem] = [],
        attachmentTypes: [CometChat.AttachmentType] = [],
        hasLinks: Bool = false
    ) {
        
        self.filterMessageRequest = nil
        self.filteredMessages.removeAll()
        self.hasMoreMessages = true
        self.isLoadingMessages = false

        searchWorkItem?.cancel()
        
        let task = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            let text = searchText ?? ""
            self.currentSearchText = text
            
            // Reset counts
            self.displayedMessageCount = 3
            self.displayedConversationCount = 3
            
            // Case: nothing to search
            if text.isEmpty && selectedFilters.isEmpty && !hasLinks && attachmentTypes.isEmpty {
                self.filteredConversations.removeAll()
                self.filteredMessages.removeAll()
                self.reload?()
                return
            }
            
            // --- Conversations search ---
            if self.activeScopes.contains(.conversations) {
                var builder = ConversationsBuilder.getDefaultRequestBuilder()
                    .set(searchKeyword: text)
                
                if selectedFilters.contains(where: { $0.title == "Groups" }) {
                    builder = builder.setConversationType(conversationType: .group)
                }
                if selectedFilters.contains(where: { $0.title == "Unread" }) {
                    builder = builder.set(unread: true)
                }
                
                self.filterConversationRequest = builder.build()
                self.filterConversationRequest?.fetchNext(
                    onSuccess: { conversations in
                        DispatchQueue.main.async {
                            self.filteredConversations = conversations
                            self.reload?()
                        }
                    },
                    onError: { error in
                        print(error?.errorDescription ?? "")
                    }
                )
            } else {
                self.filteredConversations.removeAll()
            }
            
            // --- Messages search ---
            if self.activeScopes.contains(.messages) {
                self.fetchNextMessages(
                    searchText: text,
                    attachmentTypes: attachmentTypes,
                    hasLinks: hasLinks
                )

            } else {
                self.filteredMessages.removeAll()
            }
        }
        
        searchWorkItem = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: task)
    }
    
    public func connect() {
        CometChat.addGroupListener("conversations-list-groups-sdk-listner-\(listenerRandomID)", self)
        CometChatGroupEvents.addListener("conversations-list-groups-event-listner-\(listenerRandomID)", self)
        CometChatMessageEvents.addListener("conversations-list-messages-event-listener-\(listenerRandomID)", self)
        CometChatConversationEvents.addListener("user-details-conversations-event-listener-\(listenerRandomID)", self)
    }
    
    // MARK:- disconnect conversation listener
    public func disconnect() {
        CometChat.removeGroupListener("conversations-list-groups-sdk-listner-\(listenerRandomID)")
        CometChatGroupEvents.removeListener("conversations-list-groups-event-listner-\(listenerRandomID)")
        CometChatMessageEvents.removeListener("conversations-list-messages-event-listener-\(listenerRandomID)")
        CometChatConversationEvents.removeListener("user-details-conversations-event-listener-\(listenerRandomID)")
    }
    
    func fetchNextMessages(
        searchText: String,
        attachmentTypes: [CometChat.AttachmentType],
        hasLinks: Bool
    ) {
        guard !isLoadingMessages, hasMoreMessages else { return }

        isLoadingMessages = true

        var builder = MessagesListBuilder.getDefaultRequestBuilder()
            .set(limit: pageLimit)
            .hideDeletedMessages(hide: true)

        if !attachmentTypes.isEmpty {
            builder = builder.set(attachmentTypes: attachmentTypes)
        }

        if hasLinks {
            builder = builder.has(links: true)
        }

        if let user = user {
            builder = builder.set(uid: user.uid ?? "")
        }

        if let group = group {
            builder = builder.set(guid: group.guid)
        }

        if !searchText.isEmpty {
            builder = builder.set(searchKeyword: searchText)
        }

        // Filter by category only — NOT by type. Developer cards (category `card`) can carry
        // any developer-defined type (e.g. "product"), and the SDK filters on the raw type sent.
        // Enumerating types would drop cards whose type isn't in the fixed list, so they'd never
        // appear in search results. The display layer keeps only text + card messages.
        builder = builder
            .set(categories: ChatConfigurator.getDataSource().getAllMessageCategories() ?? [])

        if filterMessageRequest == nil {
            filterMessageRequest = builder.build()
        }

        filterMessageRequest?.fetchPrevious(
            onSuccess: { messages in
                DispatchQueue.main.async {
                    var validMessages = (messages ?? []).filter { $0.deletedAt == 0 && !($0 is ActionMessage) }

                    let group = DispatchGroup()
                    var invalidParentIds: Set<Int> = []

                    for message in validMessages {
                        if message.parentMessageId > 0 {
                            group.enter()
                            CometChat.getMessageDetails(message.parentMessageId) { parent in

                                if parent.deletedAt > 0 {
                                    invalidParentIds.insert(parent.id)
                                }
                                group.leave()

                            } onError: { error in
                                print("no parent message found")
                                group.leave()
                            }
                        }
                    }

                    group.notify(queue: .main) {
                        // Remove all messages whose parent was found deleted
                        validMessages.removeAll { msg in
                            invalidParentIds.contains(msg.parentMessageId)
                        }
                        
                        if validMessages.count < self.pageLimit {
                            self.hasMoreMessages = false
                        }

                        self.filteredMessages.append(contentsOf: validMessages.reversed())
                        self.isLoadingMessages = false
                        self.reload?()

                        self.reload?()
                    }
                }
            },
            onError: { [weak self] _ in
                self?.isLoadingMessages = false
            }
        )
    }

}
