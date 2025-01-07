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
    private var baseMessage: BaseMessage?
    private var tableViewSpinner = UIActivityIndicatorView()
    private var defaultReaction: String?
    private var layout = UICollectionViewFlowLayout()
    
    private var reactionRequestBuilder: ReactionsRequestBuilder?
    private var listItemStyle: ListItemStyle?
    private var onClick: ((_ messageReaction: CometChatSDK.Reaction, _ messageObject: BaseMessage) -> ())?
    private var errorStateView: UIView?
    private var loadingStateView: UIView?
    
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
                    self.collectionView.reloadItems(at: [IndexPath(row: oldValue, section: 0), IndexPath(row: selectedIndex, section: 0)])
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
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        setupStyle()
        fetchReactions()
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
        reactionDataSource.append(ReactionListDataModel(reaction: "All", count: totalReactions, messageID: baseMessage.id, reactionsRequest: reactionRequestBuilder))
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
            tableView.reloadData()
        }
        
    }
    
    func fetchPrevious() {
        reactionDataSource[selectedIndex].fetchPrevious { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.hideLoadingView()
                self.tableView.reloadData()
            }
        } onError: { [weak self] _ in
            DispatchQueue.main.async{
                self?.addErrorView()
                self?.hideLoadingView()
            }
        }
    }
    
    func addErrorView() {
        if let errorStateView = errorStateView {
            view.embed(errorStateView)
        } else {
            //TODO: update the value of "SOMETHING_WENT_WRONG_ERROR" in localise files if other classes are using same text
            let backView = UIView().withoutAutoresizingMaskConstraints()
            view.embed(backView)
            backView.backgroundColor = CometChatTheme.backgroundColor01
            errorLabel.text = "Looks like something went wrong. Please try again."
            backView.addSubview(errorLabel)
            errorLabel.pin(anchors: [.centerX, .centerY], to: view)
            errorLabel.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: CometChatSpacing.Spacing.s4).isActive = true
            errorLabel.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -(CometChatSpacing.Spacing.s4)).isActive = true
        }
        
    }
    
    func setupStyle(){
        self.view.backgroundColor = style.backgroundColor
        self.view.borderWith(width: style.borderWidth)
        self.view.borderColor(color: style.borderColor)
        self.view.roundViewCorners(corner: style.cornerRadius ?? .init(cornerRadius: 20))
        errorLabel.textColor = style.errorTextColor
        errorLabel.font = style.errorTextFont
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
                if reaction.reactedBy?.uid == CometChat.getLoggedInUser()?.uid {
                    
                    //Table View Update
                    removedReactionModel.messageReaction.remove(at: reactionIndex)
                    if index == selectedIndex { tableView.deleteRows(at: [IndexPath(row: reactionIndex, section: 0)], with: .left) }
                    
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
                if index != 0 {
                    reactionDataSource.remove(at: index)
                }
                collectionView.reloadData()
                collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
            } else {
                collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
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
            if reaction.reactedBy?.uid == CometChat.getLoggedInUser()?.uid {
                
                CometChat.removeReaction(messageId: reactionDataSource[selectedIndex].messageID, reaction: reaction.reaction) { _ in    } onError: {  [weak self] error in
                    guard let self = self else { return }
                    if let baseMessage = self.baseMessage {
                        let updatedBaseMessage = CometChat.updateMessageWithReactionInfo(baseMessage: baseMessage, messageReaction: reaction, action: .REACTION_ADDED)
                        CometChatMessageEvents.ccMessageEdited(message: updatedBaseMessage, status: .success)
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
            
            if reaction.reactedBy?.uid == CometChat.getLoggedInUser()?.uid {
                let tapToRemoveLabel = UILabel()
                tapToRemoveLabel.text = "Tap to remove"
                tapToRemoveLabel.font = style.subTitleTextFont
                tapToRemoveLabel.textColor = style.subTitleTextColor
                tapToRemoveLabel.textAlignment = .left
                
                listItem.set(subtitle: tapToRemoveLabel)
            }
            
            let reactionLabel = UILabel()
            reactionLabel.text = reaction.reaction
            reactionLabel.font = style.tailViewTextFont
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
