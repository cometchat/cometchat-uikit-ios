//
//  CometChatMessageComposer + ActionSheetDelegate.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 31/01/22.
//

import Foundation
import UIKit
import CometChatPro


extension CometChatMessageComposer : CometChatActionSheetDelegate {

    func onActionItemClick(item: ActionItem) {
        if item.id == UIKitConstants.MessageTypeConstants.image && item.text == "TAKE_A_PHOTO".localize() {
            takeAPhotoPressed()
        }else if item.id == UIKitConstants.MessageTypeConstants.image && item.text == "PHOTO_VIDEO_LIBRARY".localize() {
            photoAndVideoLibraryPressed()
        }else if item.id == UIKitConstants.MessageTypeConstants.file {
            documentPressed()
        }else if item.id == UIKitConstants.MessageTypeConstants.location {
            shareLocationPressed()
        }else if item.id == UIKitConstants.MessageTypeConstants.poll {
            createPoll()
        }else if item.id == UIKitConstants.MessageTypeConstants.whiteboard {
            shareCollaborativeWhiteboard()
        }else if item.id == UIKitConstants.MessageTypeConstants.document {
            shareCollaborativeDocument()
        }else if item.id == UIKitConstants.MessageTypeConstants.sticker {
            shareSticker()
        } else {
            for messageType in messageTypes {
                if messageType.type == item.id {
                    if let user = currentUser {
                        messageType.onActionClick?(user, nil)
                    }
                    if let group = currentGroup {
                        messageType.onActionClick?(nil, group)
                    }
                }
            }
        }
        
    }
    
    
    private func takeAPhotoPressed() {
        if let controller = controller {
            CameraHandler.shared.presentCamera(for: controller)
            CameraHandler.shared.imagePickedBlock = {(photoURL) in
                if let user = self.currentUser {
                    self.sendMediaMessage(url: photoURL, type: .image, user)
                }else if let group = self.currentGroup {
                    self.sendMediaMessage(url: photoURL, type: .image, group)
                }
            }
        }
    }
    
    private func photoAndVideoLibraryPressed() {
        if let controller = controller {
            CameraHandler.shared.presentPhotoLibrary(for: controller)
            CameraHandler.shared.imagePickedBlock = {(photoURL) in
                if let user = self.currentUser {
                    self.sendMediaMessage(url: photoURL, type: .image, user)
                }else if let group = self.currentGroup {
                    self.sendMediaMessage(url: photoURL, type: .image, group)
                }
            }
            CameraHandler.shared.videoPickedBlock = {(videoURL) in
                if let user = self.currentUser {
                    self.sendMediaMessage(url: videoURL, type: .video, user)
                }else if let group = self.currentGroup {
                    self.sendMediaMessage(url: videoURL, type: .video, group)
                }
            }
        }
    }
    
    func documentPressed() {
        if let controller = controller {
            self.documentPicker.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            controller.present(self.documentPicker, animated: true, completion: nil)
        }
     
    }
    
    func shareLocationPressed() {
        if let controller = controller {
            print("~~~", curentLocation)
            let alert = UIAlertController(title: "" , message: "SHARE_LOCATION_CONFIRMATION_MESSAGE".localize(), preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "SHARE".localize(), style: .default, handler: { action in
                
                let pushNotificationTitle = (CometChat.getLoggedInUser()?.name ?? "") + " has shared his location"
                if let location = self.curentLocation {
                let locationData = ["latitude": location.coordinate.latitude, "longitude": location.coordinate.longitude] as [String : Any]
                    
                    if let user = self.currentUser {
                        self.sendCustomMessage(data: locationData, pushNotificationTitle: pushNotificationTitle, type: "location", user)
                    }else if let group = self.currentGroup {
                        self.sendCustomMessage(data: locationData, pushNotificationTitle: pushNotificationTitle, type: "location", group)
                    }
                }
            }))
            alert.addAction(UIAlertAction(title: "CANCEL".localize(), style: .cancel, handler: { action in
                
            }))
            alert.view.tintColor = CometChatTheme.palatte?.primary
            controller.present(alert, animated: true)
        }
     
    }
    
    
    private func shareCollaborativeWhiteboard() {
        if let group = currentGroup {
            CometChat.callExtension(slug: ExtensionConstants.whiteboard, type: .post, endPoint: "v1/create", body: ["receiver":group.guid,"receiverType": UIKitConstants.ReceiverTypeConstants.group], onSuccess: { (response) in
            }) { (error) in
                if let error = error {
                    let confirmDialog = CometChatDialog()
                    confirmDialog.set(cancelButtonText: "CANCEL".localize())
                    confirmDialog.set(error: CometChatServerError.get(error: error))
                    confirmDialog.open()
                }
            }
            
        } else if let user = currentUser {
            CometChat.callExtension(slug: ExtensionConstants.whiteboard, type: .post, endPoint:  "v1/create", body: ["receiver":user.uid,"receiverType": UIKitConstants.ReceiverTypeConstants.user], onSuccess: { (response) in
            }) { (error) in
                if let error = error {
                    let confirmDialog = CometChatDialog()
                    confirmDialog.set(cancelButtonText: "CANCEL".localize())
                    confirmDialog.set(error: CometChatServerError.get(error: error))
                    confirmDialog.open()
                }
            }
        }
    }
    
    private func shareCollaborativeDocument() {
        if let group = currentGroup {
            CometChat.callExtension(slug: ExtensionConstants.document, type: .post, endPoint: "v1/create", body: ["receiver":group.guid,"receiverType": UIKitConstants.ReceiverTypeConstants.group], onSuccess: { (response) in
            }) { (error) in
                if let error = error {
                    let confirmDialog = CometChatDialog()
                    confirmDialog.set(cancelButtonText: "CANCEL".localize())
                    confirmDialog.set(error: CometChatServerError.get(error: error))
                    confirmDialog.open()
                }
            }
        } else if let user = currentUser {
            CometChat.callExtension(slug: ExtensionConstants.document, type: .post, endPoint: "v1/create", body: ["receiver":user.uid,"receiverType": UIKitConstants.ReceiverTypeConstants.user], onSuccess: { (response) in
               
            }) { (error) in
                if let error = error {
                    let confirmDialog = CometChatDialog()
                    confirmDialog.set(cancelButtonText: "CANCEL".localize())
                    confirmDialog.set(error: CometChatServerError.get(error: error))
                    confirmDialog.open()
                }
            }
        }
    }
    
    private func shareSticker() {
        if let controller = controller {
            DispatchQueue.main.async {
                let stickerView = CometChatStickerKeyboard()
                stickerView.modalPresentationStyle = .custom
                controller.present(stickerView, animated: true, completion: nil)
            }
        }
    }
    
    private func createPoll() {
        if let controller = controller {
            if let group = currentGroup {
                DispatchQueue.main.async {
                    let cometChatCreatePoll = CometChatCreatePoll()
                    cometChatCreatePoll.modalPresentationStyle = .custom
                    cometChatCreatePoll.set(group: group)
                    let naviVC = UINavigationController(rootViewController: cometChatCreatePoll)
                    controller.present(naviVC, animated: true, completion: nil)
                }
            }
            
            if let user = currentUser {
                DispatchQueue.main.async {
                    let cometChatCreatePoll = CometChatCreatePoll()
                    cometChatCreatePoll.modalPresentationStyle = .custom
                    cometChatCreatePoll.set(user: user)
                    let naviVC = UINavigationController(rootViewController: cometChatCreatePoll)
                    controller.present(naviVC, animated: true, completion: nil)
                }
            }
            
        }
    }
    
}

extension CometChatMessageComposer: StickerViewDelegate {
    
    func didClosePressed() {
        
    }
    
    
    func didStickerSelected(sticker: CometChatSticker) {
        if let url = sticker.url {
            DispatchQueue.main.async {
                let pushNotificationTitle = (CometChat.getLoggedInUser()?.name ?? "") + " has shared sticker"
                let stickerData =  [UIKitConstants.MetadataConstants.sticker_url: url] as [String : Any]
                    if let user = self.currentUser {
                        self.sendCustomMessage(data: stickerData, pushNotificationTitle: pushNotificationTitle, type: UIKitConstants.MessageTypeConstants.sticker, user)
                    }else if let group = self.currentGroup {
                        self.sendCustomMessage(data: stickerData, pushNotificationTitle: pushNotificationTitle, type: UIKitConstants.MessageTypeConstants.sticker, group)
                    }
            }
        }
    }
    
    func didStickerSetSelected(stickerSet: CometChatStickerSet) {
        
    }
    
    
}

