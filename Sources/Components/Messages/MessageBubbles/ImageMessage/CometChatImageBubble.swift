//
//  CometChatImageBubble.swift
//  CometChatUIKit
//
//  Created by Abdullah Ansari on 12/05/22.
//

import UIKit
import CometChatPro
import QuickLook


class CometChatImageBubble: UIView {
    
    // MARK: - Properties
    @IBOutlet weak var unsafeContent: UILabel!
    @IBOutlet weak var unsafeContentView: UIStackView!
    @IBOutlet weak var imageModerationView: UIView!
    @IBOutlet weak var imageThumbnail: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var message: MediaMessage?
    lazy var previewItem = NSURL()
    private var imageRequest: Cancellable?
    private lazy var imageService = ImageService()
    
    var controller: UIViewController?
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    @discardableResult
    public func set(controller: UIViewController) -> Self {
        self.controller = controller
        return self
    }
    
    
    convenience init(frame: CGRect, message: MediaMessage) {
        self.init(frame: frame)
        self.message = message
        
        if message.sentAt == 0 {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        }else{
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
        }
        unsafeContent.text = "SENSITIVE_CONTENT".localize()
        guard let mediaURL = message.metaData, let imageURL = mediaURL["fileURL"] as? String, let url = URL(string: imageURL) else {
            parseThumbnailForImage(forMessage: message)
            parseImageForModeration(forMessage: message)
            print("Media Message not found.")
            return }
        
        if url.checkFileExist() {
            do {
                let imageData = try Data(contentsOf: url)
                let image = UIImage(data: imageData)
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.imageThumbnail.image = image
                }
                if message.sender?.uid != CometChat.getLoggedInUser()?.uid  {
                    parseImageForModeration(forMessage: message)
                }
                
            } catch {
                print("Image url not found correctly.")
            }
        } else {
            parseThumbnailForImage(forMessage: message)
            if message.sender?.uid != CometChat.getLoggedInUser()?.uid  {
                parseImageForModeration(forMessage: message)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Helper Methods
    
    private func commonInit() {
        Bundle.module.loadNibNamed("CometChatImageBubble", owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onImageClick))
        imageThumbnail.addGestureRecognizer(tap)
        imageThumbnail.isUserInteractionEnabled = true
        
        let tapOnImageModerationView: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onImageClick))
        imageModerationView.addGestureRecognizer(tapOnImageModerationView)
        imageModerationView.isUserInteractionEnabled = true
        
        let tapOnUnsafeContentView: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onImageClick))
        unsafeContentView.addGestureRecognizer(tapOnUnsafeContentView)
        unsafeContentView.isUserInteractionEnabled = true
    }
    
    
    @objc  func onImageClick() {
        

        if let metaData = message?.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected[ExtensionConstants.extensions] as? [String : Any], let imageModeration = cometChatExtension[ExtensionConstants.imageModeration] as? [String:Any] , message?.sender?.uid != CometChat.getLoggedInUser()?.uid {

            
            if let unsafeContent = imageModeration["unsafe"] as? String {
                if unsafeContent == "yes" {
                    
                    let confirmDialog = CometChatDialog()
                    confirmDialog.set(title: "SENSITIVE_CONTENT".localize())
                    confirmDialog.set(messageText: "THIS_MAY_CONTAIN_UNSAFE_CONTENT_MESSAGE".localize())
                    confirmDialog.set(confirmButtonText: "OK".localize())
                    confirmDialog.set(cancelButtonText: "CANCEL".localize())
                    confirmDialog.open {
                        self.previewMediaMessage(url: self.message?.attachment?.fileUrl ?? "", completion: {(success, fileURL) in
                            if success {
                                if let url = fileURL {
                                    self.previewItem = url as NSURL
                                    self.presentQuickLook()
                                }
                            }
                        })
                    } onCancel: { }
                }
            }
        }else{
            self.previewMediaMessage(url: message?.attachment?.fileUrl ?? "", completion: {(success, fileURL) in
                if success {
                    if let url = fileURL {
                        self.previewItem = url as NSURL
                        self.presentQuickLook()
                    }
                }
            })
        }
        
        
    }
    
    private func parseThumbnailForImage(forMessage: MediaMessage?) {
        imageThumbnail.image = nil
        if let metaData = forMessage?.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected[ExtensionConstants.extensions] as? [String : Any], let thumbnailGenerationDictionary = cometChatExtension[ExtensionConstants.thumbnailGeneration] as? [String : Any] {
            if let url = URL(string: thumbnailGenerationDictionary["url_medium"] as? String ?? "") {
                imageRequest = imageService.image(for: url) { [weak self] image in
                    guard let strongSelf = self else { return }
                    // Update Thumbnail Image View
                    if let image = image {
                        DispatchQueue.main.async {
                            strongSelf.imageThumbnail.image = image
                        }
                    }
                }
            }
        } else {
            if let message = message, let url = URL(string: message.attachment?.fileUrl ?? "") {
                imageRequest = imageService.image(for: url) { [weak self] image in
                    guard let strongSelf = self else { return }
                    // Update Thumbnail Image View
                    if let image = image {
                        DispatchQueue.main.async {
                            strongSelf.imageThumbnail.image = image
                        }
                    }
                }
            }
        }
    }
    
    private func parseImageForModeration(forMessage: MediaMessage?) {

        if let metaData = forMessage?.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected[ExtensionConstants.extensions] as? [String : Any], let imageModeration = cometChatExtension[ExtensionConstants.imageModeration] as? [String:Any] {
            
            if let unsafeContent = imageModeration["unsafe"] as? String {
                if unsafeContent == "yes" {
                    imageModerationView.addBlur()
                    imageModerationView.roundViewCorners([.layerMaxXMaxYCorner,.layerMaxXMinYCorner,.layerMinXMaxYCorner,.layerMinXMinYCorner], radius: 15)
                    imageModerationView.isHidden = false
                    unsafeContentView.isHidden = false
                }else{
                    imageModerationView.isHidden = true
                    unsafeContentView.isHidden = true
                }
            }
        }
    }
    
    deinit {
        imageRequest?.cancel()
    }
    
}


extension CometChatImageBubble: QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    
    
    /**
     This method will open  quick look preview controller.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func presentQuickLook() {
        DispatchQueue.main.async { [weak self] in
            let previewController = QLPreviewController()
            previewController.modalPresentationStyle = .popover
            previewController.dataSource = self
            previewController.navigationController?.title = ""
            previewController.editButtonItem.isEnabled = false
            if let controller = self?.controller {
                controller.present(previewController, animated: true, completion: nil)
            }
           
        }
    }
    
    /**
     This method will preview media message under  quick look preview controller.
     - Parameters:
     - url:  this specifies the `url` of Media Message.
     - completion: This handles the completion of method.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    func previewMediaMessage(url: String, completion: @escaping (_ success: Bool,_ fileLocation: URL?) -> Void){
        let itemUrl = URL(string: url)
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(itemUrl?.lastPathComponent ?? "")
        if FileManager.default.fileExists(atPath: destinationUrl.path) {
            completion(true, destinationUrl)
        } else {
            URLSession.shared.downloadTask(with: itemUrl!, completionHandler: { (location, response, error) -> Void in
                guard let tempLocation = location, error == nil else { return }
                do {
                    try FileManager.default.moveItem(at: tempLocation, to: destinationUrl)
                    completion(true, destinationUrl)
                } catch let error as NSError {
                    completion(false, nil)
                }
            }).resume()
        }
    }
    
    
    /// Invoked when the Quick Look preview controller needs to know the number of preview items to include in the preview navigation list.
    /// - Parameter controller: A specialized view for previewing an item.
    public func numberOfPreviewItems(in controller: QLPreviewController) -> Int { return 1 }
    
    
    /// Invoked when the Quick Look preview controller needs the preview item for a specified index position.
    /// - Parameters:
    ///   - controller: A specialized view for previewing an item.
    ///   - index: The index position, within the preview navigation list, of the item to preview.
    public func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return self.previewItem as QLPreviewItem
    }
}
