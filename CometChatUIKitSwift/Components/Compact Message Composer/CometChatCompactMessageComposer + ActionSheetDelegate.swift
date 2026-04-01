//
//  CometChatCompactMessageComposer + ActionSheetDelegate.swift
//  CometChatUIKitSwift
//
//  Created by Kiro on 12/02/26.
//

import Foundation
import UIKit
import CometChatSDK

extension CometChatCompactMessageComposer: CometChatActionSheetDelegate {
    
    public func onActionItemClick(item: ActionItem) {
        if item.id == ComposerAttachmentConstants.camera {
            takeAPhotoPressed()
        } else if item.id == ComposerAttachmentConstants.photo {
            photoLibraryPressed()
        } else if item.id == ComposerAttachmentConstants.video {
            videoLibraryPressed()
        } else if item.id == ComposerAttachmentConstants.file {
            documentPressed()
        } else {
            item.onActionClick?()
        }
    }

    // MARK: - Attachment Methods
    
    private func takeAPhotoPressed() {
        if let controller = controller {
            CameraHandler.shared.presentCamera(for: controller)
            CameraHandler.shared.imagePickedBlock = { [weak self] (photoURL) in
                DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
                    guard let this = self else { return }
                    if this.viewModel.user != nil {
                        this.viewModel.sendMediaMessageToUser(url: photoURL, type: .image)
                    } else if this.viewModel.group != nil {
                        this.viewModel.sendMediaMessageToGroup(url: photoURL, type: .image)
                    }
                }
            }
        }
    }
    
    private func photoLibraryPressed() {
        if let controller = controller {
            CameraHandler.shared.presentPhotoLibrary(for: controller)
            CameraHandler.shared.imagePickedBlock = { [weak self] (photoURL) in
                guard let this = self else { return }
                if this.viewModel.user != nil {
                    this.viewModel.sendMediaMessageToUser(url: photoURL, type: .image)
                } else if this.viewModel.group != nil {
                    this.viewModel.sendMediaMessageToGroup(url: photoURL, type: .image)
                }
            }
        }
    }
    
    private func videoLibraryPressed() {
        if let controller = controller {
            CameraHandler.shared.presentVideoLibrary(for: controller)
            CameraHandler.shared.videoPickedBlock = { [weak self] (videoURL) in
                guard let this = self else { return }
                if this.viewModel.user != nil {
                    this.viewModel.sendMediaMessageToUser(url: videoURL, type: .video)
                } else if this.viewModel.group != nil {
                    this.viewModel.sendMediaMessageToGroup(url: videoURL, type: .video)
                }
            }
        }
    }
    
    private func documentPressed() {
        if let controller = controller {
            // Create a new document picker each time (UIDocumentPickerViewController cannot be reused)
            let picker = UIDocumentPickerViewController(
                documentTypes: ["public.data", "public.content", "public.audiovisual-content",
                               "public.movie", "public.video", "public.audio",
                               "public.zip-archive", "com.pkware.zip-archive",
                               "public.composite-content", "public.text"],
                in: .import
            )
            picker.delegate = self
            picker.modalPresentationStyle = .fullScreen
            controller.present(picker, animated: true, completion: nil)
        }
    }
}

// MARK: - UIDocumentPickerDelegate

extension CometChatCompactMessageComposer: UIDocumentPickerDelegate {
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        // Only process if in import mode (matches CometChatMessageComposer behavior)
        if controller.documentPickerMode == UIDocumentPickerMode.import {
            guard let url = urls.first else {
                return
            }
            
            // Send the file directly using absoluteString (matches regular Message Composer behavior)
            if viewModel.user != nil {
                viewModel.sendMediaMessageToUser(url: url.absoluteString, type: .file)
            } else if viewModel.group != nil {
                viewModel.sendMediaMessageToGroup(url: url.absoluteString, type: .file)
            }
        }
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
