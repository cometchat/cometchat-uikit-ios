//
//  CometChatFormBubble.swift
//  CometChatUIKitSwift
//
//  Created by Admin on 14/09/23.
//

import Foundation
import CometChatSDK
public class CometChatFormBubble: UIView {
    
    @IBOutlet weak var containerView: UIStackView!
    private weak var controller: UIViewController?
    private var formMessage: FormMessage?
    private var elementEntities: [ElementEntity]?
    private var elementIds: [String] = [String]()
    fileprivate var cometChatData = [String:Any]()
    fileprivate var interactedElements = [String]()
    private var style = FormBubbleStyle()
    private var containerViews = [String:[UIView]]()
    private var isDateSelected = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    
    private func customInit() {
        CometChatUIKit.bundle.loadNibNamed("CometChatFormBubble", owner: self, options: nil)
        addSubview(containerView)
        if style.borderColor == .systemFill {
            style = style.set(borderColor: (self.traitCollection.userInterfaceStyle == .dark) ? CometChatTheme_v4.palatte.accent900 : CometChatTheme_v4.palatte.secondary)
        }
        set(style: style)
//        backgroundColor = (self.traitCollection.userInterfaceStyle == .dark) ? CometChatTheme.palatte.accent100 : CometChatTheme.palatte.secondary
//        containerView.backgroundColor = (self.traitCollection.userInterfaceStyle == .dark) ? CometChatTheme.palatte.accent100 : CometChatTheme.palatte.secondary
        containerView.frame = bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.translatesAutoresizingMaskIntoConstraints = false
        let width = CGFloat((window?.bounds.size.width ?? 300) - 48)
        
        
        NSLayoutConstraint.activate([containerView.topAnchor.constraint(equalTo: self.topAnchor, constant: 11),
                                     containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -11),
                                     containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                                     containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor)])
        containerView.layer.cornerRadius = 10
        containerView.clipsToBounds = true
        containerView.borderWith(width: 1)
        containerView.borderColor(color: (self.traitCollection.userInterfaceStyle == .dark) ? CometChatTheme_v4.palatte.accent100 : CometChatTheme_v4.palatte.secondary)
        if let formMessage = formMessage, let interactions = formMessage.interactions, let interactionGoal = formMessage.interactionGoal, let elementIds = interactionGoal.elementIds {
            print("elementIds",elementIds)
            for interaction in interactions {
                if let elementId = interaction.elementId {
                    interactedElements.append(elementId)
                }
            }
            switch interactionGoal.interactionType {
            case .allOf :
                var count = 0
                for interaction in interactions {
                    if elementIds.contains(where: {$0 == interaction.elementId}) {
                        count += 1
                    }
                }
                if count == elementIds.count {
                    presentQuickView(formMessage: formMessage)
                    return
                }
                break
            case .anyOf :
                for interaction in interactions {
                    if elementIds.contains(where: {$0 == interaction.elementId}) {
                        presentQuickView(formMessage: formMessage)
                        return
                    }
                }
                break
            case .anyAction :
                if interactions.count > 0 {
                    presentQuickView(formMessage: formMessage)
                    return
                }
                break
            case .none:
                break
            case .some(.none):
                break
            case .some(_):
                break
            }
        }
        
        buildForm()
        if CometChatUIKit.getLoggedInUser()?.uid == formMessage?.sender?.uid, let allowSenderInteraction = formMessage?.allowSenderInteraction, !allowSenderInteraction {
            for view1 in containerView.subviews {
                view1.isUserInteractionEnabled = false
                for gestureRecognizer in view1.gestureRecognizers ?? [] {
                    if gestureRecognizer is UITapGestureRecognizer {
                        let tapRecognizer = gestureRecognizer as! UITapGestureRecognizer
                        view1.removeGestureRecognizer(tapRecognizer)

                    }
                }
            }
        }
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: width)
        ])
    }
    
    func presentQuickView(formMessage: FormMessage) {
        let width = CGFloat((controller?.view.bounds.width ?? 300) - 48)
        let quickView = CometChatQuickView(frame: CGRect(x: 0, y: 0, width: containerView.frame.width, height: containerView.frame.height))
        containerView.arrangedSubviews.forEach({
            $0.removeFromSuperview()
        })
        containerView.backgroundColor = (self.traitCollection.userInterfaceStyle == .dark) ? CometChatTheme_v4.palatte.accent100 : CometChatTheme_v4.palatte.secondary
        containerView.addArrangedSubview(quickView)
        let label = UILabel()
        label.text = "Thank you for filling out the Form."
        var labelHeight = label.text?.height(withConstrainedWidth: containerView.frame.width, font: UIFont.systemFont(ofSize: 17)) ?? 60
        if labelHeight < 60 {
            labelHeight = 60
        }
        
        
        if let name = formMessage.sender?.name {
            quickView.set(title: name)
        }
        
        if !formMessage.getTitle().isEmpty {
            quickView.set(subTitle: formMessage.getTitle())
        }
        
        if let formMessage = self.formMessage, !formMessage.getGoalCompletionText().isEmpty {
            label.text = formMessage.getGoalCompletionText()
        }
        label.textColor = style.getLabelColor()
        label.numberOfLines = 0
        containerView.addArrangedSubview(label)
        NSLayoutConstraint.activate([quickView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
                                     quickView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,constant: 8),
                                     quickView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 8),
                                     quickView.heightAnchor.constraint(equalToConstant: 60),
                                     label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,constant: 8),
                                     label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
                                     label.topAnchor.constraint(equalTo: quickView.bottomAnchor),
                                     label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24),
                                     label.heightAnchor.constraint(equalToConstant: labelHeight),
                                     containerView.heightAnchor.constraint(equalToConstant: 80 + labelHeight)])
        containerView.spacing = 10
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: width)
        ])
        return
    }
    
    @discardableResult
    public func set(formMessage: FormMessage) -> Self {
        self.formMessage = formMessage
        self.setUIElements(formMessage.getFormFields())
        return self
    }
    
    @discardableResult
    public func setUIElements(_ elementEntities: [ElementEntity]) -> Self {
        self.elementEntities = elementEntities
        self.customInit()
        return self
    }
    
    func buildForm() {
        containerView.spacing = 5
        containerView.arrangedSubviews.forEach({
            $0.removeFromSuperview()
        })
        if let title = self.formMessage?.getTitle() {
            let spacer = UIView()
            containerView.addArrangedSubview(spacer)
            NSLayoutConstraint.activate([spacer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                                         spacer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                                         spacer.topAnchor.constraint(equalTo: containerView.topAnchor),
                                         spacer.heightAnchor.constraint(equalToConstant: 14)])
            let label = UILabel()
            label.text = title
            label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
            containerView.addArrangedSubview(label)
            NSLayoutConstraint.activate([label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
                                         label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 8),
                                         label.topAnchor.constraint(equalTo: spacer.bottomAnchor),
                                         label.heightAnchor.constraint(equalToConstant: 30)])
            
            let divider = UIView()
            divider.backgroundColor = .black
            containerView.addArrangedSubview(divider)
            NSLayoutConstraint.activate([divider.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                                         divider.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                                         divider.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 25),
                                         divider.heightAnchor.constraint(equalToConstant: 0.6)])
        }
        if let _elementEntities = elementEntities {
            for elementEntity in _elementEntities {
                switch elementEntity.elementType {
                case .label:
                    if let labelElement = elementEntity as? LabelElement {
                        buildLabel(labelElement)
                    }
                    break
                case .textInput:
                    if let textInputElement = elementEntity as? TextInputElement {
                        buildTextInput(textInputElement)
                    }
                    break
                case .button:
                    if let buttonElement = elementEntity as? ButtonElement {
                        buildButton(buttonElement)
                    }
                    break
                case .checkbox:
                    if let checkboxElement = elementEntity as? CheckboxElement {
                        buildCheckbox(checkboxElement)
                    }
                    break
                case .radio:
                    if let radioButtonElemnet = elementEntity as? RadioButtonElement{
                        buildRadioButton(radioButtonElemnet)
                    }
                case .dropdown:
                    if let dropdownElement = elementEntity as? DropdownElement{
                        buildDropdown(dropdownElement)
                    }
                case .singleSelect:
                    if let singleSelectElement = elementEntity as? SingleSelectElement{
                        buildSingleSelect(singleSelectElement)
                    }
                case .dateTime:
                    if let dateTimePicker = elementEntity as? DateTimeElement {
                        buildDateTimePicker(element: dateTimePicker)
                    }
                default:
                    break
                }
                
            }
        }
        if let _formMessage = self.formMessage {
            buildSubmitButton(_formMessage.getSubmitElement())
        }
    }
    
    func buildLabel(_ labelElement: LabelElement) {
        let label = UILabel()
        label.text = labelElement.text
        label.textColor = style.getLabelColor()
        containerView.addArrangedSubview(label)
        let anchor = containerView.subviews.last?.bottomAnchor ?? containerView.topAnchor
        NSLayoutConstraint.activate([label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                                     label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                                     label.topAnchor.constraint(equalTo: anchor),
                                     label.heightAnchor.constraint(equalToConstant: 30)])
    }
    
    func buildTextInput(_ textInputElement: TextInputElement) {
        let label = UILabel()
        if !textInputElement.label.isEmpty {
            let spacer = UIView()
            containerView.addArrangedSubview(spacer)
            let anchor = containerView.subviews.last?.bottomAnchor ?? containerView.topAnchor
            NSLayoutConstraint.activate([spacer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                                         spacer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                                         spacer.topAnchor.constraint(equalTo: anchor),
                                         spacer.heightAnchor.constraint(equalToConstant: 14)])
            label.textColor = style.getLabelColor()
            if textInputElement.optional ?? true {
                label.text = textInputElement.label
            } else {
                label.text = "\(textInputElement.label) *"
                elementIds.append(textInputElement.elementId)
            }
            containerView.addArrangedSubview(label)
            NSLayoutConstraint.activate([label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
                                         label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
                                         label.topAnchor.constraint(equalTo: spacer.bottomAnchor),
                                         label.heightAnchor.constraint(equalToConstant: 30)])
        }
        let textView = TextView(textInputElement, controller)
        if let formMessage = formMessage {
            textView.tag = formMessage.id
        }
//        textView.placeholder = textInputElement.placeHolder
//
//        textView.data = cometChatData
//        textView.elementId = textInputElement.elementId
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        textView.borderWith(width: style.getInputStrokeWidth())
        textView.borderColor(color: style.getInputStrokeColor())
        textView.layer.cornerRadius = 5
        
        textView.textInputColor = style.getInputTextColor()
        textView.textColor = style.getInputTextColor()
        textView.hintColor = style.getInputHintColor()
        textView.text = textInputElement.placeHolder
        textView.textColor = style.getInputHintColor()
        if !textInputElement.defaultValue.isEmpty {
            textView.text = textInputElement.defaultValue
            textView.textColor = style.getInputTextColor()
        }
        containerView.addArrangedSubview(textView)
        NSLayoutConstraint.activate([textView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
                                     textView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
                                     textView.topAnchor.constraint(equalTo: label.bottomAnchor),
                                     textView.heightAnchor.constraint(equalToConstant: 30)])
        textView.isHidden = false
        containerViews[textInputElement.elementId] = [textView]
        
        
    }
    
    @objc func keyboardWillShow(_ notification: Notification,_ textView: UITextView) {
        if let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                let keyboardHeight = keyboardFrame.height
            UIView.animate(withDuration: 0.3) {
                let offset = CGPoint(x: 0, y: keyboardHeight)
                if let controller = self.controller {
                    for view1 in controller.view.subviews {
                        if let scrollView = view1 as? UIScrollView {
                            scrollView.setContentOffset(offset, animated: true)
                        }
                    }
                }
                self.controller?.view.frame.origin.y -= keyboardHeight
//                self.controller?.view.layoutIfNeeded()
            }
        }
    }

    @objc func keyboardWillHide(_ notification: Notification,_ textView: UITextView) {
        UIView.animate(withDuration: 0.3) {
            if let controller = self.controller {
                for view1 in controller.view.subviews {
                    if let scrollView = view1 as? UIScrollView {
                        scrollView.setContentOffset(.zero, animated: true)
                    }
                }
            }
            self.controller?.view.frame.origin.y = 0
//            self.controller?.view.layoutIfNeeded()
        }
    }
    
    func buildButton(_ buttonElement: ButtonElement) {
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(buttonElement.onButtonClickAction(_:)))
        let button = Button()
        button.buttonElement = buttonElement
        button.addTarget(self, action: #selector(onButtonClickAction(_:)), for: .touchUpInside)
//        buttonElement.frame = CGRect(x: 0, y: 0, width: 100, height: 30)
        button.titleLabel?.text = buttonElement.buttonText
        button.setTitle(buttonElement.buttonText, for: .normal)
        button.setTitleColor(style.getButtonTextColor(), for: .normal)
        containerView.addArrangedSubview(button)
        button.backgroundColor = style.getButtonBackgroundColor()
        button.layer.cornerRadius = 10
        if let formMessage = self.formMessage, let interactions = formMessage.interactions {
            if interactions.contains(where: {$0.elementId == buttonElement.elementId}) {
                if buttonElement.disableAfterInteracted {
                    DispatchQueue.main.async {
                        button.isUserInteractionEnabled = false
                        let lightercolor = button.backgroundColor?.withBrightness(1.2)
                        button.backgroundColor = lightercolor
                    }
                }
            }
        }
        let anchor = containerView.subviews.last?.bottomAnchor ?? containerView.topAnchor
        NSLayoutConstraint.activate([button.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
                                     button.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
                                     button.topAnchor.constraint(equalTo: anchor, constant: 24),
                                     button.heightAnchor.constraint(equalToConstant: 50)])
        
        containerViews[buttonElement.elementId] = [button]
       
    }
    
    func buildSubmitButton(_ buttonElement: ButtonElement) {
        let spacer = UIView()
        containerView.addArrangedSubview(spacer)
        let anchor = containerView.subviews.last?.bottomAnchor ?? containerView.topAnchor
        NSLayoutConstraint.activate([spacer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                                     spacer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                                     spacer.topAnchor.constraint(equalTo: anchor),
                                     spacer.heightAnchor.constraint(equalToConstant: 8)])
        let button = Button()
        button.buttonElement = buttonElement
        button.addTarget(self, action: #selector(onSubmitButtonClickAction(_:)), for: .touchUpInside)
//        buttonElement.frame = CGRect(x: 0, y: 0, width: 100, height: 30)
        button.titleLabel?.text = buttonElement.buttonText
        button.setTitle(buttonElement.buttonText, for: .normal)
        button.setTitleColor(style.getButtonTextColor(), for: .normal)
        	
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.color = style.getButtonTextColor()
        activityIndicator.backgroundColor = style.getButtonBackgroundColor()
        activityIndicator.layer.cornerRadius = 10
        containerView.addArrangedSubview(activityIndicator)
        containerView.addArrangedSubview(button)
        button.backgroundColor = style.getButtonBackgroundColor()
        button.layer.cornerRadius = 10
        if let formMessage = self.formMessage, let interactions = formMessage.interactions {
            if interactions.contains(where: {$0.elementId == buttonElement.elementId}) {
                if buttonElement.disableAfterInteracted {
                    DispatchQueue.main.async {
                        button.isUserInteractionEnabled = true
                        let lightercolor = button.backgroundColor?.withBrightness(1.2)
                        button.backgroundColor = lightercolor
                    }
                }
            }
        }
        
        
        NSLayoutConstraint.activate([activityIndicator.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
                                     activityIndicator.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
                                     activityIndicator.topAnchor.constraint(equalTo: spacer.bottomAnchor, constant: 24),
                                     activityIndicator.heightAnchor.constraint(equalToConstant: 50),
                                     button.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
                                     button.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
                                     button.topAnchor.constraint(equalTo: spacer.bottomAnchor, constant: 24),
                                     button.heightAnchor.constraint(equalToConstant: 50)])
        let spacer1 = UIView()
        containerView.addArrangedSubview(spacer1)
        NSLayoutConstraint.activate([spacer1.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                                     spacer1.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                                     spacer1.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 24),
                                     spacer1.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
                                     spacer1.heightAnchor.constraint(equalToConstant: 8)])
        containerViews[buttonElement.elementId] = [button,activityIndicator]
    }
    
    class Button: UIButton {
        var buttonElement: ButtonElement?
    }
    
    @objc func onSubmitButtonClickAction(_ sender: Button) {
        if let buttonElement = sender.buttonElement, let url = URL(string: buttonElement.action.url) {
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = buttonElement.action.method.value
            interactedElements.append(buttonElement.elementId)
            if let _elementEntities = elementEntities {
                for elementEntity in _elementEntities {
                    if let textInputElement = elementEntity as? TextInputElement, !textInputElement.text.isEmpty {
                        self.cometChatData[elementEntity.elementId] = textInputElement.text
                    }
                    if let checkboxElement = elementEntity as? CheckboxElement, checkboxElement.selectedValues.count > 0 {
                        self.cometChatData[elementEntity.elementId] = checkboxElement.selectedValues
                    }
                    if let radioElement = elementEntity as? RadioButtonElement {
                        self.cometChatData[elementEntity.elementId] = radioElement.selectedValue
                    }
                    if let dropdownElement = elementEntity as? DropdownElement {
                        self.cometChatData[elementEntity.elementId] = dropdownElement.selectedValue
                    }
                    if let singleSelectElement = elementEntity as? SingleSelectElement {
                        self.cometChatData[elementEntity.elementId] = singleSelectElement.selectedValue
                    }
                    if let dateTimePickerElement = elementEntity as? DateTimeElement, dateTimePickerElement.selectedDateTime != nil {
                        self.cometChatData[elementEntity.elementId] = dateTimePickerElement.selectedDateTime
                    }
                }
            }
            
            if self.cometChatData.count > 0 && validateFields() {
                do {
                    var data = [String:Any]()
                    
                    data[InteractiveConstants.ButtonUIConstants.APP_ID] = CometChatUIKit.uiKitSettings?.appID
                    data[InteractiveConstants.ButtonUIConstants.REGION] = CometChatUIKit.uiKitSettings?.region
                    data[InteractiveConstants.ButtonUIConstants.TRIGGER] = InteractiveConstants.ButtonUIConstants.UI_MESSAGE_INTERACTED
                    if !buttonElement.action.payLoad.isEmpty {
                        data[InteractiveConstants.ButtonUIConstants.PAYLOAD] = buttonElement.action.payLoad
                    }
                   var dataPayLoad = [String: Any]()
                    dataPayLoad[InteractiveConstants.ButtonUIConstants.CONVERSATION_ID] = formMessage?.conversationId
                    dataPayLoad[InteractiveConstants.ButtonUIConstants.SENDER] = formMessage?.senderUid
                    dataPayLoad[InteractiveConstants.ButtonUIConstants.RECEIVER] = formMessage?.receiverUid
                    dataPayLoad[InteractiveConstants.ButtonUIConstants.RECEIVER_TYPE] = formMessage?.receiverType == .user ? ReceiverTypeConstants.user : ReceiverTypeConstants.group
                    dataPayLoad[InteractiveConstants.ButtonUIConstants.MESSAGE_CATEGORY] = MessageCategoryConstants.interactive
                    dataPayLoad[InteractiveConstants.ButtonUIConstants.MESSAGE_TYPE] = formMessage?.type
                    dataPayLoad[InteractiveConstants.ButtonUIConstants.MESSAGE_ID] = formMessage?.id
                    dataPayLoad[InteractiveConstants.ButtonUIConstants.INTERACTION_TIMEZONE_CODE] = TimeZone.current.identifier
                    dataPayLoad[InteractiveConstants.ButtonUIConstants.INTERACTED_BY] = CometChat.getLoggedInUser()?.uid
                    dataPayLoad[InteractiveConstants.ButtonUIConstants.INTERACTED_ELEMENT_ID] =  buttonElement.elementId
    
                    var formattedData = [[String: Any]]()
                    cometChatData.forEach { (key, value) in
                        formattedData.append([
                            InteractiveConstants.ELEMENT_ID: key,
                            InteractiveConstants.value: value
                        ])
                    }
                    dataPayLoad["InteractiveConstants.ButtonUIConstants.FORM_DATA"] = formattedData
                    
                    let jsonAsData = try JSONSerialization.data(withJSONObject: data, options: []);
                    
                    urlRequest.httpBody = jsonAsData;
                    urlRequest.httpMethod = buttonElement.action.method.value
                    if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept");
                    }
                    urlRequest.allHTTPHeaderFields?.append(with: buttonElement.action.headers)
                } catch  {
                    
                }
                
                if let view = containerViews[buttonElement.elementId]?.first, let view1 = containerViews[buttonElement.elementId]?.last as? UIActivityIndicatorView {
                    view1.startAnimating()
                    view.isHidden = true
                    view1.isHidden = false
                    containerView.insertSubview(view1, aboveSubview: view)
                    dataTaskWith(request: urlRequest, completion: {data,response,error  in
                        if let response = response as? HTTPURLResponse {
                            if response.statusCode > 199 && response.statusCode < 300 {
                                if let formMessage = self.formMessage {
                                    var interactions = [Interaction]()
                                    CometChat.markAsInteracted(messageId: formMessage.id, interactedElementId: buttonElement.elementId, onSuccess: {
                                        _ in
                                        interactions.append(Interaction(elementId: buttonElement.elementId, interactedAt: Date().timeIntervalSince1970))
                                        if buttonElement.disableAfterInteracted {
                                            DispatchQueue.main.async {
                                                sender.isUserInteractionEnabled = false
                                                let lightercolor = sender.backgroundColor?.withBrightness(1.2)
                                                sender.backgroundColor = lightercolor
                                                view1.stopAnimating()
                                                self.containerView.insertSubview(view, aboveSubview: view1)
                                                view1.isHidden = true
                                                view.isHidden = false
                                            }
                                        } else {
                                            DispatchQueue.main.async {
                                                view1.stopAnimating()
                                                self.containerView.insertSubview(view, aboveSubview: view1)
                                                view1.isHidden = true
                                                view.isHidden = false
                                            }
                                        }
                                        self.checkIfPresentQuickView(button: sender)
                                    }, onError: {
                                        _ in
                                        DispatchQueue.main.async {
                                            view1.stopAnimating()
                                            self.containerView.insertSubview(view, aboveSubview: view1)
                                            view1.isHidden = true
                                            view.isHidden = false
                                        }
                                    })
                                }
                                //                            DispatchQueue.main.async {
                                //                                let width = self.containerView.frame.width
                                //                                let quickView = CometChatQuickView(frame: CGRect(x: 0, y: 0, width: self.containerView.frame.width, height: self.containerView.frame.height))
                                //                                self.containerView.arrangedSubviews.forEach({
                                //                                    $0.removeFromSuperview()
                                //                                })
                                //
                                //                                self.containerView.addArrangedSubview(quickView)
                                //                                let label = UILabel()
                                //                                label.text = "Thank you for filling out the Form."
                                //                                var labelHeight = label.text?.height(withConstrainedWidth: self.containerView.frame.width, font: UIFont.systemFont(ofSize: 17)) ?? 60
                                //                                if labelHeight < 60 {
                                //                                    labelHeight = 60
                                //                                }
                                //
                                //                                if let formMessage = self.formMessage, !formMessage.getGoalCompletionText().isEmpty {
                                //                                    label.text = formMessage.getGoalCompletionText()
                                //                                }
                                //                                label.textColor = self.style.getLabelColor()
                                //                                label.numberOfLines = 0
                                //                                self.containerView.addArrangedSubview(label)
                                //                                NSLayoutConstraint.activate([quickView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 8),
                                //                                                             quickView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor,constant: 8),
                                //                                                             quickView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: 8),
                                //                                                             quickView.heightAnchor.constraint(equalToConstant: 60),
                                //                                                             label.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor,constant: 8),
                                //                                                             label.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -8),
                                //                                                             label.topAnchor.constraint(equalTo: quickView.bottomAnchor),
                                //                                                             label.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -24),
                                //                                                             label.heightAnchor.constraint(equalToConstant: labelHeight),
                                //                                                             self.containerView.heightAnchor.constraint(equalToConstant: 80 + labelHeight)])
                                //                                self.containerView.spacing = 5
                                //                                NSLayoutConstraint.activate([
                                //                                    self.widthAnchor.constraint(equalToConstant: width)
                                //                                ])
                                //
                                
                            }
                        }
                    })
                }
                
            }
        } else {
            
        }
    }
    
    func getCell(_ view: UIView) {
        DispatchQueue.main.async {
            if let tableView = self.traverseSubviews(view: self.controller?.view ?? UIView()) {
                UIView.animate(withDuration: 0.2) {
                    var responder: UIResponder? = view
                    //                if let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
                    //                    if let activeButton = keyWindow.findFirstResponder() {
                    //                        responder = activeButton
                    //                    }
                    //                }
                    while responder != nil {
                        if let cell = responder as? UITableViewCell {
                            // Found the UITableViewCell
                            // You can use 'cell' here
                            if let indexPath = tableView.indexPath(for: cell) {
                                tableView.reloadRows(at: [indexPath], with: .automatic)
                            }
                        }
                        responder = responder?.next
                    }
                }
            }
        }
    }
    
    func traverseSubviews(view: UIView) -> UITableView? {
        if let tableview = view as? UITableView {
            return tableview
        }
        for i in 0..<view.subviews.count {
            // Do something with the subview
            let subview = view.subviews[i]
            print("subview11",i, view.subviews.count)
            print(subview)
            
            // Recursively traverse subviews
            if let tableview1 = traverseSubviews(view: subview) {
                return tableview1
            }
        }
            
        return nil
    }
    
    func validateFields() -> Bool {
        var isSelectedValue = true
        for elementId in elementIds {
            if !self.cometChatData.keys.contains(where: {$0 == elementId}) {
                if isSelectedValue {
                    isSelectedValue = false
                }
                if let elementView = containerViews[elementId] {
                    if let textView = elementView.first as? TextView {
                        if textView.text.isEmpty || textView.text == textView.parentTextInputElement?.placeHolder {
                            textView.borderColor(color: .red)
                        }
                    } else if let dateTimeSelector = (elementView.first as? DateTimeElement.DateTimePickerView) {
                        if !dateTimeSelector.isDateTimeSelected {
                            dateTimeSelector.borderColor(color: .red)
                        }
                    } else {
                        if let containerViews = self.containerViews[elementId] {
                            for view1 in containerViews {
                                if let checkox = view1 as? CheckboxElement.AddtionalView, checkox.parentCheckBoxElement?.selectedValues.count == 0 {
                                    checkox.layer.borderColor = UIColor.red.cgColor
                                } else if let button = view1 as? Button, button.tag != 2 {
                                    button.layer.borderColor = UIColor.red.cgColor
                                } else {
                                    
                                }
                            }
                        }
                    }
                }
                
            }
            if let _ = self.containerViews[elementId]?.first as? DropdownElement.DropdownButtonView, let selectedValue = self.cometChatData[elementId] as? String, selectedValue.isEmpty {
                if isSelectedValue {
                    isSelectedValue = false
                }
            } else if let _ = self.containerViews[elementId]?.first as? RadioButtonElement.RadioButtonView, let selectedValue = self.cometChatData[elementId] as? String, selectedValue.isEmpty {
                if isSelectedValue {
                    isSelectedValue = false
                }
            } else if let _ = self.containerViews[elementId]?.first as? SingleSelectElement.ToggleSwitchView, let selectedValue = self.cometChatData[elementId] as? String, selectedValue.isEmpty {
                if isSelectedValue {
                    isSelectedValue = false
                }
            }
        }
        return isSelectedValue
    }
    
    @objc func onButtonClickAction(_ sender:Button) {
        if let buttonElement = sender.buttonElement, !buttonElement.navigationAction.url.isEmpty {
            if let formMessage = self.formMessage {
                interactedElements.append(buttonElement.elementId)
                CometChat.markAsInteracted(messageId: formMessage.id, interactedElementId: buttonElement.elementId, onSuccess: {
                    _ in
                    if buttonElement.disableAfterInteracted {
                        DispatchQueue.main.async {
                            sender.isUserInteractionEnabled = false
                            let lightercolor = sender.backgroundColor?.withBrightness(1.2)
                            sender.backgroundColor = lightercolor
                            self.checkIfPresentQuickView(button: sender)
                        }
                    }
                }, onError: {
                    _ in
                })
            }
            let cometChatWebView = CometChatWebView()
            sender.tag = 2
            cometChatWebView.set(webViewType: .none)
                .set(url: buttonElement.navigationAction.url)
                .set(title: buttonElement.buttonText)
            controller?.navigationController?.navigationBar.isHidden = false
            controller?.navigationController?.isNavigationBarHidden = false
            controller?.navigationController?.pushViewController(cometChatWebView, animated: true)
        }
    }
    
    func checkIfPresentQuickView(button: Button) {
        DispatchQueue.main.async {
            if let formMessage = self.formMessage, let interactionGoal = formMessage.interactionGoal, let _elementIds = interactionGoal.elementIds {
                switch interactionGoal.interactionType {
                case .allOf :
                    for elementId in _elementIds {
                        if !self.interactedElements.contains(where: {$0 == elementId}) {
                            return
                        }
                    }
                    break
                case .anyOf :
                    var count = 0
                    for elementId in _elementIds {
                        if self.interactedElements.contains(where: {$0 == elementId}) {
                            break
                        } else {
                            count += 1
                        }
                    }
                    if count == _elementIds.count {
                        return
                    }
                    break
                case .anyAction :
                    if self.interactedElements.count > 0 {
                        break
                    }
                    return
                case .none:
                    break
                case .some(.none):
                    break
                case .some(_):
                    break
                }
                var interactions = formMessage.interactions ?? [Interaction]()
                interactions.append(Interaction(elementId: button.buttonElement?.elementId, interactedAt: Date().timeIntervalSince1970))
                for elementId in self.interactedElements {
                    if !interactions.contains(where: {$0.elementId == elementId}) {
                        interactions.append(Interaction(elementId: elementId, interactedAt: Date().timeIntervalSince1970))
                    }
                }
                let formMessage = formMessage
                formMessage.interactions = interactions
                self.set(formMessage: formMessage)
                self.formMessage = formMessage
                self.getCell(self.containerView)
            }
        }
    }
    
    func dataTaskWith(request : URLRequest, completion: @escaping ((Data?,URLResponse?, Error?)-> Void)){
        
        let session = URLSession.shared;
        session.configuration.timeoutIntervalForRequest = 30
        let task = session.dataTask(with: request){ (data, response, error) -> Void in
            
            // ensure there is data returned from this HTTP response
            guard let content = data else {
                completion(nil,response, error)
                return;
            }
            completion(content,response, error)
            
        }
        
        task.resume();
    }
    
    func buildCheckbox(_ checkboxElement: CheckboxElement) {
        if !checkboxElement.label.isEmpty {
            let spacer = UIView()
            containerView.addArrangedSubview(spacer)
            let anchor = containerView.subviews.last?.bottomAnchor ?? containerView.topAnchor
            NSLayoutConstraint.activate([spacer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                                         spacer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                                         spacer.topAnchor.constraint(equalTo: anchor),
                                         spacer.heightAnchor.constraint(equalToConstant: 14)])
            let label = UILabel()
            label.textColor = style.getLabelColor()
            if checkboxElement.optional {
                label.text = checkboxElement.label
            } else {
                label.text = "\(checkboxElement.label) *"
                elementIds.append(checkboxElement.elementId)
            }
            containerView.addArrangedSubview(label)
            NSLayoutConstraint.activate([label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
                                         label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
                                         label.topAnchor.constraint(equalTo: spacer.bottomAnchor),
                                         label.heightAnchor.constraint(equalToConstant: 30)])
        }
        for option_ in checkboxElement.options {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            label.textColor = style.getCheckboxTextColor()
            label.text = option_.id
            let addtionalView = CheckboxElement.AddtionalView()
            addtionalView.parentCheckBoxElement = checkboxElement
            addtionalView.tag = checkboxElement.options.lastIndex(of: option_) ?? -1
//            addtionalView.clipsToBounds = false
//            containerView.addArrangedSubview(addtionalView)
//            containerView.addArrangedSubview(label)
            let stackView = UIStackView()
//            stackView.backgroundColor = style.getCheckboxButtonTint()
            stackView.axis = .horizontal
            stackView.spacing = 10
            stackView.addArrangedSubview(addtionalView)
            if var additionalViews: [UIView] = containerViews[checkboxElement.elementId] {
                additionalViews.append(addtionalView)
                containerViews[checkboxElement.elementId] = additionalViews
            } else {
                containerViews[checkboxElement.elementId] = [addtionalView]
            }
            stackView.addArrangedSubview(label)
            addtionalView.clipsToBounds = true
            label.clipsToBounds = true
            let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: addtionalView, action: #selector(addtionalView.onCheckBoxClickAction))
            stackView.addGestureRecognizer(tap)
            stackView.isLayoutMarginsRelativeArrangement = true
            stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 5, leading: 24, bottom: 5, trailing: 24)
            NSLayoutConstraint.activate([addtionalView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
                                         addtionalView.heightAnchor.constraint(equalToConstant: 30),
                                         addtionalView.widthAnchor.constraint(equalToConstant: 30)])
            NSLayoutConstraint.activate([label.leadingAnchor.constraint(equalTo: addtionalView.trailingAnchor, constant: 14),
                                         label.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
                                         label.topAnchor.constraint(equalTo: stackView.topAnchor),
                                         label.bottomAnchor.constraint(equalTo: stackView.bottomAnchor)])
            containerView.addArrangedSubview(stackView)
            let anchor = containerView.subviews.last?.bottomAnchor ?? containerView.topAnchor
            NSLayoutConstraint.activate([stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
                                         stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
                                         stackView.topAnchor.constraint(equalTo: anchor, constant: 14),
                                         stackView.heightAnchor.constraint(equalToConstant: 30)])
        }
    }
    
    func buildRadioButton(_ radioButtonElement: RadioButtonElement) {
        if !radioButtonElement.label.isEmpty {
            let spacer = UIView()
            containerView.addArrangedSubview(spacer)
            let anchor = containerView.subviews.last?.bottomAnchor ?? containerView.topAnchor
            NSLayoutConstraint.activate([spacer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                                         spacer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                                         spacer.topAnchor.constraint(equalTo: anchor),
                                         spacer.heightAnchor.constraint(equalToConstant: 14)])
            let label = UILabel()
            label.textColor = style.getLabelColor()
            if radioButtonElement.optional {
                label.text = radioButtonElement.label
            } else {
                label.text = "\(radioButtonElement.label) *"
                elementIds.append(radioButtonElement.elementId)
            }
            containerView.addArrangedSubview(label)
            NSLayoutConstraint.activate([label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
                                         label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
                                         label.topAnchor.constraint(equalTo: spacer.bottomAnchor, constant: 24),
                                         label.heightAnchor.constraint(equalToConstant: 30)])
        }
        for option_ in radioButtonElement.options {
            let label = UILabel()
            label.textColor = style.getRadioButtonTextColor()
            label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            label.text = option_.id
            let addtionalView = RadioButtonElement.RadioButtonView()
            addtionalView.parentRadioButtonElement = radioButtonElement
            addtionalView.tag = radioButtonElement.options.lastIndex(of: option_) ?? -1
            let stackView = UIStackView()
            stackView.backgroundColor = style.getRadioButtonTint()
            stackView.axis = .horizontal
            stackView.spacing = 10
            stackView.addArrangedSubview(addtionalView)
            stackView.addArrangedSubview(label)
            addtionalView.clipsToBounds = true
            label.clipsToBounds = true
            let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: addtionalView, action: #selector(addtionalView.radioButtonTapped))
            stackView.addGestureRecognizer(tap)
//            addtionalView.backgroundColor = .black
//            label.backgroundColor = .black
            stackView.isLayoutMarginsRelativeArrangement = true
            if var additionalViews: [UIView] = containerViews[radioButtonElement.elementId] {
                additionalViews.append(addtionalView)
                self.containerViews[radioButtonElement.elementId] = additionalViews
            } else {
                containerViews[radioButtonElement.elementId] = [addtionalView]
            }
            stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 5, leading: 24, bottom: 5, trailing: 24)
            NSLayoutConstraint.activate([addtionalView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
                                         addtionalView.heightAnchor.constraint(equalToConstant: 30),
                                         addtionalView.widthAnchor.constraint(equalToConstant: 30)])
            NSLayoutConstraint.activate([label.leadingAnchor.constraint(equalTo: addtionalView.trailingAnchor, constant: 14),
                                         label.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
                                         label.topAnchor.constraint(equalTo: stackView.topAnchor),
                                         label.bottomAnchor.constraint(equalTo: stackView.bottomAnchor)])
            containerView.addArrangedSubview(stackView)
            let anchor = containerView.subviews.last?.bottomAnchor ?? containerView.topAnchor
            NSLayoutConstraint.activate([stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
                                         stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
                                         stackView.topAnchor.constraint(equalTo: anchor, constant: 14),
                                         stackView.heightAnchor.constraint(equalToConstant: 30)])
        }

    }
    
    func buildDropdown(_ dropdownElement: DropdownElement) {
        if !dropdownElement.label.isEmpty {
            let spacer = UIView()
            containerView.addArrangedSubview(spacer)
            let anchor = containerView.subviews.last?.bottomAnchor ?? containerView.topAnchor
            NSLayoutConstraint.activate([spacer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                                         spacer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                                         spacer.topAnchor.constraint(equalTo: anchor),
                                         spacer.heightAnchor.constraint(equalToConstant: 14)])
            let label = UILabel()
            label.textColor = style.getLabelColor()
            if dropdownElement.optional {
                label.text = dropdownElement.label
            } else {
                label.text = "\(dropdownElement.label) *"
                elementIds.append(dropdownElement.elementId)
            }
            containerView.addArrangedSubview(label)
            NSLayoutConstraint.activate([label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
                                         label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
                                         label.topAnchor.constraint(equalTo: spacer.bottomAnchor, constant: 24),
                                         label.heightAnchor.constraint(equalToConstant: 30)])
        }
        var dropdownWidth:CGFloat = 430
        if let controllerWidth = controller?.view.bounds.width {
            dropdownWidth = controllerWidth
        }
        let dropdownButtonView = DropdownElement.DropdownButtonView(frame: CGRect(x: 0, y: 0, width: dropdownWidth - 174, height: 30))
        dropdownButtonView.backgroundColor = style.getSpinnerBackgroundColor()
        dropdownButtonView.layer.borderWidth = 1.0
        dropdownButtonView.layer.borderColor = UIColor.lightGray.cgColor
        dropdownButtonView.parentDropdownElement = dropdownElement
        dropdownButtonView.setOptions(dropdownElement.options)
        dropdownButtonView.style = style
        if var additionalViews: [UIView] = containerViews[dropdownElement.elementId] {
            additionalViews.append(dropdownButtonView)
            self.containerViews[dropdownElement.elementId] = additionalViews
        } else {
            containerViews[dropdownElement.elementId] = [dropdownButtonView]
        }
        containerView.addArrangedSubview(dropdownButtonView)
        NSLayoutConstraint.activate([dropdownButtonView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
                                     dropdownButtonView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
                                     dropdownButtonView.heightAnchor.constraint(equalToConstant: 30),
                                     dropdownButtonView.widthAnchor.constraint(equalToConstant: 30)])
        dropdownButtonView.parentContainerView = containerView
    }
    
    func buildDateTimePicker(element: DateTimeElement) {
        
        let label = UILabel()
        
        if !element.label.isEmpty {
            let spacer = UIView()
            spacer.translatesAutoresizingMaskIntoConstraints = false
            containerView.addArrangedSubview(spacer)
            let anchor = containerView.subviews.last?.bottomAnchor ?? containerView.topAnchor
            NSLayoutConstraint.activate([spacer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                                         spacer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                                         spacer.topAnchor.constraint(equalTo: anchor),
                                         spacer.heightAnchor.constraint(equalToConstant: 14)])
            
            label.translatesAutoresizingMaskIntoConstraints = false
            if element.isOptional {
                label.text = "\(element.label) *"
                elementIds.append(element.elementId)
            } else {
                label.text = element.label
            }
            containerView.addArrangedSubview(label)
            NSLayoutConstraint.activate([label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
                                         label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
                                         label.topAnchor.constraint(equalTo: spacer.bottomAnchor, constant: 0),
                                         label.heightAnchor.constraint(equalToConstant: 30)])
        }
        
        let datTimePickerView = DateTimeElement.DateTimePickerView()
        datTimePickerView.element = element
        datTimePickerView.controller = controller
        datTimePickerView.style = style
        datTimePickerView.build()
        datTimePickerView.translatesAutoresizingMaskIntoConstraints = false
        datTimePickerView.layoutIfNeeded()
        containerView.addArrangedSubview(datTimePickerView)
        containerViews.append(with: [element.elementId: [datTimePickerView]])
        
        let anchor = containerView.subviews.last?.bottomAnchor ?? containerView.topAnchor
        NSLayoutConstraint.activate([
            datTimePickerView.heightAnchor.constraint(equalToConstant: 30),
            datTimePickerView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 0),
            datTimePickerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            datTimePickerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8)
        ])
    }
    
    func buildSingleSelect(_ singleSelectElement: SingleSelectElement) {
        if !singleSelectElement.label.isEmpty {
            let spacer = UIView()
            containerView.addArrangedSubview(spacer)
            let anchor = containerView.subviews.last?.bottomAnchor ?? containerView.topAnchor
            NSLayoutConstraint.activate([spacer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                                         spacer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                                         spacer.topAnchor.constraint(equalTo: anchor),
                                         spacer.heightAnchor.constraint(equalToConstant: 14)])
            let label = UILabel()
            if singleSelectElement.optional {
                label.text = singleSelectElement.label
            } else {
                label.text = "\(singleSelectElement.label) *"
                elementIds.append(singleSelectElement.elementId)
            }
            containerView.addArrangedSubview(label)
            NSLayoutConstraint.activate([label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
                                         label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
                                         label.topAnchor.constraint(equalTo: spacer.bottomAnchor, constant: 24),
                                         label.heightAnchor.constraint(equalToConstant: 30)])
        }
        let toggleSwitchView = SingleSelectElement.ToggleSwitchView(frame: CGRect(x: 0, y: 0, width: 252, height: 30))
//        toggleSwitchView.backgroundColor = (self.traitCollection.userInterfaceStyle == .dark) ? UIColor.white : .black
        toggleSwitchView.layer.borderWidth = 1.0
        toggleSwitchView.layer.borderColor = (self.traitCollection.userInterfaceStyle == .dark) ? UIColor.white.cgColor : UIColor.lightGray.cgColor
        toggleSwitchView.style = style
        toggleSwitchView.parentSingleSelectElement = singleSelectElement
        toggleSwitchView.setOptions(singleSelectElement.options)
        if var additionalViews: [UIView] = containerViews[singleSelectElement.elementId] {
            additionalViews.append(toggleSwitchView)
            self.containerViews[singleSelectElement.elementId] = additionalViews
        } else {
            containerViews[singleSelectElement.elementId] = [toggleSwitchView]
        }
        containerView.addArrangedSubview(toggleSwitchView)
        NSLayoutConstraint.activate([toggleSwitchView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
                                     toggleSwitchView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
                                     toggleSwitchView.heightAnchor.constraint(equalToConstant: 30),
                                     toggleSwitchView.widthAnchor.constraint(equalToConstant: 30)])
//        toggleSwitchView.parentSingleSelectElement = containerView
    }
    
    @discardableResult
    public func set(style: FormBubbleStyle) -> Self {
//        set(textColor: style.textColor)
//        set(textFont: style.textFont)
        set(background: style.background)
        set(borderColor: style.borderColor)
        set(borderWidth: style.borderWidth)
        set(corner: style.cornerRadius)
        return self
    }
    
    @discardableResult
    public func set(background: UIColor) -> Self {
        self.backgroundColor = background
        return self
    }
    
    @discardableResult
    public func set(corner: CometChatCornerStyle) -> Self {
        self.roundViewCorners(corner: corner)
        return self
    }
    
    @discardableResult
    public func set(borderWidth: CGFloat) -> Self {
        self.layer.borderWidth = borderWidth
        return self
    }
    
    @discardableResult
    public func set(borderColor: UIColor) -> Self {
        self.layer.borderColor = borderColor.cgColor
        return self
    }
    
    @discardableResult
    public func set(textColor: UIColor) -> Self {
        // Set the text color here.
        return self
    }
    
    @discardableResult
    public func set(textFont: UIFont) -> Self {
        // Set the text Font here.
        return self
    }
    
    @discardableResult
    public func set(controller: UIViewController) -> Self {
        self.controller = controller
        return self
    }

    
}

class TextView : UITextView, UITextViewDelegate {
    fileprivate var parentTextInputElement: TextInputElement?
    fileprivate var hintColor = UIColor.lightGray
    fileprivate var textInputColor = UIColor.black
    fileprivate var controller: UIViewController?
    
    init(_ parentTextInputElement: TextInputElement, _ controller: UIViewController?) {
        super.init(frame: CGRect(), textContainer: nil)
        self.parentTextInputElement = parentTextInputElement
        self.controller = controller
        if !parentTextInputElement.placeHolder.isEmpty {
            text = parentTextInputElement.placeHolder
        }
        parentTextInputElement.text = parentTextInputElement.defaultValue
        text = parentTextInputElement.defaultValue
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeListener()
    }
    
    func removeListener() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        if let tableView = traverseSubviews(view: self.controller?.view ?? UIView()) {
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                UIView.animate(withDuration: 0.2) {
//                    let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
//                    tableView.contentInset = contentInsets
//                    tableView.scrollIndicatorInsets = contentInsets
                    var textfieldMaxY:CGFloat = 0.0
                    var responder: UIResponder?
                    if let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
                        if let activeTextField = keyWindow.findFirstResponder() as? TextView {
                            responder = activeTextField
                            textfieldMaxY = activeTextField.convert(activeTextField.bounds, to: nil).maxY
                        }
                    }
                    while responder != nil {
                        if let cell = responder as? UITableViewCell {
                            // Found the UITableViewCell
                            // You can use 'cell' here
                            if let indexRow = tableView.indexPath(for: cell) {
                                let rectInTableView = tableView.rectForRow(at: indexRow)
                                let rectInView = tableView.convert(rectInTableView, to: tableView.superview)
                                
                                let keyboardFrameInView = tableView.superview?.convert(keyboardSize, from: nil)
                                
//                                if let keyboardFrame = keyboardFrameInView, rectInView.intersects(keyboardFrame), textfieldMaxY > 0, textfieldMaxY < keyboardFrame.maxY, keyboardFrame.maxY - textfieldMaxY < keyboardFrame.height, textfieldMaxY > keyboardFrame.height {
                                if let keyboardFrame = keyboardFrameInView, rectInView.intersects(keyboardFrame), textfieldMaxY > 0, textfieldMaxY > keyboardFrame.height, keyboardFrame.maxY - textfieldMaxY < 200 {
                                    var offset = textfieldMaxY - keyboardFrame.maxY
                                    if keyboardFrame.maxY - textfieldMaxY < 100 {
                                        offset -= (200 - (keyboardFrame.maxY - textfieldMaxY))
                                    }
                                    let contentOffset = tableView.contentOffset
                                    
//                                    if offset < -keyboardFrame.height {
//                                        offset += keyboardFrame.height
//                                    }
                                    
                                    if offset < 0 {
                                        // The cell is covered by the keyboard, scroll to make it visible
                                        tableView.setContentOffset(CGPoint(x: contentOffset.x, y: contentOffset.y - offset), animated: true)
                                    }
                                }
                            }
                        }
                        responder = responder?.next
                    }
                }
            }
        }
    }
    
    func traverseSubviews(view: UIView) -> UITableView? {
        if let tableview = view as? UITableView {
            return tableview
        }
        for i in 0..<view.subviews.count {
            // Do something with the subview
            let subview = view.subviews[i]
            print("subview11",i, view.subviews.count)
            print(subview)
            
            // Recursively traverse subviews
            if let tableview1 = traverseSubviews(view: subview) {
                return tableview1
            }
        }
            
        return nil
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if let tableView = self.controller?.view.subviews[1].subviews[1].subviews[0].subviews[0].subviews[0].subviews[1] as? UITableView {
            let contentInsets = UIEdgeInsets.zero
            tableView.contentInset = contentInsets
            tableView.scrollIndicatorInsets = contentInsets
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == hintColor {
            textView.text = ""
            textView.textColor = textInputColor
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            if let parentTextInputElement = parentTextInputElement {
                parentTextInputElement.text = ""
                if !parentTextInputElement.placeHolder.isEmpty {
                textView.text = parentTextInputElement.placeHolder
                }
            }
            textView.textColor = hintColor
        } else {
            if let parentTextInputElement = parentTextInputElement, !parentTextInputElement.elementId.isEmpty {
                parentTextInputElement.text = textView.text
            }
        }
    }
}

extension String {
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
}

extension UIColor {
    func withBrightness(_ factor: CGFloat) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return UIColor(hue: hue, saturation: saturation, brightness: brightness * factor, alpha: alpha)
    }
}

extension UIWindow {
    func findFirstResponder() -> UIView? {
        if isKeyWindow {
            return self.findFirstResponderInView(self)
        }
        return nil
    }

    private func findFirstResponderInView(_ view: UIView) -> UIView? {
        if view.isFirstResponder {
            return view
        }

        for subview in view.subviews {
            if let firstResponder = self.findFirstResponderInView(subview) {
                return firstResponder
            }
        }

        return nil
    }
}
