//
//  CometChatCallLogs.swift
//  CometChatUIKitSwift
//
//  Created by SuryanshBisen on 17/11/23.
//

import Foundation
import CometChatSDK

#if canImport(CometChatCallsSDK)
open class CometChatCallLogs: CometChatListBase {
    
    // MARK: - Properties
    public let viewModel = CallLogsViewModel()
    var listItemView: ((_ call: CometChatCallsSDK.CallLog) -> UIView)?
    var trailView: ((_ call: CometChatCallsSDK.CallLog) -> UIView)?
    var leadingView: ((_ call: CometChatCallsSDK.CallLog) -> UIView)?
    var titleView: ((_ call: CometChatCallsSDK.CallLog) -> UIView)?
    var subtitleView: ((_ callLog : CometChatCallsSDK.CallLog) -> UIView)?
    var onItemClick: ((_ callLog: CometChatCallsSDK.CallLog) -> Void)?
    var onItemLongClick: ((_ callLog: CometChatCallsSDK.CallLog, _ indexPath: IndexPath) -> Void)?
    var goToCallLogDetail: ((_ callLog: CometChatCallsSDK.CallLog, _ user: User?, _ group: Group?) -> Void)?
    var onError: ((_ error: Any?) -> Void)?
    var outgoingCallConfiguration = OutgoingCallConfiguration()
    var onCallButtonClicked: ((CometChatCallsSDK.CallLog) -> Void)?
    var callUser: CallUser?
    var callGroup: CallGroup?
    var callRequestBuilder: CometChatCallsSDK.CallLogsRequest.CallLogsBuilder?
    public static var style = CallLogStyle()
    public lazy var style = CometChatCallLogs.style
    
    var onEmpty: (() -> Void)?
    var onLoad: (([CometChatCallsSDK.CallLog]) -> Void)?
    var datePattern: ((_ callLog: CometChatCallsSDK.CallLog) -> String)?
    var options: ((_ call: CometChatCallsSDK.CallLog) -> [CometChatCallOption])?
    var addOptions: ((_ call: CometChatCallsSDK.CallLog) -> [CometChatCallOption])?
    
    
    //Date Time Formatter
    public static var dateTimeFormatter: CometChatDateTimeFormatter = CometChatUIKit.dateTimeFormatter
    public lazy var dateTimeFormatter: CometChatDateTimeFormatter = CometChatCallLogs.dateTimeFormatter
    
    
    public static var avatarStyle: AvatarStyle = {
        var avatarStyle = CometChatAvatar.style
        return avatarStyle
    }()
    public lazy var avatarStyle = CometChatCallLogs.avatarStyle
    
    /// Styles the date in each row's subtitle. Defaults to the call-log subtitle font and
    /// colour, so the default rows look as they did before the date honoured this style.
    /// A field of `dateStyle` still holding this inherited value defers to the
    /// instance's `style.listItemSubTitleFont` / `listItemSubTitleTextColor`.
    public static var dateStyle : DateStyle = CometChatCallLogs.inheritedDateStyle
    public lazy var dateStyle = CometChatCallLogs.dateStyle

    /// The date style the subtitle starts from: the call-log subtitle font and colour.
    private static let inheritedDateStyle: DateStyle = {
        var dateStyle = CometChatDate.style
        dateStyle.textFont = CometChatCallLogs.style.listItemSubTitleFont
        dateStyle.textColor = CometChatCallLogs.style.listItemSubTitleTextColor
        return dateStyle
    }()

    /// The row's date style: fields the integrator set on `dateStyle` win; the rest
    /// follow `style.listItemSubTitle*`, so the subtitle honours the call-log style.
    func resolvedDateStyle() -> DateStyle {
        var resolved = dateStyle
        let inherited = CometChatCallLogs.inheritedDateStyle
        if resolved.textFont == inherited.textFont {
            resolved.textFont = style.listItemSubTitleFont
        }
        if resolved.textColor == inherited.textColor {
            resolved.textColor = style.listItemSubTitleTextColor
        }
        return resolved
    }

    // MARK: - Initializers
    public init() {
        super.init(nibName: nil, bundle: nil)
        defaultSetup()
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView(style: .plain, withRefreshControl: true)
        registerCells()
        tableView.separatorStyle = .none
        showLoadingView()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
        viewModel.fetchCallLogs()
    }
    
    // MARK: - Setup Methods
    open func defaultSetup() {
        title = "CALLS".localize()
        prefersLargeTitles = true
        loadingView = CometChatCallLogShimmer()
        errorStateTitleText = "OOPS!".localize()
        errorStateSubTitleText = "LOOKS_LIKE_SOMETHINGS_WENT_WORNG._PLEASE_TRY_AGAIN".localize()
        errorStateImage = UIImage(named: "error-icon", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal) ?? UIImage()
        emptyStateImage = UIImage(systemName: "phone.fill")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
        emptyStateTitleText = "CALL_LOGS_EMPTY_MESSAGE".localize()
        emptyStateSubTitleText = "CALL_LOGS_EMPTY_SUBTITLE_MESSAGE".localize()
    }
    
    open override func setupStyle() {
        listBaseStyle = style
        super.setupStyle()
    }
    
    open func registerCells() {
        tableView.register(CometChatListItem.self, forCellReuseIdentifier: CometChatListItem.identifier)
    }
    
    // MARK: - Data Loading
    override func onRefreshControlTriggered() {
        viewModel.isRefresh = true
    }

    open func reloadData() {
        
        viewModel.reload = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if self.isEmptyStateVisible {
                    self.removeEmptyView()
                } else if self.isErrorStateVisible {
                    self.removeErrorView()
                }
                self.removeLoadingView()
                self.tableView.restore()
                self.reload()
                self.hideFooterIndicator()
                self.refreshControl.endRefreshing()
                if let onLoad = self.onLoad?(self.viewModel.callLogs){
                    onLoad
                }
            }
        }
        
        viewModel.failure = { [weak self] error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.hideFooterIndicator()
                self.refreshControl.endRefreshing()
                if self.viewModel.callLogs.isEmpty {
                    self.removeLoadingView()
                    self.showErrorView()
                    
                }
                self.onError?(error)
            }
        }
        
        viewModel.empty = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                // The end-of-list page answers the paging fetch that showed the footer spinner.
                self.hideFooterIndicator()
                self.refreshControl.endRefreshing()
                self.removeLoadingView()
                if self.viewModel.callLogs.isEmpty{
                    self.showEmptyView()
                    if let onEmpty = self.onEmpty?(){
                        onEmpty
                    }
                }
            }
        }
    }
    
    // MARK: - Call Handling

    /// Test seam: when set, a call resolved from a log is handed here instead of being
    /// placed through the SDK. Never set from product code.
    internal var placeResolvedCall: ((Call) -> Void)?

    /// The call that re-dials `callObject`: the other party of a one-to-one log — the
    /// receiver when the logged-in user placed it, the initiator when someone else did —
    /// with the log's media type. Nil for a group log (a call-back places one-to-one calls
    /// only; group calls are meetings started from the group) and when no user resolves.
    internal func resolveCall(for callObject: CallLog) -> Call? {
        guard !(callObject.receiver is CallGroup) else { return nil }
        let isLoggedInUserInitiator = LoggedInUserInformation.getUser()?.uid == (callObject.initiator as? CallUser)?.uid
        guard let callUser = isLoggedInUserInitiator ? (callObject.receiver as? CallUser) : (callObject.initiator as? CallUser) else {
            return nil
        }
        return Call(receiverId: callUser.uid, callType: callObject.type == .video ? .video : .audio, receiverType: .user)
    }

    func placeCall(for callObject: CallLog) {
        guard let call = resolveCall(for: callObject) else { return }
        if let placeResolvedCall = placeResolvedCall {
            placeResolvedCall(call)
            return
        }
        if callObject.type == .video {
            initiateDefaultVideoCall(call)
        } else {
            initiateDefaultAudioCall(call)
        }
    }
    
    @objc func onCallTap(_ sender: UIButton) {
        guard !viewModel.callLogs.isEmpty else { return }
        let index = sender.tag
        if let onCallButtonClicked = onCallButtonClicked?(viewModel.callLogs[index]) {
            onCallButtonClicked
        } else {
            let callData = viewModel.callLogs[index]
            placeCall(for: callData)
        }
    }
}

//MARK: Table view Delegate and Datasource methods
extension CometChatCallLogs {
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.callLogs.count
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastRow = tableView.numberOfRows(inSection: 0) - 1
        if indexPath.row == lastRow && !viewModel.isFetchedAll && !viewModel.isFetching {
            showFooterIndicator()
            viewModel.isRefresh = false
            viewModel.fetchNext()
        }else{
            hideFooterIndicator()
        }
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let listItem = tableView.dequeueReusableCell(withIdentifier: CometChatListItem.identifier, for: indexPath) as? CometChatListItem,
              let callData = viewModel.callLogs[safe: indexPath.row] else {
            return UITableViewCell()
        }
        
        if let group = (callData.receiver as? CallGroup) {
            callGroup = group
        } else if let initiator = (callData.initiator as? CallUser), initiator.uid != LoggedInUserInformation.getUser()?.uid {
            callUser = initiator
        } else if let receiver = (callData.receiver as? CallUser) {
            callUser = receiver
        }
        
        listItem.avatarHeightConstraint.constant = 48
        listItem.avatarWidthConstraint.constant = 48
        listItem.statusIndicator.isHidden = true
        
        listItem.set(title: (callUser?.name ?? callGroup?.name ?? ""))
        listItem.style = style
        listItem.avatar.style = avatarStyle
        
        if callData.status == .unanswered || callData.status == .busy {
            listItem.titleLabel.textColor = style.missedCallTitleColor
        }
        
        if let titleView = titleView{
            let titleView = titleView(callData)
            listItem.set(titleView: titleView)
        }
        
        if let subTitleCallBack = subtitleView {
            let subTitleView = subTitleCallBack(callData)
            listItem.set(subtitle: subTitleView)
        } else {
            let defaultSubtitle = CallUtils().configureCallLogSubtitleView(
                callData: callData,
                style: style,
                incomingCallIcon: style.incomingCallIcon,
                outgoingCallIcon: style.outgoingCallIcon,
                missedCallIcon: style.missedCallIcon, callDate: datePattern?(callData), dateTimeFormatter: dateTimeFormatter,
                dateStyle: resolvedDateStyle()
            )
            listItem.set(subtitle: defaultSubtitle)
        }
        
        if let listItemView = listItemView{
            let listItemView = listItemView(callData)
            listItem.set(customView: listItemView)
        }
        
        if let leadingView = leadingView?(callData){
            listItem.set(leadingView: leadingView)
        }
        
        listItem.set(avatarURL: callUser?.avatar ?? callGroup?.icon ?? "")
        
        if let tailViewCallBack = trailView {
            let tailView = tailViewCallBack(callData)
            listItem.set(tail: tailView)
        } else {
            var callImage = UIImage()
            let tailView = UIButton().withoutAutoresizingMaskConstraints()
            tailView.tag = indexPath.row
            if callData.type == .audio {
                callImage = style.audioCallIcon ?? UIImage()
                tailView.imageView?.tintColor = style.audioCallIconTint
            } else {
                callImage = style.videoCallIcon ?? UIImage()
                tailView.imageView?.tintColor = style.videoCallIconTint
            }
            tailView.addTarget(self, action: #selector(onCallTap(_:)), for: .touchUpInside)
            tailView.pin(anchors: [.height, .width], to: 24)
            tailView.setImage(callImage, for: .normal)
            tailView.accessibilityLabel = "a11y_call_back".localize()
            listItem.set(tail: tailView)
        }
        
        listItem.onItemLongClick = {
            self.onItemLongClick?(callData, indexPath)
        }
        
        return listItem
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.isUserInteractionEnabled = false
        if let onItemClick = self.onItemClick?(viewModel.callLogs[indexPath.row]){
            self.tableView.isUserInteractionEnabled = true
            onItemClick
        }else{
            var currentUser: User?
            var currentGroup: Group?
            
            let callData = viewModel.callLogs[indexPath.row]
            if let group = (callData.receiver as? CallGroup) {
                callGroup = group
            } else if let initiator = (callData.initiator as? CallUser), initiator.uid != LoggedInUserInformation.getUser()?.uid {
                callUser = initiator
            } else if let receiver = (callData.receiver as? CallUser) {
                callUser = receiver
            }
            if let callUser = callUser{
                CometChat.getUser(UID: callUser.uid) { user in
                    DispatchQueue.main.async {
                        if let user = user{
                            currentUser = user
                            self.tableView.isUserInteractionEnabled = true
                            self.goToCallLogDetail?(self.viewModel.callLogs[indexPath.row], user, nil)
                        }
                    }
                } onError: { error in
                    self.tableView.isUserInteractionEnabled = true
                    self.onError?(error)
                    CometChatLogger.error("error")
                }
            }else{
                CometChat.getGroup(GUID: callGroup?.guid ?? "") { group in
                    DispatchQueue.main.async {
                        currentGroup = group
                        self.tableView.isUserInteractionEnabled = true
                        self.goToCallLogDetail?(self.viewModel.callLogs[indexPath.row], nil, group)
                    }
                } onError: { error in
                    self.onError?(error)
                    self.tableView.isUserInteractionEnabled = true
                    CometChatLogger.error("error")
                }

            }
        }
    }
    
    public override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        guard let callData = viewModel.callLogs[safe: indexPath.row] else {
            return nil
        }
            
        var actions = [UIContextualAction]()
        if let customOptions = options?(callData) {
            let customActions = customOptions.map { option -> UIContextualAction in
                let action = UIContextualAction(style: .normal, title: option.title) { (action, sourceView, completionHandler) in
                    option.onClick?(nil, indexPath.section, option, self)
                    completionHandler(true)
                }
                action.backgroundColor = option.backgroundColor
                action.image = option.icon?.withTintColor(option.iconTint ?? .white)
                return action
            }
            actions.append(contentsOf: customActions)
        }
        
        if let addOptions = addOptions?(callData){
            let customActions = addOptions.map { option -> UIContextualAction in
                let action = UIContextualAction(style: .normal, title: option.title) { (action, sourceView, completionHandler) in
                    option.onClick?(nil, indexPath.section, option, self)
                    completionHandler(true)
                }
                action.backgroundColor = option.backgroundColor
                action.image = option.icon?.withTintColor(option.iconTint ?? .white)
                return action
            }
            actions.append(contentsOf: customActions)
        }
        
        let swipeActionConfig = UISwipeActionsConfiguration(actions: actions)
        swipeActionConfig.performsFirstActionWithFullSwipe = false
        return swipeActionConfig
        
    }
    
    public override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
#endif
