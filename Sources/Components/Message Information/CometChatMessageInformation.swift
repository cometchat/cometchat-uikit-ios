//
//  CometChatMessageInformation.swift
//
//
//  Created by Ajay Verma on 06/07/23.
//

import UIKit
import CometChatSDK

@objc public class CometChatMessageInformation: UIViewController {
    
    ///Outlets declaration
    @IBOutlet weak var messageContainer: UIStackView!
    @IBOutlet weak var container: UIStackView!
    @IBOutlet weak var infoTable: UITableView!
    
    ///Variable declaration
    
    var titleText: String?
    var backIcon: UIImage?
    var readIcon: UIImage?
    var deliveredIcon: UIImage?
    var emptyStateText: String = ""
    var emptyStateView: UIView?
    var loadingIcon: UIImage?
    var loadingStateView: UIView?
    var errorStateText: String = ""
    var errorStateView: UIView?
    var listItemStyle = ListItemStyle()
    var template: CometChatMessageTemplate?
    var messageInformationStyle = MessageInformationStyle()
    var subtitle: ((_ message: BaseMessage, _ receipt: MessageReceipt) -> UIView)?
    var bubbleView: ((_ message: BaseMessage) -> UIView)?
    var listItemView: ((_ message: BaseMessage, _ receipt: MessageReceipt) ->  UIView)?
    var onError: ((_ error: CometChatException) -> Void)?
    var onBack: (() -> Void)?
    var receiptDatePattern: ((_ timestamp: Int?) -> String)?
    var viewModel: MessageInformationViewModel?
    let tryAgainText = "TRY_AGAIN".localize()
    let cancelText = "CANCEL".localize()
  
    
    ///Life cycle method
    public override func loadView() {
        let loadedNib = Bundle.module.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)
        if let contentView = loadedNib?.first as? UIView  {
            contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.view  = contentView
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        configureViewModel()
        setupBubbleView()
        viewModel?.connect()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        viewModel?.remove()
    }
    
    @objc func didBackButtonPressed() {
        if let onBack = onBack{
            onBack()
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func setupBubbleView() {
        if let customBubble = bubbleView?((viewModel?.message)!) {
            container.addArrangedSubview(customBubble)
        } else {
            if let bubbleView = template?.contentView?(viewModel?.message, .left, self) {
                if let senderUid = viewModel?.message?.senderUid, let message = viewModel?.message {
                    MessageUtils.bubbleBackgroundAppearance(bubbleView: bubbleView, senderUid: senderUid, message: message, controller: self)
                    bubbleView.roundViewCorners(corner: messageInformationStyle.cornerRadius)
                    container.addArrangedSubview(bubbleView)
                }

            }
        }
        
    }
    
    private func setupNavigationBar()  {
        self.navigationItem.title = (titleText?.isEmpty == false) ? titleText : "MESSAGE_INFORMATION".localize()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: backIcon != nil ? backIcon : UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(didBackButtonPressed))
    }
    
    private func setupTableView() {
        infoTable.delegate = self
        infoTable.dataSource = self
        registerCellWith(title: CometChatListItem.identifier)
    }
    
    private func registerCellWith(title: String) {
        let cell = UINib(nibName: title, bundle: CometChatUIKit.bundle)
        self.infoTable.register(cell, forCellReuseIdentifier: title)
    }
    
}

extension CometChatMessageInformation {
    
    public func set(message: BaseMessage) {
        viewModel = MessageInformationViewModel()
        viewModel?.message = message
    }
    
    @discardableResult
    public func set(emptyStateText: String) -> Self {
        self.emptyStateText = emptyStateText
        return self
    }
    
    @discardableResult
    public func set(emptyStateView: UIView) -> Self {
        self.emptyStateView = emptyStateView
        return self
    }
    
    @discardableResult
    public func set(loadingStateView: UIView) -> Self {
        self.loadingStateView = loadingStateView
        return self
    }
    
    @discardableResult
    public func set(loadingIcon: UIImage) -> Self {
        self.loadingIcon = loadingIcon
        return self
    }
    
    @discardableResult
    public func set(errorStateText: String) -> Self {
        self.errorStateText = errorStateText
        return self
    }
    
    @discardableResult
    public func set(errorStateView: UIView) -> Self {
        self.errorStateView = errorStateView
        return self
    }
    
    @discardableResult
    public func set(backIcon: UIImage) -> Self {
        self.backIcon = backIcon
        return self
    }
    
    @discardableResult
    public func set(readIcon: UIImage) -> Self {
        self.readIcon = readIcon
        return self
    }
    
    @discardableResult
    public func set(deliveredIcon: UIImage) -> Self {
        self.deliveredIcon = deliveredIcon
        return self
    }
        
    @discardableResult
    public func set(listItemStyle: ListItemStyle) -> Self {
        self.listItemStyle = listItemStyle
        return self
    }
    
    @discardableResult
    public func set(messageInformationStyle: MessageInformationStyle) -> Self {
        self.messageInformationStyle = messageInformationStyle
        return self
    }
    
    @discardableResult
    public func set(template: CometChatMessageTemplate) -> Self {
        self.template = template
        return self
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
    
    @discardableResult
    public func setOnBack(onBack: @escaping () -> Void) -> Self {
        self.onBack = onBack
        return self
    }
    
    @discardableResult
    public func set(titleText: String) -> Self {
        self.titleText = titleText
        return self
    }
    
    
}

///Implementing TableView delegate and datasource methods
extension CometChatMessageInformation: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.receipts.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Receipt Information".localize()
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let listItem = tableView.dequeueReusableCell(withIdentifier: CometChatListItem.identifier, for: indexPath) as? CometChatListItem  {
            listItem.selectionStyle = .none
            if let receipt = viewModel?.receipts[indexPath.row] , let sender = receipt.sender {
                if let listItemView = listItemView?((viewModel?.message)!, receipt) {
                    let container = UIStackView()
                    container.axis = .vertical
                    container.addArrangedSubview(listItemView)
                    listItem.set(customView: container)
                } else {
                    
                    if let avatar = sender.avatar {
                        listItem.set(avatarURL: avatar)
                    }
                    
                    if let name = sender.name {
                        listItem.set(title: name.capitalized)
                    }
                    
                    if let subTitleView = subtitle?((viewModel?.message)!, receipt) {
                        listItem.set(subtitle: subTitleView)
                    } else {
                        if  let subtitle =  configureSubtitleView(deliveredAt: receipt.deliveredAt, readAt: receipt.readAt) {
                            listItem.set(subtitle: subtitle)
                        }
                    }
                    
                }
            }
            
            listItem.build()
            return listItem
        }
        return UITableViewCell()
    }
    
}

extension CometChatMessageInformation {
    
    private func configureViewModel() {
        initViewModel()
    }
    
    private func initViewModel() {
        observeEvent()
        if let message = viewModel?.message {
            viewModel?.getMessageReceipt(information: message)
        }
    }
    
    private func observeEvent() {
        viewModel?.eventHandler = { [weak self] event in
            guard let self else { return }
            switch event {
                
            case .startLoading: break
            case .endLoading: break
            case .reload:
                DispatchQueue.main.async {
                    if self.viewModel?.receipts.count == 0 {
                        if let emptyStateView = self.emptyStateView {
                            self.infoTable.set(customView: emptyStateView)
                        } else {
                            self.infoTable.setEmptyMessage(self.emptyStateText, color: nil, font: nil)
                        }
                    }
                    self.infoTable.reloadData()
                }
            case .error(let error):
                if let errorStateView =  self.errorStateView {
                    self.infoTable.set(customView: errorStateView)
                } else {
                    let confirmDialog = CometChatDialog()
                    confirmDialog.set(confirmButtonText: self.tryAgainText)
                    confirmDialog.set(cancelButtonText: self.cancelText)
                    if self.errorStateText.isEmpty {
                        if let error = error {
                            confirmDialog.set(error: CometChatServerError.get(error: error))
                        }
                    } else {
                        confirmDialog.set(messageText: self.errorStateText)
                    }
                    confirmDialog.open {}
                }
            }
        }
    }
    
    private func configureSubtitleView(deliveredAt: Double, readAt: Double) -> UIView? {
        let subTitleView = UIStackView()
        subTitleView.alignment = .leading
        subTitleView.distribution = .fillProportionally
        subTitleView.axis = .vertical
        subTitleView.spacing = 0
        
        if deliveredAt > 0.0 {
            
            let date = setupDate(timeStamp: deliveredAt)
            let deliveredLabel = setupReceiptStatus(receiptStatus: "DELIVERED".localize())
            let reciept = CometChatReceipt(image: deliveredIcon != nil ? deliveredIcon : UIImage(named: "messages-delivered" ,in: CometChatUIKit.bundle, with: nil))
            reciept.heightAnchor.constraint(equalToConstant: 20).isActive = true
            reciept.widthAnchor.constraint(equalToConstant: 20).isActive = true
            
            let dStack = UIStackView()
            dStack.axis = .horizontal
            dStack.spacing = 10
            dStack.addArrangedSubview(reciept)
            dStack.addArrangedSubview(deliveredLabel)
            dStack.addArrangedSubview(date)
            subTitleView.addArrangedSubview(dStack)
        }
        
        if readAt > 0.0 {
            
            let reciept = CometChatReceipt(image: readIcon != nil ? readIcon : UIImage(named: "messages-read" ,in: CometChatUIKit.bundle, with: nil))
            reciept.heightAnchor.constraint(equalToConstant: 20).isActive = true
            reciept.widthAnchor.constraint(equalToConstant: 20).isActive = true
            let date = setupDate(timeStamp: readAt)
            let readLabel = setupReceiptStatus(receiptStatus: "READ".localize())
            
            let rStack = UIStackView()
            rStack.axis = .horizontal
            rStack.spacing = 10
            rStack.addArrangedSubview(reciept)
            rStack.addArrangedSubview(readLabel)
            rStack.addArrangedSubview(date)
            subTitleView.addArrangedSubview(rStack)
            
        }
        return subTitleView
    }
    
    func setupDate(timeStamp: Double) -> CometChatDate {
        let date = CometChatDate()
        date.set(timeFont: messageInformationStyle.subtitleTextFont)
        date.set(timeColor: messageInformationStyle.subtitleTextColor)
        if let receiptDatePattern = receiptDatePattern?(Int(timeStamp)) {
            date.text = receiptDatePattern
        } else  {
            date.set(pattern: .dayDate)
            date.set(timestamp: Int(timeStamp))
        }
        return date
    }
    
    func setupReceiptStatus(receiptStatus: String) -> UILabel {
        let readLabel = UILabel()
        readLabel.font = messageInformationStyle.subtitleTextFont
        readLabel.textColor = messageInformationStyle.subtitleTextColor
        readLabel.textAlignment = .right
        readLabel.text = receiptStatus.localize() + ":"
        return readLabel
    }
    
}
