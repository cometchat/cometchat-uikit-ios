//
//  CometChatMessageInformation.swift
//
//
//  Created by Ajay Verma on 06/07/23.
//

import UIKit
import CometChatSDK

open class CometChatMessageInformation: CometChatListBase {
    
    public lazy var bubbleContainerView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints()
        return view
    }()
    
    ///Variable declaration
    public static var style = MessageInformationStyle()
    public static var receiptStyle: ReceiptStyle = {
        var receiptStyle = CometChatReceipt.style
        receiptStyle.readImageTintColor = CometChatTheme.infoColor
        return receiptStyle
    }()
    
    public var style = CometChatMessageInformation.style
    public var messageStyle: MessageBubbleStyle = CometChatMessageBubble.style.outgoing
    public var receiptStyle = CometChatMessageInformation.receiptStyle
    
    var bubbleSnapshotView: UIView?
    var subtitle: ((_ message: BaseMessage, _ receipt: MessageReceipt) -> UIView)?
    var bubbleView: ((_ message: BaseMessage) -> UIView)?
    var listItemView: ((_ message: BaseMessage, _ receipt: MessageReceipt) ->  UIView)?
    var onError: ((_ error: CometChatException) -> Void)?
    var receiptDatePattern: ((_ timestamp: Int?) -> String)?
    open var viewModel: MessageInformationViewModelProtocol = MessageInformationViewModel()
    lazy var activityIndicator = UIActivityIndicatorView().withoutAutoresizingMaskConstraints()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView(style: .plain, withRefreshControl: false)
        tableView.alwaysBounceVertical = true
        tableView.separatorStyle = .none
        
        registerCells()
        setupViewModel()
        if let message = viewModel.message { viewModel.getMessageReceipt(information: message) }
        viewModel.connect()
        buildBubbleView()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
        
    public init() {
        super.init(nibName: nil, bundle: nil)
        defaultSetup()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func defaultSetup() {
        
        prefersLargeTitles = false
                
        if let errorView = self.errorStateView as? StateView {
            errorView.imageView.isHidden = true
            errorView.titleLabel.isHidden = true
            errorView.retryButton.isHidden = true
            errorView.subtitleLabel.text = "Looks like something went wrong.\nPlease try again."
        }
        
        if let emptyStateView = self.emptyStateView as? StateView {
            emptyStateView.imageView.isHidden = true
            emptyStateView.titleLabel.isHidden = true
            emptyStateView.retryButton.isHidden = true
            emptyStateView.subtitleLabel.text = "Waiting for recipients to receive and view the message"
        }
    }
    
    open func registerCells() {
        tableView.register(CometChatListItem.self, forCellReuseIdentifier: CometChatListItem.identifier)
    }
    
    open override func setupStyle() {
        title = "Message Info"
        
        view.backgroundColor = style.backgroundColor
        view.borderWith(width: style.borderWidth)
        view.borderColor(color: style.borderColor)
        if let cornerRadius = style.cornerRadius { view.roundViewCorners(corner: cornerRadius) }
        
        bubbleContainerView.backgroundColor = style.bubbleContainerBackgroundColor
        bubbleContainerView.borderWith(width: style.borderWidth)
        bubbleContainerView.borderColor(color: style.borderColor)
        if let cornerRadius = style.bubbleContainerCornerRadius { bubbleContainerView.roundViewCorners(corner: cornerRadius)}
        
        if let errorView = self.errorStateView as? StateView {
            errorView.subtitleLabel.textColor = style.errorStateTextColor
            errorView.subtitleLabel.font = style.errorStateTextFont
        }
        
        if let emptyStateView = self.emptyStateView as? StateView {
            emptyStateView.subtitleLabel.textColor = style.emptyStateTextColor
            emptyStateView.subtitleLabel.font = style.emptyStateTextFont
        }
    }
    
    open override func styleNavigationBar() {
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
    
    open func buildBubbleView() {
        
        if let bubbleView = bubbleView?((viewModel.message)!) {
            tableView.tableHeaderView = bubbleView
        } else if let bubbleSnapshotView = bubbleSnapshotView {
            
            bubbleContainerView.heightAnchor.pin(equalToConstant: bubbleSnapshotView.bounds.height + (CometChatSpacing.Padding.p5*2)).isActive = true
            bubbleContainerView.widthAnchor.pin(equalToConstant: UIScreen.main.bounds.width).isActive = true
                        
            bubbleContainerView.addSubview(bubbleSnapshotView)
            bubbleSnapshotView.frame = CGRect(
                x: UIScreen.main.bounds.width - CometChatSpacing.Padding.p5 - bubbleSnapshotView.bounds.width,
                y: CometChatSpacing.Padding.p5,
                width: bubbleSnapshotView.bounds.width,
                height: bubbleSnapshotView.bounds.height
            )
            
            tableView.tableHeaderView = bubbleContainerView
        }
    }
    
    open override func showErrorView() {
        if disableErrorState { return }
        isErrorStateVisible = true
        errorStateView.translatesAutoresizingMaskIntoConstraints = true
        var heightForErrorStateView = self.view.frame.height - ((bubbleSnapshotView?.bounds.height ?? 0) + (CometChatSpacing.Padding.p5*2)) - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom
        if ((bubbleSnapshotView?.bounds.height ?? 0) + 120) > (self.view.frame.height - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom) {
            heightForErrorStateView = 200
        }
        errorStateView.frame = .init(
            x: 0,
            y: 0,
            width: UIScreen().bounds.width,
            height: heightForErrorStateView
        )
        tableView.tableFooterView = errorStateView
    }
    
    open override func showEmptyView() {
        if disableEmptyState { return }
        isEmptyStateVisible = true
       
        emptyStateView.translatesAutoresizingMaskIntoConstraints = true
        var heightForEmptyStateView = self.view.frame.height - ((bubbleSnapshotView?.bounds.height ?? 0) + (CometChatSpacing.Padding.p5*2)) - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom
        if ((bubbleSnapshotView?.bounds.height ?? 0) + 120) > (self.view.frame.height - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom) {
            heightForEmptyStateView = 200
        }

        emptyStateView.frame = .init(
            x: 0,
            y: 0,
            width: UIScreen().bounds.width,
            height: heightForEmptyStateView
        )
        tableView.tableFooterView = emptyStateView
    }
    
    deinit {
        viewModel.disconnect()
    }
    
}

///Implementing TableView delegate and datasource methods
extension CometChatMessageInformation {
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.receipts.count
    }
    
    open override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let listItem = tableView.dequeueReusableCell(withIdentifier: CometChatListItem.identifier, for: indexPath) as? CometChatListItem  {
            listItem.selectionStyle = .none
            if let receipt = viewModel.receipts[safe: indexPath.row] {
                
                //Custom View
                if let listItemView = listItemView?((viewModel.message)!, receipt) {
                    let container = UIStackView()
                    container.axis = .vertical
                    container.addArrangedSubview(listItemView)
                    listItem.set(customView: container)
                } else {
                    
                    if let group = viewModel.message?.receiver as? Group, let receiptBy = receipt.sender { //building for groups
                        
                        listItem.hide(statusIndicator: true)
                        listItem.set(avatarURL: receiptBy.avatar ?? "", with: receiptBy.name)
                        listItem.set(title: receiptBy.name ?? "")
                        
                        //Building tail View
                        buildSubTitleView(on: listItem, with: receipt)
                         
                    } else if let user = viewModel.message?.receiver as? User { //building for Users
                        
                        listItem.hide(avatar: true)

                        let receiptAttributedText = NSMutableAttributedString(string: "")
                        let imageAttachment = NSTextAttachment()
                        imageAttachment.bounds = CGRect(x: 0, y: -2.3, width: 16, height: 16)
                        
                        if receipt.receiptType == .delivered {
                            imageAttachment.image = receiptStyle.deliveredImage.withTintColor(receiptStyle.deliveredImageTintColor)
                            imageAttachment.image?.withTintColor(receiptStyle.deliveredImageTintColor)
                            receiptAttributedText.append(NSAttributedString(attachment: imageAttachment))
                            receiptAttributedText.append(NSAttributedString(string: " "))
                            receiptAttributedText.append(NSAttributedString(string: "DELIVERED".localize()))
                        } else if receipt.receiptType == .read {
                            imageAttachment.image = receiptStyle.readImage.withTintColor(receiptStyle.readImageTintColor)
                            imageAttachment.image?.withTintColor(receiptStyle.readImageTintColor)
                            receiptAttributedText.append(NSAttributedString(attachment: imageAttachment))
                            receiptAttributedText.append(NSAttributedString(string: " "))
                            receiptAttributedText.append(NSAttributedString(string: "READ".localize()))
                        } 
                        
                        listItem.titleLabel.attributedText = receiptAttributedText
                        
                        let dateLabel = UILabel().withoutAutoresizingMaskConstraints()
                        dateLabel.text = receipt.timeStamp != 0 ? receipt.timeStamp.getDateInString() : "---"
                        dateLabel.textColor = style.listItemSubTitleTextColor
                        dateLabel.font = style.listItemSubTitleFont
                        
                        listItem.set(subtitle: dateLabel)
                    }
                }
            }
            return listItem
        }
        return UITableViewCell()
    }
    
    func buildSubTitleView(on cell: CometChatListItem, with receipt: MessageReceipt) {
        
        let subTitleView = UIStackView().withoutAutoresizingMaskConstraints()
        subTitleView.axis = .vertical
        subTitleView.distribution = .fill
        subTitleView.alignment = .fill
        cell.set(subtitle: subTitleView)
        
        let tailView = UIStackView().withoutAutoresizingMaskConstraints()
        tailView.axis = .vertical
        tailView.distribution = .fill
        tailView.alignment = .fill
        
        let spacerLabel = UILabel()
        spacerLabel.text = " "
        spacerLabel.alpha = 0
        spacerLabel.font = style.titleFont
        
        tailView.addArrangedSubview(spacerLabel)
        
        if receipt.receiptType == .read {
            let receiptLabel = UILabel().withoutAutoresizingMaskConstraints()
            receiptLabel.textColor = style.listItemSubTitleTextColor
            receiptLabel.font = style.listItemSubTitleFont
            receiptLabel.text = "READ".localize()
            subTitleView.addArrangedSubview(receiptLabel)
            
            let dateLabel = UILabel().withoutAutoresizingMaskConstraints()
            dateLabel.textColor = style.listItemSubTitleTextColor
            dateLabel.font = style.listItemSubTitleFont
            dateLabel.text = receipt.timeStamp.getDateInString()
            tailView.addArrangedSubview(dateLabel)
        }
        
        let receiptLabel = UILabel().withoutAutoresizingMaskConstraints()
        receiptLabel.textColor = style.listItemSubTitleTextColor
        receiptLabel.font = style.listItemSubTitleFont
        receiptLabel.text = "DELIVERED".localize()
        subTitleView.addArrangedSubview(receiptLabel)
        subTitleView.setCustomSpacing(CometChatSpacing.Padding.p, after: receiptLabel)
        
        let dateLabel = UILabel().withoutAutoresizingMaskConstraints()
        dateLabel.textColor = style.listItemSubTitleTextColor
        dateLabel.font = style.listItemSubTitleFont
        dateLabel.text = receipt.timeStamp.getDateInString() // receipt.timeStamp.toDateFormatted()
        tailView.addArrangedSubview(dateLabel)
        tailView.setCustomSpacing(CometChatSpacing.Padding.p, after: dateLabel)
                
        cell.set(tail: tailView)
        
    }
    
    open override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    open override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration(actions: [])
    }
}

extension CometChatMessageInformation {
    
    private func getReceipt() {
        if let message = viewModel.message {
            viewModel.getMessageReceipt(information: message)
        }
    }
    
    private func setupViewModel() {
        
        viewModel.onError = { [weak self] error in
            guard let self else { return }
            DispatchQueue.main.async {
                self.showErrorView()
            }
        }
        
        viewModel.reload = { [weak self] in
            guard let self else { return }
            
            DispatchQueue.main.async {
                if self.viewModel.receipts.isEmpty {
                    self.showEmptyView()
                } else {
                    self.removeEmptyView()
                    self.removeLoadingView()
                    self.removeErrorView()
                }
                self.reload()
            }
        }
    }
    
}

//MARK: PROPERTIES
extension CometChatMessageInformation {
    
    public func set(message: BaseMessage) {
        viewModel.message = message
    }
    
    @discardableResult
    public func setSubtitle(subtitle: @escaping ((_ message: BaseMessage, _ receipt: MessageReceipt) -> UIView)) -> Self {
        self.subtitle = subtitle
        return self
    }
    
    @discardableResult
    public func setBubbleView(bubbleView: @escaping ((_ message: BaseMessage) -> UIView)) -> Self {
        self.bubbleView = bubbleView
        return self
    }
    
    @discardableResult
    public func setListItemView(listItemView: @escaping ((_ message: BaseMessage, _ receipt: MessageReceipt) ->  UIView)) -> Self {
        self.listItemView = listItemView
        return self
    }
    
    @discardableResult
    public func setOnError(onError: @escaping ((_ error: CometChatException) -> Void)) -> Self {
        self.onError = onError
        return self
    }
    
}

extension Int {
    /// Converts an Int Unix Epoch timestamp to the format "15 Oct, 2024".
    func getDateInString(with pattern: String = "dd/M/yyyy, h:mm a") -> String {
        // Create a Date object from the Unix timestamp
        let date = Date(timeIntervalSince1970: TimeInterval(self))
        
        // Create a DateFormatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = pattern
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        // Convert the date to the desired string format
        return dateFormatter.string(from: date)
    }
}
