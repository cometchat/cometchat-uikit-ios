//
//  SavedMessagesViewModel.swift
//  CometChatUIKitSwift
//

import Foundation
import CometChatSDK

protocol SavedMessagesViewModelProtocol {

    var reload: (() -> Void)? { get set }
    var failure: ((CometChatSDK.CometChatException) -> Void)? { get set }
    func fetchSavedMessages()
}

public class SavedMessagesViewModel: SavedMessagesViewModelProtocol {

    /// Offline ON: two-phase read of the whole list (the server caps it at 100, so one read is all of
    /// it). The cached rows paint; the server's list replaces them, and a row the server no longer
    /// lists is removed. A failed read follows D84 (`OfflineReadFailure`): rows stay and a
    /// not-connected failure reports nothing; nothing on screen is "Connect to load messages" when not
    /// connected, the error view otherwise.
    private func offlineFetch(request: MessagesRequest, automatic: Bool = false) {
        let wasRefresh = isRefresh
        let hubGen = OfflineHub.shared.gen
        offlineError = .none
        let key: (BaseMessage) -> String? = { "\($0.id)" }
        // The cached rows are applied on a later main-queue turn, so the error phase cannot read
        // `messages` to know whether saved rows are on screen; it reads this instead.
        var cachedShown = false
        service.fetchSavedMessagesTwoPhase(request: request, onCached: { [weak self] page in
            guard let this = self, !page.isEmpty, hubGen == OfflineHub.shared.gen else { return }
            cachedShown = true
            this.offlineApply(SnapshotRows.paintCached(current: wasRefresh ? [] : this.messages, cachedPage: page, key: key))
        }, onServer: { [weak self] page in
            guard let this = self, hubGen == OfflineHub.shared.gen else { return }
            this.isFetchedAll = true
            this.isFetching = false
            this.isRefresh = false
            // The server's answer is the whole list (capped at 100): it replaces what is shown, so a
            // row no longer saved on the server goes.
            this.offlineApply(page)
        }, onError: { [weak self] error in
            guard let this = self, hubGen == OfflineHub.shared.gen else { return }
            this.isFetching = false
            this.isRefresh = false
            let rowsShown = cachedShown || !this.messages.isEmpty
            // Rows on screen stay; nothing on screen is the offline state or the error view. Only an
            // online failure of a load the user or app started reaches `onError` over rows.
            let verdict = OfflineReadFailure.evaluate(error, rowsShown: rowsShown, keywordSearch: false, kitStarted: automatic)
            this.offlineError = OfflineListError.afterFailure(error, rowsShown: rowsShown)
            if verdict.reportsError, let error = error {
                this.failure?(error)
            } else {
                // No callback to end a pull-to-refresh: redraw.
                this.reload?()
            }
        })
    }

    private func offlineApply(_ combined: [BaseMessage]) {
        var rows = combined
        rows.sort { $0.savedAt > $1.savedAt }
        DispatchQueue.main.async {
            self.messages = rows

            self.reload?()
        }
    }

    /// Newest save first. The only strong owner of these messages.
    var messages: [BaseMessage] = []

    var reload: (() -> Void)?
    /// Asks whether offline is on for this read (`OfflineGate.isOn`, read once per read). A seam so a
    /// test can drive the offline path of this one instance without a live SDK.
    internal var offlineGate: () -> Bool = { OfflineGate.isOn() }
    var removeAtIndex: ((IndexPath) -> Void)?
    var failure: ((CometChatSDK.CometChatException) -> Void)?
    /// Reports an unsave the server accepted, so the removal can be confirmed to the user.
    var unsaveSuccess: (() -> Void)?
    /// Reports an unsave that the server rejected, so the row can be restored.
    var unsaveFailure: ((CometChatSDK.CometChatException) -> Void)?

    var requestBuilder: MessagesRequest.MessageRequestBuilder
    var request: MessagesRequest?

    /// Offline ON: set by `connected()` just before the refetch it triggers, so a failure of that
    /// automatic read stays quiet while rows are on screen. Read and cleared at the start of the next fetch.
    var automaticRefetch = false
    /// Offline ON: why the offline state or error view is showing over nothing. Cleared when the next
    /// read starts.
    var offlineError: OfflineListError = .none
    /// Offline ON (D84 rule 3): the list could not load for want of a connection and shows nothing:
    /// "Connect to load messages" (the app's error view, if it set one), `onError` once.
    var connectToLoad: Bool { return offlineError == .notConnected }
    /// Offline ON: a reconnect leaves the list alone while its error view is for a non-network error.
    var skipsReconnectReload: Bool { return offlineGate() && offlineError.skipsReconnectReload }
    var isFetching = false
    var isFetchedAll = false
    var isRefresh: Bool = false {
        didSet {
            if isRefresh {
                self.fetchSavedMessages()
            }
        }
    }

    /// Seam over the SDK request/response calls. Defaulted so callers are unchanged.
    private let service: SavedMessagesServicing

    init(
        requestBuilder: MessagesRequest.MessageRequestBuilder? = nil,
        service: SavedMessagesServicing = LiveSavedMessagesService()
    ) {
        self.service = service
        self.requestBuilder = requestBuilder ?? SavedMessagesBuilder.getDefaultRequestBuilder()
        self.request = self.requestBuilder.build()
    }

    public func setRequestBuilder(requestBuilder: MessagesRequest.MessageRequestBuilder) {
        self.requestBuilder = requestBuilder
        self.request = self.requestBuilder.build()
    }

    /// The server caps saved messages at 100 (design doc §8-Q10), and the builder asks for
    /// exactly that, so one fetch is the whole list — fetch-all-and-count, no pagination.
    /// A refresh rebuilds the request because an exhausted one returns empty forever.
    func fetchSavedMessages() {
        let automatic = automaticRefetch
        automaticRefetch = false
        if isRefresh {
            isFetchedAll = false
            request = requestBuilder.build()
        }

        guard let request = request else { return }
        if isFetchedAll || isFetching { return }

        isFetching = true

        // Offline ON (read once for this read): the on-device list paints first, the server's replaces it.
        if offlineGate() {
            offlineFetch(request: request, automatic: automatic)
            return
        }

        service.fetchSavedMessages(request: request) { [weak self] result in
            guard let this = self else { return }
            switch result {
            case .success(let fetched):
                if this.isRefresh {
                    this.messages.removeAll()
                    this.isRefresh = false
                }
                this.isFetchedAll = true
                this.isFetching = false
                this.append(messages: fetched)
            case .failure(let error):
                this.isFetching = false
                this.isRefresh = false
                this.failure?(error)
            }
        }
    }

    /// Newest save first. `savedAt` is the sort key, not `sentAt` — an old message saved
    /// today belongs at the top.
    private func append(messages: [BaseMessage]) {
        var combined = self.messages
        for message in messages where !combined.contains(where: { $0.id == message.id }) {
            combined.append(message)
        }
        combined.sort { $0.savedAt > $1.savedAt }

        DispatchQueue.main.async {
            self.messages = combined
            self.reload?()
        }
    }

    func connect() {
        CometChatMessageEvents.addListener(SavedMessagesConstants.eventListener, self)
        OfflineHub.shared.addObserver(SavedMessagesConstants.eventListener, self)
    }

    func disconnect() {
        CometChatMessageEvents.removeListener(SavedMessagesConstants.eventListener)
        OfflineHub.shared.removeObserver(SavedMessagesConstants.eventListener)
    }

    func indexPath(for messageId: Int) -> IndexPath? {
        guard let row = messages.firstIndex(where: { $0.id == messageId }) else { return nil }
        return IndexPath(row: row, section: 0)
    }

    // MARK: - Unsave

    /// Removes the row first and restores it if the server rejects the unsave, so the
    /// list matches the bubble surface's optimistic behaviour.
    func unsave(message: BaseMessage) {
        let messageId = message.id
        guard MessageActionToggleGuard.shared.begin(action: .save, messageId: messageId) else { return }

        guard let indexPath = indexPath(for: messageId) else {
            MessageActionToggleGuard.shared.end(action: .save, messageId: messageId)
            return
        }

        let removed = messages[indexPath.row]
        messages.remove(at: indexPath.row)
        removeAtIndex?(indexPath)

        service.unsaveMessage(messageId: messageId) { [weak self] updated in
            MessageActionToggleGuard.shared.end(action: .save, messageId: messageId)
            guard let this = self else { return }
            DispatchQueue.main.async {
                CometChatMessageEvents.ccMessageSaved(message: updated, status: .success)
                // The row is already gone; reload settles the empty state.
                this.reload?()
                this.unsaveSuccess?()
            }
        } onError: { [weak self] error in
            MessageActionToggleGuard.shared.end(action: .save, messageId: messageId)
            guard let this = self else { return }
            DispatchQueue.main.async {
                this.restore(message: removed)
                this.unsaveFailure?(error)
            }
        }
    }

    private func restore(message: BaseMessage) {
        guard !messages.contains(where: { $0.id == message.id }) else { return }
        messages.append(message)
        messages.sort { $0.savedAt > $1.savedAt }
        reload?()
    }

    // MARK: - List mutation

    @discardableResult
    func add(message: BaseMessage) -> Self {
        guard !messages.contains(where: { $0.id == message.id }) else { return self }
        messages.append(message)
        messages.sort { $0.savedAt > $1.savedAt }
        reload?()
        return self
    }

    @discardableResult
    func remove(messageId: Int) -> Self {
        guard let indexPath = indexPath(for: messageId) else { return self }
        messages.remove(at: indexPath.row)
        reload?()
        return self
    }

    func size() -> Int {
        return messages.count
    }
}

// MARK: - Offline hub

extension SavedMessagesViewModel: OfflineHubObserver {

    /// Logout, user switch or cache reset: no row of the old session survives.
    func offlineSessionChanged(gen: Int) {
        messages = []
        offlineError = .none
        isFetching = false
        isFetchedAll = false
        isRefresh = false
        reload?()
    }

    /// The cache was rebuilt: read the list again, two-phase.
    func offlineCacheReset(_ event: OfflineCacheResetEvent) {
        guard event.gen == OfflineHub.shared.gen else { return }
        request = requestBuilder.build()
        // The kit's own reload: it fails quietly over rows on screen.
        automaticRefetch = true
        fetchSavedMessages()
    }

    /// A user logged in (a token refresh keeps the cache): reload what was cleared.
    func offlineSessionStarted(gen: Int) {
        guard messages.isEmpty, gen == OfflineHub.shared.gen else { return }
        request = requestBuilder.build()
        fetchSavedMessages()
    }
}
