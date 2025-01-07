
//  StickerKeyboard.swift
//  Created by admin on 04/11/22.

import Foundation
import UIKit
import CometChatSDK

protocol  StickerViewDelegate {
    func didStickerSelected(sticker: CometChatSticker)
    func didStickerSetSelected(stickerSet: CometChatStickerSet)
    func didClosePressed()
}

protocol StickerkeyboardDelegate {
    func showStickerKeyboard(status: Bool)
}

@objc @IBDesignable 
public class CometChatStickerKeyboard: UIView {
    
    /// Collection view to display sticker sets in a horizontal scrollable layout.
    lazy var stickerSetCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).withoutAutoresizingMaskConstraints()
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = layout
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        collectionView.showsVerticalScrollIndicator = false  // Disable vertical scroll indicator
        collectionView.showsHorizontalScrollIndicator = false // Disable horizontal scroll indicator
        collectionView.dataSource = self  // Set the data source to the current class
        collectionView.delegate = self    // Set the delegate to the current class
        collectionView.isPagingEnabled = true // Enable paging for horizontal scrolling
        collectionView.backgroundColor = .clear // Set background color to clear
        collectionView.register(StickerCell.self, forCellWithReuseIdentifier: "StickerCell") // Register custom cell for sticker set
        return collectionView
    }()

    /// Collection view to display stickers in a horizontal scrollable layout.
    lazy var stickersCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).withoutAutoresizingMaskConstraints()
        collectionView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        collectionView.showsVerticalScrollIndicator = false  // Disable vertical scroll indicator
        collectionView.showsHorizontalScrollIndicator = false // Disable horizontal scroll indicator
        collectionView.dataSource = self  // Set the data source to the current class
        collectionView.delegate = self    // Set the delegate to the current class
        collectionView.isPagingEnabled = true // Enable paging for horizontal scrolling
        collectionView.backgroundColor = .clear // Set background color to clear
        collectionView.register(StickerCell.self, forCellWithReuseIdentifier: "StickerCell") // Register custom cell for stickers
        return collectionView
    }()

    /// A separator line view to visually separate UI components.
    lazy var separatorLineView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints()
        return view
    }()

    /// A separator used for separating sections in the sticker keyboard with a predefined accent color.
    lazy var stickerKeyboardSeparator: UIView = {
        let separator = UIView().withoutAutoresizingMaskConstraints()
        separator.backgroundColor = CometChatTheme_v4.palatte.accent100 // Set background color to an accent
        return separator
    }()

    /// A view shown when no stickers or sticker sets are available.
    lazy var emptyView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints()
        return view
    }()

    /// A stack view that holds the UI elements displayed when no stickers are available.
    lazy var emptyStackView: UIStackView = {
        let view = UIStackView().withoutAutoresizingMaskConstraints()
        view.axis = .vertical // Arrange elements vertically
        view.alignment = .center // Center-align the elements
        view.spacing = CometChatSpacing.Spacing.s1 // Set vertical spacing between elements
        return view
    }()

    /// A view shown when there's an error fetching stickers.
    lazy var errorView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints()
        return view
    }()

    /// An image view displayed when there are no stickers available.
    lazy var emptyImageView: UIImageView = {
        let imageView = UIImageView().withoutAutoresizingMaskConstraints()
        imageView.pin(anchors: [.height, .width], to: 60) // Set fixed height and width
        imageView.image = UIImage(named: "sticker-image-filled", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage() // Set placeholder image
        imageView.tintColor = CometChatTheme.iconColorTertiary // Apply a tint color to the image
        return imageView
    }()

    /// A label for displaying a title when the sticker set is empty.
    lazy var emptyTitleLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints()
        label.textAlignment = .center // Center-align the text
        return label
    }()

    /// A label for displaying a subtitle when the sticker set is empty.
    lazy var emptySubTitleLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints()
        label.textAlignment = .center // Center-align the text
        return label
    }()

    /// A label for displaying error messages.
    lazy var errorLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints()
        label.textAlignment = .center // Center-align the text
        label.numberOfLines = 0 // Allow multiple lines for longer error messages
        return label
    }()

    /// A button to allow users to retry fetching stickers in case of an error.
    lazy var errorRetryButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.counterclockwise")?.withRenderingMode(.alwaysTemplate), for: .normal) // Set retry button image
        button.addTarget(self, action: #selector(retry), for: .touchUpInside) // Set action to retry fetching stickers
        return button
    }()

    /// A stack view to hold the error message and retry button.
    lazy var errorStackView: UIStackView = {
        let view = UIStackView().withoutAutoresizingMaskConstraints()
        view.axis = .vertical // Arrange elements vertically
        view.alignment = .center // Center-align the elements
        view.spacing = CometChatSpacing.Spacing.s1 // Set vertical spacing between elements
        return view
    }()

    // MARK: - Data Variables

    /// Array to hold all stickers fetched.
    var allstickers = [CometChatSticker]()

    /// Array to hold stickers of the selected sticker set.
    var stickers = [CometChatSticker]()

    /// Array to hold stickers displayed in the preview section.
    var stickersForPreview = [CometChatSticker]()

    /// Array to hold sticker sets fetched from the server.
    var stickerSet = [CometChatStickerSet]()

    // MARK: - Loading State Variables

    /// View shown when the loading state is active.
    var loadingView: UIView!

    /// Boolean to disable the loading state if required.
    public var disableLoadingState: Bool = false

    /// Boolean to track whether the loading view is currently visible.
    var isLoadingViewVisible = false

    // MARK: - Style Variables

    /// Static style configuration for the sticker keyboard.
    public static var style = StickerKeyboardStyle()

    /// Lazy-loaded style for the sticker keyboard, which can be overridden.
    public lazy var style = CometChatStickerKeyboard.style

    // MARK: - Callbacks

    /// Closure called when a sticker is tapped.
    var onStickerTap: ((_ sticker: CometChatSticker) -> Void)?

    /// Closure called when a sticker set is selected.
    var onStickerSetSelected: ((_ stickerSet: CometChatStickerSet) -> Void)?

    /// Closure called when the sticker keyboard is closed.
    var onClose: (() -> Void)?

    // MARK: - Initializers

    /// Initializer to set up the UI when the view is created programmatically.
    override public init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        buildUI()
    }

    /// Initializer for creating the view from a storyboard or XIB file.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        buildUI()
    }

    open func buildUI() {
        
        // Initialize the loading view
        loadingView = CometChatStickerShimmer()
        
        // Add subviews
        self.addSubview(stickerSetCollectionView)
        self.addSubview(stickersCollectionView)
        self.addSubview(separatorLineView)
        self.addSubview(errorView)
        self.addSubview(emptyView)
        
        // Configure empty stack view
        emptyStackView.addArrangedSubview(emptyImageView)
        emptyStackView.addArrangedSubview(emptyTitleLabel)
        emptyStackView.addArrangedSubview(emptySubTitleLabel)
        
        // Configure error stack view
        errorStackView.addArrangedSubview(errorLabel)
        errorStackView.addArrangedSubview(errorRetryButton)
        
        // Add stack views to their respective views
        emptyView.addSubview(emptyStackView)
        errorView.addSubview(errorStackView)
        
        // Sticker set collection view constraints
        stickerSetCollectionView.leadingAnchor.pin(equalTo: self.leadingAnchor).isActive = true
        stickerSetCollectionView.trailingAnchor.pin(equalTo: self.trailingAnchor).isActive = true
        stickerSetCollectionView.bottomAnchor.pin(equalTo: self.bottomAnchor).isActive = true
        stickerSetCollectionView.pin(anchors: [.height], to: 49)
        
        // Separator line view constraints
        separatorLineView.pin(anchors: [.leading, .trailing], to: self)
        separatorLineView.pin(anchors: [.height], to: 1)
        separatorLineView.bottomAnchor.pin(equalTo: stickerSetCollectionView.topAnchor, constant: -(CometChatSpacing.Spacing.s2)).isActive = true
        
        // Stickers collection view constraints
        stickersCollectionView.leadingAnchor.pin(equalTo: self.leadingAnchor, constant: CometChatSpacing.Padding.p4).isActive = true
        stickersCollectionView.trailingAnchor.pin(equalTo: self.trailingAnchor, constant: -(CometChatSpacing.Padding.p4)).isActive = true
        stickersCollectionView.bottomAnchor.pin(equalTo: separatorLineView.topAnchor).isActive = true
        stickersCollectionView.topAnchor.pin(equalTo: self.topAnchor).isActive = true
        stickersCollectionView.pin(anchors: [.height], to: 250)
        
        // Error view constraints
        errorView.leadingAnchor.pin(equalTo: self.leadingAnchor, constant: CometChatSpacing.Padding.p3).isActive = true
        errorView.trailingAnchor.pin(equalTo: self.trailingAnchor, constant: -(CometChatSpacing.Padding.p3)).isActive = true
        errorView.bottomAnchor.pin(equalTo: self.bottomAnchor, constant: -(CometChatSpacing.Padding.p2)).isActive = true
        errorView.topAnchor.pin(equalTo: self.topAnchor, constant: CometChatSpacing.Padding.p3).isActive = true
        
        // Empty view constraints
        emptyView.leadingAnchor.pin(equalTo: self.leadingAnchor, constant: CometChatSpacing.Padding.p3).isActive = true
        emptyView.trailingAnchor.pin(equalTo: self.trailingAnchor, constant: -(CometChatSpacing.Padding.p3)).isActive = true
        emptyView.bottomAnchor.pin(equalTo: self.bottomAnchor, constant: -(CometChatSpacing.Padding.p2)).isActive = true
        emptyView.topAnchor.pin(equalTo: self.topAnchor, constant: CometChatSpacing.Padding.p3).isActive = true
        
        // Empty stack view constraints
        emptyStackView.pin(anchors: [.centerX, .centerY], to: emptyView)
        emptyStackView.leadingAnchor.pin(equalTo: emptyView.leadingAnchor, constant: CometChatSpacing.Padding.p2).isActive = true
        emptyStackView.trailingAnchor.pin(equalTo: emptyView.trailingAnchor, constant: -(CometChatSpacing.Padding.p2)).isActive = true
        
        // Error stack view constraints
        errorStackView.pin(anchors: [.centerX, .centerY], to: errorView)
        
        // Hide views by default
        emptyView.isHidden = true
        errorView.isHidden = true
        separatorLineView.isHidden = true
        
        // Set labels' text
        emptyTitleLabel.text = "No Stickers Available"
        emptySubTitleLabel.text = "You don’t have any stickers yet."
        errorLabel.text = "Looks like something went wrong.\nPlease try again."
    }

    
    /// Sets up the styles for various UI components based on the provided `style` object.
    /// This method applies the background color, separator color, and text styles for empty and error states.
    open func setupStyle() {
        // Set the background color of the view.
        backgroundColor = style.backgroundColor
        
        // Set the background color for the separator line view.
        separatorLineView.backgroundColor = style.separatorColor
        
        // Set the text color and font for the empty state title label.
        emptyTitleLabel.textColor = style.emptyStateTitleTextColor
        emptyTitleLabel.font = style.emptyStateTitleTextFont
        
        // Set the text color and font for the empty state subtitle label.
        emptySubTitleLabel.textColor = style.emptyStateSubtitleTextColor
        emptySubTitleLabel.font = style.emptyStateSubtitleTextFont
        
        // Set the text color and font for the error state label.
        errorLabel.textColor = style.errorStateTextColor
        errorLabel.font = style.errorStateTextFont
    }

    /// This method is called when the view is about to be added to a window.
    /// It checks if the view is being added to a valid window and if the sticker set is empty,
    /// triggering sticker fetching and applying styles accordingly.
    /// - Parameter newWindow: The new window that the view will be added to.
    public override func willMove(toWindow newWindow: UIWindow?) {
        // Check if the view is being added to a valid window.
        if newWindow != nil && stickerSet.isEmpty {
            // If the sticker set is empty, fetch stickers.
            fetchStickers()
            
            // Apply the style to the view components.
            setupStyle()
        }
    }

    /// Displays the loading view with shimmer animation and pins it to the view's edges.
    /// The loading view's visibility is controlled by `disableLoadingState`.
    func showLoadingView() {
        // If loading state is disabled, exit the function.
        if disableLoadingState { return }
        
        // Start shimmer animation if loadingView is of type CometChatShimmerView.
        (loadingView as? CometChatShimmerView)?.startShimmer()
        
        // Mark the loading view as visible.
        isLoadingViewVisible = true
        
        // Add the loadingView as a subview.
        self.addSubview(loadingView)
        
        // Pin the loadingView to the edges of the parent view with padding.
        loadingView.leadingAnchor.pin(equalTo: self.leadingAnchor, constant: CometChatSpacing.Padding.p4).isActive = true
        loadingView.trailingAnchor.pin(equalTo: self.trailingAnchor, constant: -(CometChatSpacing.Padding.p4)).isActive = true
        loadingView.bottomAnchor.pin(equalTo: self.bottomAnchor).isActive = true
        loadingView.topAnchor.pin(equalTo: self.topAnchor).isActive = true
        
        // Set a fixed height for the loadingView.
        loadingView.heightAnchor.constraint(equalToConstant: 300).isActive = true
    }

    /// Hides the loading view and stops the shimmer animation.
    func hideLoadingView() {
        // Stop shimmer animation if loadingView is of type CometChatShimmerView.
        (loadingView as? CometChatShimmerView)?.stopShimmer()
        
        // Mark the loading view as not visible.
        isLoadingViewVisible = false
        
        // Remove the loadingView from its superview.
        loadingView.removeFromSuperview()
    }

    /// Fetches stickers from the server and updates the UI based on the response.
    public func fetchStickers() {
        // Show loading view while fetching stickers.
        showLoadingView()
        
        // Hide error and empty views initially.
        self.errorView.isHidden = true
        self.emptyView.isHidden = true
        
        // Clear previous sticker data.
        self.stickerSet.removeAll()
        self.stickersForPreview.removeAll()
        self.allstickers.removeAll()
        self.stickers.removeAll()
        
        // Make a network call to fetch stickers.
        CometChat.callExtension(slug: ExtensionConstants.stickers, type: .get, endPoint: "v1/fetch", body: nil, onSuccess: { response in
            if let response = response {
                // Parse the response and group stickers by set.
                self.parseStickersSet(forData: response) { result in
                    self.stickerSet = result.compactMap { key, value in
                        CometChatStickerSet(order: value.first?.setOrder ?? 0, id: value.first?.setID ?? "", thumbnail: value.first?.url ?? "", name: value.first?.setName ?? "", stickers: value)
                    }
                    
                    // Sort the sticker sets based on their order.
                    self.stickerSet.sort { $0.order ?? 0 < $1.order ?? 0 }
                    
                    // Filter stickers for preview based on the first sticker set.
                    self.stickersForPreview = self.allstickers.filter { $0.setID == self.stickerSet.first?.id }
                    
                    DispatchQueue.main.async {
                        // Update the collection views.
                        self.stickersCollectionView.backgroundView?.isHidden = true
                        self.stickersCollectionView.reloadData()
                        self.stickerSetCollectionView.reloadData()
                        
                        // Hide loading view after data is loaded.
                        self.hideLoadingView()
                        
                        // Handle empty sticker sets scenario.
                        if self.stickerSet.isEmpty {
                            self.stickersCollectionView.isHidden = true
                            self.separatorLineView.isHidden = true
                            self.stickerSetCollectionView.isHidden = true
                            self.errorView.isHidden = true
                            self.emptyView.isHidden = false
                        } else {
                            self.stickersCollectionView.isHidden = false
                            self.separatorLineView.isHidden = false
                            self.stickerSetCollectionView.isHidden = false
                            self.errorView.isHidden = true
                            self.emptyView.isHidden = true
                        }
                    }
                }
            }
        }) { error in
            // Handle error in fetching stickers.
            self.hideLoadingView()
            self.stickersCollectionView.isHidden = true
            self.separatorLineView.isHidden = true
            self.stickerSetCollectionView.isHidden = true
            self.errorView.isHidden = false
            self.emptyView.isHidden = true
            print("Error fetching stickers: \(error?.errorDescription ?? "Unknown error")")
        }
    }

    /// Parses the response data to extract and group stickers by their sticker sets.
    /// - Parameters:
    ///   - response: The response data containing stickers.
    ///   - onSuccess: Closure to return grouped sticker sets.
    private func parseStickersSet(forData response: [String: Any]?, onSuccess: @escaping ([String?: [CometChatSticker]]) -> Void) {
        // Ensure response contains valid data for default and custom sticker sets.
        guard let response = response, let defaultStickerSet = response["defaultStickers"] as? [[String: Any]], let customStickerSet = response["customStickers"] as? [[String: Any]] else { return }
        
        // Parse default sticker sets.
        defaultStickerSet.forEach { stickerData in
            let sticker = CometChatSticker(id: stickerData["id"] as? String ?? "", name: stickerData["stickerName"] as? String ?? "", order: stickerData["stickerOrder"] as? Int ?? 0, setID: stickerData["stickerSetId"] as? String ?? "", setName: stickerData["stickerSetName"] as? String ?? "", setOrder: stickerData["stickerSetOrder"] as? Int ?? 0, url: stickerData["stickerUrl"] as? String ?? "")
            stickers.append(sticker)
            allstickers.append(sticker)
        }
        
        // Parse custom sticker sets.
        customStickerSet.forEach { stickerData in
            let sticker = CometChatSticker(id: stickerData["id"] as? String ?? "", name: stickerData["stickerName"] as? String ?? "", order: stickerData["stickerOrder"] as? Int ?? 0, setID: stickerData["stickerSetId"] as? String ?? "", setName: stickerData["stickerSetName"] as? String ?? "", setOrder: stickerData["stickerSetOrder"] as? Int ?? 0, url: stickerData["stickerUrl"] as? String ?? "")
            stickers.append(sticker)
            allstickers.append(sticker)
        }
        
        // Group stickers by their set name and pass the result to the success closure.
        let dictionary = Dictionary(grouping: stickers, by: { $0.setName })
        onSuccess(dictionary)
    }

    /// Allows setting a callback for when a sticker is tapped.
    /// - Parameter onStickerTap: Closure to handle the tapped sticker.
    /// - Returns: Self for chaining.
    @discardableResult
    public func setOnStickerTap(onStickerTap: @escaping (_ sticker: CometChatSticker) -> Void) -> Self {
        self.onStickerTap = onStickerTap
        return self
    }

    /// Allows setting a callback for when a sticker set is selected.
    /// - Parameter onStickerSetSelected: Closure to handle the selected sticker set.
    /// - Returns: Self for chaining.
    @discardableResult
    public func setOnStickerSetSelected(onStickerSetSelected: @escaping (_ stickerSet: CometChatStickerSet) -> Void) -> Self {
        self.onStickerSetSelected = onStickerSetSelected
        return self
    }

    /// Retries fetching stickers by calling `fetchStickers` again.
    @objc func retry() {
        fetchStickers()
    }

}

// MARK: - CollectionView Delegate
extension CometChatStickerKeyboard : UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.stickerSetCollectionView {
            return stickerSet.count
        }else if collectionView == self.stickersCollectionView {
            return stickersForPreview.count
        } else {
            return 0
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let sticketSetCell = collectionView.dequeueReusableCell(withReuseIdentifier: "StickerCell", for: indexPath) as! StickerCell
        if collectionView == self.stickersCollectionView {
            if stickersForPreview.count != 0 {
                if let sticker = stickersForPreview[safe: indexPath.row] {
                    sticketSetCell.sticker = sticker
                }
            }
        }else if collectionView == self.stickerSetCollectionView {
            if stickerSet.count != 0 {
                let stickerCollection = stickerSet[safe: indexPath.row]
                sticketSetCell.stickerSet = stickerCollection
            }
        }
        return sticketSetCell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == self.stickerSetCollectionView {
            if let cell = collectionView.cellForItem(at: indexPath) as? StickerCell, let stickerSet = cell.stickerSet, let stickers = stickerSet.stickers {
                self.stickersForPreview.removeAll()
                self.stickersForPreview = stickers
                for sticker in stickers {
                    self.stickersForPreview.append(sticker)
                }
                DispatchQueue.main.async {
                    self.stickersCollectionView.reloadData()
                    self.stickersCollectionView.setContentOffset(CGPoint.zero, animated: true)
                }
                onStickerSetSelected?(stickerSet)
                CometChatStickerKeyboard.stickerDelegate?.didStickerSetSelected(stickerSet: stickerSet)
            }
            
        }else if collectionView == self.stickersCollectionView {
            if let cell = collectionView.cellForItem(at: indexPath) as? StickerCell, let sticker = cell.sticker {
                onStickerTap?(sticker)
                CometChatStickerKeyboard.stickerDelegate?.didStickerSelected(sticker: sticker)
                CometChatStickerKeyboard.stickerkeyboardDelegate?.showStickerKeyboard(status: false)
            }
        }
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        var spacing: CGFloat = 0 // Space between cells
        var numberOfCellsPerRow: CGFloat = 0
        
        if collectionView == self.stickersCollectionView {
            spacing = CometChatSpacing.Spacing.s4 // Space between cells
            numberOfCellsPerRow = 4
            let totalSpacing = (numberOfCellsPerRow - 1) * spacing
            let availableWidth = collectionView.frame.width - totalSpacing
            let cellWidth = availableWidth / numberOfCellsPerRow
            return CGSize(width: cellWidth, height: cellWidth)
        } else if collectionView == self.stickerSetCollectionView {
            return CGSize(width: 32, height: 32)
        }
        return CGSize(width: 0, height: 0)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        // This is the spacing between rows
        return CometChatSpacing.Spacing.s5
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        // This is the spacing between items in the same row
        if collectionView == self.stickerSetCollectionView {
            return CometChatSpacing.Spacing.s4
        }
        return 0
    }

}

extension CometChatStickerKeyboard {
    static var stickerDelegate: StickerViewDelegate?
    static var stickerkeyboardDelegate: StickerkeyboardDelegate?
}
