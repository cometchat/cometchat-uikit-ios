//
//  AddReactionsView.swift
//  CometChatUIKitSwift
//
//  Created by SuryanshBisen on 18/02/24.
//

import UIKit
import Foundation

/// A customizable UIStackView for displaying quick reaction buttons in a chat interface.
open class CometChatQuickReactions: UIStackView {
    
    /// Global styling configuration for quick reactions.
    public static var style = QuickReactionsStyle()
    
    /// Component-level styling, initialized with global style.
    public lazy var style = CometChatQuickReactions.style
    
    /// List of reactions represented as emoji strings.
    var reactionList = ["👍", "❤️", "😂", "😢", "🙏"] {
        didSet {
            addReaction()
        }
    }
    
    /// Callback triggered when a reaction is selected.
    var onReacted: ((_ reaction: String?) -> Void)?
    
    /// Callback triggered when the add reaction icon is tapped.
    var onAddReactionIconTapped: (() -> Void)?
    
    /// The icon for adding a new reaction, rendered with a template style.
    public var addReactionIcon: UIImage? = UIImage(systemName: "plus")?.withRenderingMode(.alwaysTemplate)
    
    /// Direction options for presenting or dismissing the quick reactions view.
    public enum Direction {
        case left
        case right
    }

    /// Declares button variables for reaction buttons and the plus button.
    private var reactionButtons: [UIButton] = []
    private var plusIconView: UIView!
    
    // MARK: - Initializer
    
    /// Initializes the quick reactions view with the specified frame.
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
    }

    /// Initializes the quick reactions view from a storyboard or XIB file.
    required public init(coder: NSCoder) {
        super.init(coder: coder)
        buildUI()
    }
    
    /// Called when the view is about to be added to a window. Sets up the style if the window is not nil.
    open override func willMove(toWindow newWindow: UIWindow?) {
        if newWindow != nil {
            setupStyle()
        }
    }

    // MARK: - UI Setup
    
    /// Builds the UI components and adds them to the stack view.
    private func buildUI() {
        // Stack view configuration
        axis = .horizontal
        distribution = .equalSpacing
        alignment = .center
        spacing = CometChatSpacing.Spacing.s1
        isLayoutMarginsRelativeArrangement = true
        layoutMargins = UIEdgeInsets(top: CometChatSpacing.Padding.p, left: CometChatSpacing.Padding.p3, bottom: CometChatSpacing.Padding.p, right: CometChatSpacing.Padding.p3)

        addReaction()
    }
    
    /// This function will add reaction Buttons in the container view from the ReactionList .
    func addReaction() {
        
        subviews.forEach({ $0.removeFromSuperview() })
        
        // Create and add reaction buttons to the stack
        for (index, reaction) in reactionList.enumerated() {
            let reactionButton = createReactionButton(with: reaction, tag: index)
            reactionButtons.append(reactionButton)
            addArrangedSubview(reactionButton)
        }

        // Create and add the plus button (to add more reactions)
        plusIconView = createPlusIconView()
        addArrangedSubview(plusIconView)
        
    }
    
    /// Applies the style configuration to various components of the quick reactions view.
    private func setupStyle() {
        backgroundColor = style.backgroundColor
        self.roundViewCorners(corner: style.cornerRadius ?? .init(cornerRadius: CometChatSpacing.Radius.r5))
        self.borderWith(width: style.borderWidth)
        self.borderColor(color: style.borderColor)
        
        plusIconView.tintColor = style.plusIconTintColor
        plusIconView.backgroundColor = style.plusIconBackgroundColor
        plusIconView.roundViewCorners(corner: style.plusIconCornerRadius ?? .init(cornerRadius: CometChatSpacing.Radius.r3))
        plusIconView.isHidden = style.hideAddReactionsIcon
        
        for reactionButton in reactionButtons {
            reactionButton.titleLabel?.font = style.reactionFont
            reactionButton.backgroundColor = style.reactionsBackgroundColor
            reactionButton.roundViewCorners(corner: style.reactionCornerRadius)
        }
    }

    // MARK: - Button Creation
    
    /// Creates a button for a specific reaction.
    /// - Parameters:
    ///   - title: The title of the reaction (emoji).
    ///   - tag: The index of the reaction in the reaction list.
    /// - Returns: A configured UIButton for the reaction.
    private func createReactionButton(with title: String, tag: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.tag = tag
        button.addTarget(self, action: #selector(onReactionTapped(_:)), for: .primaryActionTriggered)
        return button
    }

    /// Creates the plus button for adding more reactions.
    /// - Returns: A configured UIButton for adding reactions.
    private func createPlusIconView() -> UIView {
        let containerView = UIView().withoutAutoresizingMaskConstraints()
        containerView.pin(anchors: [.width, .height], to: 24)

        let imageView = UIImageView(image: addReactionIcon).withoutAutoresizingMaskConstraints()
        imageView.contentMode = .scaleAspectFit
        
        containerView.addSubview(imageView)

        imageView.widthAnchor.pin(equalTo: containerView.widthAnchor, multiplier: 0.7).isActive = true
        imageView.heightAnchor.pin(equalTo: containerView.heightAnchor, multiplier: 0.7).isActive = true
        imageView.pin(anchors: [.centerX, .centerY], to: containerView)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onPlusIconTapped(_:)))
        containerView.addGestureRecognizer(tapGesture)

        return containerView
    }


    
    // MARK: - Animations
    
    /// Dismisses the quick reactions view with an animation.
    public func dismissAnimation() {
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 1,
                       options: .transitionCurlDown,
                       animations: {
            self.isHidden = true
        }) { completion in
            if completion {
                self.isHidden = true
            }
        }
    }
    
    /// Presents the quick reactions view with an animation in the specified direction.
    /// - Parameter animationDirection: The direction to present the view from.
    public func presentAnimation(animationDirection: CometChatQuickReactions.Direction) {
        var offset = CGPoint(x: UIScreen.main.bounds.width, y: 0)
        if animationDirection == .right {
            offset = CGPoint(x: -UIScreen.main.bounds.width, y: 0)
        }
        self.transform = CGAffineTransform(translationX: offset.x, y: offset.y)
        UIView.animate(withDuration: 0.6,
                       delay: 0.5,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 1,
                       options: .transitionCurlUp,
                       animations: {
            self.transform = .identity
            self.alpha = 1
        })
    }
    
    // MARK: - Button Actions
    
    /// Called when the plus icon is tapped. Triggers the corresponding callback.
    @objc func onPlusIconTapped(_ sender: UIButton) {
        onAddReactionIconTapped?()
    }
    
    /// Called when a reaction button is tapped. Triggers the corresponding callback with the selected reaction.
    @objc func onReactionTapped(_ sender: UIButton) {
        onReacted?(reactionList[safe: sender.tag])
    }
}



// MARK: - CometChatQuickReactions Extension
extension CometChatQuickReactions {
    
    /// Sets the list of reactions for the quick reactions view.
    /// - Parameter reactions: An array of strings representing the reactions (e.g., emojis).
    /// - Returns: The current instance of `CometChatQuickReactions` for method chaining.
    @discardableResult
    public func set(reactions: [String]) -> Self {
        self.reactionList = reactions
        return self
    }

    /// Sets the callback function to be triggered when a reaction is selected.
    /// - Parameter onReacted: A closure that takes an optional string (the selected reaction) as its parameter.
    /// - Returns: The current instance of `CometChatQuickReactions` for method chaining.
    @discardableResult
    public func set(onReacted: ((_ reaction: String?) -> Void)?) -> Self {
        self.onReacted = onReacted
        return self
    }
    
    /// Sets the callback function to be triggered when the add reaction icon is tapped.
    /// - Parameter onAddReactionIconTapped: A closure with no parameters.
    /// - Returns: The current instance of `CometChatQuickReactions` for method chaining.
    @discardableResult
    public func set(onAddReactionIconTapped: (() -> Void)?) -> Self {
        self.onAddReactionIconTapped = onAddReactionIconTapped
        return self
    }

    /// Sets the icon for adding a new reaction.
    /// - Parameter addReactionIcon: An optional `UIImage` to be used as the add reaction icon.
    /// - Returns: The current instance of `CometChatQuickReactions` for method chaining.
    @discardableResult
    public func set(addReactionIcon: UIImage?) -> Self {
        self.addReactionIcon = addReactionIcon
        return self
    }
    
    /// Sets multiple configuration options for the quick reactions view.
    /// - Parameter configuration: An optional `QuickReactionsConfiguration` object containing settings for the view.
    /// - Returns: The current instance of `CometChatQuickReactions` for method chaining.
    @discardableResult
    public func set(configuration: QuickReactionsConfiguration?) -> Self {
        
        // Apply configuration settings if provided
        if let configuration = configuration {
            if let reactionList = configuration.reactionList {
                self.set(reactions: reactionList)
            }
            
            if let addReactionIcon = configuration.addReactionIcon {
                set(addReactionIcon: addReactionIcon)
            }
            
            if let onReacted = configuration.onReacted {
                set(onReacted: onReacted)
            }
            
            if let onAddReactionIconTapped = configuration.onAddReactionIconTapped {
                set(onAddReactionIconTapped: onAddReactionIconTapped)
            }
        }
        
        return self
    }
}

