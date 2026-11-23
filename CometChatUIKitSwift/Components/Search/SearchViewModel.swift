//
//  SearchViewModel.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 08/08/25.
//

import Foundation
import CometChatSDK

open class SearchViewModel: NSObject {
    /// Seam over the listener registries, so `connect()`/`disconnect()` symmetry is
    /// assertable without a live SDK. Defaults to the real registrar.
    internal var listeners: ListenerRegistering = SDKListenerRegistrar.shared

    
    public var isLoadingMessages = false
    public var hasMoreMessages = true
    public let pageLimit = 30
    
    public var displayedMessageCount = 3
    public var displayedConversationCount = 3
    
    public var filterConversationRequest: ConversationRequest?
    public var filterMessageRequest: MessagesRequest?
    
    public var filteredConversations: [Conversation] = []
    public var filteredMessages: [BaseMessage] = []
    
    /// Moves on every keyword search and when the search is cleared. A search answer that carries an
    /// older value is for a keyword no longer shown, and is dropped (a slow old search replaced the new one).
    internal var searchGeneration = 0
    private var searchWorkItem: DispatchWorkItem? = nil
    func searchWorkItemCancel() { searchWorkItem?.cancel() }
    private var currentSearchText: String = ""
    /// The keyword of the last search, set as the search starts (offline ON: "Connect to search" is for a keyword).
    fileprivate(set) var searchKeyword = ""
    var listenerRandomID = Date().timeIntervalSince1970
    
    var onSearch: ((SearchState, String) -> ())?
    var reloadAtIndex: ((IndexPath) -> Void)?
    var reload: (() -> Void)?

    /// Whether the last conversation / message search request failed (e.g. the app's plan
    /// does not include Advanced Search). Every request ends with `reload`, success or
    /// failure, so the screen always leaves its loading state — as the Android UI Kit's
    /// search view model does; the screen shows the error state when both failed.
    var conversationSearchFailed = false
    var messageSearchFailed = false
    /// Offline ON: the search is an offline miss (it shows "Connect to search", or its error view is for a
    /// not-connected error). The same search runs again once when the connection returns (D84 rule 8).
    var searchReloadOnConnect = false
    /// Offline ON: a request of this search failed with an error other than not-connected. The search is
    /// then no offline miss: it takes the normal error path.
    var searchFailedOnline = false
    /// Offline ON: a keyword request of this search failed for want of a connection (Android's
    /// `offlineKeywordFailed`).
    private(set) var keywordFailedNotConnected = false
    /// Offline ON: the error of the request that failed last (the error view's error).
    private(set) var lastSearchError: CometChatException?
    /// Offline ON: the error of a request that failed with an error other than not-connected. If results
    /// stay on screen it is the one `onError` reports (rule 5).
    private var onlineSearchError: CometChatException?
    /// The first-page requests of this search run that have not ended yet (offline ON). The screen's state
    /// and `onError` wait until it is 0, as Android's `updateFinalStateIfCompleted` does.
    private(set) var pendingRequests = 0
    /// This run is the kit's own re-run on reconnect: a failure over results reports nothing (rule 5).
    private var searchQuiet = false
    /// Reports a failed search to the app (offline ON). Once per search run, not once per scope.
    var onError: ((CometChatException) -> Void)?
    /// The search run `onError` last fired for.
    private var errorReportedGeneration = -1
    /// Runs the last search again with the same keyword, filters and scopes.
    private var rerunLastSearch: (() -> Void)?

    var user: User?
    var group: Group?
    
    public var activeScopes: [SearchScope] = []

    /// Seam over the logged-in user read by the event handlers. Defaults to the live
    /// SDK-backed implementation so existing callers are unaffected; tests inject a fake.
    internal var service: SearchServicing

    public override init() {
        self.service = LiveSearchService()
        super.init()
        connect()
    }

    /// Test/internal seam: inject a custom service. Skips `connect()` so no real
    /// SDK / event listeners are registered during hermetic unit tests.
    internal init(service: SearchServicing) {
        self.service = service
        super.init()
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
        startSearch(searchText, selectedFilters: selectedFilters, attachmentTypes: attachmentTypes,
                    hasLinks: hasLinks, quiet: false)
    }

    /// One search run. `quiet` is for the kit's own re-run on reconnect.
    private func startSearch(
        _ searchText: String?,
        selectedFilters: [FilterItem],
        attachmentTypes: [CometChat.AttachmentType],
        hasLinks: Bool,
        quiet: Bool
    ) {
        
        self.filterMessageRequest = nil
        self.filteredMessages.removeAll()
        self.hasMoreMessages = true
        self.isLoadingMessages = false
        self.conversationSearchFailed = false
        self.messageSearchFailed = false
        self.searchReloadOnConnect = false
        self.searchFailedOnline = false
        self.keywordFailedNotConnected = false
        self.lastSearchError = nil
        self.onlineSearchError = nil
        self.pendingRequests = 0
        self.searchQuiet = quiet
        self.searchKeyword = searchText ?? ""
        self.rerunLastSearch = { [weak self] in
            self?.startSearch(searchText, selectedFilters: selectedFilters,
                              attachmentTypes: attachmentTypes, hasLinks: hasLinks, quiet: true)
        }

        searchWorkItem?.cancel()
        searchGeneration &+= 1
        
        let task = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            // A whitespace-only query is no query: trim before the empty check so "   "
            // returns the screen to its initial state instead of searching for spaces.
            let text = (searchText ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
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
            
            // Offline ON: the requests this run waits for, and no row of an older search stands in for a
            // search that could not run (Android clears its lists as the search starts).
            if OfflineGate.isOn() {
                self.offlineRunStarted(requests: (self.activeScopes.contains(.conversations) ? 1 : 0)
                                                 + (self.activeScopes.contains(.messages) ? 1 : 0))
                self.filteredConversations.removeAll()
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
                let generation = self.searchGeneration
                let onConversations: ([Conversation]) -> Void = { conversations in
                        DispatchQueue.main.async {
                            guard generation == self.searchGeneration else { return }
                            self.conversationSearchFailed = false
                            self.filteredConversations = conversations
                            self.offlineSearchAnswered(offline: OfflineGate.isOn())
                            self.reload?()
                        }
                    }
                let onConversationError: (CometChatException?) -> Void = { error in
                        CometChatLogger.error("\(error?.errorDescription ?? "")")
                        DispatchQueue.main.async {
                            guard generation == self.searchGeneration else { return }
                            self.conversationSearchFailed = true
                            self.offlineSearchFailed(error, offline: OfflineGate.isOn())
                            self.reload?()
                        }
                    }
                // Offline ON (read once for this search): the two-phase read answers "not connected"
                // for no answer at all; the one-phase read reports only the transport's own error.
                if OfflineGate.isOn() {
                    self.filterConversationRequest?.fetchNext(onCachedConversations: { _ in }, onServerConversations: onConversations, onError: onConversationError)
                } else {
                    self.filterConversationRequest?.fetchNext(onSuccess: onConversations, onError: onConversationError)
                }
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
        listeners.add(.offlineHub, id: "search-offline-hub-listener-\(listenerRandomID)", listener: self as OfflineHubObserver)
        listeners.add(.groupSDK, id: "conversations-list-groups-sdk-listner-\(listenerRandomID)", listener: self)
        listeners.add(.groupEvents, id: "conversations-list-groups-event-listner-\(listenerRandomID)", listener: self)
        listeners.add(.messageEvents, id: "conversations-list-messages-event-listener-\(listenerRandomID)", listener: self)
        listeners.add(.conversationEvents, id: "user-details-conversations-event-listener-\(listenerRandomID)", listener: self)
    }
    
    // MARK:- disconnect conversation listener
    public func disconnect() {
        listeners.remove(.offlineHub, id: "search-offline-hub-listener-\(listenerRandomID)")
        listeners.remove(.groupSDK, id: "conversations-list-groups-sdk-listner-\(listenerRandomID)")
        listeners.remove(.groupEvents, id: "conversations-list-groups-event-listner-\(listenerRandomID)")
        listeners.remove(.messageEvents, id: "conversations-list-messages-event-listener-\(listenerRandomID)")
        listeners.remove(.conversationEvents, id: "user-details-conversations-event-listener-\(listenerRandomID)")
    }
    
    func fetchNextMessages(
        searchText: String,
        attachmentTypes: [CometChat.AttachmentType],
        hasLinks: Bool
    ) {
        guard !isLoadingMessages, hasMoreMessages else { return }

        isLoadingMessages = true
        let generation = searchGeneration

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

        let keyword = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !keyword.isEmpty {
            builder = builder.set(searchKeyword: keyword)
        }

        // Filter by category only — NOT by type. Developer cards (category `card`) can carry
        // any developer-defined type (e.g. "product"), and the SDK filters on the raw type sent.
        // Enumerating types would drop cards whose type isn't in the fixed list, so they'd never
        // appear in search results. The display layer keeps only text + card messages.
        builder = builder
            .set(categories: ChatConfigurator.getDataSource().getAllMessageCategories() ?? [])

        // Pages after the first are the user scrolling: their failure is not this search's `onError`.
        let isFirstPage = filterMessageRequest == nil
        if filterMessageRequest == nil {
            filterMessageRequest = builder.build()
        }

        let onMessages: ([BaseMessage]?) -> Void = { messages in
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
                                CometChatLogger.debug("no parent message found")
                                group.leave()
                            }
                        }
                    }

                    group.notify(queue: .main) {
                        // A newer search has begun: this page is for a keyword no longer shown, and
                        // the flag it would clear belongs to the new search's read.
                        guard generation == self.searchGeneration else { return }
                        // Remove all messages whose parent was found deleted
                        validMessages.removeAll { msg in
                            invalidParentIds.contains(msg.parentMessageId)
                        }
                        
                        if validMessages.count < self.pageLimit {
                            self.hasMoreMessages = false
                        }

                        self.filteredMessages.append(contentsOf: validMessages.reversed())
                        self.isLoadingMessages = false
                        self.messageSearchFailed = false
                        if isFirstPage { self.offlineSearchAnswered(offline: OfflineGate.isOn()) }
                        self.reload?()

                        self.reload?()
                    }
                }
            }
        let onMessageError: (CometChatException?) -> Void = { [weak self] error in
                CometChatLogger.error("\(error?.errorDescription ?? "")")
                DispatchQueue.main.async {
                    guard let self = self, generation == self.searchGeneration else { return }
                    self.isLoadingMessages = false
                    self.messageSearchFailed = true
                    if isFirstPage { self.offlineSearchFailed(error, offline: OfflineGate.isOn()) }
                    self.reload?()
                }
            }
        // Offline ON (read once for this search): the two-phase read answers "not connected" for no
        // answer at all; the one-phase read reports only the transport's own error.
        if OfflineGate.isOn() {
            filterMessageRequest?.fetchPrevious(onCachedMessages: { _ in }, onServerMessages: { onMessages($0) }, onError: onMessageError)
        } else {
            filterMessageRequest?.fetchPrevious(onSuccess: onMessages, onError: onMessageError)
        }
    }

}

// MARK: - Offline failures (D84 rule 7, as the Android Search screen)

extension SearchViewModel {

    /// A search run that waits for `requests` first-page requests begins (offline ON).
    func offlineRunStarted(requests: Int) {
        pendingRequests = requests
    }

    /// A first-page search request failed. Offline ON only. The failure is recorded; what the screen shows,
    /// whether `onError` fires and whether the search runs again on reconnect are decided once every
    /// request of the run has ended (`OfflineSearchOutcome`).
    func offlineSearchFailed(_ error: CometChatException?, offline: Bool) {
        guard offline else { return }
        let notConnected = OfflineErrors.isNotConnected(code: error?.errorCode)
        if notConnected {
            if hasKeyword { keywordFailedNotConnected = true }
        } else {
            searchFailedOnline = true
            onlineSearchError = error
        }
        lastSearchError = error
        requestEnded()
    }

    /// A first-page search request was answered. Offline ON only.
    func offlineSearchAnswered(offline: Bool) {
        guard offline else { return }
        requestEnded()
    }

    private func requestEnded() {
        if pendingRequests > 0 { pendingRequests -= 1 }
        guard pendingRequests == 0, let outcome = offlineOutcome() else { return }
        searchReloadOnConnect = outcome.runsAgainOnReconnect
        guard outcome.reportsError, errorReportedGeneration != searchGeneration else { return }
        errorReportedGeneration = searchGeneration
        if let error = (outcome.screen == .errorView ? lastSearchError : onlineSearchError) { onError?(error) }
    }

    /// The search carries a keyword: the search box has text.
    var hasKeyword: Bool { return OfflineReadFailure.isKeyword(searchKeyword) }

    /// What this search leaves on screen (offline ON); `nil` while a request is still out.
    func offlineOutcome() -> OfflineSearchOutcome? {
        guard pendingRequests == 0 else { return nil }
        return OfflineSearchOutcome.evaluate(
            nothingShown: filteredConversations.isEmpty && filteredMessages.isEmpty,
            conversationFailed: conversationSearchFailed,
            messageFailed: messageSearchFailed,
            failedOnline: searchFailedOnline,
            keywordFailedNotConnected: keywordFailedNotConnected,
            lastErrorNotConnected: OfflineErrors.isNotConnected(code: lastSearchError?.errorCode),
            rowsKeptError: onlineSearchError != nil,
            quiet: searchQuiet)
    }

    /// "Connect to search" and "Search needs an internet connection." are showing (D84 rule 7).
    var connectToSearch: Bool { return offlineOutcome()?.screen == .connectToSearch }

    /// The connection is back: a search that was an offline miss runs again, once, as the kit's own read.
    func offlineReconnected(offline: Bool) {
        guard offline, searchReloadOnConnect else { return }
        searchReloadOnConnect = false
        rerunLastSearch?()
    }
}

// MARK: - Offline hub

extension SearchViewModel: OfflineHubObserver {

    /// Logout, user switch or cache reset: no result of the old session survives.
    func offlineSessionChanged(gen: Int) {
        searchWorkItemCancel()
        filteredConversations.removeAll()
        filteredMessages.removeAll()
        conversationSearchFailed = false
        messageSearchFailed = false
        searchReloadOnConnect = false
        searchFailedOnline = false
        keywordFailedNotConnected = false
        lastSearchError = nil
        onlineSearchError = nil
        pendingRequests = 0
        reload?()
    }
}
