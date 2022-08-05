//
// DeleteMessage.swift
// CometChatUIKit
//
// Created by Abdullah Ansari on 25/05/22.
//
import Foundation
import UIKit
import CometChatPro

class CometChatDeleteBubble: UIView {
    
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var message: HyperlinkLabel!
  override init(frame: CGRect) {
    super.init(frame: frame)
    customInit()
  }
  convenience init(frame: CGRect, message: BaseMessage, isStandard: Bool) {
    self.init(frame: frame)
    set(text: "MESSAGE_IS_DELETED".localize())
    setupStyle(isStandard: isStandard)
    addDashedBorder()
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
    
  private func addDashedBorder() {
    let shapeLayer:CAShapeLayer = CAShapeLayer()
    let frameSize = self.frame.size
    let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
    shapeLayer.bounds = shapeRect
    shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
    shapeLayer.fillColor = UIColor.clear.cgColor
    shapeLayer.strokeColor = CometChatTheme.palatte?.accent200?.cgColor
    shapeLayer.lineWidth = 2
    shapeLayer.lineJoin = CAShapeLayerLineJoin.round
    shapeLayer.lineDashPattern = [4, 5]
    shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 12).cgPath
    self.layer.addSublayer(shapeLayer)
  }
    
  private func customInit() {
      CometChatUIKit.bundle.loadNibNamed("CometChatDeleteBubble", owner: self, options: nil)
    addSubview(containerView)
    containerView.frame = bounds
    containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
  }
  private func setupStyle(isStandard: Bool) {
    let deleteStyle = DeleteBubbleStyle(
      titleColor: CometChatTheme.palatte?.accent500, titleFont: CometChatTheme.typography?.Subtitle2)
    set(style: deleteStyle)
  }
  @discardableResult
  public func set(style: DeleteBubbleStyle) -> Self {
    self.set(textColor: style.titleColor!)
    self.set(textFont: style.titleFont!)
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
}
