//
//  CardMessage.swift
//  
//
//  Created by Abhishek Saralaya on 23/10/23.
//

import Foundation
import CometChatSDK

import Foundation
import CometChatSDK
public class CometChatCardBubble: UIView {
    
    @IBOutlet weak var containerView: UIStackView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var labelText: UILabel!
    private weak var controller: UIViewController?
    private var cardMessage: CardMessage?
    private var elementEntities: [ElementEntity]?
    fileprivate var cometChatData = [String:Any]()
    private var style = CardBubbleStyle()
    private var containerViews = [String:[UIView]]()
    private var separatorViews = [UIView]()
    private (set) var onActionClick: ((Button) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        customInit()
    }
    
    
    
    private func customInit() {
        CometChatUIKit.bundle.loadNibNamed("CometChatCardBubble", owner: self, options: nil)
        addSubview(containerView)
        if style.borderColor == .systemFill {
            style = style.set(borderColor: (self.traitCollection.userInterfaceStyle == .dark) ? CometChatTheme_v4.palatte.accent900 : CometChatTheme_v4.palatte.secondary)
            style = style.set(buttonSeparatorColor: (self.traitCollection.userInterfaceStyle == .dark) ? CometChatTheme_v4.palatte.accent500 : style.getButtonSeparatorColor())
        }
        style = style.set(buttonBackgroundColor: .clear)
        style = style.set(buttonTextColor: CometChatTheme_v4.palatte.primary)
        set(style: style)
        containerView.frame = bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let width = CGFloat((controller?.view.bounds.width ?? 300) - 48)
        
        NSLayoutConstraint.activate([containerView.topAnchor.constraint(equalTo: self.topAnchor, constant: 11),
                                     containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -11),
                                     containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                                     containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor)])
        containerView.layer.cornerRadius = 10
        containerView.clipsToBounds = true
        containerView.borderWith(width: 1)
        containerView.borderColor(color: (self.traitCollection.userInterfaceStyle == .dark) ? CometChatTheme_v4.palatte.accent100 : CometChatTheme_v4.palatte.secondary)
        
        buildForm()
        if CometChatUIKit.getLoggedInUser()?.uid == cardMessage?.sender?.uid, let allowSenderInteraction = cardMessage?.allowSenderInteraction, !allowSenderInteraction {
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
        
    func buildForm() {
        containerView.spacing = 5
        if let urlString = self.cardMessage?.getImageUrl() {
            if let url = URL(string: urlString) {
                getData(from: url, completion: {
                    data, response, error in
                    if let data = data {
                        DispatchQueue.main.async {
                            self.imageView.image = UIImage(data: data)
                        }
                    }
                })
            }
        }
        if let text = self.cardMessage?.getText() {
            labelText.text = text
        }
        if let _elementEntities = elementEntities {
            for elementEntity in _elementEntities {
                switch elementEntity.elementType {
                case .button:
                    if let buttonElement = elementEntity as? ButtonElement {
                        buildButton(buttonElement)
                    }
                    break
                default:
                    break
                }
                
            }
            for separator in self.separatorViews {
                NSLayoutConstraint.activate([separator.heightAnchor.constraint(equalToConstant: 1)])
            }
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func buildButton(_ buttonElement: ButtonElement) {
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(buttonElement.onButtonClickAction(_:)))
        
        let separator = UIView()
        separator.frame.size.height = 1
        containerView.addArrangedSubview(separator)
        separator.clipsToBounds = true
        let anchor = containerView.subviews.last?.bottomAnchor ?? containerView.topAnchor
        NSLayoutConstraint.activate([separator.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                                     separator.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                                     separator.topAnchor.constraint(equalTo: anchor),
                                     separator.heightAnchor.constraint(equalToConstant: 20)])
        separator.backgroundColor = style.getButtonSeparatorColor()
        separator.alpha = 1
        let button = Button()
        button.buttonElement = buttonElement
        button.addTarget(self, action: #selector(onButtonClickAction(_:)), for: .touchUpInside)
//        buttonElement.frame = CGRect(x: 0, y: 0, width: 100, height: 30)
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        button.titleLabel?.text = buttonElement.buttonText
        button.setTitle(buttonElement.buttonText, for: .normal)
        button.setTitleColor(style.getButtonTextColor(), for: .normal)
        separator.setContentHuggingPriority(.required, for: .horizontal)
        separator.setContentHuggingPriority(.required, for: .vertical)
        separator.setContentCompressionResistancePriority(.required, for: .horizontal)
        separator.setContentCompressionResistancePriority(.required, for: .vertical)
        activityIndicator.color = style.getButtonTextColor()
        containerView.addArrangedSubview(activityIndicator)
        containerView.addArrangedSubview(button)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = style.getButtonBackgroundColor()
        button.layer.cornerRadius = style.cornerRadius.cornerRadius
        if buttonElement.disableAfterInteracted, let cardMessage = self.cardMessage, let interactions = cardMessage.interactions,  interactions.contains(where: {$0.elementId == buttonElement.elementId}) {
            button.isUserInteractionEnabled = false
        }
        NSLayoutConstraint.activate([activityIndicator.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
                                     activityIndicator.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
                                     activityIndicator.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 8),
                                     activityIndicator.heightAnchor.constraint(equalToConstant: 50),
                                     button.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
                                     button.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
                                     button.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 8),
                                     button.heightAnchor.constraint(equalToConstant: 50)])
        separator.layoutIfNeeded()
        containerViews[buttonElement.elementId] = [button, activityIndicator]
        if containerViews.keys.count == self.elementEntities?.count {
            activityIndicator.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 8).isActive = true
            button.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 8).isActive = true
        }
        self.separatorViews.append(separator)
    }
    
    public class Button: UIButton {
        var buttonElement: ButtonElement?
    }
    
    @discardableResult
    public func set(onActionClick: @escaping ((Button) -> Void)) -> Self {
        self.onActionClick = onActionClick
        return self
    }
    
    @objc func onButtonClickAction(_ sender: Button) {
        
        if let onActionClick = onActionClick {
            onActionClick(sender)
        } else {
            if let buttonElement = sender.buttonElement, let url = URL(string: buttonElement.action.url), buttonElement.action.actionType == "apiAction" {
                var urlRequest = URLRequest(url: url)
                urlRequest.httpMethod = buttonElement.action.method.value
                do {
                    var data = [String:Any]()
                    data.append(with: buttonElement.action.payLoad)
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
                    dataTaskWith(request: urlRequest, completion: { [weak self] data,response,error  in
                        guard let this = self else { return }
                        if let response = response as? HTTPURLResponse {
                            if response.statusCode > 199 && response.statusCode < 300 {
                                DispatchQueue.main.async {
                                    view1.stopAnimating()
                                    this.containerView.insertSubview(view, aboveSubview: view1)
                                    view1.isHidden = true
                                    view.isHidden = false
                                    if buttonElement.disableAfterInteracted {
                                            view.isUserInteractionEnabled = false
                                        }
                                }
                            } else {
                                DispatchQueue.main.async {
                                    view1.stopAnimating()
                                    this.containerView.insertSubview(view, aboveSubview: view1)
                                    view1.isHidden = true
                                    view.isHidden = false
                                    if buttonElement.disableAfterInteracted {
                                        view.isUserInteractionEnabled = false
                                    }
                                }
                            }
                        }
                    })
                }
            } else if let buttonElement = sender.buttonElement, buttonElement.navigationAction.actionType == "urlNavigation", !buttonElement.navigationAction.url.isEmpty {
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
    
    @discardableResult
    public func set(cardMessage: CardMessage) {
        self.cardMessage = cardMessage
        self.setUIElements(cardMessage.getCardActions())
    }
    
    @discardableResult
    public func setUIElements(_ elementEntities: [ElementEntity]) {
        self.elementEntities = elementEntities
        customInit()
    }
    
    @discardableResult
    public func set(style: CardBubbleStyle) -> Self {
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

