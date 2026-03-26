
//  CometChatCreatePoll.swift
 
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.

import UIKit
import CometChatSDK

public enum CometChatPollsSection{
    case question
    case answers
}

open class CometChatCreatePoll: UIViewController, UIGestureRecognizerDelegate, CometChatCreatePollOptionsDelegate, UITableViewDragDelegate {

    lazy var sendButton: UIButton = {
        let button = UIButton().withoutAutoresizingMaskConstraints()
        button.setTitle("SEND".localize(), for: .normal)
        button.addTarget(self, action: #selector(didSendPressed), for: .touchUpInside)
        return button
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton().withoutAutoresizingMaskConstraints()
        button.setTitle("CANCEL".localize(), for: .normal)
        button.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        return button
    }()

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped).withoutAutoresizingMaskConstraints()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.dragDelegate = self
        tableView.dragInteractionEnabled = true
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .clear
        return tableView
    }()
    
    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView().withoutAutoresizingMaskConstraints()
        imageView.pin(anchors: [.height, .width], to: 16)
        return imageView
    }()

    lazy var messageLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints()
        label.numberOfLines = 0
        return label
    }()
    
    lazy var errorView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints()
        return view
    }()
    
    lazy var errorStatckView: UIStackView = {
        let stackView = UIStackView().withoutAutoresizingMaskConstraints()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .top
        stackView.spacing = CometChatSpacing.Padding.p1
        return stackView
    }()

    // MARK: - Properties
    public  var items: [String] = ["", ""]
    public var user: User?
    public var group: Group?
    public var onDismiss: (() -> ())?
    public var questionString: String = ""
    public var firstOptionString: String = ""
    public var secondOptionString: String = ""
    public var initialOptionsFilled = (false, false)
    public static var style = CreatePollStyle()
    public lazy var style = CometChatCreatePoll.style
    
    var quotedMessageId: Int?
    var quotedMessage: BaseMessage?
    
    public var cometChatPollSection: [CometChatPollsSection] = [.question, .answers]
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
        setupTapGesture()
        registerCells()
        setupNavigation()
        tableView.reloadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let keyboardHeight = calculateKeyboardHeight(from: keyboardFrame)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        tableView.scrollIndicatorInsets = tableView.contentInset
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        tableView.contentInset = .zero
        tableView.scrollIndicatorInsets = .zero
    }
    
    /// Calculate keyboard height accounting for iPad flexible window positioning
    private func calculateKeyboardHeight(from keyboardFrame: CGRect) -> CGFloat {
        guard let window = self.view.window else {
            return keyboardFrame.height
        }
        
        // Convert keyboard frame from screen coordinates to window coordinates
        let keyboardFrameInWindow = window.convert(keyboardFrame, from: nil)
        
        // Calculate the keyboard height relative to the window bottom
        let windowHeight = window.bounds.height
        let keyboardTopInWindow = keyboardFrameInWindow.origin.y
        
        // If keyboard is below the window (not visible), return 0
        if keyboardTopInWindow >= windowHeight {
            return 0
        }
        
        return max(0, windowHeight - keyboardTopInWindow)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    open func registerCells() {
        tableView.register(CometChatCreatePollQuestions.self, forCellReuseIdentifier: "CometChatCreatePollQuestions")
        tableView.register(CometChatCreatePollOptions.self, forCellReuseIdentifier: "CometChatCreatePollOptions")
        tableView.register(CometChatCreatePollHeader.self, forCellReuseIdentifier: "CometChatCreatePollHeader")
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupStyle()
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        onDismiss?()
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    open func buildUI() {
        view.addSubview(tableView)
        view.addSubview(errorView)
        errorView.addSubview(errorStatckView)
        errorStatckView.addArrangedSubview(iconImageView)
        errorStatckView.addArrangedSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            errorStatckView.topAnchor.constraint(equalTo: errorView.topAnchor, constant: CometChatSpacing.Padding.p1),
            errorStatckView.leadingAnchor.constraint(equalTo: errorView.leadingAnchor, constant: CometChatSpacing.Padding.p2),
            errorStatckView.trailingAnchor.constraint(equalTo: errorView.trailingAnchor, constant: -(CometChatSpacing.Padding.p2)),
            errorStatckView.bottomAnchor.constraint(greaterThanOrEqualTo: errorView.bottomAnchor, constant: -(CometChatSpacing.Padding.p1)),
            
            errorView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: -(CometChatSpacing.Padding.p5)),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: CometChatSpacing.Padding.p4),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -(CometChatSpacing.Padding.p4)),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -(CometChatSpacing.Padding.p10)),
        ])
        errorView.isHidden = true
    }

    open func setupStyle() {
        view.backgroundColor = style.backgroundColor
        view.borderWith(width: style.borderWidth)
        view.borderColor(color: style.borderColor)
        view.roundViewCorners(corner: style.cornerRadius ?? .init(cornerRadius: CometChatSpacing.Radius.r3))
        
        sendButton.backgroundColor = style.sendButtonBackgroundColor
        sendButton.borderColor(color: style.sendButtonBorderColor)
        sendButton.borderWith(width: style.sendButtonBorderWidth)
        sendButton.roundViewCorners(corner: style.sendButtonCornerRadius ?? .init(cornerRadius: CometChatSpacing.Radius.r2))
        sendButton.setTitleColor(style.sendButtonDisabledTextColor, for: .normal)
        sendButton.titleLabel?.font = style.sendButtonTextFont
        
        cancelButton.backgroundColor = style.cancelButtonBackgroundColor
        cancelButton.borderColor(color: style.cancelButtonBorderColor)
        cancelButton.borderWith(width: style.cancelButtonBorderWidth)
        cancelButton.roundViewCorners(corner: style.cancelButtonCornerRadius ?? .init(cornerRadius: CometChatSpacing.Radius.r2))
        cancelButton.setTitleColor(style.cancelButtonTextColor, for: .normal)
        cancelButton.titleLabel?.font = style.cancelButtonTextFont
        
        errorView.backgroundColor = style.errorViewBackgroundColor
        errorView.borderWith(width: style.errorViewBorderWidth)
        errorView.borderColor(color: style.errorViewBorderColor)
        errorView.roundViewCorners(corner: style.errorViewCornerRadius ?? .init(cornerRadius: CometChatSpacing.Radius.r2))
        messageLabel.textColor = style.errorTextColor
        messageLabel.font = style.errorTextFont
        iconImageView.image = style.errorImage
        iconImageView.tintColor = style.errorImageTintColor
    }
        
    open func setupNavigation() {
        if navigationController != nil {
            navigationItem.title = "CREATE_POLL".localize()
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: sendButton)
        }
    }
    
    @objc open func dismissView() {
        if !(questionString.isEmpty) || !(firstOptionString.isEmpty) || !(secondOptionString.isEmpty){
            showExitConfirmation()
        }else{
            dismiss(animated: true)
        }
    }

    @objc open func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        validateSendButtonState()
        view.endEditing(true)
    }

    @objc open func didSendPressed() {
        view.endEditing(true)
        if questionString != "" {
            let options = items.filter { !$0.isEmpty }
            var body = ["question": questionString, "options": options] as [String: Any]
            
            if let user = user {
                body.append(with: ["receiver": user.uid ?? "", "receiverType": ReceiverTypeConstants.user])
            } else if let group = group {
                body.append(with: ["receiver": group.guid, "receiverType": ReceiverTypeConstants.group])
            }
            
            if let quotedMessage = quotedMessage {
                body.append(with: ["quotedMessage": quotedMessage.rawMessage ?? [:]])
            }
            if let id = quotedMessageId {
                body.append(with: ["quotedMessageId": id])
            }
            
            if (firstOptionString.isEmpty || secondOptionString.isEmpty) && items.filter({$0 != ""}).count < 2{
                showErrorView(errorText: "FILL_POLL_DETAILS".localize())
            }else{
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: nil, message: "CREATING_POLL".localize(), preferredStyle: .alert)
                    let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
                    loadingIndicator.hidesWhenStopped = true
                    loadingIndicator.style = .medium
                    loadingIndicator.color = CometChatTheme.iconColorSecondary
                    loadingIndicator.startAnimating()
                    alert.view.addSubview(loadingIndicator)
                    self.present(alert, animated: true, completion: nil)
                }
                
                CometChat.callExtension(slug: ExtensionConstants.polls, type: .post, endPoint: "v2/create", body: body, onSuccess: { [weak self] _ in
                    if let mssg = self?.quotedMessage {
                        CometChatMessageEvents.ccReplyToMessage(message: mssg, status: .success)
                    }
                    self?.quotedMessage = nil
                    self?.quotedMessageId = nil
                    DispatchQueue.main.async {
                        self?.dismiss(animated: true) {
                            self?.dismiss(animated: true, completion: nil)
                        }
                    }
                }) { error in
                    DispatchQueue.main.async {
                        self.dismiss(animated: true) {
                            if let error = error {
                                let confirmDialog = CometChatDialog()
                                confirmDialog.set(confirmButtonText: "TRY_AGAIN".localize())
                                confirmDialog.set(cancelButtonText: "CANCEL".localize())
                                confirmDialog.set(error: CometChatServerError.get(error: error))
                                confirmDialog.open(onConfirm: { [weak self] in
                                    self?.viewDidLoad()
                                    self?.viewWillAppear(true)
                                })
                            }
                        }
                    }
                }
            }
        }
    }
   
   open func validateSendButtonState() {
       if questionString.isEmpty{
           disableSendButton()
           return
       }

        let filledOptions = items.filter { !$0.isEmpty }
        if items.count == 2 {
            filledOptions.count == 2 ? enableSendButton() : disableSendButton()
        } else {
            filledOptions.count >= 2 ? enableSendButton() : disableSendButton()
        }
    }

    open func enableSendButton() {
        sendButton.isUserInteractionEnabled = true
        sendButton.setTitleColor(style.sendButtonTextColor, for: .normal)
    }

    open func disableSendButton() {
        sendButton.isUserInteractionEnabled = false
        sendButton.setTitleColor(style.sendButtonDisabledTextColor, for: .normal)
    }

    @objc open func textFieldDidChange(_ textField: UITextField) {
        let section = textField.tag
        if section == 0 {
            questionString = textField.text ?? ""
        }
        validateSendButtonState()
    }
    
   open func didStartEditingOption(at index: Int, with string: String) {
       
       if index == 0{
           initialOptionsFilled.0 = true
       }else if index == 1{
           initialOptionsFilled.1 = true
           if initialOptionsFilled.0 == false{
               return
           }
       }
       
       if initialOptionsFilled == (true, true) && (!firstOptionString.isEmpty || !secondOptionString.isEmpty){
           if (index == 0 || index == 1) && items.last != ""{
               items.append("")
               let newIndexPath = IndexPath(row: items.count - 1, section: 1)
               
               tableView.beginUpdates()
               tableView.insertRows(at: [newIndexPath], with: .automatic)
               tableView.endUpdates()
           }else if index == items.count - 1 && items.count < 12 {
               items.append("")
               let newIndexPath = IndexPath(row: items.count - 1, section: 1)
               
               tableView.beginUpdates()
               tableView.insertRows(at: [newIndexPath], with: .automatic)
               tableView.endUpdates()
           }
       }
    }
    
    open func showExitConfirmation() {
        let alertController = UIAlertController(title: "EXIT".localize(), message: "EXIT_ALERT".localize(), preferredStyle: .alert)

        let confirmAction = UIAlertAction(title: "YES".localize(), style: .destructive) { [weak self] _ in
            self?.dismiss(animated: true)
        }
        let cancelAction = UIAlertAction(title: "NO".localize(), style: .cancel, handler: nil)

        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true)
    }
    
    open func showErrorView(errorText: String){
        errorView.isHidden = false
        messageLabel.text = errorText
    }

    @discardableResult
    @objc public func set(user: User) -> CometChatCreatePoll {
        self.user = user
        return self
    }

    @discardableResult
    @objc public func set(group: Group) -> CometChatCreatePoll {
        self.group = group
        return self
    }

    @discardableResult
    public func set(onDismiss: @escaping (() -> ())) -> Self {
        self.onDismiss = onDismiss
        return self
    }
}

extension CometChatCreatePoll: UITableViewDelegate, UITableViewDataSource {
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return cometChatPollSection.count
    }

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch cometChatPollSection[section] {
        case .question:
            return 1
        case .answers:
            return items.count
        }
    }
    
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: CometChatSpacing.Padding.p2),
            titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -CometChatSpacing.Padding.p2)
        ])
        
        switch cometChatPollSection[section] {
        case .question:
            titleLabel.text = "QUESTION".localize()
            titleLabel.textColor = style.questionTitleTextColor
            titleLabel.font = style.questionTitleTextFont
        case .answers:
            titleLabel.text = "OPTIONS".localize()
            titleLabel.textColor = style.optionsTitleTextColor
            titleLabel.font = style.optionsTitleTextFont
        }
        return headerView
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch cometChatPollSection[indexPath.section] {
        case .question:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CometChatCreatePollQuestions", for: indexPath) as? CometChatCreatePollQuestions else {
                return UITableViewCell()
            }
            cell.question.tag = indexPath.section
            cell.question.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            cell.containerView.backgroundColor = style.questionInputBoxBackground
            cell.containerView.borderWith(width: style.questionInputBoxBorderWidth)
            cell.containerView.borderColor(color: style.questionInputBoxBorderColor)
            cell.containerView.roundViewCorners(corner: style.questionInputBoxCornerRadius ?? .init(cornerRadius: CometChatSpacing.Radius.r2))
            cell.question.textColor = style.questionTextColor
            cell.question.font = style.questionTextFont
            cell.question.attributedPlaceholder = NSAttributedString(
                string: "ASK_QUESTION".localize(),
                attributes: [.foregroundColor: style.questionPlaceholderColor, .font: style.questionPlaceholderFont]
            )
            return cell
        case .answers:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CometChatCreatePollOptions", for: indexPath) as? CometChatCreatePollOptions else {
                return UITableViewCell()
            }
            cell.options.tag = indexPath.section
            cell.options.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            cell.delegate = self
            cell.index = indexPath.row
            cell.options.text = items[indexPath.row]
            cell.textChanged = { [weak self] newText, index in
                guard let self = self else { return }
                self.items[index] = newText ?? ""
                if index == 0 {
                    self.firstOptionString = newText ?? ""
                } else if index == 1 {
                    self.secondOptionString = newText ?? ""
                }
            }
            cell.editingEnd = { [weak self] _ in
                guard let self = self else { return }
                
                // Remove empty items from the middle (not the last one which is "Add Option")
                var indicesToRemove: [Int] = []
                for (index, optionText) in self.items.enumerated() {
                    if optionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && index != self.items.count - 1 && self.items.count > 2 {
                        indicesToRemove.append(index)
                    }
                }
                
                // Remove in reverse order to maintain correct indices
                for index in indicesToRemove.reversed() {
                    self.items.remove(at: index)
                    // Append "Add Option" for each removed middle item
                    self.items.append("")
                }
                
                // Ensure only one empty "Add Option" at the end
                while self.items.count > 2 && self.items.last?.isEmpty == true && self.items[self.items.count - 2].isEmpty {
                    self.items.removeLast()
                }
                
                // Update first and second option strings
                let filledOptions = self.items.filter { !$0.isEmpty }
                self.firstOptionString = filledOptions.count > 0 ? filledOptions[0] : ""
                self.secondOptionString = filledOptions.count > 1 ? filledOptions[1] : ""
                self.validateSendButtonState()
                
                if !indicesToRemove.isEmpty {
                    tableView.reloadData()
                }
            }
            cell.deleteOption = { [weak self] in
                guard let self = self, self.items.count > 2 else { return }
                
                let isLastFilledOption = indexPath.row == self.items.count - 1 || 
                    (indexPath.row == self.items.count - 2 && self.items.last?.isEmpty == true)
                
                if isLastFilledOption && self.items.last?.isEmpty == false {
                    // If deleting the last filled option (no empty "Add Option" exists), 
                    // just clear it to become "Add Option"
                    self.items[indexPath.row] = ""
                    tableView.reloadData()
                } else if isLastFilledOption {
                    // Last filled option but there's already an empty "Add Option" at end
                    // Clear this one and remove the duplicate empty at end
                    self.items[indexPath.row] = ""
                    if self.items.count > 2 && self.items.last?.isEmpty == true && indexPath.row != self.items.count - 1 {
                        self.items.removeLast()
                    }
                    tableView.reloadData()
                } else {
                    // Deleting from middle - remove the item and append "Add Option"
                    self.items.remove(at: indexPath.row)
                    self.items.append("")
                    tableView.reloadData()
                }
                
                // Update first and second option strings
                let filledOptions = self.items.filter { !$0.isEmpty }
                self.firstOptionString = filledOptions.count > 0 ? filledOptions[0] : ""
                self.secondOptionString = filledOptions.count > 1 ? filledOptions[1] : ""
                self.validateSendButtonState()
            }
            cell.reorderButton.tintColor = style.dragButtonTintColor
            cell.reorderButton.setImage(style.dragButtonImage, for: .normal)
            cell.deleteButton.setImage(style.deleteButtonImage, for: .normal)
            cell.deleteButton.tintColor = style.deleteButtonTintColor
            cell.options.textColor = style.optionsTextColor
            cell.options.font = style.optionsTextFont
            cell.backgroundColor = style.optionsInputBoxBackground
            cell.borderWith(width: style.optionsInputBoxBorderWidth)
            cell.borderColor(color: style.optionsInputBoxBorderColor)
            cell.roundViewCorners(corner: style.optionsInputBoxCornerRadius ?? .init(cornerRadius: CometChatSpacing.Radius.r2))
            cell.options.attributedPlaceholder = NSAttributedString(
                string: "ADD".localize(),
                attributes: [.foregroundColor: style.optionsPlaceholderColor, .font: style.optionsPlaceholderFont]
            )
            return cell
        }
    }

    public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedItem = items.remove(at: sourceIndexPath.row)
        items.insert(movedItem, at: destinationIndexPath.row)
        DispatchQueue.main.async { tableView.reloadData() }
    }

    public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        guard cometChatPollSection[indexPath.section] == .answers,
              let cell = tableView.cellForRow(at: indexPath) as? CometChatCreatePollOptions else {
            return false
        }
        return !items[indexPath.row].isEmpty
    }

    public func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        guard cometChatPollSection[proposedDestinationIndexPath.section] == .answers,
              let cell = tableView.cellForRow(at: proposedDestinationIndexPath) as? CometChatCreatePollOptions else {
            return sourceIndexPath
        }
        return items[proposedDestinationIndexPath.row].isEmpty ? sourceIndexPath : proposedDestinationIndexPath
    }

    public func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        dragItem.localObject = items[indexPath.row]
        return [dragItem]
    }

    public func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        tableView.setEditing(cometChatPollSection[indexPath.section] == .answers, animated: true)
    }

    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }

    public func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
