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
        } else if item.id == ComposerAttachmentConstants.photo {
            photoLibraryPressed()
        } else if item.id == ComposerAttachmentConstants.video {
            videoLibraryPressed()
        } else if item.id == ComposerAttachmentConstants.audio {
            audioLibraryPressed()
        } else if item.id == ComposerAttachmentConstants.file {
            documentPressed()
        } else {
            item.onActionClick?()
        }
    }

    //Methods
    private func takeAPhotoPressed() {
        guard let controller = controller else { return }
        CameraHandler.shared.presentCamera(for: controller)
        CameraHandler.shared.imagePickedBlock = { [weak self] (photoURL) in
            guard let this = self else { return }
            if this.enableMultipleAttachments {
                DispatchQueue.main.async { this.stageLocalMedia(urlString: photoURL) }
            } else {
                this.sendSingleMedia(url: photoURL, type: .image)
            }
        }
    }

    private func photoLibraryPressed() {
        if enableMultipleAttachments { presentMultiMediaLibrary(); return }
        guard let controller = controller else { return }
        CameraHandler.shared.presentPhotoLibrary(for: controller)
        CameraHandler.shared.imagePickedBlock = { [weak self] (photoURL) in
            self?.sendSingleMedia(url: photoURL, type: .image)
        }
    }

    private func videoLibraryPressed() {
        if enableMultipleAttachments { presentMultiMediaLibrary(); return }
        guard let controller = controller else { return }
        CameraHandler.shared.presentVideoLibrary(for: controller)
        CameraHandler.shared.videoPickedBlock = { [weak self] (videoURL) in
            self?.sendSingleMedia(url: videoURL, type: .video)
        }
    }

    private func audioLibraryPressed() {
        guard let controller = controller else { return }
        CameraHandler.shared.presentAudioLibrary(for: controller, allowsMultiple: enableMultipleAttachments)
        CameraHandler.shared.audioPickedBlock = { [weak self] (audioURL) in
            guard let this = self else { return }
            if this.enableMultipleAttachments {
                DispatchQueue.main.async { this.stageLocalMedia(urlString: audioURL) }
            } else {
                this.sendSingleMedia(url: audioURL, type: .audio)
            }
        }
    }

    private func documentPressed() {
        if enableMultipleAttachments { presentMultiDocumentPicker(); return }
        guard let controller = controller else { return }
        self.documentPicker.modalPresentationStyle = .fullScreen
        controller.present(self.documentPicker, animated: true, completion: nil)
    }

    /// Legacy single-attachment send (used when `enableMultipleAttachments` is false).
    private func sendSingleMedia(url: String, type: CometChat.MessageType) {
        if viewModel.user != nil {
            viewModel.sendMediaMessageToUser(url: url, type: type)
        } else if viewModel.group != nil {
            viewModel.sendMediaMessageToGroup(url: url, type: type)
        }
    }
}
