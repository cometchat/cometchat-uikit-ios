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
    
    public func set(imageUrl: String, localFileURL: String? = nil) {
        let localUrl = URL(string: localFileURL ?? "")
        if (localUrl?.checkFileExist()) ?? false {
            self.imageURL = localFileURL
            do {
                let imageData = try Data(contentsOf: localUrl!)
                let image = UIImage(data: imageData as Data)
                previewItemURL = localUrl! as NSURL
                imageView.image = image
                activityIndicator.isHidden = true
            } catch {
                self.imageURL = imageUrl
            }
        }else if let url = URL(string: imageUrl) {
            self.imageURL = imageUrl
            previewMediaMessage(url: imageUrl, completion: { [weak self] success, fileLocation in
                guard let this = self, let fileLocation = fileLocation else { return }
                DispatchQueue.main.async(execute: {
                    this.activityIndicator.isHidden = true
                    do {
                        let imageData = try Data(contentsOf: fileLocation)
                        let image = UIImage(data: imageData as Data)
                        this.previewItemURL = fileLocation as NSURL
                        this.imageView.image = image
                        this.activityIndicator.isHidden = true
                    } catch {  }
                })
            })
        }
    }
    
    func previewMediaMessage(url: String, completion: @escaping (_ success: Bool,_ fileLocation: URL?) -> Void){
        let itemUrl = URL(string: url)
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(itemUrl?.lastPathComponent ?? "")
        if FileManager.default.fileExists(atPath: destinationUrl.path) {
            completion(true, destinationUrl)
        } else if (itemUrl?.checkFileExist())! {
            completion(true, destinationUrl)
        } else {
            downloadImage(url: itemUrl, completion: completion)
        }
    }
    
    func downloadImage(url: URL?, completion: @escaping (_ success: Bool,_ fileLocation: URL?) -> Void) {
        
        if retryCount >= 5 { return }
        retryCount+=1 //retrying thumbnail download
        
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(url?.lastPathComponent ?? "")
        imageDownloadService = URLSession.shared.downloadTask(with: url!, completionHandler: { [weak self] (location, response, error) -> Void in
            guard let tempLocation = location, error == nil else {
                self?.downloadImage(url: url, completion: completion)
                return
            }
            do {
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
        guard let controller = self.controller else { return }
        
        //TODO: IMAGE PREIVEW 
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
