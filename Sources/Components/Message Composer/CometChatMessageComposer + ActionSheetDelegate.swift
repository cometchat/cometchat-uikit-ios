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
        if item.id == MessageTypeConstants.image && item.text == "TAKE_A_PHOTO".localize() {
            takeAPhotoPressed()
        } else if item.id == MessageTypeConstants.image && item.text == "PHOTO_VIDEO_LIBRARY".localize() {
            photoAndVideoLibraryPressed()
        } else if item.id == MessageTypeConstants.file {
            documentPressed()
        } else {
            item.onActionClick?()
        }
    }
    
    //Methods
    private func takeAPhotoPressed() {
        if let controller = controller {
            CameraHandler.shared.presentCamera(for: controller)
            CameraHandler.shared.imagePickedBlock = {(photoURL) in
                if let _ = self.viewModel?.user {
                    self.viewModel?.sendMediaMessageToUser(url: photoURL, type: .image)
                } else if let _ = self.viewModel?.group {
                    self.viewModel?.sendMediaMessageToGroup(url: photoURL, type: .image)
                }
            }
        }
    }
    
    private func photoAndVideoLibraryPressed() {
        if let controller = controller {
            CameraHandler.shared.presentPhotoLibrary(for: controller)
            CameraHandler.shared.imagePickedBlock = {(photoURL) in
                if let _ = self.viewModel?.user {
                    self.viewModel?.sendMediaMessageToUser(url: photoURL, type: .image)
                } else if let _ = self.viewModel?.group {
                    self.viewModel?.sendMediaMessageToGroup(url: photoURL, type: .image)
                }
            }
            CameraHandler.shared.videoPickedBlock = {(videoURL) in
                if let _ = self.viewModel?.user {
                    self.viewModel?.sendMediaMessageToUser(url: videoURL, type: .video)
                }else if let _ = self.viewModel?.group {
                    self.viewModel?.sendMediaMessageToGroup(url: videoURL, type: .video)
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
