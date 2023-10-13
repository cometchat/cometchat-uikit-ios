//
//  AIStateManagementView.swift
//  
//
//  Created by SuryanshBisen on 25/09/23.
//

import Foundation
import UIKit

class AIStateManagementView: UIStackView {
    
    let spinnerView = UIActivityIndicatorView()
    let mainLabel = UILabel()
    let firstSpacingView = UIView()
    let lastSpacingView = UIView()
    
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
        self.backgroundColor = CometChatTheme.palatte.background
                
        self.alignment = .center
        
        self.addArrangedSubview(firstSpacingView)
        
        spinnerView.startAnimating()
        self.addArrangedSubview(spinnerView)
        
        self.addArrangedSubview(mainLabel)
        self.addArrangedSubview(lastSpacingView)
        
        mainLabel.textColor = CometChatTheme.palatte.accent700
        
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
        
        icon?.withRenderingMode(.alwaysTemplate)
        let imageIcon = UIImageView(image: icon)
        
        imageIcon.contentMode = .scaleAspectFit
        imageIcon.tintColor = CometChatTheme.palatte.accent700
        
        self.addArrangedSubview(imageIcon)
        imageIcon.widthAnchor.constraint(equalToConstant: iconWidth ?? 25).isActive = true
        imageIcon.heightAnchor.constraint(equalToConstant: iconHeight ?? 25).isActive = true
        
        
        
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
    public func setBorderRadius(radius: CGFloat) -> Self {
        self.layer.cornerRadius = radius
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
    public func configurationForLoadingView(configuration: AIParentConfiguration?, style: AIParentRepliesStyle?) -> Self {
        
        if let style = style {
            
            if let textFont = style.loadingViewTextFont {
                self.setTextFont(font: textFont)
            }
            
            if let border = style.loadingViewBorder {
                self.setBorder(border: border)
            }
            
            if let borderRadius = style.loadingViewBorderRadius {
                self.setBorderRadius(radius: borderRadius)
            }
            
            if let textColour = style.loadingViewTextColor {
                self.setTextColor(color: textColour)
            }
            
            if let backgroundColor = style.loadingViewBackgroundColor {
                self.setBackground(color: backgroundColor)
            }
            
        }
        
        if let configuration = configuration {
            
            if let loadingIcon = configuration.loadingIcon {
                self.setIcon(icon: loadingIcon)
            }
            
        }
        
        return self
        
    }

    
    @discardableResult
    public func configurationForErrorView(configuration: AIParentConfiguration?, style: AIParentRepliesStyle?) -> Self {
        
        if let style = style {
            
            if let textFont = style.errorViewTextFont {
                self.setTextFont(font: textFont)
            }
            
            if let border = style.errorViewBorder {
                self.setBorder(border: border)
            }
            
            if let borderRadius = style.errorViewBorderRadius {
                self.setBorderRadius(radius: borderRadius)
            }
            
            if let textColour = style.errorViewTextColor {
                self.setTextColor(color: textColour)
            }
            
            if let backgroundColor = style.errorViewBackgroundColor {
                self.setBackground(color: backgroundColor)
            }
            
        }
        
        if let configuration = configuration {
            
            if let errorIcon = configuration.errorIcon {
                self.setIcon(icon: errorIcon)
            }
            
        }
        
        return self
        
    }
    
    
    @discardableResult
    public func configurationForEmptyView(configuration: AIParentConfiguration?, style: AIParentRepliesStyle?) -> Self {
        
        if let style = style {
            
            if let textFont = style.emptyViewTextFont {
                self.setTextFont(font: textFont)
            }
            
            if let border = style.emptyViewBorder {
                self.setBorder(border: border)
            }
            
            if let borderRadius = style.emptyViewBorderRadius {
                self.setBorderRadius(radius: borderRadius)
            }
            
            if let textColour = style.emptyViewTextColor {
                self.setTextColor(color: textColour)
            }
            
            if let backgroundColor = style.emptyViewBackgroundColor {
                self.setBackground(color: backgroundColor)
            }
        }
        
        if let configuration = configuration {
            
            if let errorIcon = configuration.errorIcon {
                self.setIcon(icon: errorIcon)
            }
            
        }
        
        return self
        
    }

    
}
