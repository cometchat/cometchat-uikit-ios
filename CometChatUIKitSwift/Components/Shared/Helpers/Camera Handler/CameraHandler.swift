//
//  CameraHandler.swift
 
//
//  Created by CometChat Inc. on 23/10/19.
//  Copyright © 2022 CometChat Inc. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer
import UniformTypeIdentifiers

class CameraHandler: NSObject{
    static let shared = CameraHandler()
    
    fileprivate weak var currentVC: UIViewController?
    
    //MARK: Internal Properties
    
    var imagePickedBlock: ((String) -> Void)?
    var videoPickedBlock: ((String) -> Void)?
    var audioPickedBlock: ((String) -> Void)?
    
    /// Copies a file from a temporary location to the app's cache directory
    /// This is needed because files from photo picker are in temporary locations that get deleted
    private func copyToPersistentLocation(from sourceURL: URL, fileExtension: String) -> URL? {
        let fileManager = FileManager.default
        guard let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let fileName = "media_\(Int(Date().timeIntervalSince1970 * 1000)).\(fileExtension)"
        let destinationURL = cacheDirectory.appendingPathComponent(fileName)
        
        // Remove existing file if any
        if fileManager.fileExists(atPath: destinationURL.path) {
            do {
                try fileManager.removeItem(at: destinationURL)
            } catch { }
        }
        
        do {
            try fileManager.copyItem(at: sourceURL, to: destinationURL)
            return destinationURL
        } catch {
            return nil
        }
    }
    
    func presentCamera(for view: UIViewController){
        currentVC = view
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self;
            myPickerController.sourceType = .camera
            currentVC?.present(myPickerController, animated: true, completion: nil)
        }
        
    }
    
    func presentPhotoLibrary(for view: UIViewController) {
        currentVC = view
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self;
            myPickerController.sourceType = .photoLibrary
            myPickerController.mediaTypes = ["public.image"]
            currentVC?.present(myPickerController, animated: true, completion: nil)
        }
    }
    
    func presentVideoLibrary(for view: UIViewController) {
        currentVC = view
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self;
            myPickerController.sourceType = .photoLibrary
            myPickerController.mediaTypes = ["public.movie"]
            currentVC?.present(myPickerController, animated: true, completion: nil)
        }
    }
    
    func presentAudioLibrary(for view: UIViewController, allowsMultiple: Bool = false) {
        currentVC = view
        // Copy-in pickers race their Inbox copies on multi-select and deliver only a
        // subset of the selection (iOS 18). Open-in-place returns every selected URL
        // immediately as a security-scoped reference; the delegate copies the bytes
        // itself, so there is no system copy to race or drop.
        let documentPicker: UIDocumentPickerViewController
        if #available(iOS 14.0, *) {
            documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.audio])
        } else {
            documentPicker = UIDocumentPickerViewController(documentTypes: ["public.audio"], in: .open)
        }
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = allowsMultiple
        currentVC?.present(documentPicker, animated: true, completion: nil)
    }
    
    func showActionSheet(vc: UIViewController) {
        currentVC = vc
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { [weak self] (alert:UIAlertAction!) -> Void in
            guard let this = self else { return }
            this.presentPhotoLibrary(for: vc)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "CANCEL".localize(), style: .cancel, handler: nil))
        vc.view.tintColor = CometChatTheme_v4.palatte.primary
        vc.present(actionSheet, animated: true, completion: nil)
    }
}


extension CameraHandler: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        currentVC?.dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        switch picker.sourceType {
        case .photoLibrary:
            
            if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
                // Copy video to persistent location to prevent deletion of temp file
                let fileExtension = videoURL.pathExtension.isEmpty ? "mov" : videoURL.pathExtension
                if let persistentURL = copyToPersistentLocation(from: videoURL, fileExtension: fileExtension) {
                    self.videoPickedBlock?(persistentURL.absoluteString)
                } else {
                    // Fallback to original URL if copy fails
                    self.videoPickedBlock?(videoURL.absoluteString)
                }
            }
            
            if let imageURL = info[UIImagePickerController.InfoKey.imageURL] as? URL {
                // Copy image to persistent location to prevent deletion of temp file
                let fileExtension = imageURL.pathExtension.isEmpty ? "jpg" : imageURL.pathExtension
                if let persistentURL = copyToPersistentLocation(from: imageURL, fileExtension: fileExtension) {
                    self.imagePickedBlock?(persistentURL.absoluteString)
                } else {
                    // Fallback to original URL if copy fails
                    self.imagePickedBlock?(imageURL.absoluteString)
                }
            }
        case .camera:
            guard let image = info[.originalImage] as? UIImage else {
                return
            }
            saveImage(imageName: "image_\(Int(Date().timeIntervalSince1970 * 100)).png", image: image)
        case .savedPhotosAlbum:
            self.imagePickedBlock?("\(String(describing: info[UIImagePickerController.InfoKey.imageURL]!))")
        @unknown default:
            break
        }
        currentVC?.dismiss(animated: true, completion: nil)
    }
    
    func saveImage(imageName: String, image: UIImage) {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileName = imageName
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        guard let data = image.jpegData(compressionQuality: 1) else { return }
        
        //Checks if file exists, removes it if so.
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
               
            } catch let removeError {
                print(removeError.localizedDescription)
            }
        }
        do {
            try data.write(to: fileURL)
            let path = self.getImagePathFromDiskWith(fileName: fileName)
            if let imagePath = path {
                self.imagePickedBlock?(imagePath.absoluteString)
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    
    func getImagePathFromDiskWith(fileName: String) -> URL? {
        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)
        if let dirPath = paths.first {
            let imageUrl = URL(fileURLWithPath: dirPath).appendingPathComponent(fileName)
            return imageUrl
        }
        return nil
    }
    
}


extension CameraHandler: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        // Deliver every picked file (multi-select), preserving selection order.
        // Open-in-place URLs are security-scoped — access must be held for the copy.
        for selectedFileURL in urls {
            let needsScope = selectedFileURL.startAccessingSecurityScopedResource()
            defer { if needsScope { selectedFileURL.stopAccessingSecurityScopedResource() } }
            // Copy audio to persistent location to prevent deletion of temp file
            let fileExtension = selectedFileURL.pathExtension.isEmpty ? "m4a" : selectedFileURL.pathExtension
            if let persistentURL = copyToPersistentLocation(from: selectedFileURL, fileExtension: fileExtension) {
                self.audioPickedBlock?(persistentURL.absoluteString)
            } else {
                // Fallback to original URL if copy fails
                self.audioPickedBlock?(selectedFileURL.absoluteString)
            }
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        currentVC?.dismiss(animated: true, completion: nil)
    }
}
