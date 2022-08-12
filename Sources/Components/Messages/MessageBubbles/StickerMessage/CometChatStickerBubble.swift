//
//  CometChatStickerBubble.swift
//  CometChatUIKit
//
//  Created by Abdullah Ansari on 13/05/22.
//

import UIKit
import CometChatPro

public class CometChatStickerBubble: UIView {
    
    @IBOutlet weak var imageThumbnail: UIImageView!
    @IBOutlet weak var containerView: UIView!
    // TODO:- Refactor this code.
    private var imageRequest: Cancellable?
    private lazy var imageService = ImageService()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    convenience init(frame: CGRect, message: CustomMessage) {
        self.init(frame: frame)
        set(image: message)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        customInit()
    }
    
    private func customInit() {
        let loadedNib = Bundle.module.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)
        if let contentView = loadedNib?.first as? UIView  {
            contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            contentView.frame = bounds
            addSubview(contentView)
        }
    }
    
    @discardableResult
    @objc public func set(image forMessage: CustomMessage) -> Self {
        guard let string = forMessage.customData?[UIKitConstants.MetadataConstants.sticker_url] as? String, let url = URL(string: string) else {
            return self
        }
        imageRequest = imageService.image(for: url) { [weak self] image in
            guard let strongSelf = self else { return }
            // Update Thumbnail Image View
            if let image = image {
                strongSelf.imageThumbnail.image = image
            }else{
                strongSelf.imageThumbnail.image = UIImage(named: "default-image.png", in: CometChatUIKit.bundle, compatibleWith: nil)
            }
        }
        return self
    }
    
    // TODO: - Complete this method.
    @discardableResult
    @objc public func set(messageObject: CustomMessage) -> Self {
        // self.stickerMessage = messageObject
        return self
    }
    
    deinit {
        imageRequest?.cancel()
    }
 
}
