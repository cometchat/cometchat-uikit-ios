//
//  File.swift
//  
//
//  Created by SuryanshBisen on 20/10/23.
//

import Foundation
import UIKit

open class CometChatAIConversationSummary: UIView {

    // Title Label
    public let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Conversation summary"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Description Label
    public let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Close Button
    public let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
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
    
    public var id: [String: Any]?
    public static var style = AIConversationSummaryStyle()
    public lazy var style = CometChatAIConversationSummary.style
    public var loadingView: UIView!
    public var disableLoadingState: Bool = false
    public var isLoadingViewVisible = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func willMove(toWindow newWindow: UIWindow?) {
        if newWindow != nil {
            setupStyle()
        }
    }
    
    open func buildUI() {
        
        loadingView = CometChatAIConversationSummaryShimmer()
        
        // Add subviews
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(closeButton)
        
        // Set up constraints
        NSLayoutConstraint.activate([
                        
            // Title label constraints
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: CometChatSpacing.Padding.p3),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: CometChatSpacing.Padding.p4),
            titleLabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor),
            
            // Close button constraints
            closeButton.topAnchor.constraint(equalTo: topAnchor, constant: CometChatSpacing.Padding.p3),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -CometChatSpacing.Padding.p4),
            closeButton.widthAnchor.constraint(equalToConstant: 16),
            closeButton.heightAnchor.constraint(equalToConstant: 16),
            
            // Description label constraints
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: CometChatSpacing.Padding.p2),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: CometChatSpacing.Padding.p4),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -CometChatSpacing.Padding.p4),
            descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -CometChatSpacing.Padding.p3)
        ])
                
        closeButton.addTarget(self, action: #selector(onCloseButtonClicked), for: .touchUpInside)
    }
    
    open func setupStyle(){
        self.backgroundColor = style.backgroundColor
        self.borderWith(width: style.borderWidth)
        self.borderColor(color: style.borderColor)
        self.roundViewCorners(corner: style.cornerRadius ?? .init(cornerRadius: CometChatSpacing.Radius.r2))
        self.applyCornerRadiusAndShadow(cornerRadius: style.cornerRadius?.cornerRadius ?? CometChatSpacing.Radius.r2)
        self.titleLabel.textColor = style.titleTextColor
        self.titleLabel.font = style.titleTextFont
        self.descriptionLabel.textColor = style.summaryTextColor
        self.descriptionLabel.font = style.summaryTextFont
        self.closeButton.setImage(style.cancelButtonImage, for: .normal)
        self.closeButton.tintColor = style.cancelButtonImageTintColor
        self.errorLabel.textColor = style.errorViewTextColor
        self.errorLabel.font = style.errorViewTextFont
    }
    
    public func showLoadingView() {
        if disableLoadingState { return }
        (loadingView as? CometChatShimmerView)?.startShimmer()
        
        isLoadingViewVisible = true
        
        self.addSubview(loadingView)
        
        loadingView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: CometChatSpacing.Padding.p2).isActive = true
        loadingView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: CometChatSpacing.Padding.p2).isActive = true
        loadingView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -CometChatSpacing.Padding.p2).isActive = true
        loadingView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -CometChatSpacing.Padding.p3).isActive = true
        loadingView.roundViewCorners(corner: style.cornerRadius ?? .init(cornerRadius: CometChatSpacing.Radius.r2))
        loadingView.heightAnchor.constraint(equalToConstant: 160).isActive = true
        
    }

    public func hideLoadingView() {
        (loadingView as? CometChatShimmerView)?.stopShimmer()
        
        isLoadingViewVisible = false
        
        loadingView.removeFromSuperview()
    }
    
    @objc func onCloseButtonClicked() {
        CometChatUIEvents.hidePanel(id: id, alignment: .composerTop)
    }
    
    @discardableResult
    public func set(summary: String) -> Self {
        descriptionLabel.text = summary
        return self
    }
    
    @discardableResult
    public func set(id: [String: Any]?) -> Self {
        self.id = id
        return self
    }
    
    @discardableResult
    public func set(title: String) -> Self {
        self.titleLabel.text = title
        return self
    }
    
    @discardableResult
    @objc public func show(error: Bool) -> Self {
        if error{
            addSubview(errorView)
            errorView.addSubview(errorLabel)
            NSLayoutConstraint.activate([
                errorView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: CometChatSpacing.Padding.p2),
                errorView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                errorView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                errorView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                
                errorLabel.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
                errorLabel.centerYAnchor.constraint(equalTo: errorView.centerYAnchor),
                errorLabel.leadingAnchor.constraint(equalTo: errorView.leadingAnchor, constant: CometChatSpacing.Padding.p6),
                errorLabel.trailingAnchor.constraint(equalTo: errorView.trailingAnchor, constant: -CometChatSpacing.Padding.p6),
                errorLabel.topAnchor.constraint(equalTo: errorView.topAnchor, constant: CometChatSpacing.Padding.p2),
                errorLabel.bottomAnchor.constraint(equalTo: errorView.bottomAnchor, constant: -CometChatSpacing.Padding.p2),
                errorLabel.heightAnchor.constraint(equalToConstant: 162)
            ])
        }else{
            errorView.removeFromSuperview()
        }
        return self
    }
    
    @discardableResult
    public func set(configuration: AIConversationSummaryConfiguration?) -> Self {
        
        if let configuration = configuration {
            
            if let title = configuration.title {
                self.set(title: title)
            }
        }
        return self
    }
}
