//
//  File.swift
//  
//
//  Created by Pushpsen Airekar on 16/02/23.
//

import Foundation
import UIKit

public class StickerAuxiliaryButton: UIButton {
    
    var stickerButtonIcon: UIImage = UIImage(named: "sticker-image", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    var keyboardButtonIcon: UIImage = UIImage(named: "sticker-image-filled", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    var onStickerTap:(() -> Void)?
    var onKeyboardTap:(() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    init(stickerButtonIcon: UIImage? = nil, keyboardButtonIcon: UIImage? = nil, onStickerTap: (() -> Void)? = nil, onKeyboardTap: ( () -> Void)? = nil) {
        super.init(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        self.stickerButtonIcon = stickerButtonIcon ?? self.stickerButtonIcon
        self.keyboardButtonIcon = keyboardButtonIcon ?? self.keyboardButtonIcon
        self.onStickerTap = onStickerTap
        self.onKeyboardTap = onKeyboardTap
    }
    
    @objc func keyBoardWillShow(notification: NSNotification) {
        self.imageView?.tintColor = CometChatTheme.iconColorSecondary
        self.setImage(stickerButtonIcon, for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        print("deinit for StickerAuxiliaryButton called")
    }
    
    fileprivate func customInit() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        self.setImage(stickerButtonIcon, for: .normal)
        imageView?.contentMode = .scaleAspectFit
        imageView?.tintColor = CometChatTheme_v4.palatte.accent700
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onPressed))
        tapGesture.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapGesture)
        self.isUserInteractionEnabled = true
    }
    
    @objc func onPressed() {
        if imageView?.image == stickerButtonIcon {
            self.setImage(keyboardButtonIcon, for: .normal)
            self.imageView?.tintColor = CometChatTheme.primaryColor
            onStickerTap?()
        }else if imageView?.image == keyboardButtonIcon {
            self.imageView?.tintColor = CometChatTheme.iconColorSecondary
            self.setImage(stickerButtonIcon, for: .normal)
            onKeyboardTap?()
        }
    }
    
    @discardableResult
    public func setOnStickerTap(onStickerTap: @escaping () -> Void) -> Self {
        self.onStickerTap = onStickerTap
        return self
    }
    
    @discardableResult
    public func setOnKeyboardTap(onKeyboardTap: @escaping () -> Void) -> Self {
        self.onKeyboardTap = onKeyboardTap
        return self
    }
}
