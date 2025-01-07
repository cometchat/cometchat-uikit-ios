//
//  CometChatNewMessageIndicator.swift
//  
//
//  Created by admin on 15/09/22.
//

import UIKit
import CometChatSDK

public class CometChatNewMessageIndicator: UIStackView {
    
    //MARK: - Declaration of Outlets
    public lazy var title: UILabel = {
        var title = UILabel().withoutAutoresizingMaskConstraints()
        title.pin(anchors: [.height, .width], to: 20)
        title.textAlignment = .center
        title.isHidden = true
        return title
    }()
    
    public lazy var iconImageView: UIImageView = {
        var image = UIImageView().withoutAutoresizingMaskConstraints()
        image.image = style.iconImage
        image.pin(anchors: [.height, .width], to: 24)
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    private var customTitle: String?

    public static var style = NewMessageIndicatorStyle()
    public  var style = NewMessageIndicatorStyle()
    private var count: Int = 0
    @objc var onClick: (() -> Void)?
    var getCount: Int {
        get {
            return count
        }
    }
    
    @discardableResult
    public func set(count : Int) -> Self {
        self.count = count
        self.title.text = "\(count)"
        return self
    }
    
    @discardableResult
    public func incrementCount() -> Self {
        let currentCount = self.getCount
        self.set(count: currentCount + 1)
        
        if title.isHidden == true {
            iconImageView.removeFromSuperview()
            addArrangedSubview(title)
            addArrangedSubview(iconImageView)
            self.title.isHidden = false
            super.layoutSubviews()
        }
       return self
    }
    
    @discardableResult
    public func reset() -> Self {
        self.title.isHidden = true
        self.title.removeFromSuperview()
        self.count = 0
        return self
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        title.roundViewCorners(corner: .init(cornerRadius: 9))
        roundViewCorners(corner: .init(cornerRadius: bounds.width/2)) //rounded corner
    }
    
    public override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview != nil {
            setupStyle()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func setupStyle() {
        if let cornerRadius = style.cornerRadius {
            roundViewCorners(corner: cornerRadius)
        }
        backgroundColor = style.backgroundColor
        borderWith(width: style.borderWidth)
        borderColor(color: style.borderColor)
        title.backgroundColor = style.textBackgroundColor
        title.textColor = style.textColor
        title.font = style.textFont
        iconImageView.image = style.iconImage
        iconImageView.tintColor = style.imageTint
    }
    
    open func buildUI() {
        
        withoutAutoresizingMaskConstraints()
        pin(anchors: [.height, .width], to: 32)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTap)))
        
        axis = .vertical
        spacing = 4
        distribution = .fill
        alignment = .center
        isLayoutMarginsRelativeArrangement = true
        layoutMargins = UIEdgeInsets(
            top: CometChatSpacing.Padding.p2,
            left: CometChatSpacing.Padding.p2,
            bottom: CometChatSpacing.Padding.p2,
            right: CometChatSpacing.Padding.p2
        )
        
        addArrangedSubview(iconImageView)
        
        reset()
        handleThemeModeChange()
    }
    
    open func handleThemeModeChange() {
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self], handler: { (self: Self, previousTraitCollection: UITraitCollection) in
                self.setupStyle()
            })
        }
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        // Check if the user interface style has changed
        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            self.setupStyle()
        }
    }
    
    @objc func onTap() {
        onClick?()
    }

}
