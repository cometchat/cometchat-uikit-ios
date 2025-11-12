//
//  CometChatCallRecordingTVC.swift
//  Sample App
//
//  Created by Dawinder on 30/10/24.
//

import Foundation
import UIKit
import CometChatSDK
import CometChatUIKitSwift

public class CallRecordingTVC: UITableViewCell {
    static let identifier = "CallRecordingTVC"

    public lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = CometChatTypography.Heading4.medium
        label.textColor = CometChatTheme.textColorPrimary
        return label
    }()

    public lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = CometChatTypography.Button.regular
        label.textColor = CometChatTheme.textColorSecondary
        return label
    }()

    public lazy var playButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "play"), for: .normal)
        button.tintColor = CometChatTheme.iconColorHighlight
        return button
    }()

    public lazy var downloadButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.down.circle"), for: .normal)
        button.tintColor = CometChatTheme.iconColorHighlight
        return button
    }()
    
    public lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = CometChatTheme.iconColorHighlight
        indicator.hidesWhenStopped = true
        return indicator
    }()

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func setupUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(playButton)
        contentView.addSubview(downloadButton)
        contentView.addSubview(activityIndicator)
        
        selectionStyle = .none
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        playButton.translatesAutoresizingMaskIntoConstraints = false
        downloadButton.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            playButton.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
            playButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            playButton.heightAnchor.constraint(equalToConstant: 24),
            playButton.widthAnchor.constraint(equalToConstant: 24),
            
            downloadButton.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 24),
            downloadButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            downloadButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            downloadButton.heightAnchor.constraint(equalToConstant: 24),
            downloadButton.widthAnchor.constraint(equalToConstant: 24),
            
            activityIndicator.centerXAnchor.constraint(equalTo: downloadButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: downloadButton.centerYAnchor)
        ])
    }
    
    public func configure(with status: DownloadingStatus) {
        switch status {
        case .downloading:
            downloadButton.isHidden = true
            activityIndicator.startAnimating()
        case .downloaded:
            downloadButton.isHidden = false
            activityIndicator.stopAnimating()
        case .failed:
            downloadButton.isHidden = false
            activityIndicator.stopAnimating()
        }
    }
}
