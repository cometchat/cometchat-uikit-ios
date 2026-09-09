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

    /// Newest save first. The only strong owner of these messages.
    var messages: [BaseMessage] = []

    var reload: (() -> Void)?
    var removeAtIndex: ((IndexPath) -> Void)?
    var failure: ((CometChatSDK.CometChatException) -> Void)?
    /// Reports an unsave the server accepted, so the removal can be confirmed to the user.
    var unsaveSuccess: (() -> Void)?
    /// Reports an unsave that the server rejected, so the row can be restored.
    var unsaveFailure: ((CometChatSDK.CometChatException) -> Void)?

    var requestBuilder: MessagesRequest.MessageRequestBuilder
    var request: MessagesRequest?

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
        if isRefresh {
            isFetchedAll = false
            request = requestBuilder.build()
        }

        guard let request = request else { return }
        if isFetchedAll || isFetching { return }

        isFetching = true

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
    }

    func disconnect() {
        CometChatMessageEvents.removeListener(SavedMessagesConstants.eventListener)
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
