//
//  StateView.swift
//  CometChatUIKitSwift
//
//  Created by Suryansh on 26/09/24.
//

import UIKit
import Foundation

public class StateView: UIStackView {
    
    public lazy var titleLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints()
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    public lazy var subtitleLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints()
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    public lazy var imageView: UIImageView = {
        let imageView = UIImageView().withoutAutoresizingMaskConstraints()
        imageView.pin(anchors: [.height, .width], to: 120)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    public lazy var retryButton: UIButton = {
        let button = UIButton().withoutAutoresizingMaskConstraints()
        button.setTitle("Retry", for: .normal) //TODO: add text to localise files
        button.pin(anchors: [.width], to: 120)
        button.pin(anchors: [.height], to: 40)
        return button
    }()
    
    public lazy var containerStackView: UIView = {
        let stackView = UIStackView().withoutAutoresizingMaskConstraints()
        stackView.axis = .vertical
        stackView.spacing = CometChatSpacing.Padding.p5
        stackView.distribution = .fill
        stackView.alignment = .center
        
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.setCustomSpacing(CometChatSpacing.Padding.p1, after: titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.addArrangedSubview(retryButton)

        return stackView
    }()
    
    var title: String {
        didSet {
            titleLabel.text = title
        }
    }
    
    var subtitle: String {
        didSet {
            subtitleLabel.text = subtitle
        }
    }
    
    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
    
    public var onRetry: (() -> ())?
    
    public init(title: String, subtitle: String, image: UIImage? = nil, buttonText: String? = nil) {
        
        self.title = title
        self.subtitle = subtitle
        self.image = image
        super.init(frame: .infinite)
        
        self.titleLabel.text = title
        self.subtitleLabel.text = subtitle
        self.imageView.image = image

        if let buttonText{
            self.retryButton.setTitle(buttonText, for: .normal)
            self.retryButton.isHidden = false
        }else{
            self.retryButton.isHidden = true
        }

        buildUI()
    }
    
    @objc func retryTapped(){
        onRetry?()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buildUI() {
        withoutAutoresizingMaskConstraints()
        pin(anchors: [.width], to:(UIScreen.main.bounds.width/1.5))
        
        axis = .vertical
        spacing = CometChatSpacing.Padding.p5
        distribution = .fill
        alignment = .center
        
        addArrangedSubview(imageView)
        addArrangedSubview(titleLabel)
        setCustomSpacing(CometChatSpacing.Padding.p1, after: titleLabel)
        addArrangedSubview(subtitleLabel)
        addArrangedSubview(retryButton)
        
        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)

    }
    
    
}
