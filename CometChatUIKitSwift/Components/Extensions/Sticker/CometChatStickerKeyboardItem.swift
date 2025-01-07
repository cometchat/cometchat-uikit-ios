//  CometChatSharedMediaItem.swift
 
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2019 CometChat Inc. All rights reserved.


// MARK: - Importing Frameworks.

import UIKit
import AVFoundation
import CoreMedia
import CometChatSDK

class StickerCell: UICollectionViewCell {

    // MARK: - Declaration of Views
    var stickerIcon: UIImageView! // Image view for displaying the sticker icon
    private var imageRequest: Cancellable? // Holds the cancellable image request
    private lazy var imageService = ImageService() // Lazy initialization of the image service
    private var loader: UIActivityIndicatorView! // Loader to indicate image loading

    // MARK: - Configuration
    // Property for configuring the cell with a sticker
    var sticker: CometChatSticker! {
        didSet {
            configureCell(for: sticker.url) // Update the cell with the sticker's URL
        }
    }
    
    // Property for configuring the cell with a sticker set
    var stickerSet: CometChatStickerSet! {
        didSet {
            configureCell(for: stickerSet.thumbnail) // Update the cell with the sticker set's thumbnail
        }
    }
    
    // MARK: - Initialization and Setup
    // Initializer for programmatically created cells
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStickerIcon() // Set up the sticker icon
        setupLoader() // Set up the loader
    }
    
    // Required initializer for loading from storyboard or XIB
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupStickerIcon() // Set up the sticker icon
        setupLoader() // Set up the loader
    }

    // MARK: - Setup Methods
    // Configures the sticker icon view
    private func setupStickerIcon() {
        stickerIcon = UIImageView().withoutAutoresizingMaskConstraints() // Initialize the sticker icon
        stickerIcon.contentMode = .scaleAspectFit // Set the content mode for the image view
        stickerIcon.clipsToBounds = true // Enable clipping to bounds
        contentView.embed(stickerIcon) // Embed the sticker icon in the content view
        contentView.layer.cornerRadius = CometChatSpacing.Radius.r2 // Set corner radius for content view
        stickerIcon.layer.cornerRadius = CometChatSpacing.Radius.r2 // Set corner radius for sticker icon
        stickerIcon.layer.masksToBounds = true // Enable masks to bounds for the sticker icon
    }
    
    // Configures the loader view
    private func setupLoader() {
        loader = UIActivityIndicatorView(style: .medium) // Initialize the activity indicator
        loader.hidesWhenStopped = true // Hide the loader when not animating
        contentView.addSubview(loader) // Add the loader to the content view
        
        // Set up constraints for the loader to center it in the sticker icon
        loader.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loader.centerXAnchor.constraint(equalTo: stickerIcon.centerXAnchor),
            loader.centerYAnchor.constraint(equalTo: stickerIcon.centerYAnchor)
        ])
    }

    // Configures the cell's image based on the provided URL string
    private func configureCell(for urlString: String?) {
        loader.startAnimating() // Start the loader animation
        stickerIcon.image = nil // Clear the existing image

        // Check if the URL string is valid
        guard let urlString = urlString, let url = URL(string: urlString) else {
            loader.stopAnimating() // Stop the loader
            // Set a default image if the URL is invalid
            stickerIcon.image = UIImage(named: "default-sticker-image", in: CometChatUIKit.bundle, compatibleWith: nil)
            return
        }

        // Request the image from the image service
        imageRequest = imageService.image(for: url, cacheType: .normal) { [weak self] image in
            guard let strongSelf = self else { return } // Prevent retain cycles
            strongSelf.loader.stopAnimating() // Stop the loader
            // Set the loaded image or a default image if loading fails
            strongSelf.stickerIcon.image = image ?? UIImage(named: "default-sticker-image", in: CometChatUIKit.bundle, compatibleWith: nil)
        }
    }

    // Prepare the cell for reuse
    override func prepareForReuse() {
        super.prepareForReuse() // Call superclass implementation
        imageRequest?.cancel() // Cancel any ongoing image requests
        loader.stopAnimating() // Stop the loader
        stickerIcon.image = nil // Clear the sticker icon image
    }
}
