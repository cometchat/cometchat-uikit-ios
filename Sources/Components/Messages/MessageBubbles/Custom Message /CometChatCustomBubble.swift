//
//  CometChatCustomBubble.swift
//  CometChatUIKit
//
//  Created by Abdullah Ansari on 22/05/22.
//

import UIKit
import CometChatPro

protocol CustomDelegate: NSObject {
    func onClick(forMessage: CustomMessage, cell: UITableViewCell)
    func onLongPress(message: CustomMessage,cell: UITableViewCell)
}

class CometChatCustomBubble: UIView {

    @IBOutlet weak var containerView: UIView!
    var controller: UIViewController?
    var customMessage: CustomMessage?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect, message: CustomMessage) {
        self.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func customInit() {
        CometChatUIKit.bundle.loadNibNamed("CometChatCustomBubble", owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    @discardableResult
    public func set(message: CustomMessage) -> Self {
        self.customMessage = message
        return self
    }
    
    
    @discardableResult
    public func set(controller: UIViewController) -> Self {
        self.controller = controller
        return self
    }

    
}
