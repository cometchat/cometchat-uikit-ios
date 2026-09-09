//
//  CometChatToast.swift
//  CometChatUIKitSwift
//

import Foundation
import UIKit

/// Transient, non-blocking confirmation. Unlike an alert it carries no title and
/// no action, so it must never be used to report something the user has to act on.
public class CometChatToast: UIView {

    public static var style = CometChatToastStyle()

    /// Only one toast is on screen at a time — a debounced toggle can emit several
    /// in a row, and stacked pills would cover the composer.
    private static weak var visibleToast: CometChatToast?

    private var dismissWorkItem: DispatchWorkItem?

    /// Internal rather than private so the component and snapshot suites can assert
    /// against the rendered text without reaching through the view hierarchy.
    internal lazy var label: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    /// Internal rather than private so the component and snapshot suites can host a
    /// real toast. `show(message:on:)` remains the only supported entry point: it
    /// owns placement, the single-visible-toast rule and dismissal.
    internal init(message: String, style: CometChatToastStyle) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        // The pill is decoration over the message list; swallowing touches would
        // block the composer underneath it.
        isUserInteractionEnabled = false
        backgroundColor = style.backgroundColor
        roundViewCorners(corner: style.cornerRadius)

        layer.shadowColor = style.shadowColor.cgColor
        layer.shadowOpacity = style.shadowOpacity
        layer.shadowOffset = style.shadowOffset
        layer.shadowRadius = style.shadowRadius

        label.text = message
        label.font = style.textFont
        label.textColor = style.textColor

        addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: style.verticalPadding),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -style.verticalPadding),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: style.horizontalPadding),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -style.horizontalPadding)
        ])

        isAccessibilityElement = true
        accessibilityLabel = message
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Shows `message` over `controller`'s view, above the keyboard/composer.
    /// Safe to call from any thread.
    public static func show(message: String,
                            on controller: UIViewController?,
                            duration: TimeInterval = 3,
                            style: CometChatToastStyle = CometChatToast.style) {
        guard !message.isEmpty else { return }

        DispatchQueue.main.async {
            guard let host = controller?.view else { return }

            visibleToast?.dismiss()

            let toast = CometChatToast(message: message, style: style)
            toast.alpha = 0
            host.addSubview(toast)
            visibleToast = toast

            NSLayoutConstraint.activate([
                toast.centerXAnchor.constraint(equalTo: host.centerXAnchor),
                // Sits above the composer, which is pinned to the keyboard layout guide.
                toast.bottomAnchor.constraint(equalTo: host.keyboardLayoutGuide.topAnchor,
                                              constant: -CometChatSpacing.Padding.p4),
                toast.leadingAnchor.constraint(greaterThanOrEqualTo: host.leadingAnchor,
                                               constant: CometChatSpacing.Padding.p4),
                toast.trailingAnchor.constraint(lessThanOrEqualTo: host.trailingAnchor,
                                                constant: -CometChatSpacing.Padding.p4),
                // Hug width from the design; the edge insets above win on narrow screens.
                toast.widthAnchor.constraint(lessThanOrEqualToConstant: 256)
            ])

            UIView.animate(withDuration: 0.25) { toast.alpha = 1 }

            UIAccessibility.post(notification: .announcement, argument: message)

            let work = DispatchWorkItem { [weak toast] in toast?.dismiss() }
            toast.dismissWorkItem = work
            DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: work)
        }
    }

    private func dismiss() {
        dismissWorkItem?.cancel()
        dismissWorkItem = nil
        UIView.animate(withDuration: 0.25, animations: { self.alpha = 0 }) { _ in
            self.removeFromSuperview()
        }
    }
}
