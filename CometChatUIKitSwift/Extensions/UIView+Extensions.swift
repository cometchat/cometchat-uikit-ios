//
//  UIView+Extensions.swift
//  CometChatUIKitSwift
//
//  Created by Suryansh on 02/09/24.
//

import Foundation
import UIKit

extension UIView {
    
    // MARK: - `embed` family of helpers
    func embed(_ subview: UIView, insets: NSDirectionalEdgeInsets = .zero) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subview)

        NSLayoutConstraint.activate([
            subview.leadingAnchor.pin(equalTo: leadingAnchor, constant: insets.leading),
            subview.trailingAnchor.pin(equalTo: trailingAnchor, constant: -insets.trailing),
            subview.topAnchor.pin(equalTo: topAnchor, constant: insets.top),
            subview.bottomAnchor.pin(equalTo: bottomAnchor, constant: -insets.bottom)
        ])
    }

    func pin(anchors: [LayoutAnchorName] = [.top, .leading, .bottom, .trailing], to view: UIView) {
        anchors
            .map { $0.makeConstraint(fromView: self, toView: view) }
            .forEach { $0.isActive = true }
    }
    

    func pin(anchors: [LayoutAnchorName] = [.top, .leading, .bottom, .trailing], to view: UIView, with constant: CGFloat = 0) {
        anchors
            .map { $0.makeConstraint(fromView: self, toView: view, constant: constant) }
            .forEach { $0.isActive = true }
    }

    func pin(anchors: [LayoutAnchorName] = [.top, .leading, .bottom, .trailing], to layoutGuide: UILayoutGuide) {
        anchors
            .compactMap { $0.makeConstraint(fromView: self, toLayoutGuide: layoutGuide) }
            .forEach { $0.isActive = true }
    }

    func pin(anchors: [LayoutAnchorName] = [.width, .height], to constant: CGFloat) {
        anchors
            .compactMap { $0.makeConstraint(fromView: self, constant: constant) }
            .forEach { $0.isActive = true }
    }
    
    
    @discardableResult
    func withoutAutoresizingMaskConstraints() -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        return self
    }

    @discardableResult
    func withAccessibilityIdentifier(identifier: String) -> Self {
        accessibilityIdentifier = identifier
        return self
    }

    /// Returns `UIView` that is flexible along defined `axis`.
    static func spacer(axis: NSLayoutConstraint.Axis) -> UIView {
        UIView().flexible(axis: axis)
    }
    
    func flexible(axis: NSLayoutConstraint.Axis) -> Self {
        setContentHuggingPriority(.lowest, for: axis)
        return self
    }
}

extension UILayoutPriority {
    static let lowest = UILayoutPriority(defaultLow.rawValue / 2.0)
}

enum LayoutAnchorName {
    case bottom
    case centerX
    case centerY
    case firstBaseline
    case height
    case lastBaseline
    case leading
    case left
    case right
    case top
    case trailing
    case width

    func makeConstraint(fromView: UIView, toView: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
        switch self {
        case .bottom:
            return fromView.bottomAnchor.pin(equalTo: toView.bottomAnchor, constant: constant)
        case .centerX:
            return fromView.centerXAnchor.pin(equalTo: toView.centerXAnchor, constant: constant)
        case .centerY:
            return fromView.centerYAnchor.pin(equalTo: toView.centerYAnchor, constant: constant)
        case .firstBaseline:
            return fromView.firstBaselineAnchor.pin(equalTo: toView.firstBaselineAnchor, constant: constant)
        case .height:
            return fromView.heightAnchor.pin(equalTo: toView.heightAnchor, constant: constant)
        case .lastBaseline:
            return fromView.lastBaselineAnchor.pin(equalTo: toView.lastBaselineAnchor, constant: constant)
        case .leading:
            return fromView.leadingAnchor.pin(equalTo: toView.leadingAnchor, constant: constant)
        case .left:
            return fromView.leftAnchor.pin(equalTo: toView.leftAnchor, constant: constant)
        case .right:
            return fromView.rightAnchor.pin(equalTo: toView.rightAnchor, constant: constant)
        case .top:
            return fromView.topAnchor.pin(equalTo: toView.topAnchor, constant: constant)
        case .trailing:
            return fromView.trailingAnchor.pin(equalTo: toView.trailingAnchor, constant: constant)
        case .width:
            return fromView.widthAnchor.pin(equalTo: toView.widthAnchor, constant: constant)
        }
    }

    func makeConstraint(fromView: UIView, toLayoutGuide: UILayoutGuide, constant: CGFloat = 0) -> NSLayoutConstraint? {
        switch self {
        case .bottom:
            return fromView.bottomAnchor.pin(equalTo: toLayoutGuide.bottomAnchor, constant: constant)
        case .centerX:
            return fromView.centerXAnchor.pin(equalTo: toLayoutGuide.centerXAnchor, constant: constant)
        case .centerY:
            return fromView.centerYAnchor.pin(equalTo: toLayoutGuide.centerYAnchor, constant: constant)
        case .height:
            return fromView.heightAnchor.pin(equalTo: toLayoutGuide.heightAnchor, constant: constant)
        case .leading:
            return fromView.leadingAnchor.pin(equalTo: toLayoutGuide.leadingAnchor, constant: constant)
        case .left:
            return fromView.leftAnchor.pin(equalTo: toLayoutGuide.leftAnchor, constant: constant)
        case .right:
            return fromView.rightAnchor.pin(equalTo: toLayoutGuide.rightAnchor, constant: constant)
        case .top:
            return fromView.topAnchor.pin(equalTo: toLayoutGuide.topAnchor, constant: constant)
        case .trailing:
            return fromView.trailingAnchor.pin(equalTo: toLayoutGuide.trailingAnchor, constant: constant)
        case .width:
            return fromView.widthAnchor.pin(equalTo: toLayoutGuide.widthAnchor, constant: constant)
        case .firstBaseline, .lastBaseline:
            // TODO: Log warning? Error?
            return nil
        }
    }

    func makeConstraint(fromView: UIView, constant: CGFloat) -> NSLayoutConstraint? {
        switch self {
        case .height:
            return fromView.heightAnchor.pin(equalToConstant: constant)
        case .width:
            return fromView.widthAnchor.pin(equalToConstant: constant)
        default:
            // TODO: Log warning? Error?
            return nil
        }
    }
}

extension UIView {
    /// According to this property, you can differ whether the current language is `rightToLeft`
    /// and setup actions according to it.
    var currentLanguageIsRightToLeftDirection: Bool {
        traitCollection.layoutDirection == .rightToLeft
    }
}


//MARK: - Simmer Extention
extension UIView {
    
    func addGradientLayer(gradientColorOne: UIColor, gradientColorTwo: UIColor, size: CGSize) -> CAGradientLayer {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.colors = [gradientColorOne.cgColor, gradientColorTwo.cgColor, gradientColorOne.cgColor]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        self.layer.addSublayer(gradientLayer)
        
        return gradientLayer
    }
    
    func startAnimating(animation: CABasicAnimation, gradientColorOne: UIColor, gradientColorTwo: UIColor, size: CGSize) {
        
        let gradientLayer = addGradientLayer(gradientColorOne: gradientColorOne, gradientColorTwo: gradientColorTwo, size: size)
        gradientLayer.add(animation, forKey: animation.keyPath)
    }

}

var animation: CABasicAnimation = {
    let animation = CABasicAnimation(keyPath: "locations")
    animation.fromValue = [-1.0, -0.5, 0.0]
    animation.toValue = [1.0, 1.5, 2.0]
    animation.repeatCount = .infinity
    animation.duration = 0.9
    return animation
}()
extension UIView {
    func applyCornerRadiusAndShadow(cornerRadius: CGFloat,
                                    shadowColor: UIColor = .black,
                                    shadowOpacity: Float = 0.1,
                                    shadowOffset: CGSize = .init(width: 1, height: 1),
                                    shadowRadius: CGFloat = 10.0) {
        // Apply corner radius
        layer.cornerRadius = cornerRadius
        
        // Keep content inside the corners, but allow shadow to be outside
        layer.masksToBounds = false
        
        // Configure the shadow
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowOffset = shadowOffset
        layer.shadowRadius = shadowRadius
    }
}

extension UIView {
    func setBackground(image: UIImage?) {
        if let image = image {
            let backgroundImageView = UIImageView(image: image)
            backgroundImageView.frame = self.bounds
            backgroundImageView.contentMode = .scaleAspectFill // Adjust as needed
            
            self.addSubview(backgroundImageView)
            self.sendSubviewToBack(backgroundImageView)
        }
    }
}
