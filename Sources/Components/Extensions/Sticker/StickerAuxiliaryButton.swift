//
//  File.swift
//  
//
//  Created by Pushpsen Airekar on 16/02/23.
//

import Foundation
import UIKit

public class StickerAuxiliaryButton: UIStackView {
    
    var stickerButtonIcon: UIImage = UIImage(named: "sticker", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    var keyboardButtonIcon: UIImage = UIImage(named: "keyboard", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    var onStickerTap:(() -> Void)?
    var onKeyboardTap:(() -> Void)?
    private var imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        customInit()
        fatalError("init(coder:) has not been implemented")
    }
    
    init(stickerButtonIcon: UIImage? = nil, keyboardButtonIcon: UIImage? = nil, onStickerTap: (() -> Void)? = nil, onKeyboardTap: ( () -> Void)? = nil) {
        super.init(frame: CGRect(x: 0, y: 0, width: 30, height: 25))
        self.stickerButtonIcon = stickerButtonIcon ?? self.stickerButtonIcon
        self.keyboardButtonIcon = keyboardButtonIcon ?? self.keyboardButtonIcon
        self.onStickerTap = onStickerTap
        self.onKeyboardTap = onKeyboardTap
        
    }
    
    fileprivate func customInit() {
        imageView.image = stickerButtonIcon
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = CometChatTheme.palatte.accent700
        self.addArrangedSubview(imageView)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onPressed))
        tapGesture.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapGesture)
        self.isUserInteractionEnabled = true
    }
    
    @objc func onPressed() {
        if imageView.image == stickerButtonIcon {
            self.imageView.image = keyboardButtonIcon
            onStickerTap?()
        }else if imageView.image == keyboardButtonIcon {
            self.imageView.image = stickerButtonIcon
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
