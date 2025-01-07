//
//  CometChatAIConversationStarter.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 18/11/24.
//

import Foundation
import UIKit

open class CometChatAIConversationStarter: UIView {
    
    // MARK: - Properties
    public let errorView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints()
        return view
    }()
    
    public let errorLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints()
        label.text = "Looks like something went wrong.\nPlease try again."
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    public var tableView = SelfSizingTableView().withoutAutoresizingMaskConstraints()
    public var aiMessagesList = [String]()
    public var onAiMessageClicked: ((_ selectedReply: String) -> ())?
    public var id: [String: Any]?
    public var loadingView: UIView!
    public var disableLoadingState: Bool = false
    public var isLoadingViewVisible = false
    
    public static var style = AIConversationStarterStyle()
    public lazy var style = CometChatAIConversationStarter.style
    
    // MARK: - Initialization
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        setupDelegate()
        buildUI()
    }
    
    public override func willMove(toWindow newWindow: UIWindow?) {
        if newWindow != nil {
            setupStyle()
        }
    }
    
    // MARK: - UI Setup
    public func setupDelegate() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(AIConversationStarterCell.self, forCellReuseIdentifier: "AIConversationStarterCell")
    }
    
    open func buildUI() {
        
        tableView.isScrollEnabled = false
        loadingView = CometChatAIConversationStarterShimmer()
        addSubview(tableView)
                
        backgroundColor = .clear
        loadingView.backgroundColor = .clear
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.topAnchor, constant: CometChatSpacing.Padding.p2),
            tableView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -CometChatSpacing.Padding.p),
        ])
    }
    
    open func setupStyle(){
        backgroundColor = .clear
        tableView.backgroundColor = .clear
        tableView.separatorStyle = style.repliesTableViewSeparatorStyle ?? .none
        errorLabel.textColor = style.errorViewTextColor
        errorLabel.font = style.errorViewTextFont
    }
    
    public func showLoadingView() {
        if disableLoadingState { return }
        (loadingView as? CometChatShimmerView)?.startShimmer()
        
        isLoadingViewVisible = true
        
        self.addSubview(loadingView)
        
        loadingView.topAnchor.constraint(equalTo: self.topAnchor, constant: CometChatSpacing.Padding.p2).isActive = true
        loadingView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        loadingView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        loadingView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -(CometChatSpacing.Padding.p)).isActive = true
        loadingView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        loadingView.roundViewCorners(corner: .init(cornerRadius: 16))
    }

    public func hideLoadingView() {
        (loadingView as? CometChatShimmerView)?.stopShimmer()
        
        isLoadingViewVisible = false
        
        loadingView.removeFromSuperview()
    }
    
    private func updateTableViewHeight() {
        tableView.invalidateIntrinsicContentSize()
        tableView.layoutIfNeeded()
    }
    
    // MARK: - Public API
    @discardableResult
    @objc public func set(aiMessageOptions: [String]) -> Self {
        self.hideLoadingView()
        self.aiMessagesList = aiMessageOptions
        tableView.reloadData()
        updateTableViewHeight()
        return self
    }
    
    @discardableResult
    @objc public func onMessageClicked(onAiMessageClicked: @escaping ((_ selectedReply: String) -> ())) -> Self {
        self.onAiMessageClicked = onAiMessageClicked
        return self
    }
    
    @discardableResult
    @objc public func show(error: Bool) -> Self {
        if error{
            addSubview(errorView)
            errorView.addSubview(errorLabel)
            NSLayoutConstraint.activate([
                errorView.topAnchor.constraint(equalTo: self.topAnchor, constant: CometChatSpacing.Padding.p2),
                errorView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                errorView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                errorView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -CometChatSpacing.Padding.p2),
                
                errorLabel.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
                errorLabel.centerYAnchor.constraint(equalTo: errorView.centerYAnchor),
                errorLabel.leadingAnchor.constraint(equalTo: errorView.leadingAnchor, constant: CometChatSpacing.Padding.p6),
                errorLabel.trailingAnchor.constraint(equalTo: errorView.trailingAnchor, constant: -CometChatSpacing.Padding.p6),
                errorLabel.topAnchor.constraint(equalTo: errorView.topAnchor, constant: CometChatSpacing.Padding.p2),
                errorLabel.bottomAnchor.constraint(equalTo: errorView.bottomAnchor, constant: -CometChatSpacing.Padding.p2),
                errorLabel.heightAnchor.constraint(equalToConstant: 120)
            ])
        }else{
            errorView.removeFromSuperview()
        }
        return self
    }
}

// MARK: - UITableView DataSource & Delegate
extension CometChatAIConversationStarter: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return aiMessagesList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AIConversationStarterCell", for: indexPath) as? AIConversationStarterCell else {
            return UITableViewCell()
        }
        
        let message = aiMessagesList[indexPath.row]
        let maxWidth = tableView.bounds.width - 40
        cell.configure(with: message, maxWidth: maxWidth)
        cell.cellLabel.textColor = style.textColor
        cell.cellLabel.font = style.textFont
        cell.containerView.borderWith(width: style.borderWidth)
        cell.containerView.borderColor(color: style.borderColor)
        cell.containerView.roundViewCorners(corner: style.cornerRadius ?? .init(cornerRadius: 15))
        cell.containerView.backgroundColor = style.backgroundColor
        cell.backgroundColor = .clear
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let onClick = onAiMessageClicked?(aiMessagesList[indexPath.row]) {
            onClick
            CometChatUIEvents.hidePanel(id: id, alignment: .composerTop)
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
