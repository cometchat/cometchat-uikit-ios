//
//  CometChatFileBubble.swift
//
//
//  Created by Abdullah Ansari on 21/12/22.
//

import Foundation
import UIKit
import QuickLook

public class CometChatFileBubble: UIStackView {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var downloadIcon: UIImageView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentStackView: UIStackView!
    private var fileUrl: URL?
    var previewItemURL = NSURL()
    lazy var previewController = QLPreviewController()
    var controller: UIViewController?
    
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
        CometChatUIKit.bundle.loadNibNamed("CometChatFileBubble", owner: self, options:  nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        translatesAutoresizingMaskIntoConstraints = false
        contentStackView.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        contentStackView.isLayoutMarginsRelativeArrangement = true
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 228),
            heightAnchor.constraint(equalToConstant: 56)
        ])
        set(style: FileBubbleStyle())
    }
    
    public func set(fileUrl: String) {
        guard let url = URL(string: fileUrl) else { return }
       // self.previewItemURL = url as NSURL
        self.fileUrl = url
    }
    
    public func set(title: String) {
        self.title.text = title
    }
    
    public func set(titleColor: UIColor) {
        title.textColor = titleColor
    }
    
    public func set(titleFont: UIFont) {
        title.font = titleFont
    }
    
    public func set(subTitle: String) {
        self.subTitle.text = subTitle
    }
    
    public func set(subTitleFont: UIFont) {
        subTitle.font = subTitleFont
    }
    
    public func set(subTitleColor: UIColor) {
        subTitle.textColor = subTitleColor
    }
    
    public func set(downloadIcon: UIImage) {
        self.downloadIcon.image = downloadIcon
    }
    
    public func set(iconTint: UIColor) {
        downloadIcon.tintColor = iconTint
    }
    
    public func set(backgroundColor: UIColor) {
        contentView.backgroundColor(color: backgroundColor)
    }
    
    public func set(cornerRadius: CometChatCornerStyle) {
        contentView.roundViewCorners(corner: cornerRadius)
    }
    
    public func set(borderWidth: CGFloat) {
        contentView.borderWith(width: borderWidth)
    }
    
    public func set(borderColor: UIColor) {
        contentView.borderColor(color: borderColor)
    }
    
    public func set(controller: UIViewController) {
        self.controller = controller
    }
    
    func previewMediaMessage(url: URL, completion: @escaping (_ success: Bool,_ fileLocation: URL?) -> Void){
        
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(url.lastPathComponent ?? "")
        if FileManager.default.fileExists(atPath: destinationUrl.path) {
            completion(true, destinationUrl)
        } else {
            // CometChatSnackBoard.show(message: "Downloading...")
            URLSession.shared.downloadTask(with: url, completionHandler: { (location, response, error) -> Void in
                guard let tempLocation = location, error == nil else { return }
                do {
                   // CometChatSnackBoard.hide()
                    try FileManager.default.moveItem(at: tempLocation, to: destinationUrl)
                    completion(true, destinationUrl)
                } catch let error as NSError {
                    completion(false, nil)
                }
            }).resume()
        }
    }
    
    public func set(style: FileBubbleStyle) {
        set(iconTint: style.iconTint)
        set(titleColor: style.titleColor)
        set(titleFont: style.titleFont)
        set(subTitleFont: style.subtitleFont)
        set(subTitleColor: style.subtitleColor)
        set(backgroundColor: style.background)
        set(cornerRadius: style.cornerRadius)
        set(borderWidth: style.borderWidth)
        set(borderColor: style.borderColor)
    }
    
    @IBAction func onDownloadClick(_ sender: UIButton) {
        guard let fileUrl = fileUrl else { return }
        self.previewMediaMessage(url: fileUrl, completion: {(success, fileURL) in
            if success {
                if let url = fileURL {
                    self.previewItemURL = url as NSURL
                    self.presentQuickLook()
                }
            }
        })
    }
    
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
    
    @IBAction func onFileClicked(_ sender: UIButton) {
        guard let fileUrl = fileUrl else { return }
        self.previewMediaMessage(url: fileUrl, completion: {(success, fileURL) in
            if success {
                if let url = fileURL {
                    self.previewItemURL = url as NSURL
                    self.presentQuickLook()
                }
            }
        })
    }

}

extension CometChatFileBubble: QLPreviewControllerDelegate, QLPreviewControllerDataSource {
    
   public func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    public func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return previewItemURL as QLPreviewItem
    }
}
