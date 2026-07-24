//
//  CometChatSearch.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 05/08/25.
//

import Foundation
import UIKit
import CometChatSDK

 extension CometChatSearch {
    /// Safely returns only text messages without touching `messageType`
    var textMessages: [BaseMessage] {
        let messages = viewModel.filteredMessages
        
        // If everything is already a TextMessage, just return as-is
        if messages.allSatisfy({ $0 is TextMessage }) {
            return messages
        }
        
        // Mixed types – keep only TextMessage instances
        return messages.filter { $0 is TextMessage || $0.messageCategory == .card }
    }
}


open class CometChatSearch: UIViewController {
    
    public var searchScopes: [SearchScope] = [.conversations, .messages]
    var originalScopes: [SearchScope] = [.conversations, .messages]
    public var originalFilterItems: [FilterItem] = [
        FilterItem(iconName: "message.badge", title: "Unread"),
        FilterItem(iconName: "person.2", title: "Groups"),
        FilterItem(iconName: "photo", title: "Photos"),
        FilterItem(iconName: "video", title: "Videos"),
        FilterItem(iconName: "link", title: "Links"),
        FilterItem(iconName: "doc.text", title: "Documents"),
        FilterItem(iconName: "headphones", title: "Audio"),
    ]
    
    public var user: User?
    public var group: Group?
    
    // MARK: - Filter Configuration
    public internal(set) var searchFilters: [SearchFilter] = []
    public internal(set) var initialSearchFilter: SearchFilter?
    
    var filterItems: [FilterItem] = []
    var selectedFilters: [FilterItem] = []
    
    public static var style = SearchStyle()
    public static var avatarStyle: AvatarStyle = CometChatAvatar.style
    public static var statusIndicatorStyle: StatusIndicatorStyle = CometChatStatusIndicator.style
    public static var receiptStyle: ReceiptStyle = {
        var defaultReceiptStyle = CometChatReceipt.style
        defaultReceiptStyle.deliveredImageTintColor = CometChatTheme.iconColorSecondary
        defaultReceiptStyle.sentImageTintColor = CometChatTheme.iconColorSecondary
        defaultReceiptStyle.waitImageTintColor = CometChatTheme.iconColorSecondary
        return defaultReceiptStyle
    }()
    public static var badgeStyle: BadgeStyle = CometChatBadge.style
    public static var dateStyle: DateStyle = CometChatDate.style
    public static var typingIndicatorStyle = CometChatTypingIndicator.style
    
    
    public lazy var style = CometChatSearch.style
    public lazy var avatarStyle: AvatarStyle = CometChatSearch.avatarStyle
    public lazy var statusIndicatorStyle: StatusIndicatorStyle = CometChatSearch.statusIndicatorStyle
    public lazy var receiptStyle: ReceiptStyle = CometChatSearch.receiptStyle
    public lazy var badgeStyle: BadgeStyle = CometChatSearch.badgeStyle
    public lazy var dateStyle: DateStyle = CometChatSearch.dateStyle
    public lazy var typingIndicatorStyle = CometChatSearch.typingIndicatorStyle
    
    //Icons
    public var privateGroupIcon = UIImage(systemName: "shield.fill")?.withRenderingMode(.alwaysTemplate)
    public var protectedGroupIcon = UIImage(systemName: "lock.fill")?.withRenderingMode(.alwaysTemplate)
    
    // Disable Properties
    public var disableTyping: Bool = false
    public var disableSoundForMessages: Bool = false
    public var customSoundForMessages: URL?
    
    //Date Time Formatter
    public static var dateTimeFormatter: CometChatDateTimeFormatter = CometChatUIKit.dateTimeFormatter
    public lazy var dateTimeFormatter: CometChatDateTimeFormatter = CometChatConversations.dateTimeFormatter
    
    var textFormatters: [CometChatTextFormatter] = {
        return ChatConfigurator.getDataSource().getTextFormatters()
    }()
    
    var datePattern: ((_ conversation: Conversation?, _ messagge: BaseMessage?) -> String)?
    public var onConversationClicked: ((_ conversation: Conversation, _ indexPath: IndexPath) -> Void)?
    public var onMessageClicked: ((_ message: BaseMessage) -> Void)?
    
    public static var sharedSearchKeyword: String?
        
     lazy var emptyStateSubtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = CometChatTypography.Body.regular
        label.textColor = CometChatTheme.textColorSecondary
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "Search for conversations or messages by typing a keyword above."
        return label
    }()

     lazy var emptyStateTitleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Start Your Search"
        titleLabel.font = CometChatTypography.Heading3.bold
        titleLabel.textColor = CometChatTheme.textColorPrimary
        titleLabel.textAlignment = .center
        return titleLabel
    }()
    
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
    
    public lazy var errorStateView: UIView = {
        let stateView = StateView(title: errorStateTitleText, subtitle: errorStateSubTitleText, image: errorStateImage)
        return stateView
    }()
    
     lazy var emptyStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear

        view.addSubview(emptyStateTitleLabel)
        view.addSubview(emptyStateSubtitleLabel)

        NSLayoutConstraint.activate([
            emptyStateTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateTitleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -12),

            emptyStateSubtitleLabel.topAnchor.constraint(equalTo: emptyStateTitleLabel.bottomAnchor, constant: 8),
            emptyStateSubtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateSubtitleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 32),
            emptyStateSubtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -32),
        ])

        return view
    }()
    
     var searchController: UISearchController!
    
     lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped).withoutAutoresizingMaskConstraints()
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(CometChatListItem.self, forCellReuseIdentifier: CometChatListItem.identifier)
        tableView.register(CometChatSearchListItemImageVideo.self, forCellReuseIdentifier: CometChatSearchListItemImageVideo.identifier)
        tableView.register(CometChatSearchListItemAttachments.self, forCellReuseIdentifier: CometChatSearchListItemAttachments.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isMultipleTouchEnabled = false
        return tableView
    }()
    
    lazy var filterCollectionView: UICollectionView = {
        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout).withoutAutoresizingMaskConstraints()
        collectionView.backgroundColor = .clear
        collectionView.register(FilterCell.self, forCellWithReuseIdentifier: FilterCell.reuseIdentifier)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isScrollEnabled = false // makes it expand vertically
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = true
        return collectionView
    }()

    public var viewModel: SearchViewModel = SearchViewModel()

     var selectedFilter: MessageFilterType? = nil

     var heightConstraint: NSLayoutConstraint!
    
    public var listItemViewForImage: ((_ message: MediaMessage) -> UIView)?
    public var listItemViewForVideo: ((_ message: MediaMessage) -> UIView)?
    public var listItemViewForAudio: ((_ message: MediaMessage) -> UIView)?
    public var listItemViewForDocument: ((_ message: MediaMessage) -> UIView)?
    public var listItemViewForLink: ((_ message: MediaMessage) -> UIView)?
    
    public var listItemViewForConversation: ((_ conversation: Conversation) -> UIView)?
    public var listItemViewForMessage: ((_ message: BaseMessage) -> UIView)?
    public var leadingViewForConversation: ((_ conversation: Conversation) -> UIView)?
    public var titleViewForConversation: ((_ conversation: Conversation) -> UIView)?
    public var subtitleViewForConversation: ((_ conversation: Conversation) -> UIView)?
    public var tailViewForConversation: ((_ conversation: Conversation) -> UIView)?
    
    public var hideUserStatus: Bool = false
    public var hideGroupType: Bool = false
    
    public var loadingView: UIView!
    var attachments: [CometChat.AttachmentType] = []
    
    private var isNavigating = false
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        filterItems = originalFilterItems
        originalScopes = searchScopes
        viewModel.activeScopes = searchScopes
        setupSearchController()
        buildUI()
        setupViewModel()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.hidesSearchBarWhenScrolling = false
        setupStyle()
    }

     func setupSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
         if #available(iOS 16.0, *) {
             self.navigationItem.preferredSearchBarPlacement = .stacked
         }
        searchController.obscuresBackgroundDuringPresentation = false
        if let user = user {
            searchController.searchBar.placeholder = "Search for \(user.name ?? "")"
        } else if let group = group {
            searchController.searchBar.placeholder = "Search in \(group.name ?? "")"
        } else{
            searchController.searchBar.placeholder = "SEARCH".localize()
        }
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    open override func viewDidLayoutSubviews() {
        updateCollectionViewHeight()
    }
    
     func updateCollectionViewHeight() {
        heightConstraint.constant = filterCollectionView.collectionViewLayout.collectionViewContentSize.height + 27
    }
    
     func buildUI() {
        loadingView = SearchShimmerView()
        view.addSubview(filterCollectionView)
        view.addSubview(tableView)
        
        viewModel.user = user
        viewModel.group = group
        
        NSLayoutConstraint.activate([
            filterCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            filterCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: CometChatSpacing.Padding.p5),
            filterCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -(CometChatSpacing.Padding.p5)),
            filterCollectionView.bottomAnchor.constraint(equalTo: tableView.topAnchor),
            
            tableView.topAnchor.constraint(equalTo: filterCollectionView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        heightConstraint = filterCollectionView.heightAnchor.constraint(equalToConstant: 130)
        heightConstraint.isActive = true
        
        addEmptyStateView()
        defaultSetUp()
    }
    
    open func setupStyle() {
        view.backgroundColor = style.backgroundColor
        tableView.borderWith(width: style.borderWidth)
        tableView.borderColor(color: style.borderColor)
        tableView.roundViewCorners(corner: style.cornerRadius)
        
        if let emptyStateView = emptyStateView as? StateView {
            emptyStateView.subtitleLabel.font = style.emptySubTitleFont
            emptyStateView.subtitleLabel.textColor = style.emptySubTitleTextColor
            emptyStateView.titleLabel.font = style.emptyTitleTextFont
            emptyStateView.titleLabel.textColor = style.emptyTitleTextColor
            emptyStateView.imageView.tintColor = CometChatTheme.neutralColor300
        }
        
        styleSearchBar()
        styleNavigationBar()
    }
    
    /// This function will set style for search bar from the component's style variable
    open func styleSearchBar() {

        if let searchTintColor = style.searchTintColor{
            searchController.searchBar.tintColor = searchTintColor
        }

        if let searchBarTintColor = style.searchBarTintColor{
            searchController.searchBar.barTintColor = searchBarTintColor
        }
        
        searchController.searchBar.searchBarStyle = style.searchBarStyle
        
        if let searchTextField = searchController.searchBar.value(forKey: "searchField") as? UITextField {

            let placeholderText = searchTextField.placeholder ?? ""
            
            if let placeholderTextColor = style.searchBarPlaceholderTextColor{
                let placeholderAttributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: placeholderTextColor]
                searchTextField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: placeholderAttributes)
            }
            
            if let placeholderTextFont = style.searchBarPlaceholderTextFont{
                let placeholderAttributes: [NSAttributedString.Key: Any] = [
                    .font: placeholderTextFont
                ]
                searchTextField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: placeholderAttributes)
            }
            
            if let searchBarTextColor = style.searchBarTextColor{
                searchTextField.textColor = searchBarTextColor
            }
            

            if let searchBarTextFont = style.searchBarTextFont{
                searchTextField.font = searchBarTextFont
            }
            
            if let searchBarBackgroundColor = style.searchBarBackgroundColor{
                searchTextField.backgroundColor = searchBarBackgroundColor
            }
        }

        if let searchIconView = searchController.searchBar.searchTextField.leftView as? UIImageView, let searchIconTintColor = style.searchIconTintColor{
            searchIconView.tintColor = searchIconTintColor // Set the tint color for the search icon.
        }

        if let clearButton = searchController.searchBar.searchTextField.value(forKey: "clearButton") as? UIButton, let searchBarCrossIconTintColor = style.searchBarCrossIconTintColor{
            clearButton.tintColor = searchBarCrossIconTintColor // Set the tint color for the clear button.
        }

        if let cancelButton = searchController.searchBar.value(forKey: "cancelButton") as? UIButton, let searchBarCancelIconTintColor = style.searchBarCancelIconTintColor {
            cancelButton.setTitleColor(searchBarCancelIconTintColor, for: .normal)
            cancelButton.setTitle("CANCEL".localize(), for: .normal)
        }
    }
    
    open func styleNavigationBar() {
        if let navigationController = navigationController {
            if let navigationBarTintColor = style.navigationBarTintColor {
                navigationController.navigationBar.barTintColor = navigationBarTintColor
            }
            
            if let navigationBarItemsTintColor = style.navigationBarItemsTintColor {
                navigationController.navigationBar.tintColor = navigationBarItemsTintColor
            }
            
            var titleTextAttributes = [NSAttributedString.Key : Any]()
    
            if let titleColor = style.titleColor {
                titleTextAttributes.append(with: [NSAttributedString.Key.foregroundColor: titleColor])
            }
            
            if let titleFont = style.titleFont {
                titleTextAttributes.append(with: [NSAttributedString.Key.font: titleFont])
            }
            
            if !titleTextAttributes.isEmpty {
                navigationController.navigationBar.titleTextAttributes = titleTextAttributes
            }
            
            var largeTitleAttributes = [NSAttributedString.Key : Any]()
            
            if let largeTitleFont = style.largeTitleFont {
                largeTitleAttributes.append(with: [NSAttributedString.Key.font: largeTitleFont])
            }
            
            if let largeTitleColor = style.largeTitleColor {
                largeTitleAttributes.append(with: [NSAttributedString.Key.foregroundColor: largeTitleColor])
            }
            
            if !largeTitleAttributes.isEmpty {
                navigationController.navigationBar.largeTitleTextAttributes = largeTitleAttributes
            }
        }
    }
    
     func setupViewModel() {
        viewModel.reload = { [weak self] in
            guard let self else { return }

            tableView.reloadData()
            
            let searchText = searchController.searchBar.text ?? ""
            let isEmptySearch = searchText.isEmpty
            let hasFilters = !selectedFilters.isEmpty

            if isEmptySearch && !hasFilters {
                addEmptyStateView()
                emptyStateSubtitleLabel.text = ""
                removeLoadingView()
                return
            }

            let noConversations = viewModel.activeScopes.contains(.conversations) && viewModel.filteredConversations.isEmpty

            var noMessages = false

            if selectedFilters.count > 0 {
                noMessages = viewModel.activeScopes.contains(.messages) && viewModel.filteredMessages.isEmpty
            } else {
                noMessages = viewModel.activeScopes.contains(.messages) && textMessages.isEmpty
            }

            if searchScopes.count == 1, searchScopes.contains(.messages), noMessages{
                addEmptyStateView()
                emptyStateTitleLabel.text = "No results"
                emptyStateSubtitleLabel.text = isEmptySearch
                    ? ""
                    : "There were no results for “\(searchText)”\nTry a new search"
            } else if searchScopes.count == 1, searchScopes.contains(.conversations), noConversations{
                addEmptyStateView()
                emptyStateTitleLabel.text = "No results"
                emptyStateSubtitleLabel.text = isEmptySearch
                    ? ""
                    : "There were no results for “\(searchText)”\nTry a new search"
            } else if (noConversations && noMessages) {
                addEmptyStateView()
                emptyStateTitleLabel.text = "No results"
                emptyStateSubtitleLabel.text = isEmptySearch
                    ? ""
                    : "There were no results for “\(searchText)”\nTry a new search"
            } else {
                emptyStateTitleLabel.text = "Start Your Search"
                emptyStateSubtitleLabel.text = "Search for conversations or messages by typing a keyword above."
                hideEmptyStateView()
            }
            
            removeLoadingView()
        }
    }
    
    @objc func handleShowMoreTapped(_ sender: UIButton) {
        let scope = searchScopes[sender.tag]
        switch scope {
        case .conversations:
            let remaining = viewModel.filteredConversations.count - viewModel.displayedConversationCount
            viewModel.displayedConversationCount += min(3, remaining)
            
        case .messages:
            let remaining = viewModel.filteredMessages.count - viewModel.displayedMessageCount
            viewModel.displayedMessageCount += min(3, remaining)
        }
        tableView.reloadSections(IndexSet(integer: sender.tag), with: .automatic)
    }

    
    func addEmptyStateView() {
        view.addSubview(emptyStateView)
        NSLayoutConstraint.activate([
            emptyStateView.topAnchor.constraint(equalTo: tableView.topAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: tableView.bottomAnchor),
        ])
        tableView.isHidden = true
    }
    
    func defaultSetUp(){
        
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        
        dateStyle.textColor = CometChatTheme.textColorSecondary
        dateStyle.textFont = CometChatTypography.Caption1.regular
        dateStyle.borderWidth = 0
        dateStyle.backgroundColor = .clear
    }

    
    func hideEmptyStateView(){
        tableView.isHidden = false
        emptyStateView.removeFromSuperview()
    }
    
    open func showLoadingView() {
        guard let loadingView = loadingView else { return }

        (loadingView as? CometChatShimmerView)?.startShimmer()

        loadingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingView)

        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: filterCollectionView.bottomAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    open func removeLoadingView() {
        (loadingView as? CometChatShimmerView)?.stopShimmer()
        loadingView?.removeFromSuperview()
    }
}

extension CometChatSearch: UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {
        if let search = searchController.searchBar.text{
            if search.count > 0{
                showLoadingView()
            }
//            viewModel.filterContentForSearchText(search, selectedFilters: selectedFilters)
            let hasLinks = selectedFilters.contains { $0.title == "Links" }
            let attachmentTypes = selectedFilters.compactMap { item -> CometChat.AttachmentType? in
                switch item.title {
                case "Photos": return .image
                case "Videos": return .video
                case "Audio": return .audio
                case "Documents": return .file
                default: return nil
                }
            }
            viewModel.filteredMessages.removeAll()
            viewModel.filterContentForSearchText(search,
                selectedFilters: selectedFilters,
                attachmentTypes: attachmentTypes,
                hasLinks: hasLinks
            )
        }
    }
}

extension CometChatSearch: UITableViewDataSource, UITableViewDelegate {
    public func numberOfSections(in tableView: UITableView) -> Int { return searchScopes.count }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let anyFilterSelected = !selectedFilters.isEmpty

        switch searchScopes[section] {
        case .conversations:
            if anyFilterSelected { return viewModel.filteredConversations.count }
            return min(viewModel.displayedConversationCount, viewModel.filteredConversations.count)

        case .messages:
            if anyFilterSelected {
                return viewModel.filteredMessages.count
            }
            return min(viewModel.displayedMessageCount, textMessages.count)
        }
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let searchText = searchController.searchBar.text ?? ""
        let mediaSelected = selectedFilters.contains { ["Photos", "Videos", "Audio", "Documents", "Links"].contains($0.title) }
        
        switch searchScopes[indexPath.section]{
        case .conversations:
            guard let listItem = tableView.dequeueReusableCell(withIdentifier: CometChatListItem.identifier, for: indexPath) as? CometChatListItem else {
                return UITableViewCell()
            }

            let conversation = viewModel.filteredConversations[indexPath.row]
            let keyword = searchController.searchBar.text ?? ""

            // Apply styling first so it doesn't override later
            listItem.style = style
            listItem.avatar.style = avatarStyle
            listItem.statusIndicator.style = statusIndicatorStyle
            listItem.hide(avatar: false)
            listItem.avatarHeightConstraint.constant = 48
            listItem.avatarWidthConstraint.constant = 48

            // Tail View
            listItem.set(tail: SearchUtils().configureTailView(
                conversation: conversation,
                badgeStyle: badgeStyle,
                dateStyle: dateStyle,
                datePattern: datePattern?(conversation, nil),
                dateTimeFormatter: dateTimeFormatter
            ))

            // Subtitle View (already supports highlighting)
            listItem.set(subtitle: SearchUtils.configureSubtitleView(
                conversation: conversation,
                isTypingEnabled: false,
                receiptStyle: receiptStyle,
                disableReceipt: false,
                textFormatter: textFormatters,
                typingIndicatorStyle: typingIndicatorStyle,
                searchStyle: style
            ))

            // --- Title Highlighting ---
            switch conversation.conversationType {
            case .user:
                guard let user = conversation.conversationWith as? User else { return UITableViewCell() }

                if let name = user.name {
                    if !keyword.isEmpty {
                        let highlighted = SearchUtils.highlightKeyword(
                            in: name,
                            keyword: keyword,
                            font: style.listItemTitleFont,
                            highlightFont: UIFont.boldSystemFont(ofSize: style.listItemTitleFont.pointSize),
                            highlightColor: CometChatTheme.primaryColor // visible color
                        )
                        listItem.set(attributedTitle: highlighted)
                    } else {
                        listItem.set(title: name)
                    }
                }

                listItem.set(avatarURL: user.avatar ?? "", with: user.name ?? "")
                if user.status == .online {
                    listItem.hide(statusIndicator: hideUserStatus)
                    listItem.statusIndicator.style.backgroundColor = CometChatTheme.successColor
                } else {
                    listItem.hide(statusIndicator: true)
                }

            case .group:
                guard let group = conversation.conversationWith as? Group else { return UITableViewCell() }

                if let name = group.name {
                    if !keyword.isEmpty {
                        let highlighted = SearchUtils.highlightKeyword(
                            in: name,
                            keyword: keyword,
                            font: style.listItemTitleFont,
                            highlightFont: UIFont.boldSystemFont(ofSize: style.listItemTitleFont.pointSize),
                            highlightColor: CometChatTheme.primaryColor
                        )
                        listItem.set(attributedTitle: highlighted)
                    } else {
                        listItem.set(title: name)
                    }
                }

                listItem.set(avatarURL: group.icon ?? "", with: group.name ?? "")
                switch group.groupType {
                case .public:
                    listItem.hide(statusIndicator: true)
                case .private:
                    listItem.hide(statusIndicator: hideGroupType)
                    listItem.statusIndicator.style.backgroundColor = style.privateGroupImageBackgroundColor
                    listItem.set(statusIndicatorIcon: privateGroupIcon)
                    listItem.set(statusIndicatorIconTint: style.privateGroupImageTintColor)
                case .password:
                    listItem.hide(statusIndicator: hideGroupType)
                    listItem.set(statusIndicatorIcon: protectedGroupIcon)
                    listItem.statusIndicator.style.backgroundColor = style.passwordGroupImageBackgroundColor
                    listItem.set(statusIndicatorIconTint: style.privateGroupImageTintColor)
                @unknown default:
                    listItem.hide(statusIndicator: true)
                }

            default:
                break
            }

            return listItem
        case .messages:
            
            if mediaSelected {
                let message = viewModel.filteredMessages[indexPath.row]
                let isLoggedInUser = LoggedInUserInformation.isLoggedInUser(uid: message.senderUid)
                if selectedFilters.contains(where: { ["Photos", "Videos"].contains($0.title) }) {
                    guard let listItem = tableView.dequeueReusableCell(withIdentifier: CometChatSearchListItemImageVideo.identifier, for: indexPath) as? CometChatSearchListItemImageVideo else {
                        return UITableViewCell()
                    }
                    // Row anatomy per design: title = the CHAT name; subtitle =
                    // "<You|Sender>: <glyph> <caption | N Images/Videos>".
                    let chatName: String
                    if message.receiverType == .group {
                        chatName = (message.receiver as? Group)?.name ?? ""
                    } else {
                        chatName = isLoggedInUser
                            ? ((message.receiver as? User)?.name ?? "")
                            : (message.sender?.name ?? "")
                    }
                    let senderPrefix = isLoggedInUser ? "You" : (message.sender?.name ?? "")

                    let media = message as? MediaMessage
                    let attachments = media?.attachments ?? []
                    let firstAttachment = attachments.first ?? media?.attachment
                    let thumbnailURL = URL(string: firstAttachment?.fileUrl ?? "")
                    let isVideo = message.messageType == .video

                    let caption = (media?.caption ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                    let summary: String
                    if !caption.isEmpty {
                        summary = caption
                    } else {
                        let count = max(attachments.count, 1)
                        if isVideo {
                            summary = count == 1 ? "search_videos_one".localize() : String(format: "search_videos_count".localize(), "\(count)")
                        } else {
                            summary = count == 1 ? "search_images_one".localize() : String(format: "search_images_count".localize(), "\(count)")
                        }
                    }
                    let extraCount = max(0, attachments.count - 1)

                    if let message = message as? MediaMessage, let videoView = listItemViewForVideo?(message), isVideo {
                        listItem.set(customView: videoView)
                    } else if let message = message as? MediaMessage, let imageView = listItemViewForImage?(message), !isVideo {
                        listItem.set(customView: imageView)
                    } else{
                        listItem.configure(title: chatName, senderPrefix: senderPrefix, summary: summary, thumbnailURL: thumbnailURL, isVideo: isVideo, extraCount: extraCount)
                    }
                    return listItem
                }else{
                    let listItem = tableView.dequeueReusableCell(withIdentifier: CometChatSearchListItemAttachments.identifier, for: indexPath) as! CometChatSearchListItemAttachments
                    listItem.user = user
                    listItem.group = group
                    listItem.configure(
                        with: message
                    )
                    return listItem
                }
            }else {
//                let message = viewModel.filteredMessages.filter({$0.messageType == .text})[indexPath.row]
                let message = textMessages[indexPath.row]
                let isLoggedInUser = LoggedInUserInformation.isLoggedInUser(uid: message.senderUid)
                guard let listItem = tableView.dequeueReusableCell(withIdentifier: CometChatListItem.identifier, for: indexPath) as? CometChatListItem else {
                    return UITableViewCell()
                }
                listItem.hide(avatar: true)
                if message.receiverType == .group {
                    listItem.set(title: (message.receiver as? Group)?.name ?? "")
                } else {
                    listItem.set(title: isLoggedInUser ? "You" : message.sender?.name ?? "")
                }
                style.listItemTitleTextColor = CometChatTheme.textColorSecondary
                listItem.style = style
                listItem.set(subtitle: SearchUtils.configureMessageSubtitleView(
                    message: message,
                    searchStyle: style, textFormatter: textFormatters,
                    searchKeyword: searchController.searchBar.text ?? ""
                ))
                listItem.set(tail: SearchUtils().configureMessageTailView(
                    message: message,
                    badgeStyle: badgeStyle,
                    dateStyle: dateStyle,
                    datePattern: datePattern?(nil, message), dateTimeFormatter: dateTimeFormatter
                ))
                return listItem
            }
        }
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !isNavigating else { return }
        isNavigating = true

        tableView.deselectRow(at: indexPath, animated: true)

        switch searchScopes[indexPath.section] {
        case .conversations:
            let conversation = viewModel.filteredConversations[indexPath.row]
            
            // Clear unread count immediately when clicking on conversation
            if conversation.unreadMessageCount > 0 {
                conversation.unreadMessageCount = 0
                viewModel.filteredConversations[indexPath.row] = conversation
                tableView.reloadRows(at: [indexPath], with: .none)
                
                // Mark last message as read if it exists
                if let lastMessage = conversation.lastMessage, lastMessage.senderUid != CometChat.getLoggedInUser()?.uid {
                    CometChat.markAsRead(baseMessage: lastMessage)
                }
            }
            
            onConversationClicked?(conversation, indexPath)

        case .messages:
            let message = viewModel.filteredMessages[indexPath.row]
            onMessageClicked?(message)
        }

        // Reset AFTER navigation completes (best place)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isNavigating = false
        }
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let headerView = UIView()
        headerView.backgroundColor = .clear

        let titleLabel = UILabel()
        titleLabel.font = CometChatTypography.Caption1.medium
        titleLabel.textColor = CometChatTheme.textColorSecondary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        headerView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -4),
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 12)
        ])
        
        switch searchScopes[section]{
        case .conversations:
            if viewModel.filteredConversations.isEmpty{
                return nil
            }else{
                titleLabel.text = "Chats"
                return headerView
            }
        case .messages:
            if viewModel.filteredMessages.isEmpty{
                return nil
            }else{
                titleLabel.text = "Messages"
                return headerView
            }
        }
    }


    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch searchScopes[section]{
        case .conversations:
            return viewModel.filteredConversations.isEmpty ? 0 : 30
        case .messages:
            return (viewModel.displayedMessageCount < textMessages.count) ? 30 : 0
        }
    }

    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let anyFilterSelected = !selectedFilters.isEmpty
        if anyFilterSelected { return nil }
        
        switch searchScopes[section]{
        case .conversations:
            guard viewModel.displayedConversationCount < viewModel.filteredConversations.count else { return nil }
        case .messages:
            guard viewModel.displayedMessageCount < textMessages.count else { return nil }
        }

        let footerView = UIView()
        let button = UIButton(type: .system)
        button.setTitle("Show More", for: .normal)
        button.titleLabel?.font = CometChatTypography.Caption1.medium
        button.setTitleColor(CometChatTheme.textColorHighlight, for: .normal)
        button.tag = section
        button.addTarget(self, action: #selector(handleShowMoreTapped(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false

        footerView.addSubview(button)
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 16),
            button.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 8),
            button.bottomAnchor.constraint(equalTo: footerView.bottomAnchor, constant: -8),
        ])
        return footerView
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard searchScopes == [.messages],
              !selectedFilters.isEmpty else { return }

        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.height

        if offsetY > contentHeight - frameHeight - 200 {
            let attachmentTypes = selectedFilters.compactMap { item -> CometChat.AttachmentType? in
                switch item.title {
                case "Photos": return .image
                case "Videos": return .video
                case "Audio": return .audio
                case "Documents": return .file
                default: return nil
                }
            }

            let hasLinks = selectedFilters.contains { $0.title == "Links" }

            viewModel.fetchNextMessages(
                searchText: searchController.searchBar.text ?? "",
                attachmentTypes: attachmentTypes,
                hasLinks: hasLinks
            )
        }
    }



    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {

        let anyFilterSelected = !selectedFilters.isEmpty
        if anyFilterSelected { return 0 }

        switch searchScopes[section] {
        case .conversations:
            return (viewModel.displayedConversationCount < viewModel.filteredConversations.count) ? 30 : 0
        case .messages:
            return (viewModel.displayedMessageCount < textMessages.count) ? 30 : 0
        }
    }
}


extension CometChatSearch: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterItems.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterCell.reuseIdentifier, for: indexPath) as? FilterCell else {
            return UICollectionViewCell()
        }
        
        let item = filterItems[indexPath.item]
        cell.configure(with: item, isSelected: selectedFilters.contains(where: { $0.title == item.title }))
                
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = filterItems[indexPath.item]
        if !selectedFilters.contains(where: { $0.title == item.title }) {
            selectedFilters.append(item)
        }
        applyFilterForCurrentSelection()
        collectionView.reloadData()
        reselectAll(in: collectionView)
    }

    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let item = filterItems[indexPath.item]
        selectedFilters.removeAll { $0.title == item.title }
        applyFilterForCurrentSelection()
        collectionView.reloadData()
        reselectAll(in: collectionView)
    }

    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if collectionView.indexPathsForSelectedItems?.contains(indexPath) == true {
            collectionView.deselectItem(at: indexPath, animated: true)
            collectionView.delegate?.collectionView?(collectionView, didDeselectItemAt: indexPath)
            return false
        }
        return true
    }

     func titleIsSelected(_ t: String) -> Bool {
        selectedFilters.contains { $0.title == t }
    }

     func applyFilterForCurrentSelection() {
        let searchText = searchController.searchBar.text ?? ""
        showLoadingView()
        // Case: no filters selected
        guard let filter = selectedFilters.first else {
            filterItems = originalFilterItems
            searchScopes = originalScopes
            viewModel.activeScopes = searchScopes
            viewModel.filterContentForSearchText(searchText)
            tableView.reloadData()
            return
        }
        
        // Map title back to SearchFilter
        guard let selectedFilter = SearchFilter(rawValue: filter.title.lowercased()) else {
            return
        }
        
        switch selectedFilter {
        case .groups, .unread:
            searchScopes = [.conversations]
            filterItems = originalFilterItems.filter { ["Groups", "Unread"].contains($0.title) }
            viewModel.activeScopes = searchScopes
            viewModel.filterContentForSearchText(searchText, selectedFilters: selectedFilters)
            
        case .photos, .videos:
            searchScopes = [.messages]
            filterItems = originalFilterItems.filter { ["Photos", "Videos"].contains($0.title) }
            
            var attachments: [CometChat.AttachmentType] = []
            if titleIsSelected("Photos") { attachments.append(.image) }
            if titleIsSelected("Videos") { attachments.append(.video) }
            
            viewModel.activeScopes = searchScopes
            viewModel.filterContentForSearchText(searchText, attachmentTypes: attachments)
            
        case .audio, .documents:
            searchScopes = [.messages]
            filterItems = originalFilterItems.filter { ["Audio", "Documents"].contains($0.title) }
            
            var attachments: [CometChat.AttachmentType] = []
            if titleIsSelected("Audio") { attachments.append(.audio) }
            if titleIsSelected("Documents") { attachments.append(.file) }
            
            viewModel.activeScopes = searchScopes
            viewModel.filterContentForSearchText(searchText, attachmentTypes: attachments)
            
        case .links:
            searchScopes = [.messages]
            filterItems = originalFilterItems.filter { ["Links"].contains($0.title) }
            viewModel.activeScopes = searchScopes
            viewModel.filterContentForSearchText(searchText, hasLinks: true)
            
        case .conversations, .messages:
            // fallback for general search
            filterItems = originalFilterItems
            searchScopes = originalScopes
            viewModel.activeScopes = searchScopes
            viewModel.filterContentForSearchText(searchText)
        }
        
        if !selectedFilters.isEmpty {
            viewModel.displayedConversationCount = viewModel.filteredConversations.count
            viewModel.displayedMessageCount = viewModel.filteredMessages.count
        } else {
            viewModel.displayedConversationCount = 3
            viewModel.displayedMessageCount = 3
        }
        
        tableView.reloadData()
    }

     func reselectAll(in collectionView: UICollectionView) {
        for f in selectedFilters {
            if let idx = filterItems.firstIndex(where: { $0.title == f.title }) {
                collectionView.selectItem(at: IndexPath(item: idx, section: 0), animated: false, scrollPosition: [])
            }
        }
    }

}

