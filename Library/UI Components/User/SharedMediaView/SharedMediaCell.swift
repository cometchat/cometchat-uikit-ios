//  SharedMediaCell.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2019 CometChat Inc. All rights reserved.


// MARK: - Importing Frameworks.

import UIKit
import AVFoundation
import CoreMedia
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */


class SharedMediaCell: UICollectionViewCell {
    
    // MARK: - Declaration of Outlets.
    
    
    @IBOutlet weak var photosView: UIView!
    @IBOutlet weak var docsView: UIView!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var docType: UIImageView!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var play: UIImageView!
    
    // MARK: - Declaration of Variables.
    
    var message : MediaMessage! {
        didSet {
            switch message.messageType {
            case .image:
                self.photosView.isHidden = false
                self.docsView.isHidden = true
                self.play.isHidden = true
                if let url = URL(string: message.attachment?.fileUrl ?? "") {
                    self.photo.cf.setImage(with: url, placeholder: UIImage(named: "default-image.png", in: UIKitSettings.bundle, compatibleWith: nil))
                }
            case .video:
                self.photo.image = nil
                self.photosView.isHidden = false
                self.docsView.isHidden = true
                self.play.isHidden = false
                self.type.text = message.attachment?.fileExtension.uppercased()
            case .file:
                self.photosView.isHidden = true
                self.docsView.isHidden = false
            case .text:break
            case .audio:break
            case .custom: break
            case .groupMember:break
            self.docsView.isHidden = false
            self.type.text = message.attachment?.fileExtension.uppercased()
            @unknown default:break
            }
        }
    }
    
  // MARK: - Required Instance Methods.
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}

/*  ----------------------------------------------------------------------------------------- */
