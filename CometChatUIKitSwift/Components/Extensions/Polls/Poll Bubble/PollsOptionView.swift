//
//  PollsOptionView.swift
//  CometChatUIKitSwift
//
//  Created by SuryanshBisen on 13/05/24.
//

import Foundation
import CometChatSDK

class PollsOptionView: UIView {
    
    lazy var spinnerView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView().withoutAutoresizingMaskConstraints()
        activityIndicatorView.style = .medium
        activityIndicatorView.isHidden = true
        return activityIndicatorView
    }()
    
    lazy var optionSelectedIndicatorImageView: UIImageView = {
        let imageView = UIImageView().withoutAutoresizingMaskConstraints()
        imageView.pin(anchors: [.height, .width], to: 20)
        imageView.roundViewCorners(corner: .init(cornerRadius: 10))
        return imageView
    }()
    
    lazy var optionProgressBar: UIProgressView = {
        let progressBar = UIProgressView().withoutAutoresizingMaskConstraints()
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.heightAnchor.constraint(equalToConstant: 8).isActive = true
        progressBar.clipsToBounds = true
        progressBar.subviews[1].clipsToBounds = true

        if total == 0 {
            progressBar.setProgress(0, animated: true)
        } else {
            progressBar.setProgress(Float(((Float(pollOption.count)/Float(total)))), animated: false)
        }
        return progressBar
    }()
    
    lazy var optionLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints()
        label.numberOfLines = 0
        return label
    }()
    
    lazy var avatarContainerStackView: UIStackView = {
        let stackView = UIStackView().withoutAutoresizingMaskConstraints()
        stackView.axis = .horizontal
        stackView.spacing = -8
        stackView.distribution = .fill
        stackView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        stackView.pin(anchors: [.height], to: 20)
        stackView.addArrangedSubview(UIView())
        var widthCalculation: CGFloat = 30
        
        for index in 0..<min(pollOption.user.count, 4) {
            let user = pollOption.user[index]
            let avatarView = CometChatAvatar(frame: .zero).withoutAutoresizingMaskConstraints()
            avatarView.style = avatarStyle
            avatarView.setAvatar(avatarUrl: user.avatar, with: user.name)
            avatarView.pin(anchors: [.height, .width], to: 20)
            stackView.addArrangedSubview(avatarView)
            widthCalculation += 16
        }
        stackView.pin(anchors: [.width], to: widthCalculation)
        stackView.setCustomSpacing(4, after: stackView.subviews.last ?? UIView())
        stackView.addArrangedSubview(pollAttemptedCountLabel)
        
        return stackView
    }()
    
    lazy var pollAttemptedCountLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints()
        label.text = String(pollOption.count)
        return label
    }()
    
    var pollOption: PollOptions
    var total: Int
    var onSelected: ((_ pollOption: PollOptions) -> ())?
    var optionCheckIcon: UIImage? {
        didSet {
            if isOptionSelected {
                optionSelectedIndicatorImageView.image = optionCheckIcon
            }
        }
    }
    var optionUncheckIcon: UIImage? {
        didSet {
            if !isOptionSelected {
                optionSelectedIndicatorImageView.image = optionUncheckIcon
            }
        }
    }
    var isOptionSelected: Bool = false
    lazy var avatarStyle: AvatarStyle = {
        var avatarStyle = CometChatAvatar.style
        avatarStyle.textFont = CometChatTypography.Caption2.regular
        return avatarStyle
    }()
    
    init(pollOption: PollOptions, total: Int) {
        self.pollOption = pollOption
        self.total = total
        super.init(frame: .infinite)
        buildUI()
    }
    
    func buildUI() {
        withoutAutoresizingMaskConstraints()
        
        let gesture = UITapGestureRecognizer_WithOptionInfo(target: self, action: #selector(onOptionSelected))
        gesture.option = pollOption.index
        addGestureRecognizer(gesture)
        
        var nsActiveLayout : [NSLayoutConstraint] = [NSLayoutConstraint]()

        addSubview(optionSelectedIndicatorImageView)
        nsActiveLayout += [
            optionSelectedIndicatorImageView.topAnchor.pin(equalTo: topAnchor),
            optionSelectedIndicatorImageView.leadingAnchor.pin(equalTo: leadingAnchor)
        ]
        pollOption.user.forEach { uid, avatar, name in
            if uid == CometChat.getLoggedInUser()?.uid {
                isOptionSelected = true
            }
        }
        
        addSubview(optionLabel)
        optionLabel.text = pollOption.text
        nsActiveLayout += [
            optionLabel.leadingAnchor.pin(equalTo: optionSelectedIndicatorImageView.trailingAnchor, constant: CometChatSpacing.Padding.p2),
            optionLabel.topAnchor.pin(equalTo: optionSelectedIndicatorImageView.topAnchor),
            optionLabel.trailingAnchor.pin(equalTo: avatarContainerStackView.leadingAnchor)
        ]

        addSubview(avatarContainerStackView)
        nsActiveLayout += [
            avatarContainerStackView.trailingAnchor.pin(equalTo: trailingAnchor),
            avatarContainerStackView.topAnchor.pin(equalTo: optionLabel.topAnchor)
        ]
        
        
        addSubview(optionProgressBar)
        nsActiveLayout += [
            optionProgressBar.leadingAnchor.pin(equalTo: optionLabel.leadingAnchor),
            optionProgressBar.trailingAnchor.pin(equalTo: trailingAnchor),
            optionProgressBar.topAnchor.pin(equalTo: optionLabel.bottomAnchor, constant: CometChatSpacing.Padding.p1 + 2),
            optionProgressBar.bottomAnchor.pin(equalTo: bottomAnchor)
        ]
        
        addSubview(spinnerView)
        nsActiveLayout += [
            spinnerView.centerXAnchor.constraint(equalTo: optionSelectedIndicatorImageView.centerXAnchor),
            spinnerView.centerYAnchor.constraint(equalTo: optionSelectedIndicatorImageView.centerYAnchor)
        ]

        NSLayoutConstraint.activate(nsActiveLayout)
    }
    
    @objc func onOptionSelected() {
        spinnerView.isHidden = false
        spinnerView.startAnimating()
        optionSelectedIndicatorImageView.isHidden = true
        onSelected?(pollOption)
    }
    
    @discardableResult
    func set(onClicked: @escaping ((_ pollOption: PollOptions) -> ())) -> Self {
        self.onSelected = onClicked
        return self
    }
    
    @discardableResult
    func set(style: PollBubbleStyle) -> Self {
        optionLabel.textColor = style.optionTextColor
        optionLabel.font = style.optionTextFont
        optionProgressBar.backgroundColor = style.optionProgressBackgroundColor
        optionProgressBar.progressTintColor = style.optionProgressTintColor
        optionProgressBar.roundViewCorners(corner: style.optionProgressCornerRadius)
        optionProgressBar.layer.sublayers?[1].cornerRadius = style.optionProgressCornerRadius.cornerRadius
        pollAttemptedCountLabel.textColor = style.optionCountTextColor
        pollAttemptedCountLabel.font = style.optionCountTextFont
        spinnerView.color = style.optionProgressTintColor
        if isOptionSelected {
            optionSelectedIndicatorImageView.tintColor = style.selectedPollImageTint
        } else {
            optionSelectedIndicatorImageView.tintColor = style.nonSelectedPollImageTint
        }
        return self
    }
        
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
