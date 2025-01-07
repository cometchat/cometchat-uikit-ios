//
//  CometChatImageBubble.swift
//
//
//  Created by Abdullah Ansari on 19/12/22.
//

import UIKit

public class CometChatStickerBubble: UIStackView {
    
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
    
    var style = StickerBubbleStyle()
    
    var imageURL: String?
    private weak var imageRequest: Cancellable?
    private lazy var imageService = ImageService()
    weak var controller: UIViewController?
    var onClick: (() -> Void)?
    
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
            bottom: CometChatSpacing.Padding.p2,
            right: CometChatSpacing.Padding.p1
        )
        
        addArrangedSubview(imageView)
        
        imageView.embed(activityIndicator)
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onImageClick)))
    }
    
    public func setUpStyle() {  }
    
    @objc func onImageClick() {
        onClick?()
    }
    
    public func set(image: UIImage) {
        if #available(iOS 15.0, *) {
            image.prepareForDisplay { [weak self] image in
                guard let this = self else { return }
                DispatchQueue.main.async {
                    this.activityIndicator.isHidden = true
                    this.imageView.image = image
                }
            }
        } else {
            activityIndicator.isHidden = true
            imageView.image = image
        }
        
        
    }
    
    @discardableResult
    public func setOnClick(onClick: @escaping (() -> Void)) -> Self {
        self.onClick = onClick
        return self
    }
    
    public func set(imageUrl: String) {
        guard let itemUrl = URL(string: imageUrl) else { return }

        imageRequest = ImageService().image(for: itemUrl, cacheType: .normal) { [weak self] image in
            guard let this = self else { return }
            if let image = image {
                this.set(image: image)
            }
        }
        
    }
    
    public func set(controller: UIViewController?) {
        self.controller = controller
    }
    
    deinit {
        imageRequest?.cancel()
    }
}
