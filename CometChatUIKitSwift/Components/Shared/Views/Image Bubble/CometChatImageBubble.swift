//
//  CometChatImageBubble.swift
//
//
//  Created by Abdullah Ansari on 19/12/22.
//

import UIKit
import QuickLook

public class CometChatImageBubble: UIStackView {
    
    public lazy var imageView: UIImageView = {
        let imageView = UIImageView().withoutAutoresizingMaskConstraints()
        imageView.contentMode = .scaleAspectFill
        imageView.embed(activityIndicator)
        return imageView
    }()
    
    public lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView().withoutAutoresizingMaskConstraints()
        activityIndicator.backgroundColor = CometChatTheme.neutralColor100
        activityIndicator.style = .medium
        activityIndicator.startAnimating()
        return activityIndicator
    }()
    
    var style = ImageBubbleStyle()
    
    
    var imageURL: String?
    weak var controller: UIViewController?
    var onClick: (() -> Void)?
    var previewItemURL = NSURL()
    private weak var imageDownloadService: URLSessionDownloadTask?
    var retryCount = 0
    var isPhotoNeedToDownload = false

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func willMove(toWindow newWindow: UIWindow?) {
        if newWindow != nil {
            setUpStyle()
        }
    }
    
    public func buildUI() {
        backgroundColor = .clear
        axis = .vertical
        spacing = 10
        distribution = .fill
        isLayoutMarginsRelativeArrangement = true
        layoutMargins = UIEdgeInsets(
            top: CometChatSpacing.Padding.p1,
            left: CometChatSpacing.Padding.p1,
            bottom: 0,
            right: CometChatSpacing.Padding.p1
        )
        
        addArrangedSubview(imageView)

        imageView.embed(activityIndicator)

        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onImageClick)))

        // The bubble is a tappable stack view that opens the full-screen viewer, but it
        // published nothing to accessibility: VoiceOver reached a silent, untyped element
        // and a received photo was unreachable to anyone not using the screen visually.
        // Exposed as ONE element rather than letting the image view surface separately,
        // so the announcement matches the thing the tap acts on.
        isAccessibilityElement = true
        accessibilityLabel = "a11y_image_message".localize()
        accessibilityTraits = [.image, .button]
    }
    
    public func setUpStyle() {
        imageView.roundViewCorners(corner: style.imageBorderCornerRadius)
        imageView.borderWith(width: style.imageBorderWidth)
        imageView.borderColor(color: style.imageBorderColor)
    }
    
    public func set(image: UIImage) {
        activityIndicator.isHidden = true
        imageView.image = image 
    }
    
    @discardableResult
    public func setOnClick(onClick: @escaping (() -> Void)) -> Self {
        self.onClick = onClick
        return self
    }
    
    public func set(imageUrl: String, localFileURL: String? = nil, thumbnailURL: String? = nil) {
        // A local copy is used only when it actually decodes; otherwise fall through to the
        // remote/thumbnail path so the bubble keeps its spinner instead of going blank.
        if let localUrl = URL(string: localFileURL ?? ""), localUrl.checkFileExist(),
           let imageData = try? Data(contentsOf: localUrl), let image = UIImage(data: imageData) {
            self.imageURL = localFileURL
            previewItemURL = localUrl as NSURL
            imageView.image = image
            activityIndicator.isHidden = true
        } else if let thumbnailString = thumbnailURL, URL(string: thumbnailString) != nil {
            self.imageURL = imageUrl
            setPreviewImage(url: thumbnailString)
            self.isPhotoNeedToDownload = true
        } else if URL(string: imageUrl) != nil {
            self.imageURL = imageUrl
            setPreviewImage(url: imageUrl)
        }
    }
    
    func setPreviewImage(url: String) {
        
        previewMediaMessage(url: url, completion: { [weak self] success, fileLocation in
            guard let this = self, let fileLocation = fileLocation else {
                return
            }
            let applyImage = {
                this.activityIndicator.isHidden = true
                do {
                    let imageData = try Data(contentsOf: fileLocation)
                    let image = UIImage(data: imageData as Data)
                    if let image = image {
                        this.previewItemURL = fileLocation as NSURL
                        this.imageView.image = image
                    } else if URL(string: url) != fileLocation {
                        // Only drop an undecodable Documents cache entry, never the caller's own file.
                        try? FileManager.default.removeItem(at: fileLocation)
                    }
                } catch {
                    CometChatLogger.error("[ImageBubble] Data error: \(error)")
                }
            }
            if Thread.isMainThread {
                applyImage()
            } else {
                DispatchQueue.main.async(execute: applyImage)
            }
        })

        
    }
    
    func previewMediaMessage(url: String, completion: @escaping (_ success: Bool,_ fileLocation: URL?) -> Void){
        let itemUrl = URL(string: url)
        // A URL with no file name has no cache slot; never look at (or purge) Documents itself.
        guard let destinationUrl = itemUrl?.documentsCacheURL else {
            downloadImage(url: itemUrl, completion: completion)
            return
        }
        if destinationUrl.isExistingRegularFile {
            // Validate cached file is not corrupt (not empty and can be decoded as image)
            if let data = try? Data(contentsOf: destinationUrl), data.count > 0, UIImage(data: data) != nil {
                completion(true, destinationUrl)
            } else {
                // Remove corrupt/empty cached file and re-download
                try? FileManager.default.removeItem(at: destinationUrl)
                downloadImage(url: itemUrl, completion: completion)
            }
        } else if let itemUrl = itemUrl, itemUrl.checkFileExist() {
            // A local file outside Documents is read where it is.
            completion(true, itemUrl)
        } else {
            downloadImage(url: itemUrl, completion: completion)
        }
    }
    
    func downloadImage(url: URL?, completion: @escaping (_ success: Bool,_ fileLocation: URL?) -> Void) {
        
        if retryCount >= 5 { return }
        // No URL, or one with no file name, cannot be downloaded into the cache.
        guard let url, let destinationUrl = url.documentsCacheURL else {
            completion(false, nil)
            return
        }
        retryCount+=1 //retrying thumbnail download

        imageDownloadService = URLSession.shared.downloadTask(with: url, completionHandler: { [weak self] (location, response, error) -> Void in
            guard let tempLocation = location, error == nil else {
                self?.downloadImage(url: url, completion: completion)
                return
            }
            // Check for HTTP errors (e.g., 403 expired signature)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                // Try the main image URL as fallback
                if let fallbackURLString = self?.imageURL, let fallbackURL = URL(string: fallbackURLString), fallbackURL != url {
                    self?.downloadImage(url: fallbackURL, completion: completion)
                } else {
                    completion(false, nil)
                }
                return
            }
            do {
                if destinationUrl.isExistingRegularFile {
                    try FileManager.default.removeItem(at: destinationUrl)
                }
                try FileManager.default.moveItem(at: tempLocation, to: destinationUrl)
                completion(true, destinationUrl)
            } catch let error as NSError {
                completion(false, nil)
            }
        })
        imageDownloadService!.resume()
    }
    
    public func set(controller: UIViewController?) {
        self.controller = controller
    }
    
    @objc func onImageClick() {
        if onClick == nil {
            setupPreviewController()
        } else {
            onClick?()
        }
    }
    
    func setupPreviewController() {
        
        if isPhotoNeedToDownload, let imageURL = imageURL {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            previewMediaMessage(url: imageURL) { [weak self] success, fileLocation in
                guard let this = self, let fileLocation = fileLocation else { return }
                
                DispatchQueue.main.async(execute: {
                    
                    do {
                        let imageData = try Data(contentsOf: fileLocation)
                        let image = UIImage(data: imageData as Data)
                        this.previewItemURL = fileLocation as NSURL
                        this.imageView.image = image
                        this.activityIndicator.isHidden = true
                    } catch {  }
                    
                    this.activityIndicator.isHidden = true
                    this.activityIndicator.stopAnimating()
                    this.startImagePreviewController()
                })
                
            }
        } else {
            startImagePreviewController()
        }
    }
    
    func startImagePreviewController() {
        
        guard let controller = self.controller else { return }
        
        let previewController = QLPreviewController()
        previewController.dataSource = self
        previewController.delegate = self
        previewController.navigationItem.title = ""
        previewController.modalPresentationStyle = .automatic
        previewController.navigationItem.setHidesBackButton(true, animated: false)
    
        if UIDevice.current.userInterfaceIdiom == .pad {
            if let popoverController = previewController.popoverPresentationController {
                popoverController.sourceView = controller.view
                
                let viewFrameInController = self.convert(self.bounds, to: controller.view)
                popoverController.sourceRect = CGRect(x: viewFrameInController.origin.x,
                                                      y: viewFrameInController.origin.y,
                                                      width: 200,
                                                      height: 200)
                popoverController.permittedArrowDirections = [.any]
            }
        }
        controller.present(previewController, animated: true)
    }

    deinit {
        imageDownloadService?.cancel()
    }
}

extension CometChatImageBubble: QLPreviewControllerDelegate, QLPreviewControllerDataSource {
    
    public func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    public func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return previewItemURL as QLPreviewItem
    }
    
    public func previewController(_ controller: QLPreviewController, transitionImageFor item: any QLPreviewItem, contentRect: UnsafeMutablePointer<CGRect>) -> UIImage? {
        return imageView.image
    }
    
    public func previewController(_ controller: QLPreviewController, transitionViewFor item: any QLPreviewItem) -> UIView? {
        return imageView
    }
    
}
