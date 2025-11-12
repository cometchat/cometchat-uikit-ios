//
//  CometChatAIAssistantBubble.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 01/10/25.
//

import Foundation
import UIKit

public class CometChatAIAssistantBubble: UIView {
    
    public static var style = AIAssistantBubbleStyle()
    public lazy var style = CometChatAIAssistantBubble.style
    
    public lazy var label: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints()
        label.numberOfLines = 0
        label.font = CometChatTypography.Body.regular
        label.textColor = .label
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        buildUI()
    }
    
    public func buildUI() {
        self.withoutAutoresizingMaskConstraints()
        
        NSLayoutConstraint.activate([
            widthAnchor.pin(lessThanOrEqualToConstant: UIScreen.main.bounds.width/1.2),
        ])
    }
    
    public override func willMove(toWindow newWindow: UIWindow?) {
        if newWindow != nil {
            setupStyle()
        }
    }
    
    open func setupStyle() {
        label.textColor = style.textColor
        label.font = style.textFont
    }
    
    // MARK: - Public API
    
    public func set(text: String) {
        let bubble = CombinedMarkdownBubbleView(markdown: text, style: style)
        bubble.withoutAutoresizingMaskConstraints()
        self.embed(
            bubble,
            insets: .init(
                top: 0,
                leading: CometChatSpacing.Padding.p3,
                bottom: 0,
                trailing: CometChatSpacing.Padding.p3
            )
        )
    }
    
    public func set(attributedText: NSAttributedString) {
        label.attributedText = attributedText
    }
}
