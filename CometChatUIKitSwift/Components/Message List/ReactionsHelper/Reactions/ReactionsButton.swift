//
//  ReactionsButton.swift
//  CometChatUIKitSwift
//
//  Created by SuryanshBisen on 18/02/24.
//

import Foundation
import CometChatSDK

/// `ReactionsView` is a custom UIView designed to display a reaction emoji along with its count
/// for a specific message in the chat interface. It includes styles for both active and inactive
/// reactions, allowing for visual feedback based on user interaction.
class ReactionsView: UIView {

    /// The base message associated with the reaction.
    var baseMessage: BaseMessage

    /// The reaction count information, including the emoji and the number of times it has been reacted to.
    var reaction: ReactionCount

    /// The style configuration for this reaction view, allowing for customization of appearance.
    var style = ReactionsStyle()

    // Labels to display the emoji and the count of reactions.
    private let emojiLabel = UILabel().withoutAutoresizingMaskConstraints()
    private let countLabel = UILabel().withoutAutoresizingMaskConstraints()

    // Stack view that contains the emoji and count labels.
    var emojiStackView: UIStackView = {
        let stackView = UIStackView().withoutAutoresizingMaskConstraints()
        stackView.distribution = .fill
        stackView.alignment = .center
        return stackView
    }()

    /// Initializes a new `ReactionsView` with a specified base message, reaction count, and styling.
    /// - Parameters:
    ///   - baseMessage: The message to which the reaction is associated.
    ///   - reaction: The count and type of the reaction.
    ///   - style: The styling options for the reactions view.
    init(baseMessage: BaseMessage, reaction: ReactionCount, style: ReactionsStyle) {
        self.baseMessage = baseMessage
        self.reaction = reaction
        self.style = style
        super.init(frame: .zero)
        self.buildUI()
    }

    /// Required initializer for loading the view from a storyboard or nib.
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Called when the view is about to be added to a window. This method sets up the style of the view.
    override func willMove(toWindow newWindow: UIWindow?) {
        if newWindow != nil {
            setupStyle()
        }
    }

    /// Configures the visual style of the reactions view, including colors, fonts, and borders.
    func setupStyle() {
        self.roundViewCorners(corner: style.cornerRadius ?? .init(cornerRadius: CometChatSpacing.Radius.r3))
        self.backgroundColor = style.backgroundColor

        self.borderWith(width: style.borderWidth)
        self.borderColor(color: style.borderColor)

        // Update style if the reaction was made by the current user.
        if reaction.reactedByMe {
            self.layer.borderWidth = style.activeReactionBorderWidth
            self.layer.borderColor = style.activeReactionBorderColor.cgColor
            self.backgroundColor = style.activeReactionBackgroundColor
        } else {
            
        }

        // Configure the emoji label with the appropriate font and text.
        emojiLabel.font = style.emojiTextFont
        emojiLabel.text = reaction.reaction

        // Configure the count label with its font, text color, and value.
        countLabel.font = style.countTextFont
        countLabel.textColor = style.countTextColor
    }

    /// Constructs the user interface for the reactions view, setting up constraints and embedding subviews.
    private func buildUI() {
        self.countLabel.text = String(reaction.count)
        self.emojiStackView.spacing = style.reactionSpacing
        self.withoutAutoresizingMaskConstraints()
        self.emojiStackView.alignment = .center

        // Embed the emoji stack view within the reactions view, applying padding.
        self.embed(emojiStackView, insets: .init(
            top: CometChatSpacing.Padding.p,
            leading: CometChatSpacing.Padding.p2,
            bottom: CometChatSpacing.Padding.p,
            trailing: CometChatSpacing.Padding.p2
        ))

        // Add emoji and count labels to the stack view.
        emojiStackView.addArrangedSubview(emojiLabel)
        emojiStackView.addArrangedSubview(countLabel)

        // Center the stack view vertically within the reactions view and set a fixed height.
        NSLayoutConstraint.activate([
            emojiStackView.centerYAnchor.pin(equalTo: centerYAnchor),
            self.heightAnchor.pin(equalToConstant: 24)
        ])
    }
}

