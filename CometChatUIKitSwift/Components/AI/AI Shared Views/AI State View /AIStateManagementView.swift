//
//  AIStateManagementView.swift
//  
//
//  Created by admin on 25/09/23.
//

import Foundation
import UIKit

class AIStateManagementView: UIStackView {
    
    let spinnerView = UIActivityIndicatorView()
    let mainLabel = UILabel()
    let firstSpacingView = UIView()
    let lastSpacingView = UIView()
    var iconImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {

        self.translatesAutoresizingMaskIntoConstraints = false
        self.spacing = 10
        self.layoutMargins = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 20)
        self.isLayoutMarginsRelativeArrangement = true
        self.backgroundColor = CometChatTheme_v4.palatte.background
                
        self.alignment = .center
        
        self.addArrangedSubview(firstSpacingView)
        
        spinnerView.startAnimating()
        self.addArrangedSubview(spinnerView)
        
        self.addArrangedSubview(mainLabel)
        self.addArrangedSubview(lastSpacingView)
        
        mainLabel.textColor = CometChatTheme_v4.palatte.accent700
        
    }
    
    @discardableResult
    public func setHeight(height: CGFloat) -> Self {
        self.heightAnchor.constraint(equalToConstant: height).isActive = true
        return self
    }
    
    @discardableResult
    public func setStackView(axis: NSLayoutConstraint.Axis) -> Self {
        self.self.axis = axis
        if axis == .horizontal {
            firstSpacingView.isHidden = true
        } else {
            self.spacing = 15
            firstSpacingView.isHidden = false
            lastSpacingView.isHidden = false
            spinnerView.style = .large
            self.distribution = .equalCentering
        }
        self.layoutIfNeeded()
        return self
    }
    
    @discardableResult
    public func setMainText(text: String) -> Self {
        self.mainLabel.text = text
        return self
    }
    
    @discardableResult
    public func setOnlySpinnerView() -> Self {
        self.mainLabel.isHidden = true
        self.firstSpacingView.isHidden = true
        self.lastSpacingView.isHidden = true
        return self
    }
    
    @discardableResult
    public func setIcon(icon: UIImage?, iconWidth: CGFloat? = nil, iconHeight: CGFloat? = nil) -> Self {
        
        self.arrangedSubviews.forEach { $0.removeFromSuperview() }
        self.addArrangedSubview(firstSpacingView)
        
        iconImageView.image = icon?.withRenderingMode(.alwaysTemplate)
        iconImageView.tintColor = CometChatTheme_v4.palatte.accent
        iconImageView.contentMode = .scaleAspectFit
        
        self.addArrangedSubview(iconImageView)
        iconImageView.widthAnchor.constraint(equalToConstant: iconWidth ?? 25).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: iconHeight ?? 25).isActive = true
        
        self.addArrangedSubview(mainLabel)
        self.addArrangedSubview(lastSpacingView)

        return self
        
    }
    
    @discardableResult
    public func setTextFont(font: UIFont) -> Self {
        self.mainLabel.font = font
        return self
    }
    
    @discardableResult
    public func setBorder(border: CGFloat) -> Self {
        self.borderWith(width: border)
        return self
    }
    
    @discardableResult
    public func setBorderRadius(radius: CometChatCornerStyle) -> Self {
        self.roundViewCorners(corner: radius)
        return self
    }
    
    @discardableResult
    public func setTextColor(color: UIColor) -> Self {
        self.mainLabel.textColor = color
        return self
    }
    
    @discardableResult
    public func setBackground(color: UIColor) -> Self {
        self.backgroundColor = color
        return self
    }
    
    @discardableResult
    public func set(iconTint: UIColor) -> Self {
        self.iconImageView.tintColor = iconTint
        return self
    }
    
    
    
    @discardableResult
    public func configurationForLoadingView(configuration: AIParentConfiguration?, style: AIParentStyle?) -> Self {
        
        if let style = style {
//            self.setTextFont(font: style.loadingViewTextFont)
//            self.setBorder(border: style.loadingViewBorder)
//            self.setBorderRadius(radius: style.loadingViewBorderRadius)
//            self.setTextColor(color: style.loadingViewTextColor)
//            self.setBackground(color: style.loadingViewBackgroundColor)
//            self.set(iconTint: style.loadingViewIconTint)
        }
        
        if let configuration = configuration {
            if let loadingIcon = configuration.loadingIcon {
                self.setIcon(icon: loadingIcon)
            }
        }
        
        return self
        
    }

    
    @discardableResult
    public func configurationForErrorView(configuration: AIParentConfiguration?, style: AIParentStyle?) -> Self {
        
        if let style = style {
//            self.setTextFont(font: style.errorViewTextFont)
//            self.setBorder(border: style.errorViewBorder)
//            self.setBorderRadius(radius: style.errorViewBorderRadius)
//            self.setTextColor(color: style.errorViewTextColor)
//            self.setBackground(color: style.errorViewBackgroundColor)
//            self.set(iconTint: style.errorViewIconTint)
        }
        
        if let configuration = configuration {
            if let errorIcon = configuration.errorIcon {
                self.setIcon(icon: errorIcon)
            }
        }
        
        return self
        
    }
    
    
    @discardableResult
    public func configurationForEmptyView(configuration: AIParentConfiguration?, style: AIParentStyle?) -> Self {
        
        if let style = style {
//            self.setTextFont(font: style.emptyViewTextFont)
//            self.setBorder(border: style.emptyViewBorder)
//            self.setBorderRadius(radius: style.emptyViewBorderRadius)
//            self.setTextColor(color: style.emptyViewTextColor)
//            self.setBackground(color: style.emptyViewBackgroundColor)
//            self.set(iconTint: style.errorViewIconTint)
        }
        
        if let configuration = configuration {
            if let errorIcon = configuration.errorIcon {
                self.setIcon(icon: errorIcon)
            }
        }
        
        return self
        
    }

    
}
