//
//  CometChatErrorStateStyle.swift
//  CometChatUIKitSwift
//
//  Transient snack bar shown above the composer (e.g. "file size exceeded" when the
//  user taps a rejected attachment tile). Slides up from the anchor, auto-dismisses,
//  and carries a close button. Colors are style-driven; the default is the theme's
//  error red with white text.
//

import UIKit

/// Styling for transient error surfaces (the error snack bar shown above the
/// composer). Defaults to the theme's error red with white text.
public class CometChatErrorStateStyle {
    public var backgroundColor: UIColor = CometChatTheme.errorColor
    public var textColor: UIColor = .white
    public var textFont: UIFont = CometChatTypography.Caption1.medium
    public var closeIconTint: UIColor = .white
    public var cornerRadius: CGFloat = CometChatSpacing.Radius.r2

    public init() { }
}

public final class CometChatErrorState: UIView {

    /// Global default styling — override per app, or pass a style to `show`.
    public static var defaultStyle = CometChatErrorStateStyle()

    /// Seconds the bar stays on screen before auto-dismissing.
    public static var displayDuration: TimeInterval = 4

    private static weak var current: CometChatErrorState?

    private let messageLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    private var dismissTimer: Timer?

    /// Presents a snack bar pinned just above `anchor` (typically the composer) inside
    /// `container`. A bar already on screen is replaced.
    @discardableResult
    public static func show(message: String,
                            above anchor: UIView,
                            in container: UIView,
                            style: CometChatErrorStateStyle = CometChatErrorState.defaultStyle) -> CometChatErrorState {
        current?.dismiss(animated: false)

        let bar = CometChatErrorState()
        bar.apply(style: style)
        bar.messageLabel.text = message
        container.addSubview(bar)
        NSLayoutConstraint.activate([
            bar.leadingAnchor.constraint(equalTo: anchor.leadingAnchor, constant: CometChatSpacing.Padding.p2),
            bar.trailingAnchor.constraint(equalTo: anchor.trailingAnchor, constant: -CometChatSpacing.Padding.p2),
            bar.bottomAnchor.constraint(equalTo: anchor.topAnchor, constant: -CometChatSpacing.Padding.p2)
        ])
        current = bar

        // Default iOS-style entrance: rise from the anchor while fading in.
        bar.alpha = 0
        bar.transform = CGAffineTransform(translationX: 0, y: 12)
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut]) {
            bar.alpha = 1
            bar.transform = .identity
        }

        bar.dismissTimer = Timer.scheduledTimer(withTimeInterval: displayDuration, repeats: false) { [weak bar] _ in
            bar?.dismiss(animated: true)
        }
        return bar
    }

    private override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false

        messageLabel.numberOfLines = 2
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(messageLabel)

        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        addSubview(closeButton)

        NSLayoutConstraint.activate([
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: CometChatSpacing.Padding.p3),
            messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: CometChatSpacing.Padding.p3),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -CometChatSpacing.Padding.p3),
            messageLabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -CometChatSpacing.Padding.p2),

            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -CometChatSpacing.Padding.p3),
            closeButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 20),
            closeButton.heightAnchor.constraint(equalToConstant: 20)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func apply(style: CometChatErrorStateStyle) {
        backgroundColor = style.backgroundColor
        layer.cornerRadius = style.cornerRadius
        messageLabel.font = style.textFont
        messageLabel.textColor = style.textColor
        closeButton.tintColor = style.closeIconTint
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    public func dismiss(animated: Bool) {
        dismissTimer?.invalidate()
        dismissTimer = nil
        guard animated else {
            removeFromSuperview()
            return
        }
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
            self.transform = CGAffineTransform(translationX: 0, y: 12)
        }, completion: { _ in
            self.removeFromSuperview()
        })
    }

    deinit {
        dismissTimer?.invalidate()
    }
}
