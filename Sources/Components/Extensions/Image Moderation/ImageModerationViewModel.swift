//
//  ImageModetarationViewModel.swift
//  
//
//  Created by Pushpsen Airekar on 20/02/23.
//

import Foundation
import CometChatSDK

class ImageModetationConfiguration {}

public class ImageModetarationViewModel : DataSourceDecorator {
    
    var imageModerationTypeConstant = ExtensionConstants.imageModeration
    var configuration: ImageModetationConfiguration?
    var loggedInUser = CometChat.getLoggedInUser()
    
    public override init(dataSource: DataSource) {
        super.init(dataSource: dataSource)
    }
    
    public override func getId() -> String {
        return "image-moderation"
    }
    
    public override func getImageMessageBubble(imageUrl: String?, caption: String?, message: MediaMessage?, controller: UIViewController?, style: ImageBubbleStyle?) -> UIView? {
        guard let message = message else { return UIView() }
        
        if let imageBubble = super.getImageMessageBubble(imageUrl: imageUrl, caption: caption, message: message, controller: controller, style: style) as? CometChatImageBubble , let unsafeContentView = checkForImageModeration(message: message) {
            imageBubble.addSubview(unsafeContentView)
            imageBubble.setOnClick {
                let confirmDialog = CometChatDialog()
                confirmDialog.set(title: "SENSITIVE_CONTENT".localize())
                confirmDialog.set(messageText: "THIS_MAY_CONTAIN_UNSAFE_CONTENT_MESSAGE".localize())
                confirmDialog.set(cancelButtonText: "CANCEL".localize())
                confirmDialog.set(confirmButtonText: "OK".localize())
                confirmDialog.open {
                    imageBubble.previewMediaMessage(url: message.attachment?.fileUrl ?? "") { success, fileLocation in
                        if success {
                            if let url = fileLocation {
                                imageBubble.previewItemURL = url as NSURL
                                imageBubble.setupPreviewController()
                            }
                        }
                    }
                }
            }
            return imageBubble
        }
        return super.getImageMessageBubble(imageUrl: imageUrl, caption: caption, message: message, controller: controller, style: style)
    }
    
    
    public func checkImageModeration(message: MediaMessage) -> Bool {
        if let map = ExtensionModerator.extensionCheck(baseMessage: message), message.sender?.uid != CometChat.getLoggedInUser()?.uid, !map.isEmpty && map.containsKey(ExtensionConstants.imageModeration),
           let imageModeration = map[ExtensionConstants.imageModeration], let unsafe = imageModeration["unsafe"] as? String {
            if unsafe == "yes" {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    public func checkForImageModeration(message: MediaMessage) -> UIView? {
        if checkImageModeration(message: message) {
            return getUnsafeContentView()
        } else {
            return nil
        }
    }
    
    public func getUnsafeContentView() -> UIView {
        let containerView = UIView()
        let blurEffect = UIBlurEffect(style: .light)
        let customBlurEffectView = CustomVisualEffectView(effect: blurEffect, intensity: 0.2)
        customBlurEffectView.frame = CGRect(x: 0, y: 0, width: 228, height: 168)
        let dimmedView = UIView()
        dimmedView.backgroundColor = .black.withAlphaComponent(0.2)
        dimmedView.frame = CGRect(x: 0, y: 0, width: 228, height: 168)
        let imageView = UIImageView(frame:  CGRect(x: dimmedView.frame.midX - 25, y: dimmedView.frame.midY - 40, width: 50, height: 50))
        imageView.image = UIImage(systemName: "hand.raised")
        let label = UILabel(frame: CGRect(x: containerView.frame.width / 2 + 65, y: imageView.frame.maxY, width: 120, height: 50))
        label.text = "SENSITIVE_CONTENT".localize()
        label.textColor = .white
        label.font = CometChatTheme.typography.caption1
        containerView.addSubview(customBlurEffectView)
        containerView.addSubview(dimmedView)
        containerView.addSubview(imageView)
        containerView.addSubview(label)
        
        
        return containerView
    }
    
    @objc func onPressed() {
        
    }
    
    
}
