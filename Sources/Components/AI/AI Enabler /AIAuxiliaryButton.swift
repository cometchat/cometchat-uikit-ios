//
//  AIAuxiliaryButton.swift
//  
//
//  Created by SuryanshBisen on 12/09/23.
//

import Foundation
import UIKit

public class AIAuxiliaryButton: UIStackView {
    
    var aiButtonIcon: UIImage = UIImage(named: "ai-auxiliary", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    var onAITap:(() -> Void)?
    var configurationCallBack: (() -> Void)?
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
    
    init(aiButtonIcon: UIImage? = nil, onAITap: (() -> Void)? = nil) {
        super.init(frame: CGRect(x: 0, y: 0, width: 30, height: 25))
        self.aiButtonIcon = aiButtonIcon ?? self.aiButtonIcon
        self.onAITap = onAITap
        
    }
    
    fileprivate func customInit() {
        self.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
        self.isLayoutMarginsRelativeArrangement = true
        self.widthAnchor.constraint(equalToConstant: 40).isActive = true

        imageView.image = aiButtonIcon
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = CometChatTheme.palatte.accent700
        self.addArrangedSubview(imageView)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onPressed))
        tapGesture.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapGesture)
        self.isUserInteractionEnabled = true
    }
    
    @objc func onPressed() {
        onAITap?()
        configurationCallBack?()
    }
    
    @objc func buildFromConfiguration(configuration: AIEnablerConfiguration?){
        if let backgroundColour = configuration?.style?.auxiliaryButtonTintColour {
            self.setTintColour(tintColour: backgroundColour)
        }
        
        if let icon = configuration?.auxiliaryButtonIcon {
            self.setButtonIcon(icon: icon)
        }
    }
    
    @discardableResult
    public func setOnAIButtonTap(onAITap: @escaping () -> Void) -> Self {
        self.onAITap = onAITap
        return self
    }
    
    @discardableResult
    public func setButtonIcon(icon: UIImage) -> Self {
        self.imageView.image = icon
        return self
    }
    
    @discardableResult
    public func setTintColour(tintColour: UIColor) -> Self {
        self.imageView.tintColor = tintColour
        return self
    }
    
    @discardableResult
    public func setBackgroundColour(colour: UIColor) -> Self {
        self.backgroundColor = colour
        return self
    }
    

}
