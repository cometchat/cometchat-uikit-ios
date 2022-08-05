//
//  ShowAlert.swift
//  CometChatSwift
//
//  Created by Pushpsen Airekar on 02/02/21.
//  Copyright © 2021 MacMini-03. All rights reserved.
//

import Foundation
import UIKit
import CometChatPro

public class CometChatDialog {
    
    private var title: String? = ""
    private var titleColor: UIColor? = .gray
    private var titleFont: UIFont? = CometChatTheme.typography?.Name2
    private var messageText: String? = ""
    private var messageTextColor: UIColor? = .gray
    private var messageTextFont: UIFont?  = CometChatTheme.typography?.Subtitle2
    private var confirmButtonText: String? = ""
    private var confirmButtonTextColor: UIColor? = CometChatTheme.palatte?.primary
    private var confirmButtonTextFont: UIFont? = CometChatTheme.typography?.Body
    private var cancelButtonText: String? = ""
    private var cancelButtonTextColor: UIColor? = CometChatTheme.palatte?.primary
    private var cancelButtonTextFont: UIFont? = CometChatTheme.typography?.Body
    
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
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            let alert = UIAlertController(title: strongSelf.title, message: strongSelf.messageText, preferredStyle: .alert)
            let cancel = UIAlertAction(title: strongSelf.cancelButtonText, style: .cancel) { cancel in
            onCancel()
        }
            let tryAgain = UIAlertAction(title: strongSelf.confirmButtonText, style: .default) { tryAgain in
            onConfirm()
        }
        alert.addAction(cancel)
        alert.addAction(tryAgain)
        
        
        if let window = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).flatMap({$0.windows }).first(where: { $0.isKeyWindow }) {
            window.rootViewController?.presentedViewController?.present(alert, animated: true)
        }
        }
        return self
    }
    
    @discardableResult
    public func open(onConfirm: @escaping () -> ()) -> Self {
            let alert = UIAlertController(title: title, message: messageText, preferredStyle: .alert)
            let cancel = UIAlertAction(title: cancelButtonText, style: .cancel) { _ in}
            let tryAgain = UIAlertAction(title: confirmButtonText, style: .default) { tryAgain in
            onConfirm()
        }
            if !cancelButtonText!.isEmpty {
            alert.addAction(cancel)
        }
            if !confirmButtonText!.isEmpty {
            alert.addAction(tryAgain)
        }
        if let window = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).flatMap({$0.windows }).first(where: { $0.isKeyWindow }) {
            window.rootViewController?.presentedViewController?.present(alert, animated: true)
        }
        return self
    }
    
    @discardableResult
    public func open() -> Self {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            let alert = UIAlertController(title: strongSelf.title, message: strongSelf.messageText, preferredStyle: .alert)
            let cancel = UIAlertAction(title: strongSelf.cancelButtonText, style: .cancel) { _ in}
            let tryAgain = UIAlertAction(title: strongSelf.confirmButtonText, style: .default) { _ in }
            if !strongSelf.cancelButtonText!.isEmpty {
            alert.addAction(cancel)
        }
            if !strongSelf.confirmButtonText!.isEmpty {
            alert.addAction(tryAgain)
        }
        if let window = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).flatMap({$0.windows }).first(where: { $0.isKeyWindow }) {
            window.rootViewController?.presentedViewController?.present(alert, animated: true)
        }
        }
        return self
    }
}

// TODO: - This class should be moved into other file.
final class CometChatServerError {
    
    static func get(error :CometChatException) -> String {
        let message = error.errorCode == "ERROR_INTERNET_UNAVAILABLE" ? "ERROR_INTERNET_UNAVAILABLE".localize() : "SOMETHING_WENT_WRONG_ERROR".localize()
        return message
    }
    
}
