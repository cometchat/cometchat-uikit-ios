//
//  CometChatQuickView.swift
//  
//
//  Created by Abhishek Saralaya on 20/10/23.
//

import Foundation
import UIKit

public class CometChatQuickView: UIStackView {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var sideView : UIView!
    @IBOutlet weak var titleLabel : UILabel!
    @IBOutlet weak var subTitleLabel : UILabel!
    private let style = QuickViewStyle()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit(frame: CGRect(x: 0, y: 0, width: 300, height: 140))
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        customInit(frame: .zero)
    }
    
    func customInit(frame: CGRect) {
        CometChatUIKit.bundle.loadNibNamed("CometChatQuickView", owner: self, options: nil)
        addSubview(contentView)
        clipsToBounds = true
        contentView.backgroundColor = (self.traitCollection.userInterfaceStyle == .dark) ? .black : .white
        contentView.layer.cornerRadius = 5
        contentView.clipsToBounds = true
        sideView.layer.cornerRadius = 5
        set(title: "Interactive Message")
        set(subTitle: "Participant Information")
        set(titleFont: style.titleFont)
        set(titleColor: style.titleColor)
        set(subTitleFont: style.subtitleFont)
        set(subTitleColor: style.subtitleColor)
        set(leadingBarTint: style.leadingBarTint)
        set(leadingBarWidth: style.leadingBarWidth)
        
        NSLayoutConstraint.activate([
            sideView.heightAnchor.constraint(equalToConstant: 80),
            titleLabel.heightAnchor.constraint(equalToConstant: 30),
            subTitleLabel.heightAnchor.constraint(equalToConstant: 30),
            widthAnchor.constraint(equalToConstant: frame.width - 8),
            heightAnchor.constraint(equalToConstant: frame.height),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    @discardableResult
    public func set(title: String) -> Self {
        self.titleLabel.text = title
        return self
    }
    
    @discardableResult
    public func set(titleFont: UIFont) -> Self {
        self.titleLabel.font = titleFont
        return self
    }
    
    @discardableResult
    public func set(titleColor: UIColor) -> Self {
        self.titleLabel.textColor = titleColor
        return self
    }
    
    @discardableResult
    public func set(subTitle: String) -> Self {
        self.subTitleLabel.text = subTitle
        return self
    }
    
    @discardableResult
    public func set(subTitleFont: UIFont) -> Self {
        self.subTitleLabel.font = subTitleFont
        return self
    }
    
    @discardableResult
    public func set(subTitleColor: UIColor) -> Self {
        self.subTitleLabel.textColor = subTitleColor
        return self
    }
    
    @discardableResult
    public func set(leadingBarTint: UIColor) -> Self {
        self.sideView.backgroundColor = leadingBarTint
        return self
    }
    
    @discardableResult
    public func set(leadingBarWidth: CGFloat) -> Self {
        self.sideView.bounds.size.width = leadingBarWidth
        return self
    }
}
