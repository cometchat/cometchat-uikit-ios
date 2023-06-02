//
//  CometChatImageBubble.swift
//
//
//  Created by Abdullah Ansari on 19/12/22.
//

import UIKit
import QuickLook

public class CometChatImageBubble: UIStackView {
   
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var caption: UILabel!
    var previewItemURL = NSURL()
    var imageURL: String?
    private var imageRequest: Cancellable?
    private lazy var imageService = ImageService()
    var controller: UIViewController?
    var onClick: (() -> Void)?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        customInit()
        fatalError("init(coder:) has not been implemented")
    }
    
    private func customInit() {
        CometChatUIKit.bundle.loadNibNamed("CometChatImageBubble", owner: self, options:  nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        set(width: 228, height: 168)
       // set(style: ImageBubbleStyle())
        activityIndicator.isHidden = false
        self.imageView.image = UIImage(named: "default-image.png", in: CometChatUIKit.bundle, compatibleWith: nil)
    }
    
    @discardableResult
    public func set(width: CGFloat, height: CGFloat) -> Self {
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: width),
            heightAnchor.constraint(greaterThanOrEqualToConstant: height)
        ])
        return self
    }

    @discardableResult
    public func set(captionTextColor: UIColor) -> Self {
        caption.textColor = captionTextColor
        return self
    }
    
    @discardableResult
    public func set(captionTextFont: UIFont) -> Self {
        caption.font = captionTextFont
        return self
    }
    
    public func set(image: UIImage) {
        imageView.image = image
        activityIndicator.isHidden = true
    }
    
    @discardableResult
    public func setOnClick(onClick: @escaping (() -> Void)) -> Self {
        self.onClick = onClick
        return self
    }
    
    public func set(imageUrl: String, sentAt: Double? = nil) {
        self.imageURL = imageUrl
        if let url = URL(string: imageUrl) {
            imageRequest = imageService.image(for: url) { [weak self] image in
                guard let this = self else { return }
                // Update Thumbnail Image View
                if let image = image {
                    this.imageView.image = image
                } else {
                    this.imageView.isHidden = true
                }
                this.activityIndicator.isHidden = true
            }
        }
    }
    
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
    
    @discardableResult
    public func set(backgroundColor: UIColor) -> Self {
        contentView.backgroundColor = backgroundColor
        return self
    }

    @discardableResult
    public func set(cornerRadius: CometChatCornerStyle) -> Self {
        contentView.roundViewCorners(corner: cornerRadius)
        return self
    }
    
    @discardableResult
    public func set(borderWidth: CGFloat) -> Self {
        contentView.borderWith(width: borderWidth)
        return self
    }
    
    @discardableResult
    public func set(borderColor: UIColor) -> Self {
        contentView.borderColor(color: borderColor)
        return self
    }
    
    @discardableResult
    public func set(activityIndicatorTint: UIColor) -> Self {
        ActivityIndicator.set(tintColor: activityIndicatorTint)
        return self
    }
    
    public func set(caption: String) {
        if !caption.isEmpty {
            self.caption.isHidden = false
            self.caption.text =  caption
            contentStackView.layoutMargins = UIEdgeInsets(top: 0, left: -1, bottom: 10, right: -1)
            contentStackView.isLayoutMarginsRelativeArrangement = true
        } else {
            self.caption.isHidden = true
        }
    }
    
    public func set(controller: UIViewController?) {
        self.controller = controller
    }
    
    @IBAction func onImageClick(_ sender: UIButton) {
        if onClick == nil {
            guard let imageURL = imageURL else { return }
            guard let _ = URL(string: imageURL) else { return }
            previewMediaMessage(url: imageURL) { success, fileLocation in
                if success {
                    if let url = fileLocation {
                        self.previewItemURL = url as NSURL
                        self.setupPreviewController()
                    }
                }
            }
        } else {
            onClick?()
        }
    }
    
    func setupPreviewController() {
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            let previewController = QLPreviewController()
            previewController.modalPresentationStyle = .popover
            previewController.dataSource = self
            previewController.delegate = self
            previewController.navigationController?.title = ""
            previewController.editButtonItem.isEnabled = false
            if let controller = this.controller {
                controller.present(previewController, animated: true, completion: nil)
             }
        }
    }
    
    public func set(style: ImageBubbleStyle) {
        set(captionTextColor: style.captionTextColor)
        set(captionTextFont: style.captionTextFont)
        set(backgroundColor: style.background)
        set(cornerRadius: style.cornerRadius)
        set(borderWidth: style.borderWidth)
        set(borderColor: style.borderColor)
        set(activityIndicatorTint: style.activityIndicatorTint)
    }

    deinit {
        imageRequest?.cancel()
    }
}

extension CometChatImageBubble: QLPreviewControllerDelegate, QLPreviewControllerDataSource {
    
   public func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    public func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return previewItemURL as QLPreviewItem
    }
    
}
