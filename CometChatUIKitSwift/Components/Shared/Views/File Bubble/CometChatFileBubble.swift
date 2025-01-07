//
//  CometChatFileBubble.swift
//
//
//  Created by CometChat on 21/12/22.
//

import Foundation
import UIKit
import QuickLook
import CometChatSDK

/// A custom UI component representing a file bubble in CometChat messages.
public class CometChatFileBubble: UIStackView {
    
    /// The title label displayed in the file bubble.
    public lazy var title: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints()
        return label
    }()

    /// The subtitle label displayed under the title in the file bubble.
    public lazy var subTitle: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints()
        return label
    }()
    
    /// A vertical stack view containing the title and subtitle.
    public lazy var middleStackView: UIStackView = {
        let stackView = UIStackView().withoutAutoresizingMaskConstraints()
        stackView.axis = .vertical
        stackView.distribution = .fill
        title.setContentHuggingPriority(.cometChatLow, for: .vertical)
        stackView.addArrangedSubview(title)
        stackView.addArrangedSubview(subTitle)
        return stackView
    }()
    
    /// An image view that shows the file type icon (e.g., PDF).
    public lazy var fileImageView: UIImageView = {
        let imageView = UIImageView().withoutAutoresizingMaskConstraints()
        imageView.pin(anchors: [.width, .height], to: 32)
        return imageView
    }()
    
    /// A circular progress bar to show the download progress of the file.
    public lazy var downloadProgressBar: DownloadableCircularProgressBar = {
        let imageView = DownloadableCircularProgressBar(frame: CGRect(x: 0, y: 0, width: 22, height: 22)).withoutAutoresizingMaskConstraints()
        imageView.pin(anchors: [.width, .height], to: 22)
        return imageView
    }()
    
    /// The image used for representing the file type (e.g., a PDF icon).
    public var fileImage = UIImage(named: "cometchat_unknown_file_icon", in: CometChatUIKit.bundle, with: nil)?.withRenderingMode(.alwaysOriginal)
    
    /// The image used for representing the download button.
    public var downloadImage = UIImage(named: "download", in: CometChatUIKit.bundle, with: nil)?.withRenderingMode(.alwaysTemplate)
    
    private var fileUrl: URL?
    private var cacheFileURL: URL?
    private var previewItemURL: NSURL?
    private var urlSessionDownloadTask: URLSessionDownloadTask?
        
    /// The parent view controller to present the preview.
    weak var controller: UIViewController?
    
    /// The style of the file bubble, defining appearance properties.
    var style = CometChatMessageBubble.style.incoming.fileBubbleStyle
    
    /// Initializes the file bubble view with a frame.
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
    }
    
    /// Initializes the file bubble view from the storyboard or XIB.
    required init(coder: NSCoder) {
        super.init(coder: coder)
        buildUI()
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Called when the view is about to be added to a superview.
    /// Sets up the UI when added to the view hierarchy.
    public override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview != nil {
            setUpUI()
        }
    }
    
    /// Sets up the UI by applying styles to title, subtitle, and the progress bar.
    public func setUpUI() {
        title.font = style.titleFont
        title.textColor = style.titleColor
        subTitle.font = style.subtitleFont
        subTitle.textColor = style.subtitleColor
        fileImageView.image = fileImage
        downloadProgressBar.cancelImageView.tintColor = style.downloadTintColor
        downloadProgressBar.downloadImageView.tintColor = style.downloadTintColor
        downloadProgressBar.setTrackColor = style.downloadTintColor.withAlphaComponent(0.2)
        downloadProgressBar.setProgressColor = style.downloadTintColor
    }
    
    /// Builds the file bubble UI by arranging its subviews and setting layout constraints.
    public func buildUI() {
        withoutAutoresizingMaskConstraints()
        pin(anchors: [.width], to: 232)
        backgroundColor = .clear
        axis = .horizontal
        distribution = .fill
        spacing = CometChatSpacing.Padding.p2
        isLayoutMarginsRelativeArrangement = true
        layoutMargins = UIEdgeInsets(
            top: CometChatSpacing.Padding.p2,
            left: CometChatSpacing.Padding.p2,
            bottom: CometChatSpacing.Padding.p2,
            right: CometChatSpacing.Padding.p2
        )
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClick)))
        
        addArrangedSubview(fileImageView)
        addArrangedSubview(middleStackView)
        addArrangedSubview(downloadProgressBar)
        
        circularProgressBarSetup()
    }
    
    /// Configures the progress bar and sets up the download and cancel callbacks.
    func circularProgressBarSetup() {
        downloadProgressBar.on(downloadClicked: { [weak self] in
            guard let this = self, let fileUrl = this.fileUrl else { return }
            if this.urlSessionDownloadTask != nil { return }
            this.previewMediaMessage(url: fileUrl, completion: {(success, fileURL) in
                if success {
                    if let url = fileURL {
                        this.previewItemURL = url as NSURL
                        this.presentQuickLook()
                    }
                }
            })
        })
        
        downloadProgressBar.on(cancelClicked: { [weak self] in
            guard let this = self else { return }
            this.urlSessionDownloadTask?.cancel()
            this.urlSessionDownloadTask = nil
        })
    }
    
    /// Sets the file URL for the bubble. This method also hides the download progress bar if the file already exists locally.
    /// - Parameter fileUrl: The URL string of the file to be set.
    public func set(fileUrl: String) {
        guard let url = URL(string: fileUrl) else { return }
        self.fileUrl = url
        if doesFileExists(url: url).0 {
            downloadProgressBar.isHidden = true
        }
    }
    
    /// Sets the file cache URL for the bubble. This method also hides the download progress bar if the file already exists locally.
    /// - Parameter fileUrl: The URL string of the file to be set.
    public func set(cacheFileURL: String?) {
        guard let url = URL(string: cacheFileURL ?? "") else { return }
        self.cacheFileURL = url
        if doesFileExists(url: url, isLocalURL: true, movedLocalURL: { [weak self] url in
            guard let this = self else { return }
            this.previewItemURL = url as? NSURL
        }).0 {
            downloadProgressBar.isHidden = true
        }
    }
    
    /// Sets the view controller that will present the file preview.
    /// - Parameter controller: The `UIViewController` instance to be set.
    public func set(controller: UIViewController) {
        self.controller = controller
    }
    
    /// Sets the title of the file bubble.
    /// - Parameter title: The text to display as the title.
    public func set(title: String) {
        self.title.text = title
    }
    
    /// Sets the subtitle of the file bubble.
    /// - Parameter subtitle: The text to display as the subtitle.
    public func set(subtitle: String) {
        self.subTitle.text = subtitle
    }
    
    /// Checks if the file already exists locally.
    /// - Parameter url: The URL of the file to check.
    /// - Returns: A tuple with a boolean indicating whether the file exists and the local URL of the file.
    func doesFileExists(
        url: URL,
        isLocalURL: Bool = false,
        movedLocalURL: ((_ url: URL?) -> ())? = nil)
    -> (Bool, URL?) {
        
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(url.lastPathComponent)
        
        if FileManager.default.fileExists(atPath: destinationUrl.path) {
            movedLocalURL?(destinationUrl)
            return (true, destinationUrl)
        } else if isLocalURL {
            if FileManager.default.fileExists(atPath: url.path) {
                do {
                    try FileManager.default.copyItem(at: url, to: destinationUrl)
                    movedLocalURL?(destinationUrl)
                } catch {
                    movedLocalURL?(nil)
                }
                return (true, nil)
            } else {
                return (false, nil)
            }
        } else {
            return (false, nil)
        }
    }
    
    /// Downloads and previews a media file message.
    /// - Parameters:
    ///   - url: The URL of the media file.
    ///   - completion: A closure that returns whether the download was successful and the file's local URL.
    func previewMediaMessage(url: URL, completion: @escaping (_ success: Bool,_ fileLocation: URL?) -> Void) {
        if let destinationUrl = doesFileExists(url: url).1  {
            completion(true, destinationUrl)
        } else {
            let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(url.lastPathComponent)
            urlSessionDownloadTask = URLSession.shared.downloadTask(with: url, completionHandler: { [weak self] (location, response, error) -> Void in
                guard let this = self else { return }
                guard let tempLocation = location, error == nil else { return }
                do {
                    DispatchQueue.main.async {
                        this.downloadProgressBar.isHidden = true
                    }
                    try FileManager.default.moveItem(at: tempLocation, to: destinationUrl)
                    completion(true, destinationUrl)
                } catch {
                    DispatchQueue.main.async {
                        this.downloadProgressBar.isHidden = true
                    }
                    completion(true, destinationUrl)
                }
            })
            urlSessionDownloadTask!.resume()
            downloadProgressBar.observeDownloadProgress(for: urlSessionDownloadTask!)
        }
    }
    
    /// Handles the tap gesture on the file bubble. If a previewable file is available, it presents the preview.
    @objc func onClick() {
        if let previewItemURL = previewItemURL {
            presentQuickLook()
        } else {
            if let url = fileUrl, let previewItemURL = doesFileExists(url: url).1 {
                self.previewItemURL = previewItemURL as NSURL
                presentQuickLook()
            }
        }
    }
    
    /// Presents the file preview using the QuickLook framework.
    func presentQuickLook() {
        
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            guard let controller = this.controller else { return }
            
            let previewController = QLPreviewController()
            previewController.dataSource = self
            previewController.delegate = self
            previewController.navigationItem.title = ""
            previewController.modalPresentationStyle = .fullScreen
            previewController.navigationItem.setHidesBackButton(true, animated: false)
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                if let popoverController = previewController.popoverPresentationController {
                    popoverController.sourceView = controller.view
                    
                    let viewFrameInController = this.convert(this.bounds, to: controller.view)
                    popoverController.sourceRect = CGRect(x: viewFrameInController.origin.x,
                                                          y: viewFrameInController.origin.y,
                                                          width: 200,
                                                          height: 200)
                    popoverController.permittedArrowDirections = [.any]
                }
            }
            controller.present(previewController, animated: true)

        }
        
    }
    
    public static func getFileIcon(for mediaMessage: MediaMessage, localURL: URL? = nil) -> UIImage? {
        let bundle = CometChatUIKit.bundle
        
        // Image constants
        let wordFileIcon = UIImage(named: "cometchat_word_file_icon", in: bundle, with: nil)?.withRenderingMode(.alwaysOriginal)
        let pptFileIcon = UIImage(named: "cometchat_ppt_file_icon", in: bundle, with: nil)?.withRenderingMode(.alwaysOriginal)
        let xlsxFileIcon = UIImage(named: "cometchat_xlsx_file_icon", in: bundle, with: nil)?.withRenderingMode(.alwaysOriginal)
        let pdfFileIcon = UIImage(named: "cometchat_pdf_file_icon", in: bundle, with: nil)?.withRenderingMode(.alwaysOriginal)
        let zipFileIcon = UIImage(named: "cometchat_zip_file_icon", in: bundle, with: nil)?.withRenderingMode(.alwaysOriginal)
        let textFileIcon = UIImage(named: "cometchat_text_file_icon", in: bundle, with: nil)?.withRenderingMode(.alwaysOriginal)
        let audioFileIcon = UIImage(named: "cometchat_audio_file_icon", in: bundle, with: nil)?.withRenderingMode(.alwaysOriginal)
        let imageFileIcon = UIImage(named: "cometchat_image_file_icon", in: bundle, with: nil)?.withRenderingMode(.alwaysOriginal)
        let videoFileIcon = UIImage(named: "cometchat_video_file_icon", in: bundle, with: nil)?.withRenderingMode(.alwaysOriginal)
        let linkFileIcon = UIImage(named: "cometchat_link_file_icon", in: bundle, with: nil)?.withRenderingMode(.alwaysOriginal)
        let unknownFileIcon = UIImage(named: "cometchat_unknown_file_icon", in: bundle, with: nil)?.withRenderingMode(.alwaysOriginal)

        // Helper function to get file icon based on file extension
        func getFileIcon(for fileExtension: String?) -> UIImage? {
            guard let fileExtension = fileExtension else { return nil }
            switch fileExtension.lowercased() {
            case "doc", "docx":
                return wordFileIcon
            case "ppt", "pptx":
                return pptFileIcon
            case "xls", "xlsx":
                return xlsxFileIcon
            case "pdf":
                return pdfFileIcon
            case "zip":
                return zipFileIcon
            case "csv":
                return textFileIcon
            case "mp3", "wav", "aac":
                return audioFileIcon
            case "jpg", "jpeg", "png", "gif":
                return imageFileIcon
            case "mp4", "mov":
                return videoFileIcon
            case "txt":
                return textFileIcon
            case "html", "url":
                return linkFileIcon
            default:
                return nil
            }
        }

        // If a local URL is provided, use it to determine the file icon
        if let imageFromLocalURL = getFileIcon(for: localURL?.pathExtension) {
            return imageFromLocalURL
        }
        
        // If no URL, fallback to handling MediaMessage
        if let attachment = mediaMessage.attachment {
            let mimeType = attachment.fileMimeType
            
            if mimeType.contains("video") {
                return videoFileIcon
            } else if mimeType.contains("octet-stream") {
                if attachment.fileUrl.hasSuffix(".doc") {
                    return wordFileIcon
                } else if attachment.fileUrl.hasSuffix(".ppt") {
                    return pptFileIcon
                } else if attachment.fileUrl.hasSuffix(".xls") {
                    return xlsxFileIcon
                }
            } else if mimeType.contains("pdf") {
                return pdfFileIcon
            } else if mimeType.contains("zip") {
                return zipFileIcon
            } else if attachment.fileUrl.contains(".csv") {
                return textFileIcon
            } else if mimeType.contains("audio") {
                return audioFileIcon
            } else if mimeType.contains("image") {
                return imageFileIcon
            } else if mimeType.contains("text") {
                return textFileIcon
            } else if mimeType.contains("link") {
                return linkFileIcon
            }
        }
        
        return unknownFileIcon
    }


}

/// Extension to conform to `QLPreviewControllerDataSource` for previewing files.
extension CometChatFileBubble: QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    public func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }

    public func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return previewItemURL!
    }
    
    public func previewController(_ controller: QLPreviewController, transitionViewFor item: any QLPreviewItem) -> UIView? {
        return self.fileImageView
    }
    
    public func previewController(_ controller: QLPreviewController, transitionImageFor item: any QLPreviewItem, contentRect: UnsafeMutablePointer<CGRect>) -> UIImage? {
        return fileImageView.image
    }
}



extension Int {
    /// Converts an Int Unix Epoch timestamp to the format "15 Oct, 2024".
    func toDateFormatted() -> String {
        // Create a Date object from the Unix timestamp
        let date = Date(timeIntervalSince1970: TimeInterval(self))
        
        // Create a DateFormatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM, yyyy"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        // Convert the date to the desired string format
        return dateFormatter.string(from: date)
    }
}
