//
//  ViewTransformation.swift
//  CometChatSwift
//
//  Created by Pushpsen Airekar on 02/02/21.
//  Copyright © 2021 MacMini-03. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func roundViewCorners(corner: CometChatCornerStyle) {
        
        var maskedCorners: CACornerMask = .init()
        
        if corner.topLeft {
            maskedCorners.insert(.layerMinXMinYCorner)
        }
        if corner.topRight {
            maskedCorners.insert(.layerMaxXMinYCorner)
        }
        if corner.bottomRight {
            maskedCorners.insert(.layerMaxXMaxYCorner)
        }
        if corner.bottomLeft {
            maskedCorners.insert(.layerMinXMaxYCorner)
        }
        
        if !corner.topLeft && !corner.topLeft && !corner.bottomRight && !corner.bottomLeft {
            maskedCorners.insert(.layerMinXMinYCorner)
            maskedCorners.insert(.layerMaxXMinYCorner)
            maskedCorners.insert(.layerMaxXMaxYCorner)
            maskedCorners.insert(.layerMinXMaxYCorner)
        }
        self.layer.masksToBounds = true
        self.layer.maskedCorners = maskedCorners
        self.layer.cornerRadius = corner.cornerRadius
    }
    
    func borderWith(width: CGFloat) {
        self.layer.borderWidth = width
    }
    
    func borderColor(color: UIColor) {
        self.layer.borderColor = color.cgColor
    }
    
    func backgroundColor(color: UIColor) {
        self.backgroundColor = color
    }
    
}

extension UIView {

    func makeCustomRound(topLeft: CGFloat = 0, topRight: CGFloat = 0, bottomLeft: CGFloat = 0, bottomRight: CGFloat = 0) {
        let minX = bounds.minX
        let minY = bounds.minY
        let maxX = bounds.maxX
        let maxY = bounds.maxY

        let path = UIBezierPath()
        path.move(to: CGPoint(x: minX + topLeft, y: minY))
        path.addLine(to: CGPoint(x: maxX - topRight, y: minY))
        path.addArc(withCenter: CGPoint(x: maxX - topRight, y: minY + topRight), radius: topRight, startAngle:CGFloat(3 * Double.pi / 2), endAngle: 0, clockwise: true)
        path.addLine(to: CGPoint(x: maxX, y: maxY - bottomRight))
        path.addArc(withCenter: CGPoint(x: maxX - bottomRight, y: maxY - bottomRight), radius: bottomRight, startAngle: 0, endAngle: CGFloat(Double.pi / 2), clockwise: true)
        path.addLine(to: CGPoint(x: minX + bottomLeft, y: maxY))
        path.addArc(withCenter: CGPoint(x: minX + bottomLeft, y: maxY - bottomLeft), radius: bottomLeft, startAngle: CGFloat(Double.pi / 2), endAngle: CGFloat(Double.pi), clockwise: true)
        path.addLine(to: CGPoint(x: minX, y: minY + topLeft))
        path.addArc(withCenter: CGPoint(x: minX + topLeft, y: minY + topLeft), radius: topLeft, startAngle: CGFloat(Double.pi), endAngle: CGFloat(3 * Double.pi / 2), clockwise: true)
        path.close()

        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}


extension UIView{
    func roundCorners(topLeft: CGFloat, topRight: CGFloat, bottomLeft: CGFloat, bottomRight: CGFloat) {//(topLeft: CGFloat, topRight: CGFloat, bottomLeft: CGFloat, bottomRight: CGFloat) {
        let topLeftRadius = CGSize(width: topLeft, height: topLeft)
        let topRightRadius = CGSize(width: topRight, height: topRight)
        let bottomLeftRadius = CGSize(width: bottomLeft, height: bottomLeft)
        let bottomRightRadius = CGSize(width: bottomRight, height: bottomRight)
        let maskPath = UIBezierPath(shouldRoundRect: bounds, topLeftRadius: topLeftRadius, topRightRadius: topRightRadius, bottomLeftRadius: bottomLeftRadius, bottomRightRadius: bottomRightRadius)
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        layer.mask = shape
    }
}

extension UIBezierPath {
    convenience init(shouldRoundRect rect: CGRect, topLeftRadius: CGSize = .zero, topRightRadius: CGSize = .zero, bottomLeftRadius: CGSize = .zero, bottomRightRadius: CGSize = .zero){

        self.init()

        let path = CGMutablePath()

        let topLeft = rect.origin
        let topRight = CGPoint(x: rect.maxX, y: rect.minY)
        let bottomRight = CGPoint(x: rect.maxX, y: rect.maxY)
        let bottomLeft = CGPoint(x: rect.minX, y: rect.maxY)

        if topLeftRadius != .zero{
            path.move(to: CGPoint(x: topLeft.x+topLeftRadius.width, y: topLeft.y))
        } else {
            path.move(to: CGPoint(x: topLeft.x, y: topLeft.y))
        }

        if topRightRadius != .zero{
            path.addLine(to: CGPoint(x: topRight.x-topRightRadius.width, y: topRight.y))
            path.addCurve(to:  CGPoint(x: topRight.x, y: topRight.y+topRightRadius.height), control1: CGPoint(x: topRight.x, y: topRight.y), control2:CGPoint(x: topRight.x, y: topRight.y+topRightRadius.height))
        } else {
             path.addLine(to: CGPoint(x: topRight.x, y: topRight.y))
        }

        if bottomRightRadius != .zero{
            path.addLine(to: CGPoint(x: bottomRight.x, y: bottomRight.y-bottomRightRadius.height))
            path.addCurve(to: CGPoint(x: bottomRight.x-bottomRightRadius.width, y: bottomRight.y), control1: CGPoint(x: bottomRight.x, y: bottomRight.y), control2: CGPoint(x: bottomRight.x-bottomRightRadius.width, y: bottomRight.y))
        } else {
            path.addLine(to: CGPoint(x: bottomRight.x, y: bottomRight.y))
        }

        if bottomLeftRadius != .zero{
            path.addLine(to: CGPoint(x: bottomLeft.x+bottomLeftRadius.width, y: bottomLeft.y))
            path.addCurve(to: CGPoint(x: bottomLeft.x, y: bottomLeft.y-bottomLeftRadius.height), control1: CGPoint(x: bottomLeft.x, y: bottomLeft.y), control2: CGPoint(x: bottomLeft.x, y: bottomLeft.y-bottomLeftRadius.height))
        } else {
            path.addLine(to: CGPoint(x: bottomLeft.x, y: bottomLeft.y))
        }

        if topLeftRadius != .zero{
            path.addLine(to: CGPoint(x: topLeft.x, y: topLeft.y+topLeftRadius.height))
            path.addCurve(to: CGPoint(x: topLeft.x+topLeftRadius.width, y: topLeft.y) , control1: CGPoint(x: topLeft.x, y: topLeft.y) , control2: CGPoint(x: topLeft.x+topLeftRadius.width, y: topLeft.y))
        } else {
            path.addLine(to: CGPoint(x: topLeft.x, y: topLeft.y))
        }

        path.closeSubpath()
        cgPath = path
    }
}


extension UIViewController {
    
    func isModal() -> Bool {
        var isFirstViewController = true
        DispatchQueue.main.async {
            if let navigationController = self.navigationController {
                if navigationController.viewControllers.first != self {
                    isFirstViewController = false
                }
            }
        
            if self.presentingViewController != nil {
                isFirstViewController = true
            }
            
            if self.navigationController?.presentingViewController?.presentedViewController == self.navigationController  {
                isFirstViewController =  true
            }
            
            if self.tabBarController?.presentingViewController is UITabBarController {
                isFirstViewController = true
            }
        }
        
        return isFirstViewController
    }
}

extension UIView {
    
    func dropShadow() {
        DispatchQueue.main.async {  [weak self] in
               guard let this = self else { return }
              this.layer.masksToBounds = true
            this.layer.shadowColor = self?.traitCollection.userInterfaceStyle == .light ? UIColor.gray.cgColor : UIColor.lightGray.withAlphaComponent(0.2).cgColor
                  this.layer.shadowOpacity = 0.3
                  this.layer.shadowOffset = CGSize.zero
                  this.layer.shadowRadius = 5
                  this.layer.shouldRasterize = true
                  this.layer.rasterizationScale = UIScreen.main.scale
        }
    }
}


extension UISegmentedControl {
    /// Tint color doesn't have any effect on iOS 13.
    func ensureiOS12Style() {
        if #available(iOS 13, *) {
            
        } else {
            self.backgroundColor = UIColor.white
            self.tintColor = CometChatTheme_v4.palatte.primary
            self.layer.borderColor = CometChatTheme_v4.palatte.primary.cgColor
            self.layer.borderWidth = 1
            self.layer.cornerRadius = 8
            self.clipsToBounds = true
            
        }
    }
}


import UIKit

public protocol NibLoadable {
    func loadFromNib()
}

public extension NibLoadable where Self: UIView {
    
    func loadFromNib() {
        
        let bundle = Bundle(for: Self.self)
        
        let nibName = (String(describing: type(of: self)) as NSString).components(separatedBy: ".").last!
                
        guard let view = bundle.loadNibNamed(nibName, owner: self, options: nil)?.first as? UIView else {

            CometChatLogger.debug("Could not load nib with name: \(nibName)")
            return
        }
        view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        view.frame = bounds

        self.addSubview(view)
        
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}

public class UIViewNibLoadable: UIView, NibLoadable {
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        loadFromNib()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        loadFromNib()
        
        awakeFromNib()
    }
    
    public convenience init() {
        self.init(frame: .zero)
    }
}



extension UIStackView {
  func addBackground(color: UIColor) {
    let subView = UIView(frame: bounds)
    subView.backgroundColor = color
    subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    insertSubview(subView, at: 0)
    subView.layer.cornerRadius = 12
    subView.layer.masksToBounds = true
    subView.clipsToBounds = true
  }
}

extension String {
    
    func compareDates(newTimeInterval: Double, currentTimeInterval: Double ) -> Bool {
        let tempNewDate = Date(timeIntervalSince1970: TimeInterval(newTimeInterval))
        let tempCurrentDate = Date(timeIntervalSince1970: TimeInterval(currentTimeInterval))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        dateFormatter.locale = Locale(identifier: CometChatLocalize.getLocale())
        let formattedNewDate = dateFormatter.string(from: tempNewDate)
        let formattedCurrentDate = dateFormatter.string(from: tempCurrentDate)
        if let previousDate = dateFormatter.date(from: formattedNewDate) , let currentDate = dateFormatter.date(from: formattedCurrentDate) {
                return previousDate.compare(currentDate) == .orderedSame
        }
        return false
    }
    
    func checkNewMessageDate(time: Int) -> String {
        let interval = TimeInterval(time)
        let date = Date(timeIntervalSince1970: interval)
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM, yyyy"
        formatter.locale = Locale(identifier: CometChatLocalize.getLocale())
        let strDate: String = formatter.string(from: date)
        return strDate
    }
    
}


public final class CustomVisualEffectView: UIVisualEffectView {
    
    private let theEffect: UIVisualEffect
    private let customIntensity: CGFloat
    private var animator: UIViewPropertyAnimator?
    
    public init(effect: UIVisualEffect, intensity: CGFloat) {
        theEffect = effect
        customIntensity = intensity
        super.init(effect: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) { nil }
    
    deinit {
        animator?.stopAnimation(true)
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        effect = nil
        animator?.stopAnimation(true)
        animator = UIViewPropertyAnimator(duration: 1, curve: .linear) { [unowned self] in
            self.effect = theEffect
        }
        animator?.fractionComplete = customIntensity
    }
}

extension UIViewController {
    
    public func blurView(view: UIView) -> UIView {
        let containerView = UIView()
        let blurEffect = UIBlurEffect(style: .light)
        let customBlurEffectView = CustomVisualEffectView(effect: blurEffect, intensity: 0.2)
        customBlurEffectView.frame = view.bounds
        let dimmedView = UIView()
        dimmedView.backgroundColor = .black.withAlphaComponent(0.2)
        dimmedView.frame = view.bounds
        containerView.addSubview(customBlurEffectView)
        containerView.addSubview(dimmedView)
        return containerView
    }
}

// MARK: - Minimum tap target

/// Grows the touchable area of small controls to the 44×44pt minimum from the
/// Human Interface Guidelines without changing how big they look.
///
/// UIKit only asks a view about a touch that already lies inside its superview, so the
/// extra margin reaches as far as the container allows. The margin never takes a touch
/// that lands on a neighbouring interactive view.
@MainActor
enum CometChatHitArea {

    static let minimumSize: CGFloat = 44

    /// `view.bounds`, grown equally on each side up to `minimumSize` in each direction.
    static func expandedBounds(of view: UIView, minimumSize: CGFloat = minimumSize) -> CGRect {
        let bounds = view.bounds
        let dx = max(0, (minimumSize - bounds.width) / 2)
        let dy = max(0, (minimumSize - bounds.height) / 2)
        return bounds.insetBy(dx: -dx, dy: -dy)
    }

    /// Whether `point` (in `view`'s coordinates) falls inside the view's minimum tap target.
    static func contains(_ point: CGPoint, in view: UIView, minimumSize: CGFloat = minimumSize) -> Bool {
        if view.bounds.contains(point) { return true }
        guard expandedBounds(of: view, minimumSize: minimumSize).contains(point) else { return false }
        guard let superview = view.superview else { return true }
        let pointInSuperview = view.convert(point, to: superview)
        return !superview.subviews.contains { sibling in
            sibling !== view && isInteractive(sibling) && sibling.frame.contains(pointInSuperview)
        }
    }

    /// The closest of `candidates` (subviews of `container`) whose minimum tap target
    /// contains `point`, given in `container`'s coordinates.
    static func target(for point: CGPoint, in container: UIView, among candidates: [UIView], minimumSize: CGFloat = minimumSize) -> UIView? {
        let hits = candidates.filter { candidate in
            guard isInteractive(candidate) else { return false }
            return contains(container.convert(point, to: candidate), in: candidate, minimumSize: minimumSize)
        }
        return hits.min { distance(from: point, to: $0.frame) < distance(from: point, to: $1.frame) }
    }

    /// Routes a touch that landed near (not on) a small control inside a nested layout: the
    /// closest of `candidates`, anywhere below `container`, whose minimum tap target contains
    /// `point` (in `container`'s coordinates). Unlike `point(inside:)` on the control itself,
    /// this reaches past parent stack views that are shorter than the minimum target.
    static func nestedTarget(for point: CGPoint, in container: UIView, among candidates: [UIView], minimumSize: CGFloat = minimumSize) -> UIView? {
        let hits = candidates.filter { candidate in
            guard candidate.window != nil, candidate.isDescendant(of: container), isInteractive(candidate) else { return false }
            return expandedBounds(of: candidate, minimumSize: minimumSize).contains(container.convert(point, to: candidate))
        }
        return hits.min {
            distance(from: point, to: $0.convert($0.bounds, to: container)) < distance(from: point, to: $1.convert($1.bounds, to: container))
        }
    }

    private static func isInteractive(_ view: UIView) -> Bool {
        guard !view.isHidden, view.alpha > 0.01, view.isUserInteractionEnabled else { return false }
        return view is UIControl || !(view.gestureRecognizers?.isEmpty ?? true)
    }

    private static func distance(from point: CGPoint, to rect: CGRect) -> CGFloat {
        let dx = max(rect.minX - point.x, 0, point.x - rect.maxX)
        let dy = max(rect.minY - point.y, 0, point.y - rect.maxY)
        return (dx * dx + dy * dy).squareRoot()
    }
}

/// A button that keeps its visual size but accepts touches in a 44×44pt area.
final class CometChatHitAreaButton: UIButton {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        CometChatHitArea.contains(point, in: self)
    }
}

/// A view that keeps its visual size but accepts touches in a 44×44pt area.
final class CometChatHitAreaView: UIView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        CometChatHitArea.contains(point, in: self)
    }
}
