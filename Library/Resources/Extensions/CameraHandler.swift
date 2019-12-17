//
//  CameraHandler.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 23/10/19.
//  Copyright © 2019 Pushpsen Airekar. All rights reserved.
//

import Foundation
import UIKit

class CameraHandler: NSObject{
    static let shared = CameraHandler()
    
    fileprivate var currentVC: UIViewController!
    
    //MARK: Internal Properties
    var imagePickedBlock: ((String) -> Void)?
    
    func presentCamera(for view: UIViewController)
    {
        currentVC = view
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self;
            myPickerController.sourceType = .camera
            currentVC.present(myPickerController, animated: true, completion: nil)
        }
        
    }
    
    func presentPhotoLibrary(for view: UIViewController)
    {
        currentVC = view
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self;
            myPickerController.sourceType = .photoLibrary
            currentVC.present(myPickerController, animated: true, completion: nil)
        }
        
    }
    
    func showActionSheet(vc: UIViewController) {
        currentVC = vc
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        
        actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { (alert:UIAlertAction!) -> Void in
            self.presentPhotoLibrary(for: vc)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        vc.present(actionSheet, animated: true, completion: nil)
    }
}


extension CameraHandler: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        currentVC.dismiss(animated: true, completion: nil)
    }
    

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

   
        switch picker.sourceType {
       
        case .photoLibrary:
             self.imagePickedBlock?("\(String(describing: info[UIImagePickerController.InfoKey.imageURL]!))")
        case .camera:
            guard let image = info[.originalImage] as? UIImage else {
                          print("No image found")
                          return
                      }
                      saveImage(image: image) { (error) in
                          print("saveImage not found")
                      }
        case .savedPhotosAlbum:
             self.imagePickedBlock?("\(String(describing: info[UIImagePickerController.InfoKey.imageURL]!))")
        @unknown default:
            break
        }
        currentVC.dismiss(animated: true, completion: nil)
    }
    
    
   
    
    func saveImage(image: UIImage, completion: @escaping (Error?) -> ()) {
       UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(path:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc private func image(path: String, didFinishSavingWithError error: NSError?, contextInfo: UnsafeMutableRawPointer?) {
        debugPrint(path) // That's the path you want
    }
   
}
