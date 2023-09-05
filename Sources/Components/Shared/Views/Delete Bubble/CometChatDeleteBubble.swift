//
// DeleteMessage.swift
//
// Created by Abdullah Ansari on 25/05/22.
//
import Foundation
import UIKit
import CometChatSDK

public class CometChatDeleteBubble: UIView {
    
    @IBOutlet weak var dashedView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var message: HyperlinkLabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func customInit() {
        CometChatUIKit.bundle.loadNibNamed("CometChatDeleteBubble", owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 173),
            heightAnchor.constraint(greaterThanOrEqualToConstant: 45)
        ])
        set(text: "MESSAGE_IS_DELETED".localize())
        set(style: DeleteBubbleStyle())
        addDashedBorder(dashedView: dashedView, dashedColor: CometChatTheme.palatte.accent200, cornerRadius: 12)
    }
    
    @discardableResult
    public func set(style: DeleteBubbleStyle) -> Self {
        self.set(textColor: style.titleColor)
        self.set(textFont: style.titleFont)
        self.set(corner: style.cornerRadius)
        self.set(borderWidth: style.borderWidth)
        self.set(borderColor: style.borderColor)
        return self
    }
    
    // MARK: - Method's for DeleteMessage.
    /// Set the delete text
    @discardableResult
    @objc public func set(text: String) -> Self {
        self.message.text = text
        return self
    }
    /// Set the delete text font.
    @discardableResult
    @objc public func set(textFont: UIFont) -> Self {
        self.message.font = textFont
        return self
    }
    /// Set the delete text color.
    @discardableResult
    @objc public func set(textColor: UIColor) -> Self {
        self.message.textColor = textColor
        return self
    }
    
    @discardableResult
    public func set(corner: CometChatCornerStyle) -> Self {
        self.roundViewCorners(corner: corner)
        return self
    }
    
    @discardableResult
    public func set(borderWidth: CGFloat) -> Self {
        self.borderWith(width: borderWidth)
        return self
    }
    
    @discardableResult
    public func set(borderColor: UIColor) -> Self {
        self.borderColor(color: borderColor)
        return self
    }
    
    @discardableResult
    public func set(backgroundColor: UIColor) -> Self {
        self.backgroundColor = backgroundColor
        return self
    }
}

extension UIView {
    
    func addDashedBorder(dashedView: UIView, dashedColor: UIColor, cornerRadius: Double = 0, width: Double = 1) {
        let shapeLayer:CAShapeLayer = CAShapeLayer()
        let frameSize = dashedView.frame.size
        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: frameSize.width/2 , y: frameSize.height/2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = dashedColor.cgColor
        shapeLayer.lineWidth = width
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
        shapeLayer.lineDashPattern = [4, 5]
        shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: cornerRadius).cgPath
        dashedView.layer.addSublayer(shapeLayer)
    }
}
