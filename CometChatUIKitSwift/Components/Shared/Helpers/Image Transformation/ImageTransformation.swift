//
//  ImageBlur.swift
//  CometChatSwift
//
//  Created by Pushpsen Airekar on 02/02/21.
//  Copyright © 2021 MacMini-03. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
   convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
       let rect = CGRect(origin: .zero, size: size)
       UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
       color.setFill()
       UIRectFill(rect)
       let image = UIGraphicsGetImageFromCurrentImageContext()
       UIGraphicsEndImageContext()
       guard let cgImage = image?.cgImage else { return nil }
       self.init(cgImage: cgImage)
   }
}

//Blur the Image:
protocol Bluring {
   func addBlur(_ alpha: CGFloat)
}

extension Bluring where Self: UIView {
   func addBlur(_ alpha: CGFloat = 1) {
       // create effect
       if #available(iOS 13.0, *) {
           let effect = UIBlurEffect(style: .systemThinMaterialDark)
           let effectView = UIVisualEffectView(effect: effect)
           
           // set boundry and alpha
           effectView.frame = self.bounds
           effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
           effectView.alpha = alpha
           self.addSubview(effectView)
       } else {
           let effect = UIBlurEffect(style: .dark)
           let effectView = UIVisualEffectView(effect: effect)
           
           // set boundry and alpha
           effectView.frame = self.bounds
           effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
           effectView.alpha = alpha
           self.addSubview(effectView)
       }
       
   }
}

// Conformance
extension UIView: Bluring {}

extension URL    {
   func checkFileExist() -> Bool {
       let path = self.path
       if (FileManager.default.fileExists(atPath: path))   {
           return true
        } else {
           return false;
       }
   }

   /// The kit's own folder for downloaded image and file bubbles: `Documents/cc_media`, created if
   /// missing. Nil only when the app has no Documents directory.
   static var kitMediaCacheDirectory: URL? {
       guard let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
       let dir = documents.appendingPathComponent("cc_media", isDirectory: true)
       try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
       return dir
   }

   /// Where a download of this URL is cached: `Documents/cc_media/<file name>`.
   ///
   /// The slot is inside the kit's own folder, not the Documents root (iOS-SEC-1): a message's
   /// link is chosen by its sender, so another user's link such as `https://any.host/notes.sqlite`
   /// made the bubble show, open and share the reader's own `Documents/notes.sqlite` as that
   /// user's file. Now a link can only reach a file the kit itself downloaded.
   ///
   /// Nil when the URL names no file ("https://host", "https://host/", ""): its last path
   /// component is empty or "/", which would resolve to the folder itself, and the bubbles'
   /// purge/replace paths would then delete that whole folder.
   var documentsCacheURL: URL? {
       let name = lastPathComponent
       guard !name.isEmpty, name != "/", name != ".", name != ".." else { return nil }
       return URL.kitMediaCacheDirectory?.appendingPathComponent(name, isDirectory: false)
   }

   /// True only for an existing regular file — never for a directory.
   var isExistingRegularFile: Bool {
       var isDirectory: ObjCBool = false
       return FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) && !isDirectory.boolValue
   }
}

