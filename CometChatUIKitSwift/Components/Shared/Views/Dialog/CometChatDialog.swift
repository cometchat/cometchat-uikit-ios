//
//  ShowAlert.swift
//  CometChatSwift
//
//  Created by Pushpsen Airekar on 02/02/21.
//  Copyright © 2021 MacMini-03. All rights reserved.
//

import Foundation
import UIKit
import CometChatSDK

public class CometChatDialog {
    
    private var title: String? = ""
    private var titleColor: UIColor? = .gray
    private var titleFont: UIFont? = CometChatTheme_v4.typography.text1
    private var messageText: String? = ""
    private var messageTextColor: UIColor? = .gray
    private var messageTextFont: UIFont?  = CometChatTheme_v4.typography.subtitle2
    private var confirmButtonText: String? = ""
    private var confirmButtonTextColor: UIColor? = CometChatTheme_v4.palatte.primary
    private var confirmButtonTextFont: UIFont? = CometChatTheme_v4.typography.text1
    private var cancelButtonText: String? = ""
    private var cancelButtonTextColor: UIColor? = CometChatTheme_v4.palatte.primary
    private var cancelButtonTextFont: UIFont? = CometChatTheme_v4.typography.text1
    
    public init() {}
    
    @discardableResult
    public func set(messageText: String) -> Self {
        self.messageText = messageText
        return self
    }
    
    @discardableResult
    public func set(messageColor: UIColor) -> Self {
        self.messageTextColor = messageColor
        return self
    }
    
    @discardableResult
    public func set(messageTextFont: UIFont) -> Self {
        self.messageTextFont = messageTextFont
        return self
    }
    
    @discardableResult
    public func set(title: String) -> Self {
        self.title = title
        return self
    }
    
    @discardableResult
    public func set(titleColor: UIColor) -> Self {
        self.titleColor = titleColor
        return self
    }
    
    @discardableResult
    public func set(titleFont: UIFont) -> Self {
        self.titleFont = titleFont
        return self
    }
    
    @discardableResult
    public func set(confirmButtonText: String) -> Self {
        self.confirmButtonText = confirmButtonText
        return self
    }
    
    @discardableResult
    public func set(confirmButtonTextColor: UIColor) -> Self {
        self.confirmButtonTextColor = confirmButtonTextColor
        return self
    }
    
    @discardableResult
    public func set(confirmButtonTextFont: UIFont) -> Self {
        self.confirmButtonTextFont = confirmButtonTextFont
        return self
    }
    
    @discardableResult
    public func set(cancelButtonText: String) -> Self {
        self.cancelButtonText = cancelButtonText
        return self
    }
    
    @discardableResult
    public func set(cancelButtonTextColor: UIColor) -> Self {
        self.cancelButtonTextColor = cancelButtonTextColor
        return self
    }
    
    @discardableResult
    public func set(cancelButtonTextFont: UIFont) -> Self {
        self.cancelButtonTextFont = cancelButtonTextFont
        return self
    }
    
    @discardableResult
    public func set(error: String) -> Self {
        set(messageText: error)
        return self
    }
    
    @discardableResult
    public func open(onConfirm: @escaping () -> (), onCancel: @escaping () -> ()) -> Self {
        // `self` is captured strongly on purpose: callers rarely keep the dialog, and a
        // weak capture let it be freed before the async block ran, so nothing appeared.
        DispatchQueue.main.async {
            let alert = self.makeAlert(onConfirm: onConfirm, onCancel: onCancel, skipEmptyButtons: false)
            CometChatDialog.topMostViewController()?.present(alert, animated: true)
        }
        return self
    }

    @discardableResult
    public func open(onConfirm: @escaping () -> ()) -> Self {
        DispatchQueue.main.async {
            let alert = self.makeAlert(onConfirm: onConfirm, onCancel: nil, skipEmptyButtons: true)
            CometChatDialog.topMostViewController()?.present(alert, animated: true)
        }
        return self
    }

    @discardableResult
    public func open() -> Self {
        DispatchQueue.main.async {
            let alert = self.makeAlert(onConfirm: nil, onCancel: nil, skipEmptyButtons: true)
            CometChatDialog.topMostViewController()?.present(alert, animated: true)
        }
        return self
    }

    /// Builds the styled alert every `open` variant presents.
    ///
    /// Styling limits of `UIAlertController`: the title and message colours and fonts are
    /// applied as attributed strings (through the controller's `attributedTitle` /
    /// `attributedMessage` keys, only when the running UIKit exposes them), and the button
    /// text colours per action (`confirmButtonTextColor`, `cancelButtonTextColor`, the latter
    /// falling back to the former) with the alert's tint as a fallback. Per-button fonts (`confirmButtonTextFont`, `cancelButtonTextFont`)
    /// cannot be styled on a `UIAlertController` without a custom view and are not applied.
    func makeAlert(onConfirm: (() -> ())?, onCancel: (() -> ())?, skipEmptyButtons: Bool) -> UIAlertController {
        let alert = UIAlertController(title: title, message: messageText, preferredStyle: .alert)

        let cancelText = cancelButtonText ?? ""
        let confirmText = confirmButtonText ?? ""
        let cancel = UIAlertAction(title: cancelText, style: .cancel) { _ in onCancel?() }
        let confirm = UIAlertAction(title: confirmText, style: .default) { _ in onConfirm?() }
        if !skipEmptyButtons || !cancelText.isEmpty {
            alert.addAction(cancel)
        }
        if !skipEmptyButtons || !confirmText.isEmpty {
            alert.addAction(confirm)
        }

        if let attributedTitle = CometChatDialog.attributed(title, color: titleColor, font: titleFont),
           CometChatDialog.supportsKey("attributedTitle", on: alert) {
            alert.setValue(attributedTitle, forKey: "attributedTitle")
        }
        if let attributedMessage = CometChatDialog.attributed(messageText, color: messageTextColor, font: messageTextFont),
           CometChatDialog.supportsKey("attributedMessage", on: alert) {
            alert.setValue(attributedMessage, forKey: "attributedMessage")
        }
        if let confirmButtonTextColor = confirmButtonTextColor {
            alert.view.tintColor = confirmButtonTextColor
        }
        // The alert's tint no longer reaches its buttons on newer iOS releases, so colour each
        // action directly when UIKit exposes the key — which also lets cancel differ from confirm.
        if let color = confirmButtonTextColor, CometChatDialog.supportsKey("titleTextColor", on: confirm) {
            confirm.setValue(color, forKey: "titleTextColor")
        }
        if let color = cancelButtonTextColor ?? confirmButtonTextColor, CometChatDialog.supportsKey("titleTextColor", on: cancel) {
            cancel.setValue(color, forKey: "titleTextColor")
        }
        return alert
    }

    /// The controller at the end of the key window's presentation chain, so the dialog shows
    /// whether or not something is already presented.
    static func topMostViewController() -> UIViewController? {
        let window = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
        var top = window?.rootViewController
        while let presented = top?.presentedViewController, !presented.isBeingDismissed {
            top = presented
        }
        return top
    }

    private static func attributed(_ text: String?, color: UIColor?, font: UIFont?) -> NSAttributedString? {
        guard let text = text, !text.isEmpty else { return nil }
        var attributes = [NSAttributedString.Key: Any]()
        if let color = color { attributes[.foregroundColor] = color }
        if let font = font { attributes[.font] = font }
        guard !attributes.isEmpty else { return nil }
        return NSAttributedString(string: text, attributes: attributes)
    }

    /// `setValue(_:forKey:)` raises an Objective-C exception for an unknown key, so the private
    /// alert keys are only written when the setter or backing ivar is actually there.
    static func supportsKey(_ key: String, on object: NSObject) -> Bool {
        let setter = "set" + key.prefix(1).uppercased() + key.dropFirst() + ":"
        if object.responds(to: NSSelectorFromString(setter)) { return true }
        return class_getInstanceVariable(type(of: object), "_" + key) != nil
    }
}

// TODO: - This class should be moved into other file.
final class CometChatServerError {
    
    static func get(error :CometChatException) -> String {
        let message = error.errorCode == "ERROR_INTERNET_UNAVAILABLE" ? "ERROR_INTERNET_UNAVAILABLE".localize() : "SOMETHING_WENT_WRONG_ERROR".localize()
        return message
    }
    
}
