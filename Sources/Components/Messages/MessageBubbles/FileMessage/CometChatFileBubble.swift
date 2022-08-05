//
//  CometChatFileBubble.swift
//  CometChatUIKit
//
//  Created by Abdullah Ansari on 16/05/22.
//

import UIKit
import CometChatPro
import QuickLook



class CometChatFileBubble: UIView {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var thumbnail: UIImageView!
    
    var message: MediaMessage?
    var controller: UIViewController?
    lazy var previewItem = NSURL()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }

    convenience init(frame: CGRect, message: MediaMessage, isStandard: Bool) {
        self.init(frame: frame)
        self.message = message
        if let fileName = message.attachment?.fileName {
            set(title: fileName.capitalized)
        }else{
            set(title: "PROCESSING".localize())
        }
        set(subTitle: "SHARED_FILE".localize())
        setup(message: message, isStandard: isStandard)
        
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setup(message: MediaMessage, isStandard: Bool) {
        let fileBubbleView  = FileBubbleStyle(
            titleColor: CometChatTheme.palatte?.accent900,
            titleFont: CometChatTheme.typography?.Subtitle1,
            subTitleColor: CometChatTheme.palatte?.accent700,
            subTitleFont: CometChatTheme.typography?.Subtitle2,
            thumbnailColor: CometChatTheme.palatte?.primary
        )
        set(style: fileBubbleView)
    }
    
    private func set(style: FileBubbleStyle) -> Self {
        self.set(titleColor: style.titleColor!)
        self.set(subTitleColor: style.subTitleColor!)
        self.set(titleFont: style.titleFont!)
        self.set(subTitleFont: style.subTitleFont!)
        self.set(thumbnailColor: style.thumbnailColor!)
        return self
    }
    
    
    @discardableResult
    public func set(controller: UIViewController) -> Self {
        self.controller = controller
        return self
    }
    
    
    
    @discardableResult
    @objc public func set(title: String) -> Self {
        self.title.text = title
        return self
    }
    
    @discardableResult
    @objc public func set(titleFont: UIFont) -> Self {
        self.title.font = titleFont
        return self
    }
    
    
    @discardableResult
    @objc public func set(titleColor: UIColor) -> Self {
        self.title.textColor = titleColor
        return self
    }
    
    @discardableResult
    @objc public func set(subTitle: String) -> Self {
        self.subTitle.text = subTitle
        return self
    }
    
    @discardableResult
    @objc public func set(subTitleFont: UIFont) -> Self {
        self.subTitle.font = subTitleFont
        return self
    }
    
    
    @discardableResult
    @objc public func set(subTitleColor: UIColor) -> Self {
        self.subTitle.textColor = subTitleColor
        return self
    }
    
    @discardableResult
    @objc public func set(thumbnailColor: UIColor) -> Self {
        self.thumbnail.image = UIImage(systemName: "arrow.down.circle")
        self.thumbnail.tintColor = thumbnailColor
        return self
    }
    
    private func customInit() {
        CometChatUIKit.bundle.loadNibNamed("CometChatFileBubble", owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onFileClick))
        containerView.addGestureRecognizer(tap)
        containerView.isUserInteractionEnabled = true
        
    }
    
    @objc  func onFileClick() {
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


extension CometChatFileBubble: QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    
    
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

