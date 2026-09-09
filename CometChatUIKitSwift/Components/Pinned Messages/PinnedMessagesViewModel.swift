//
//  PinnedMessagesViewModel.swift
//  CometChatUIKitSwift
//

import Foundation
import CometChatSDK

protocol PinnedMessagesViewModelProtocol {

    var reload: (() -> Void)? { get set }
    var failure: ((CometChatSDK.CometChatException) -> Void)? { get set }
    func fetchPinnedMessages()
}

/// One day's worth of pinned messages, keyed by the start of that day.
struct PinnedMessageSection {
    let date: Int
    var messages: [BaseMessage]
}

public class PinnedMessagesViewModel: PinnedMessagesViewModelProtocol {

    /// Newest pin first. The only strong owner of these messages — the bubble holds its
    /// `baseMessage` weakly, so this array must outlive every cell.
    var messages: [BaseMessage] = []

    /// Derived from `messages`; rebuilt on every mutation, never mutated directly.
    private(set) var sections: [PinnedMessageSection] = []

    /// Resolved once per appearance, keyed `"<category>_<type>"`.
    var templates = [String: CometChatMessageTemplate]()
    var additionalConfiguration = AdditionalConfiguration()

    var textFormatters: [CometChatTextFormatter] = []
    var messageBubbleStyle = CometChatMessageBubble.style
    var actionBubbleStyle = CometChatMessageBubble.actionBubbleStyle
    var callActionBubbleStyle = CometChatMessageBubble.callActionBubbleStyle
    var enableMultipleAttachments: Bool = true
    /// Gates the "Stop notifications" context-menu option, exactly as on the message list.

    var reload: (() -> Void)?
    var removeAtIndex: ((IndexPath) -> Void)?
    var failure: ((CometChatSDK.CometChatException) -> Void)?
    /// Reports an unpin that the server rejected, so the row can be restored.
    var unpinFailure: ((CometChatSDK.CometChatException) -> Void)?
    /// Reports a context-menu action that failed with the list left untouched.
    var actionFailure: ((CometChatSDK.CometChatException) -> Void)?

    var user: User?
    var group: Group?

    /// Listener registration key. The registry is keyed by id and holds observers weakly,
    /// so two view models sharing a key evict each other — the banner therefore registers
    /// under its own id and the panel keeps the default.
    var listenerId: String = PinnedMessagesConstants.eventListener

    var requestBuilder: MessagesRequest.MessageRequestBuilder
    var request: MessagesRequest?

    var isFetching = false
    var isFetchedAll = false
    var isRefresh: Bool = false {
        didSet {
            if isRefresh {
                self.fetchPinnedMessages()
            }
        }
    }

    /// Seam over the SDK request/response calls. Defaulted so callers are unchanged.
    private let service: PinnedMessagesServicing

    init(
        user: User?,
        group: Group?,
        requestBuilder: MessagesRequest.MessageRequestBuilder? = nil,
        service: PinnedMessagesServicing = LivePinnedMessagesService()
    ) {
        self.user = user
        self.group = group
        self.service = service
        self.requestBuilder = requestBuilder ?? PinnedMessagesBuilder.getRequestBuilder(user: user, group: group)
        self.request = self.requestBuilder.build()
    }

    public func setRequestBuilder(requestBuilder: MessagesRequest.MessageRequestBuilder) {
        self.requestBuilder = requestBuilder
        self.request = self.requestBuilder.build()
    }

    /// The server caps pinned messages at 100 (design doc §8-Q10), and the builder asks for
    /// exactly that, so one fetch is the whole list — fetch-all-and-count, no pagination.
    /// A refresh rebuilds the request because an exhausted one returns empty forever.
    func fetchPinnedMessages() {
        if isRefresh {
            isFetchedAll = false
            request = requestBuilder.build()
        }

        guard let request = request else { return }
        if isFetchedAll || isFetching { return }

        isFetching = true

        service.fetchPinnedMessages(request: request) { [weak self] result in
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

    /// Newest pin first. `pinnedAt` is the sort key, not `sentAt` — an old message
    /// pinned today belongs at the top.
    private func append(messages: [BaseMessage]) {
        var combined = self.messages
        for message in messages where !combined.contains(where: { $0.id == message.id }) {
            combined.append(message)
        }
        combined.sort { $0.pinnedAt > $1.pinnedAt }

        DispatchQueue.main.async {
            self.messages = combined
            self.rebuildSections()
            self.reload?()
        }
    }

    /// Buckets by the calendar day of `pinnedAt` — the same key the list is sorted by, so
    /// one linear pass yields contiguous sections already in newest-first order. Grouping
    /// by `sentAt` here would scatter repeated dates through the list.
    private func rebuildSections() {
        var built: [PinnedMessageSection] = []
        let calendar = Calendar.current

        for message in messages {
            let startOfDay = calendar.startOfDay(for: Date(timeIntervalSince1970: Double(message.pinnedAt)))
            let day = Int(startOfDay.timeIntervalSince1970)

            if var last = built.last, last.date == day {
                last.messages.append(message)
                built[built.count - 1] = last
            } else {
                built.append(PinnedMessageSection(date: day, messages: [message]))
            }
        }

        sections = built
    }

    // MARK: - Templates

    /// Mirrors `MessageListViewModel.setUpDefaultTemplate` so pinned rows resolve the same
    /// bubbles the message list does, including any decorator overrides.
    func setUpDefaultTemplate() {
        additionalConfiguration.textFormatter = textFormatters
        additionalConfiguration.messageBubbleStyle = messageBubbleStyle
        additionalConfiguration.actionBubbleStyle = actionBubbleStyle
        additionalConfiguration.callActionBubbleStyle = callActionBubbleStyle
        additionalConfiguration.enableMultipleAttachments = enableMultipleAttachments

        ChatConfigurator.getDataSource()
            .getAllMessageTemplates(additionalConfiguration: additionalConfiguration)
            .forEach { templates["\($0.category)_\($0.type)"] = $0 }
    }

    func getTemplate(for message: BaseMessage) -> CometChatMessageTemplate? {
        let category = MessageUtils.getDefaultMessageCategories(message: message)
        let type = MessageUtils.getDefaultMessageTypes(message: message)
        return templates["\(category)_\(type)"]
    }

    func connect() {
        CometChatMessageEvents.addListener(listenerId, self)
    }

    func disconnect() {
        CometChatMessageEvents.removeListener(listenerId)
    }

    /// Index into the flat `messages` array — for mutating the model.
    func flatIndex(for messageId: Int) -> Int? {
        return messages.firstIndex(where: { $0.id == messageId })
    }

    /// Position within `sections` — for mutating the table. Distinct from `flatIndex`
    /// since the two now address different coordinate spaces.
    func indexPath(for messageId: Int) -> IndexPath? {
        for (section, bucket) in sections.enumerated() {
            if let row = bucket.messages.firstIndex(where: { $0.id == messageId }) {
                return IndexPath(row: row, section: section)
            }
        }
        return nil
    }

    func message(at indexPath: IndexPath) -> BaseMessage? {
        return sections[safe: indexPath.section]?.messages[safe: indexPath.row]
    }

    // MARK: - Unpin

    /// Removes the row first and restores it if the server rejects the unpin, so the
    /// list matches the bubble surface's optimistic behaviour.
    func unpin(message: BaseMessage) {
        let messageId = message.id
        guard MessageActionToggleGuard.shared.begin(action: .pin, messageId: messageId) else { return }

        // The table index must be captured before the model changes, and it is a different
        // coordinate space from the flat index used to mutate `messages`.
        guard let flat = flatIndex(for: messageId),
              let indexPath = indexPath(for: messageId) else {
            MessageActionToggleGuard.shared.end(action: .pin, messageId: messageId)
            return
        }

        let removed = messages[flat]
        messages.remove(at: flat)
        rebuildSections()
        removeAtIndex?(indexPath)

        service.unpinMessage(messageId: messageId) { [weak self] updated in
            MessageActionToggleGuard.shared.end(action: .pin, messageId: messageId)
            guard let this = self else { return }
            DispatchQueue.main.async {
                CometChatMessageEvents.ccMessagePinned(message: updated, status: .success)
                // The row is already gone; reload settles the title count and empty state.
                this.reload?()
            }
        } onError: { [weak self] error in
            MessageActionToggleGuard.shared.end(action: .pin, messageId: messageId)
            guard let this = self else { return }
            DispatchQueue.main.async {
                this.restore(message: removed)
                this.unpinFailure?(error)
            }
        }
    }

    private func restore(message: BaseMessage) {
        guard !messages.contains(where: { $0.id == message.id }) else { return }
        messages.append(message)
        messages.sort { $0.pinnedAt > $1.pinnedAt }
        rebuildSections()
        reload?()
    }

    /// The row is dropped by `onMessageDeleted`, which the success callback emits, so
    /// nothing is removed optimistically here.
    func delete(message: BaseMessage) {
        service.deleteMessage(messageId: message.id) { deleted in
            CometChatMessageEvents.onMessageDeleted(message: deleted)
        } onError: { [weak self] error in
            guard let this = self else { return }
            DispatchQueue.main.async {
                this.actionFailure?(error)
            }
        }
    }

    // MARK: - List mutation

    @discardableResult
    func add(message: BaseMessage) -> Self {
        guard !messages.contains(where: { $0.id == message.id }) else { return self }
        messages.append(message)
        messages.sort { $0.pinnedAt > $1.pinnedAt }
        rebuildSections()
        reload?()
        return self
    }

    @discardableResult
    func remove(messageId: Int) -> Self {
        guard let flat = flatIndex(for: messageId) else { return self }
        messages.remove(at: flat)
        rebuildSections()
        reload?()
        return self
    }

    func size() -> Int {
        return messages.count
    }
}
