//
//  CometChatAgentBadge.swift
//  CometChatUIKitSwift
//
//  Created for AI Agents in Group Chat feature.
//

import Foundation
import UIKit

/// A small pill-shaped badge that indicates the sender is an AI agent.
/// Default rendering: "AI" text with an optional icon, themed with `agentBadge*` tokens.
/// Zero-config renders the default badge; customizable via `AgentBadgeStyle`.
public class CometChatAgentBadge: UIView {
    
    // MARK: - Style
    public static var style = AgentBadgeStyle()
    public var style: AgentBadgeStyle = CometChatAgentBadge.style {
        didSet { setupStyle() }
    }
    
    // MARK: - Subviews
    private lazy var iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private lazy var label: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.numberOfLines = 1
        lbl.textAlignment = .center
        return lbl
    }()
    
    private lazy var stackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [iconImageView, label])
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.alignment = .center
        sv.spacing = 2
        return sv
    }()
    
    // MARK: - Init
    public override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        buildUI()
    }
    
    // MARK: - Build UI
    private func buildUI() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6),
            
            iconImageView.widthAnchor.constraint(equalToConstant: 12),
            iconImageView.heightAnchor.constraint(equalToConstant: 12)
        ])
        
        layer.masksToBounds = true
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }
    
    public override func willMove(toWindow newWindow: UIWindow?) {
        if newWindow != nil {
            setupStyle()
        }
    }
    
    // MARK: - Style Application
    private func setupStyle() {
        backgroundColor = style.backgroundColor
        label.text = style.labelText
        label.font = style.labelFont
        label.textColor = style.labelColor
        
        if let icon = style.icon {
            iconImageView.image = icon.withRenderingMode(.alwaysTemplate)
            iconImageView.tintColor = style.iconColor
            iconImageView.isHidden = false
        } else {
            iconImageView.isHidden = true
        }
        
        if !style.show {
            isHidden = true
        }
    }
    
    // MARK: - Accessibility
    public override var accessibilityLabel: String? {
        get { return "AGENT_BADGE_LABEL".localize() }
        set { }
    }
    
    public override var isAccessibilityElement: Bool {
        get { return true }
        set { }
    }
    
    public override var accessibilityTraits: UIAccessibilityTraits {
        get { return .staticText }
        set { }
    }
}

// MARK: - AgentBadgeStyle

/// Style configuration for the AI agent badge.
/// All properties have safe defaults — zero-config renders the badge correctly.
public struct AgentBadgeStyle {
    /// Whether to show the badge at all. Default: true.
    public var show: Bool = true
    
    /// Badge background color. Default: `CometChatTheme.agentBadgeBackground`.
    public var backgroundColor: UIColor {
        get { _backgroundColor ?? CometChatTheme.agentBadgeBackground }
        set { _backgroundColor = newValue }
    }
    private var _backgroundColor: UIColor?
    
    /// Badge text/icon color. Default: `CometChatTheme.agentBadgeText`.
    public var labelColor: UIColor {
        get { _labelColor ?? CometChatTheme.agentBadgeText }
        set { _labelColor = newValue }
    }
    private var _labelColor: UIColor?
    
    /// Badge icon color. Default: same as labelColor.
    public var iconColor: UIColor {
        get { _iconColor ?? labelColor }
        set { _iconColor = newValue }
    }
    private var _iconColor: UIColor?
    
    /// Badge label text. Default: "AI".
    public var labelText: String = "AGENT_BADGE_LABEL".localize()
    
    /// Badge label font. Default: Caption2 bold.
    public var labelFont: UIFont = CometChatTypography.Caption2.bold
    
    /// Optional icon image for the badge. Default: nil (text-only badge).
    public var icon: UIImage? = nil
    
    public init() {}
}
