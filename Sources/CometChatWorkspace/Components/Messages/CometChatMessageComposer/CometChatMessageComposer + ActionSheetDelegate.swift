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
   
        if item.id == "image" && item.title == "TAKE_A_PHOTO".localize() {
            takeAPhotoPressed()
        }else if item.id == "image" && item.title == "PHOTO_VIDEO_LIBRARY".localize() {
            photoAndVideoLibraryPressed()
        }else if item.id == "file" {
            documentPressed()
        }else if item.id == "location" {
            shareLocationPressed()
        }else if item.id == "extension_poll" {
            createPoll()
        }else if item.id == "extension_whiteboard" {
            shareCollaborativeWhiteboard()
        }else if item.id == "extension_document" {
            shareCollaborativeDocument()
        }else if item.id == "extension_sticker" {
            shareSticker()
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
            CometChat.callExtension(slug: "whiteboard", type: .post, endPoint: "v1/create", body: ["receiver":group.guid,"receiverType":"group"], onSuccess: { (response) in
            }) { (error) in
                 DispatchQueue.main.async {
                    if let error = error {
                        CometChatSnackBoard.showErrorMessage(for: error)
                    }
                }
            }
            
        } else if let user = currentUser {
            CometChat.callExtension(slug: "whiteboard", type: .post, endPoint:  "v1/create", body: ["receiver":user.uid,"receiverType":"user"], onSuccess: { (response) in
            }) { (error) in
                DispatchQueue.main.async {
                    if let error = error {
                        CometChatSnackBoard.showErrorMessage(for: error)
                    }
                }
            }
        }
    }
    
    private func shareCollaborativeDocument() {
        if let group = currentGroup {
            CometChat.callExtension(slug:  "document", type: .post, endPoint: "v1/create", body: ["receiver":group.guid,"receiverType":"group"], onSuccess: { (response) in
            }) { (error) in
                DispatchQueue.main.async {
                    if let error = error {
                        CometChatSnackBoard.showErrorMessage(for: error)
                    }
                }
            }
        } else if let user = currentUser {
            CometChat.callExtension(slug: "document", type: .post, endPoint: "v1/create", body: ["receiver":user.uid,"receiverType":"user"], onSuccess: { (response) in
               
            }) { (error) in
                DispatchQueue.main.async {
                    if let error = error {
                        CometChatSnackBoard.showErrorMessage(for: error)
                    }                    }
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
       
    }
    
}

extension CometChatMessageComposer: StickerViewDelegate {
    
    func didClosePressed() {
        
    }
    
    
    func didStickerSelected(sticker: CometChatSticker) {
        if let url = sticker.url {
            DispatchQueue.main.async {
                let pushNotificationTitle = (CometChat.getLoggedInUser()?.name ?? "") + " has shared sticker"
                let stickerData =  ["sticker_url": url] as [String : Any]
                    if let user = self.currentUser {
                        self.sendCustomMessage(data: stickerData, pushNotificationTitle: pushNotificationTitle, type: "extension_sticker", user)
                    }else if let group = self.currentGroup {
                        self.sendCustomMessage(data: stickerData, pushNotificationTitle: pushNotificationTitle, type: "extension_sticker", group)
                    }
            }
        }
    }
    
    func didStickerSetSelected(stickerSet: CometChatStickerSet) {
        
    }
    
    
}

