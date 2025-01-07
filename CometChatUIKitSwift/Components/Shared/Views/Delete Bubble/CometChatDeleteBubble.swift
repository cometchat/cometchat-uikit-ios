//
// DeleteMessage.swift
//
// Created by Abdullah Ansari on 25/05/22.
//
import Foundation
import UIKit
import CometChatSDK

/// A custom view that represents a "Message Deleted" bubble in the CometChat messaging interface.
/// This bubble displays a message and an icon indicating that a message was deleted.
public class CometChatDeleteBubble: UIView {
    
    /// The style configuration for the delete bubble, allowing customization of its appearance.
    public var style = DeleteBubbleStyle()
    public var messageText = "MESSAGE_WAS_DELETED".localize() {
        didSet {
            set(text: messageText) // Setting the default localized text for deleted message.
        }
    }
    
    /// A horizontal stack view that contains the deleted message icon and the label showing the deletion message.
    lazy var containerView : UIStackView = {
        let view = UIStackView().withoutAutoresizingMaskConstraints()
        view.axis = .horizontal
        view.distribution = .fillProportionally
        view.alignment = .center
        view.spacing = CometChatSpacing.Spacing.s1
        return view
    }()
    
    /// A label that displays the message indicating the deletion of a message. It uses `HyperlinkLabel` to support clickable links if required.
    lazy var message : UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints()
        label.text = messageText
        return label
    }()
    
    /// An image view that displays the "message deleted" icon, which is set to a template rendering mode for customizable tinting.
    lazy var deleteImage : UIImageView = {
        let imageView = UIImageView().withoutAutoresizingMaskConstraints()
        imageView.image = UIImage(named: "message-deleted", in: CometChatUIKit.bundle, with: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
        return imageView
    }()
    
    // MARK: - Initializers
    
    /// Initializes the `CometChatDeleteBubble` with a frame.
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
    }
    
    /// A required initializer when initializing from a storyboard or nib file.
    /// This implementation throws an error, as the class does not support initialization via Interface Builder.
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// This method is called when the view is about to be added to a window.
    /// It applies the styles to the bubble when the view is about to be shown.
    /// - Parameter newWindow: The window to which the view is being added.
    public override func willMove(toWindow newWindow: UIWindow?) {
        if newWindow != nil {
            setupStyle()
        }
    }
    
    // MARK: - Private Methods
    
    /// Builds the user interface for the delete bubble by adding and configuring its subviews.
    private func buildUI() {
        self.embed(
            containerView,
            insets: .init(
                top: CometChatSpacing.Padding.p2,
                leading: CometChatSpacing.Padding.p2,
                bottom: 0,
                trailing: CometChatSpacing.Padding.p2
            )
        )
        
        containerView.addArrangedSubview(deleteImage)
        containerView.addArrangedSubview(message)
        
        deleteImage.pin(anchors: [.height, .width], to: 16) // Setting a fixed size for the delete image.
    }
    
    /// Applies the current style to the delete bubble, including the text and image styling.
    private func setupStyle() {
        message.textColor = style.textColor // Applying the text color from the style.
        message.font = style.textFont // Applying the text font from the style.
        deleteImage.tintColor = style.deleteImageTintColor // Applying the tint color for the delete image.
    }
    
    // MARK: - Public Methods
    
    /// Sets the message to be displayed in the delete bubble.
    /// - Parameter text: The message text to be shown in the bubble.
    /// - Returns: The `CometChatDeleteBubble` instance for chaining.
    @discardableResult
    @objc public func set(text: String) -> Self {
        self.message.text = text
        return self
    }
}
