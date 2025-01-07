//
//  CometChatMessageComposer + ActionSheetDelegate.swift
 
//
//  Created by Pushpsen Airekar on 31/01/22.
//

import Foundation
import UIKit
import CometChatSDK

extension CometChatMessageComposer : CometChatActionSheetDelegate {
    
    func onActionItemClick(item: ActionItem) {
        if item.id == ComposerAttachmentConstants.camera {
            takeAPhotoPressed()
        } else if item.id == ComposerAttachmentConstants.gallery {
            photoAndVideoLibraryPressed()
        } else if item.id == ComposerAttachmentConstants.file {
            documentPressed()
        } else {
            item.onActionClick?()
        }
    }

    //Methods
    private func takeAPhotoPressed() {
        if let controller = controller {
            CameraHandler.shared.presentCamera(for: controller)
            CameraHandler.shared.imagePickedBlock = { [weak self] (photoURL) in
                DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
                    guard let this = self else { return }
                    if let _ = this.viewModel.user {
                        this.viewModel.sendMediaMessageToUser(url: photoURL, type: .image)
                    } else if let _ = this.viewModel.group {
                        this.viewModel.sendMediaMessageToGroup(url: photoURL, type: .image)
                    }
                }
            }
        }
    }
    
    private func photoAndVideoLibraryPressed() {
        if let controller = controller {
            CameraHandler.shared.presentPhotoLibrary(for: controller)
            CameraHandler.shared.imagePickedBlock = { [weak self] (photoURL) in
                guard let this = self else { return }
                if let _ = this.viewModel.user {
                    this.viewModel.sendMediaMessageToUser(url: photoURL, type: .image)
                } else if let _ = this.viewModel.group {
                    this.viewModel.sendMediaMessageToGroup(url: photoURL, type: .image)
                }
            }
            CameraHandler.shared.videoPickedBlock = { [weak self] (videoURL) in
                guard let this = self else { return }
                if let _ = this.viewModel.user {
                    this.viewModel.sendMediaMessageToUser(url: videoURL, type: .video)
                }else if let _ = this.viewModel.group {
                    this.viewModel.sendMediaMessageToGroup(url: videoURL, type: .video)
                }
            }
        }
    }
    
    private func documentPressed() {
        if let controller = controller {
            self.documentPicker.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            controller.present(self.documentPicker, animated: true, completion: nil)
        }
    }
}
