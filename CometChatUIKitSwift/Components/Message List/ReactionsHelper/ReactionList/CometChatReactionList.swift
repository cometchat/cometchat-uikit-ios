//
//  CometChatRectionList.swift
//  CometChatUIKitSwift
//
//  Created by SuryanshBisen on 18/02/24.
//

import UIKit
import CometChatSDK
import Foundation

open class CometChatReactionList: UIViewController {
    
    //global styling
    public static var style = ReactionListStyle()
    public static var avatarStyle: AvatarStyle = {
        var avatarStyle = CometChatAvatar.style
        avatarStyle.textFont = CometChatTypography.Heading4.bold
        return avatarStyle
    }()
    
    //local styling
    public lazy var style = CometChatReactionList.style
    public lazy var avatarStyle = CometChatReactionList.avatarStyle
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    private var separatorView = UIView()
    private var tableView = UITableView()
    private var reactionDataSource = [ReactionListDataModel]()
    /// Test seam: the tab buckets as built by `fetchReactions()`, read-only.
    internal var reactionBuckets: [ReactionListDataModel] { reactionDataSource }
    private var baseMessage: BaseMessage?
    private var tableViewSpinner = UIActivityIndicatorView()
    private var defaultReaction: String?
    private var layout = UICollectionViewFlowLayout()
    
    private var reactionRequestBuilder: ReactionsRequestBuilder?
    private var listItemStyle: ListItemStyle?
    private var onClick: ((_ messageReaction: CometChatSDK.Reaction, _ messageObject: BaseMessage) -> ())?
    private var errorStateView: UIView?
    private var loadingStateView: UIView?
    private var onError: ((_ error: CometChatException) -> Void)?
    /// The view `addErrorView` put on screen, so a reconnect can take it down again. Weak: the screen
    /// owns it, and the error label must go with it when something else takes it down.
    private weak var shownErrorView: UIView?
    /// "Connect to load reactions" while it shows. It sits below the tabs, as on Android (ENG-57325),
    /// so a tab with rows, or rows that arrive, take it down.
    private weak var connectToLoadView: UIView?
    /// Offline ON: the error view shows because the read failed for want of a connection; the
    /// connection returning reads once more (D83). Cleared when that read starts.
    private(set) var reloadOnConnect = false
    private let connectionListenerId = "reaction-list-sdk-listener-\(UUID().uuidString)"
    
    var loadingView: UIView!
    public var disableLoadingState: Bool = false
    var isLoadingViewVisible = false
        
    lazy var errorLabel : UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints()
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private var selectedIndex = 0 {
        didSet {
            if !collectionView.visibleCells.isEmpty {
                if oldValue < (reactionDataSource.count) {
                    self.collectionView.reloadData()
                } else {
                    self.collectionView.reloadItems(at: [IndexPath(row: selectedIndex, section: 0)])
                }
                self.reloadViews()
            }
        }
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        setUpDelegate()
        buildUI()
        fetchReactions()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        setupStyle()
        // Offline ON only: an error view for a missing connection reads once more when it returns.
        if OfflineGate.isOn() {
            CometChat.addConnectionListener(connectionListenerId, self)
        }
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        CometChat.removeConnectionListener(connectionListenerId)
    }
    
    func setUpDelegate() {
        
        //Setting Up CollectionView
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ReactionListCollectionCell.self, forCellWithReuseIdentifier: "ReactionListCollectionCell")
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        
        // Setting up TableView
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CometChatListItem.self, forCellReuseIdentifier: CometChatListItem.identifier)
    }
    
    func fetchReactions() {
        showLoadingView()
        
        guard let baseMessage = baseMessage else { return }
        
        //populating reactionList which will be used for collection view
        var totalReactions = 0
        baseMessage.reactions.forEach({ totalReactions = totalReactions + $0.count })
        reactionDataSource.append(ReactionListDataModel(reaction: "ALL".localize(), count: totalReactions, messageID: baseMessage.id, reactionsRequest: reactionRequestBuilder))
        baseMessage.reactions.forEach { reactions in
            reactionDataSource.append(ReactionListDataModel(reaction: reactions.reaction, count: reactions.count, messageID: baseMessage.id, reactionsRequest: reactionRequestBuilder))
        }
        
        if defaultReaction != nil {
            selectedIndex = self.reactionDataSource.firstIndex(where: { $0.reaction == defaultReaction }) ?? 0
            if selectedIndex != 0 { reactionDataSource[0].fetchPrevious {   } onError: { error in } }
        }
        
        reloadViews()
        
    }
    
    func reloadViews() {
        
        if collectionView.visibleCells.isEmpty {
            self.collectionView.reloadData()
        }
        
        tableView.reloadData()
        if reactionDataSource[selectedIndex].messageReaction.isEmpty {
            showLoadingView()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.fetchPrevious()
            }
        } else {
            removeConnectToLoadView()
            tableView.reloadData()
        }
        
    }
    
    func fetchPrevious() {
        reactionDataSource[selectedIndex].fetchPrevious { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.hideLoadingView()
                self.removeConnectToLoadView()
                self.tableView.reloadData()
            }
        } onError: { [weak self] error in
            DispatchQueue.main.async{
                self?.noteErrorForReconnect(error)
                self?.presentFailure(error)
                self?.hideLoadingView()
            }
        }
    }

    /// What a failed read of the open tab puts on screen. Offline OFF: the error view, as before.
    /// Offline ON (D84): rows already listed stay, and only an online failure reaches `onError`;
    /// nothing listed and not connected is "Connect to load reactions" (the app's error view, if it
    /// set one, shows instead) with `onError` once; any other failure is the error view and `onError`.
    func presentFailure(_ error: CometChatException?, offline: Bool = OfflineGate.isOn()) {
        guard offline else {
            addErrorView()
            return
        }
        let rowsShown = reactionDataSource.indices.contains(selectedIndex) && !reactionDataSource[selectedIndex].messageReaction.isEmpty
        let verdict = OfflineReadFailure.evaluate(error, rowsShown: rowsShown, keywordSearch: false, kitStarted: false)
        if verdict.reportsError, let error = error { onError?(error) }
        switch verdict.screen {
        case .rowsKept: break
        case .connectToLoad: addConnectToLoadView()
        default: addErrorView()
        }
    }

    /// "Connect to load reactions": an icon and text, no Retry, below the tabs, which keep the message's
    /// own counts (as on Android, ENG-57325). The app's own error view wins, and covers the tabs as before.
    func addConnectToLoadView() {
        if errorStateView != nil {
            addErrorView()
            return
        }
        removeErrorView()
        let backView = UIView().withoutAutoresizingMaskConstraints()
        view.addSubview(backView)
        NSLayoutConstraint.activate([
            backView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backView.topAnchor.constraint(equalTo: separatorView.bottomAnchor),
            backView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        shownErrorView = backView
        connectToLoadView = backView
        backView.backgroundColor = CometChatTheme.backgroundColor01
        backView.accessibilityIdentifier = StateContract.empty("connect-to-load-reactions")
        let icon = UIImageView(image: UIImage(systemName: "wifi.slash")?.withRenderingMode(.alwaysTemplate)).withoutAutoresizingMaskConstraints()
        icon.tintColor = CometChatTheme.neutralColor300
        icon.contentMode = .scaleAspectFit
        icon.pin(anchors: [.height, .width], to: 48)
        errorLabel.text = "CONNECT_TO_LOAD_REACTIONS".localize()
        let stack = UIStackView(arrangedSubviews: [icon, errorLabel]).withoutAutoresizingMaskConstraints()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = CometChatSpacing.Spacing.s3
        backView.addSubview(stack)
        stack.pin(anchors: [.centerX, .centerY], to: backView)
        stack.leadingAnchor.constraint(greaterThanOrEqualTo: backView.leadingAnchor, constant: CometChatSpacing.Spacing.s4).isActive = true
        stack.trailingAnchor.constraint(lessThanOrEqualTo: backView.trailingAnchor, constant: -(CometChatSpacing.Spacing.s4)).isActive = true
    }

    /// Offline ON: an error view for a not-connected error reads once more when the connection returns;
    /// one for any other error does not (D83).
    func noteErrorForReconnect(_ error: CometChatException?, offline: Bool = OfflineGate.isOn()) {
        reloadOnConnect = offline && OfflineErrors.isNotConnected(code: error?.errorCode)
    }

    func removeErrorView() {
        shownErrorView?.removeFromSuperview()
        shownErrorView = nil
    }

    /// Takes down "Connect to load reactions" only; the error view stays where it is.
    func removeConnectToLoadView() {
        guard let shown = connectToLoadView else { return }
        shown.removeFromSuperview()
        if shownErrorView === shown { shownErrorView = nil }
        connectToLoadView = nil
    }

    /// The connection is back (D83): read the tab again, once, when its error view waits for it.
    func reloadAfterReconnect() {
        guard reloadOnConnect, !reactionDataSource.isEmpty else { return }
        reloadOnConnect = false
        removeErrorView()
        showLoadingView()
        fetchPrevious()
    }
    
    func addErrorView() {
        if let errorStateView = errorStateView {
            view.embed(errorStateView)
            shownErrorView = errorStateView
        } else {
            //TODO: update the value of "SOMETHING_WENT_WRONG_ERROR" in localise files if other classes are using same text
            let backView = UIView().withoutAutoresizingMaskConstraints()
            view.embed(backView)
            shownErrorView = backView
            backView.backgroundColor = CometChatTheme.backgroundColor01
            errorLabel.text = "LOOKS_LIKE_SOMETHINGS_WENT_WORNG._PLEASE_TRY_AGAIN".localize()
            backView.addSubview(errorLabel)
            errorLabel.pin(anchors: [.centerX, .centerY], to: view)
            errorLabel.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: CometChatSpacing.Spacing.s4).isActive = true
            errorLabel.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -(CometChatSpacing.Spacing.s4)).isActive = true
        }
        
    }
    
    func setupStyle(){
        self.view.backgroundColor = style.backgroundColor
        self.loadingView.backgroundColor = style.backgroundColor
        self.view.borderWith(width: style.borderWidth)
        self.view.borderColor(color: style.borderColor)
        self.view.roundViewCorners(corner: style.cornerRadius ?? .init(cornerRadius: 20))
        errorLabel.textColor = style.errorTextColor
        errorLabel.font = style.errorTextFont
        errorLabel.adjustsFontForContentSizeCategory = true
    }
    
    func showLoadingView() {
        if disableLoadingState { return }
        (loadingView as? CometChatShimmerView)?.startShimmer()
        isLoadingViewVisible = true
        view.addSubview(loadingView)
        loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        loadingView.topAnchor.constraint(equalTo: separatorView.bottomAnchor).isActive = true
        loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func hideLoadingView() {
        (loadingView as? CometChatShimmerView)?.stopShimmer()
        isLoadingViewVisible = false
        loadingView.removeFromSuperview()
    }
    
    
    func buildUI() {
        
        loadingView = CometChatReactionListShimmer()
        
        self.tableView.backgroundColor = .clear
        self.tableView.separatorStyle = .none
        self.collectionView.backgroundColor = .clear
        self.separatorView.backgroundColor = CometChatTheme.borderColorDefault
        
        layout.scrollDirection = .horizontal
        
        view.addSubview(collectionView)
        view.addSubview(separatorView)
        view.addSubview(tableView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: CometChatSpacing.Spacing.s5),
            collectionView.heightAnchor.constraint(equalToConstant: 48),
            
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            separatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            separatorView.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
            
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: CometChatSpacing.Padding.p1),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -(CometChatSpacing.Padding.p1)),
            tableView.topAnchor.constraint(equalTo: separatorView.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

    }
    
    func removeInternalReaction(forIndex index: Int, reactionIndex: Int) {
        if let removedReactionModel = reactionDataSource[safe: index] {
            if let reaction = removedReactionModel.messageReaction[safe: reactionIndex] {
                if LoggedInUserInformation.isLoggedInUser(uid: reaction.reactedBy?.uid) {
                    
                    //Table View Update
                    removedReactionModel.messageReaction.remove(at: reactionIndex)
                    if index == selectedIndex {
                        tableView.deleteRows(at: [IndexPath(row: reactionIndex, section: 0)], with: .none)
                    }
                    
                    //collection View update
                    updateCollectionViewCount(index: index)
                }
            }
        }
    }
    
    func updateCollectionViewCount(index: Int) {
        if let removedReactionModel = reactionDataSource[safe: index] {
            removedReactionModel.count = removedReactionModel.count - 1
            if removedReactionModel.count == 0 {
                selectedIndex = 0
                collectionView.scrollToItem(at: IndexPath(row: selectedIndex, section: 0), at: .centeredHorizontally, animated: false)
                if index != 0 {
                    reactionDataSource.remove(at: index)
                }
                collectionView.reloadData()
                collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
            } else {
                fetchPrevious()
                collectionView.reloadData()
            }
        }
    }
    
}

extension CometChatReactionList: PanModalPresentable {
    var panScrollable: UIScrollView? {
        return nil
    }
    
    var longFormHeight: PanModalHeight {
        return PanModalHeight.contentHeight(400)
    }
}

extension CometChatReactionList: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reactionDataSource.count
    }
        
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReactionListCollectionCell", for: indexPath) as! ReactionListCollectionCell
        
        cell.reaction = reactionDataSource[indexPath.row].reaction
        cell.count = reactionDataSource[indexPath.row].count
        cell.didSelected = (indexPath.row == selectedIndex)
        cell.selectedBackgroundColor = style.reactionTabActiveIndicatorColor
        cell.tabBackgroundColor = style.reactionTabBackgroundColor
        cell.textColor = style.reactionTabTextColor
        cell.selectedTextColor = style.reactionActiveTabTextColor
        cell.font = style.reactionTabTextFont
        cell.onTapped = { [weak self] reaction, _ in
            guard let self = self else { return }
            self.selectedIndex = indexPath.row
        }
        cell.build()

        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 6, height: 50)
    }
}

extension CometChatReactionList: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reactionDataSource[safe: selectedIndex]?.messageReaction.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        //Calling configuration call back if there
        if let onClick = onClick {
            if let reaction = reactionDataSource[safe: selectedIndex]?.messageReaction[safe: indexPath.row],
               let baseMessage = baseMessage {
                onClick(reaction, baseMessage)
            }
            return nil
        }
        
        //Default Implementation for Item onClick
        if let reaction = reactionDataSource[safe: selectedIndex]?.messageReaction[safe: indexPath.row] {
            if LoggedInUserInformation.isLoggedInUser(uid: reaction.reactedBy?.uid) {
                
                CometChat.removeReaction(messageId: reactionDataSource[selectedIndex].messageID, reaction: reaction.reaction) { _ in    } onError: {  [weak self] error in
                    // The SDK calls back off the main thread; message-edited listeners are UI
                    // code, and the removal below is announced on main, so put it back there too.
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        if let baseMessage = self.baseMessage {
                            let updatedBaseMessage = CometChat.updateMessageWithReactionInfo(baseMessage: baseMessage, messageReaction: reaction, action: .REACTION_ADDED)
                            CometChatMessageEvents.ccMessageEdited(message: updatedBaseMessage, status: .success)
                        }
                    }
                }
                
                if selectedIndex == 0 {
                    if let collectionViewIndex = reactionDataSource.firstIndex(where: { $0.reaction ==  reaction.reaction }) {
                        if let reactionIndex = reactionDataSource[collectionViewIndex].messageReaction.firstIndex(where: { $0.id == reaction.id }) {
                            removeInternalReaction(forIndex: collectionViewIndex, reactionIndex: reactionIndex)
                        } else {
                            updateCollectionViewCount(index: collectionViewIndex)
                        }
                    }
                }
                
                if selectedIndex != 0 {
                    if let reactionIndex = reactionDataSource[0].messageReaction.firstIndex(where: { $0.id == reaction.id }) {
                        removeInternalReaction(forIndex: 0, reactionIndex: reactionIndex)
                    } else {
                        updateCollectionViewCount(index: 0)
                    }
                }
                
                removeInternalReaction(forIndex: selectedIndex, reactionIndex: indexPath.row)
                
                if let baseMessage = baseMessage {
                    let updatedBaseMessage = CometChat.updateMessageWithReactionInfo(baseMessage: baseMessage, messageReaction: reaction, action: .REACTION_REMOVED)
                    CometChatMessageEvents.ccMessageEdited(message: updatedBaseMessage, status: .success)
                }
                
                if reactionDataSource[0].messageReaction.isEmpty { self.dismiss(animated: true) }
                
                return nil
                
            } else {
                return nil
            }
        }
        return nil
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let listItem = tableView.dequeueReusableCell(withIdentifier: CometChatListItem.identifier, for: indexPath) as? CometChatListItem  {
            
            let reaction = reactionDataSource[selectedIndex].messageReaction[indexPath.row]
            
            listItem.set(avatarURL: reaction.reactedBy?.avatar ?? "", with: reaction.reactedBy?.name ?? "")
            listItem.set(title: reaction.reactedBy?.name ?? "")
            
            listItem.avatarHeightConstraint.constant = 32
            listItem.avatarWidthConstraint.constant = 32
            
            listItem.titleStack.spacing = 2
            
            listItem.avatar.style = avatarStyle
            if let listItemStyle = listItemStyle {
                listItem.style = listItemStyle
            }else{
                listItem.set(titleFont: style.titleTextFont)
                listItem.set(titleColor: style.titleTextColor)
            }
            
            listItem.hide(statusIndicator: true)
            
            if LoggedInUserInformation.isLoggedInUser(uid: reaction.reactedBy?.uid) {
                let tapToRemoveLabel = UILabel()
                tapToRemoveLabel.text = "TAP_TO_REMOVE".localize()
                tapToRemoveLabel.font = style.subTitleTextFont
                tapToRemoveLabel.adjustsFontForContentSizeCategory = true
                tapToRemoveLabel.textColor = style.subTitleTextColor
                tapToRemoveLabel.textAlignment = .left
                
                listItem.set(subtitle: tapToRemoveLabel)
            }
            
            let reactionLabel = UILabel()
            reactionLabel.text = reaction.reaction
            reactionLabel.font = style.tailViewTextFont
            reactionLabel.adjustsFontForContentSizeCategory = true
            reactionLabel.textAlignment = .right

            listItem.set(tail: reactionLabel)
            
            return listItem
        }
        return UITableViewCell()
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == (reactionDataSource[selectedIndex].messageReaction.count - 1)  && !reactionDataSource[selectedIndex].hasAllReactions {
            fetchPrevious()
        }
    }
}

extension CometChatReactionList {
    
    @discardableResult
    public func set(defaultReaction: String) -> Self{
        self.defaultReaction = defaultReaction
        return self
    }
    
    @discardableResult
    public func set(message: BaseMessage) -> Self {
        if let reactionRequestBuilder = reactionRequestBuilder {
            reactionRequestBuilder.set(messageId: message.id)
        }
        self.baseMessage = message
        return self
    }
    
    @discardableResult
    public func set(reactionRequestBuilder: ReactionsRequestBuilder) -> Self {
        if let messageID = baseMessage?.id {
            reactionRequestBuilder.set(messageId: messageID)
        }
        self.reactionRequestBuilder = reactionRequestBuilder
        return self
    }
    
    @discardableResult
    public func set(listItemStyle: ListItemStyle) -> Self {
        self.listItemStyle = listItemStyle
        return self
    }
    
    @discardableResult
    public func set(onClick: ((_ messageReaction: CometChatSDK.Reaction, _ messageObject: BaseMessage) -> ())?) -> Self {
        self.onClick = onClick
        return self
    }
    
    /// Called when a read fails (D84, offline ON): once for a tab that shows nothing, and for an online
    /// failure over rows already listed. A not-connected failure over rows is not reported.
    @discardableResult
    public func set(onError: ((_ error: CometChatException) -> Void)?) -> Self {
        self.onError = onError
        return self
    }

    @discardableResult
    public func set(errorStateView: UIView) -> Self {
        self.errorStateView = errorStateView
        return self
    }
    
    @discardableResult
    public func set(loadingStateView: UIView) -> Self {
        self.loadingStateView = loadingStateView
        return self
    }
    
    @discardableResult
    public func set(configuration: ReactionListConfiguration?) -> Self {
        
        if let configuration = configuration {
            
            if let reactionRequestBuilder = configuration.reactionRequestBuilder {
                set(reactionRequestBuilder: reactionRequestBuilder)
            }
            
            if let listItemStyle = configuration.listItemStyle {
                set(listItemStyle: listItemStyle)
            }
            
            if let onTappedToRemoveClicked = configuration.onTappedToRemoveClicked {
                set(onClick: onTappedToRemoveClicked)
            }
            
            if let errorStateView = configuration.errorStateView {
                set(errorStateView: errorStateView)
            }
            
            if let loadingStateView = configuration.loadingStateView {
                set(loadingStateView: loadingStateView)
            }
            
        }
        
        return self
    }
    
}

// MARK: - Connection Listener
extension CometChatReactionList: CometChatConnectionDelegate {
    public func connected() {
        DispatchQueue.main.async { [weak self] in self?.reloadAfterReconnect() }
    }

    public func connecting() {}

    public func disconnected() {}
}
