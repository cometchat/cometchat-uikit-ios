//
//  CometChatLinkPreviewBubble.swift
//  CometChatUIKit
//
//  Created by Abdullah Ansari on 12/05/22.
//

import UIKit
import CometChatPro


class CometChatLinkPreviewBubble: UIView {
    
    // MARK: - Properties
    
    @IBOutlet weak var imageThumbnail: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var message: TextMessage?
    private var imageRequest: Cancellable?
    private lazy var imageService = ImageService()
    
    var controller: UIViewController?
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    @discardableResult
    public func set(controller: UIViewController) -> Self {
        self.controller = controller
        return self
    }
    
    
    convenience init(frame: CGRect, message: TextMessage) {
        self.init(frame: frame)
        self.message = message

    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Helper Methods
    
    private func commonInit() {
        Bundle.module.loadNibNamed("CometChatLinkPreviewBubble", owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onLinkPreviewClick))
//        imageThumbnail.addGestureRecognizer(tap)
//        imageThumbnail.isUserInteractionEnabled = true
    }
    
    @objc  func onLinkPreviewClick() {
       
    }
    
   
   

    deinit {
        imageRequest?.cancel()
    }
    
}

