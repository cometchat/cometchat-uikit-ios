//  CometChatSharedMediaItem.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2019 CometChat Inc. All rights reserved.


// MARK: - Importing Frameworks.

import UIKit
import AVFoundation
import CoreMedia
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */


class CometChatStickerKeyboardItem: UICollectionViewCell {
    
    // MARK: - Declaration of Outlets.
    @IBOutlet weak var stickerIcon: UIImageView!
    
    private var imageRequest: Cancellable?
    private lazy var imageService = ImageService()
    
    var stickerSet: CometChatStickerSet! {
        didSet {
            if let url = URL(string: stickerSet.thumbnail ?? "") {
                imageRequest = imageService.image(for: url) { [weak self] image in
                    guard let strongSelf = self else { return }
                    // Update Thumbnail Image View
                    if let image = image {
                        strongSelf.stickerIcon.image = image
                    }else{
                        strongSelf.stickerIcon.image = UIImage(named: "default-image.png", in: UIKitSettings.bundle, compatibleWith: nil)
                    }
                }
               
            }
        }
        
    }
    var sticker: CometChatSticker! {
        didSet {
            if let url = URL(string: sticker.url ?? "") {
                imageRequest = imageService.image(for: url) { [weak self] image in
                    guard let strongSelf = self else { return }
                    // Update Thumbnail Image View
                    if let image = image {
                        strongSelf.stickerIcon.image = image
                    }else{
                        strongSelf.stickerIcon.image = UIImage(named: "default-image.png", in: UIKitSettings.bundle, compatibleWith: nil)
                    }
                }
            }
        }
    }
  // MARK: - Required Instance Methods.
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    
    }
    
    override func prepareForReuse() {
        imageRequest?.cancel()
    }
    
}

/*  ----------------------------------------------------------------------------------------- */
