//
//  LimitedFormatterView.swift
//  CometChatUIKitSwift
//
//  Created by SuryanshBisen on 10/03/24.
//

import UIKit
import Foundation

class LimitedFormatterView: UIView {
    
    var iconImg = UIImage(named: "messages-info", in: CometChatUIKit.bundle, with: nil)?.withRenderingMode(.alwaysTemplate)
    var icon = UIImageView()
    let infoLabel = UILabel()
    let dividerView = UIView()
    let containerStackView = UIStackView()
    
    init() {
        super.init(frame: .zero)
        buildUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buildUI() {
        
        dividerView.backgroundColor = CometChatTheme_v4.palatte.accent900
        addSubview(dividerView)
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        dividerView.heightAnchor.constraint(equalToConstant: 0.2).isActive = true
        dividerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        dividerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        dividerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        containerStackView.axis = .horizontal
        containerStackView.spacing = 10
        containerStackView.alignment = .leading
        containerStackView.distribution = .fillProportionally
        
        icon = UIImageView(image: iconImg)
        icon.tintColor = CometChatTheme_v4.palatte.accent700
        icon.translatesAutoresizingMaskIntoConstraints = false
        containerStackView.addArrangedSubview(icon)
        
        
        infoLabel.text = "MENTION_LIMIT_TEXT".localize()
        infoLabel.font = CometChatTheme_v4.typography.text1
        infoLabel.textColor = CometChatTheme_v4.palatte.accent700
        containerStackView.addArrangedSubview(infoLabel)
        
        addSubview(containerStackView)
        containerStackView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 3).isActive = true
        containerStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15).isActive = true
        containerStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15).isActive = true
        
        heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
}
