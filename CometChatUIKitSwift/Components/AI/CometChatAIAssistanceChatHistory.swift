//
//  CometChatAIAssistanceChatHistory.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 17/09/25.
//

import Foundation
import UIKit
import CometChatSDK

open class CometChatAIAssistanceChatHistory: UIViewController {
    
    // MARK: - Inputs
    public var user: User?
    public var group: Group?
    
    var onClose: (() -> Void)?
    public var onMessageClicked: ((BaseMessage) -> Void)?
    public var onNewChatButtonClicked: ((User) -> Void)?
    
    var onError: ((_ error: CometChatException) -> Void)?
    var onEmpty: (() -> Void)?
    var onLoad: (([BaseMessage]) -> Void)?
    public var hideDateSeparator = false
    
    // MARK: - ViewModel
    public var viewModel = AIAssistanceChatHistoryViewModel()
    
    // MARK: - UI Components
    public let tableView = UITableView(frame: .zero, style: .grouped)
    
    private lazy var newChatStack: UIStackView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "plus")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = CometChatTheme.iconColorSecondary
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 24),
            imageView.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        let label = UILabel()
        label.text = "New Chat"
        label.font = CometChatTypography.Button.regular
        label.textColor = CometChatTheme.textColorPrimary
        
        let stack = UIStackView(arrangedSubviews: [imageView, label])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var newChatButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(newChatTapped), for: .touchUpInside)
        return button
    }()
    
    public var loadingShimmerView: UIView!
    
    public lazy var errorStateView: UIView = {
        let stateView = StateView(title: errorStateTitleText, subtitle: errorStateSubTitleText, image: errorStateImage)
        return stateView
    }()
    
    public lazy var emptyStateView: UIView = {
        let stateView = StateView(title: emptyStateTitleText, subtitle: emptyStateSubTitleText, image: emptyStateImage)
        return stateView
    }()
    
    public var emptyStateImage: UIImage = UIImage() {
        didSet {
            (emptyStateView as? StateView)?.image = emptyStateImage
        }
    }
    public var emptyStateTitleText: String = "" {
        didSet {
            (emptyStateView as? StateView)?.title = emptyStateTitleText
        }
    }
    public var emptyStateSubTitleText: String = "" {
        didSet {
            (emptyStateView as? StateView)?.subtitle = emptyStateSubTitleText
        }
    }
    
    public var errorStateImage: UIImage = UIImage() {
        didSet {
            (errorStateView as? StateView)?.image = errorStateImage
        }
    }
    public var errorStateTitleText: String = "" {
        didSet {
            (errorStateView as? StateView)?.title = errorStateTitleText
        }
    }
    public var errorStateSubTitleText: String = "" {
        didSet {
            (errorStateView as? StateView)?.subtitle = errorStateSubTitleText
        }
    }
    
    public let errorLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .red
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Date & Formatting
    public static var dateTimeFormatter: CometChatDateTimeFormatter = CometChatUIKit.dateTimeFormatter
    public lazy var dateTimeFormatter: CometChatDateTimeFormatter = CometChatAIAssistanceChatHistory.dateTimeFormatter
    public static var dateSeparatorStyle = CometChatDate.style
    public lazy var dateSeparatorStyle = CometChatAIAssistanceChatHistory.dateSeparatorStyle
    public internal(set) var datePattern: ((_ timestamp: Int?) -> String)?
    public internal(set) var dateSeparatorPattern: ((_ timestamp: Int?) -> String)?
    
    // MARK: - Pagination
    private var lastContentOffset: CGFloat = 0
    private var isLoadingMore: Bool = false
    
    public static var style = AiAssistantChatHistoryStyle()
    public lazy var style = CometChatAIAssistanceChatHistory.style
    
    // MARK: - Lifecycle
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        showLoadingView()
        setupViewModel()
        setupInitialRequest()
        
        tableView.register(AIAssistantChatHistoryCell.self, forCellReuseIdentifier: AIAssistantChatHistoryCell.identifier)
        tableView.separatorStyle = .none
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        setupStyle()
    }
    
    func setupStyle() {
        view.backgroundColor = style.backgroundColor
        view.borderWith(width: style.borderWidth)
        view.borderColor(color: style.borderColor)
        if let cornerRadius = style.cornerRadius {
            view.roundViewCorners(corner: cornerRadius)
        }
        newChatButton.titleLabel?.font = style.newChatTitleFont
        newChatButton.setTitleColor(style.newChatTextColor, for: .normal)
        newChatButton.setImageTintColor(style.newChatImageTintColor)
        if let emptyStateView = self.emptyStateView as? StateView {
            emptyStateView.subtitleLabel.textColor = style.emptyStateSubtitleColor
            emptyStateView.subtitleLabel.font = style.emptyStateSubtitleFont
            emptyStateView.titleLabel.textColor = style.emptyStateTextColor
            emptyStateView.titleLabel.font = style.emptyStateTextFont
        }
        if let errorStateView = self.errorStateView as? StateView {
            errorStateView.subtitleLabel.textColor = style.errorStateSubtitleColor
            errorStateView.subtitleLabel.font = style.errorStateSubtitleFont
            errorStateView.titleLabel.textColor = style.errorStateTextColor
            errorStateView.titleLabel.font = style.errorStateTextFont
        }
        
        // Navigation
        var largeTitleAttributes: [NSAttributedString.Key: Any] = [
            .font: style.headerTitleFont,
            .foregroundColor: style.headerTitleTextColor
        ]
        navigationController?.navigationBar.largeTitleTextAttributes = largeTitleAttributes
        navigationController?.navigationBar.tintColor = style.closeIconColor
    }
    
    // MARK: - Setup
    private func setupUI() {
        loadingShimmerView = AIAssistanceChatHistoryShimmerView()
        tableView.backgroundColor = .clear
        
        navigationItem.title = "Chat History".localize()
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Separator under nav bar
        let separatorView = UIView().withoutAutoresizingMaskConstraints()
        separatorView.backgroundColor = CometChatTheme.borderColorDefault
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        view.addSubview(separatorView)
        
        // New Chat Button
        view.addSubview(newChatStack)
        view.addSubview(newChatButton)
        
        // TableView
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        // Empty & Error Labels
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(errorLabel)
        
        NSLayoutConstraint.activate([
            separatorView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            separatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            newChatStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            newChatStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                    
            // button covers entire stack area (tappable)
            newChatButton.topAnchor.constraint(equalTo: newChatStack.topAnchor),
            newChatButton.leadingAnchor.constraint(equalTo: newChatStack.leadingAnchor),
            newChatButton.trailingAnchor.constraint(equalTo: newChatStack.trailingAnchor),
            newChatButton.bottomAnchor.constraint(equalTo: newChatStack.bottomAnchor),
            
            tableView.topAnchor.constraint(equalTo: newChatButton.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        emptyStateImage = UIImage(named: "empty-icon", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal) ?? UIImage()
        emptyStateTitleText = "NO_CONVERSATIONS_YET".localize()
        (emptyStateView as? StateView)?.retryButton.isHidden = true
        
        errorStateImage = UIImage(named: "error-icon", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal) ?? UIImage()
        errorStateTitleText = "SOMETHING_WENT_WRONG_ERROR".localize()
        (errorStateView as? StateView)?.retryButton.isHidden = true
    }
    
    open func showEmptyView() {
        tableView.isHidden = true
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStateView)
        emptyStateView.pin(anchors: [.centerX, .centerY], to: view)
    }
    
    open func removeEmptyView() {
        tableView.isHidden = false
        emptyStateView.removeFromSuperview()
    }
    
    open func showErrorView() {
        tableView.isHidden = true
        errorStateView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(errorStateView)
        errorStateView.pin(anchors: [.centerX, .centerY], to: view)
    }
    
    open func removeErrorView() {
        tableView.isHidden = false
        errorStateView.removeFromSuperview()
    }
    
    private func setupInitialRequest() {
        if let user = user {
            let builder = MessagesRequest.MessageRequestBuilder()
                .set(uid: user.uid ?? "")
                .hideReplies(hide: true)
                .set(types: ChatConfigurator.getDataSource().getAllMessageTypes() ?? [])
            
            viewModel.set(user: user, messagesRequestBuilder: builder, parentMessage: nil)
        }
        viewModel.fetchPreviousMessages()
    }
    
    private func setupViewModel() {
        viewModel.reload = { [weak self] in
            guard let this = self else { return }
            DispatchQueue.main.async {
                this.tableView.reloadData()
                this.isLoadingMore = false
                this.removeLoadingView()
                if this.viewModel.messages.count <= 0 {
                    if let onEmpty = this.onEmpty?(){
                        onEmpty
                    }else {
                        this.showEmptyView()
                    }
                }else {
                    if let onLoad = this.onLoad?(this.viewModel.messages.flatMap { $0.messages }){
                        onLoad
                    }else {
                        self?.removeEmptyView()
                    }
                }
            }
        }
        
        viewModel.deleteAtIndex = { [weak self] section, row, message in
            guard let self = self else { return }

            DispatchQueue.main.async {
                // Validate indices before attempting deletion
                guard section < self.viewModel.messages.count,
                      section < self.tableView.numberOfSections,
                      row < self.viewModel.messages[section].messages.count,
                      row < self.tableView.numberOfRows(inSection: section) else {
                    self.tableView.reloadData()
                    return
                }

                let isLastMessageInSection = self.viewModel.messages[section].messages.count == 1

                // Update data model FIRST
                self.viewModel.messages[section].messages.remove(at: row)
                if isLastMessageInSection {
                    self.viewModel.messages.remove(at: section)
                }

                // Then update UI to match the data
                self.tableView.performBatchUpdates({
                    if isLastMessageInSection {
                        self.tableView.deleteSections(IndexSet(integer: section), with: .automatic)
                    } else {
                        let indexPath = IndexPath(row: row, section: section)
                        self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                }, completion: { _ in
                    if self.viewModel.messages.isEmpty {
                        self.showEmptyView()
                    } else {
                        self.removeEmptyView()
                    }
                })
            }
        }

        viewModel.failure = { [weak self] error in
            DispatchQueue.main.async { [weak self] in
                guard let this = self else { return }
                if let onError = this.onError?(error){
                    onError
                }
                self?.errorLabel.text = error.errorDescription
                self?.errorLabel.isHidden = false
            }
        }
    }
    
    // MARK: - Actions
    @objc private func closeTapped() {
        onClose?()
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func newChatTapped() {
        if let user = user{
            onNewChatButtonClicked?(user)
        }
    }
    
    // MARK: - Loading View
    open func showLoadingView() {
        guard let loadingView = loadingShimmerView else { return }
        (loadingView as? CometChatShimmerView)?.startShimmer()
        
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingView)
        
        NSLayoutConstraint.activate([
            loadingView.topAnchor.pin(equalTo: view.safeAreaLayoutGuide.topAnchor),
            loadingView.leadingAnchor.pin(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.pin(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.pin(equalTo: view.bottomAnchor)
        ])
    }
    
    open func removeLoadingView() {
        (loadingShimmerView as? CometChatShimmerView)?.stopShimmer()
        loadingShimmerView?.removeFromSuperview()
    }
}

// MARK: - UITableView Delegate & DataSource
extension CometChatAIAssistanceChatHistory: UITableViewDelegate, UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.messages.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if hideDateSeparator{
            return 0
        }else{
            return viewModel.messages[safe: section]?.messages.count ?? 0
        }
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if hideDateSeparator == true { return nil }
        guard let date = viewModel.messages[safe: section]?.messages.last?.sentAt else { return nil }
        
        let dateHeader = CometChatDate().withoutAutoresizingMaskConstraints()
        dateHeader.dateTimeFormatter = dateTimeFormatter
        
        if let time = dateSeparatorPattern?(date) {
            dateHeader.text = time
        } else if let datePattern = datePattern?(date) {
            let dateNow = Date(timeIntervalSince1970: Double(date))
            dateHeader.text = dateNow.reduceTo(customFormate: datePattern)
        } else {
            dateHeader.set(pattern: .dayDate)
            dateHeader.set(timestamp: date)
        }
        
        dateSeparatorStyle.borderWidth = 0
        dateSeparatorStyle.backgroundColor = .clear
        dateSeparatorStyle.textFont = CometChatTypography.Caption1.medium
        dateSeparatorStyle.textColor = CometChatTheme.textColorTertiary
        dateHeader.style = dateSeparatorStyle
        
        let container = UIView()
        container.backgroundColor = .clear
        container.addSubview(dateHeader)
        
        NSLayoutConstraint.activate([
            dateHeader.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            dateHeader.topAnchor.constraint(equalTo: container.topAnchor),
            dateHeader.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8)
        ])
        
        return container
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 28
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AIAssistantChatHistoryCell.identifier, for: indexPath) as? AIAssistantChatHistoryCell else {
            return UITableViewCell()
        }
        
        if let message = viewModel.messages[safe: indexPath.section]?.messages[safe: indexPath.row] {
            cell.configure(with: message)
        }
        cell.messageLabel.font = style.itemTextFont
        cell.messageLabel.textColor = style.itemTextColor
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let message = viewModel.messages[safe: indexPath.section]?.messages[safe: indexPath.row] {
            onMessageClicked?(message)
        }
    }
    
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        guard let message = viewModel.messages[safe: indexPath.section]?.messages[safe: indexPath.row] else {
            return nil
        }
            
        var actions = [UIContextualAction]()
        let delete = UIContextualAction(style: .destructive, title: ConversationConstants.delete) { [weak self] (action, sourceView, completionHandler) in
            guard let this = self else { return }
            self?.viewModel.delete(message: message)
        }
        delete.image = UIImage(named: "messages-delete", in: CometChatUIKit.bundle, with: nil)?.withTintColor(.white)
        actions.append(delete)
        
        let swipeActionConfig = UISwipeActionsConfiguration(actions: actions)
        swipeActionConfig.performsFirstActionWithFullSwipe = false
        return swipeActionConfig
        
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        
        let distanceFromBottom = contentHeight - offsetY - frameHeight
        
        if distanceFromBottom < 100 && distanceFromBottom > 0 {
            if !viewModel.isFetching && !viewModel.isAllMessagesFetchedInPrevious && !isLoadingMore {
                isLoadingMore = true
                viewModel.fetchPreviousMessages()
            }
        }
        
        lastContentOffset = offsetY
    }

}

