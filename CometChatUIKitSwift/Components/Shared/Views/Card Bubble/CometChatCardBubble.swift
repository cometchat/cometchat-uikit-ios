//
//  CometChatCardBubble.swift
//  CometChatUIKitSwift
//
//  Created for developer card messages (category "card").
//

import UIKit
import CometChatSDK
import CometChatCardsSwift

/// Renders a developer card message (SDK's `CometChatSDK.CardMessage` with category "card")
/// using the CometChatCardsSwift renderer library.
public class CometChatCardBubble: UIView {
    
    private let cardView = CometChatCardView()
    private let fallbackLabel = UILabel()
    
    public var onCardAction: ((BaseMessage, CometChatCardActionEvent) -> Void)?
    private weak var message: BaseMessage?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        buildUI()
    }
    
    private func buildUI() {
        cardView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cardView)
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            cardView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            cardView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            cardView.widthAnchor.constraint(lessThanOrEqualToConstant: UIScreen.main.bounds.width * 0.75)
        ])
        
        fallbackLabel.translatesAutoresizingMaskIntoConstraints = false
        fallbackLabel.numberOfLines = 0
        fallbackLabel.font = CometChatTypography.Body.regular
        fallbackLabel.textColor = CometChatTheme.textColorPrimary
        fallbackLabel.isHidden = true
        addSubview(fallbackLabel)
        NSLayoutConstraint.activate([
            fallbackLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            fallbackLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            fallbackLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            fallbackLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
        
        // Set theme based on current appearance
        cardView.themeMode = .auto
    }
    
    /// Configures the bubble with an SDK `CardMessage`.
    /// - Parameter message: A `CometChatSDK.CardMessage` (category "card").
    public func set(cardMessage message: BaseMessage) {
        self.message = message
        
        guard let cardMessage = message as? CometChatSDK.CardMessage,
              let card = cardMessage.getCard() else {
            showFallback(message: message)
            return
        }
        
        // Serialize card dictionary to JSON string for the renderer
        guard let jsonData = try? JSONSerialization.data(withJSONObject: card, options: []),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            showFallback(message: message)
            return
        }
        
        // Set action callback BEFORE cardJson (assigning schema triggers render)
        cardView.actionCallback = { [weak self] event in
            guard let self = self, let msg = self.message else { return }
            self.onCardAction?(msg, event)
            CometChatCardEvents.ccCardActionClicked(message: msg, action: event)
        }
        
        cardView.cardJson = jsonString
        cardView.isHidden = false
        fallbackLabel.isHidden = true
    }
    
    private func showFallback(message: BaseMessage) {
        cardView.isHidden = true
        fallbackLabel.isHidden = false
        if let cardMsg = message as? CometChatSDK.CardMessage {
            fallbackLabel.text = cardMsg.getFallbackText() ?? cardMsg.getText() ?? "Card Message"
        } else {
            fallbackLabel.text = "Card Message"
        }
    }
}
