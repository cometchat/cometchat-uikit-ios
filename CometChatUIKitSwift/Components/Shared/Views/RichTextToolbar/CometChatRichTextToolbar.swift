//
//  CometChatRichTextToolbar.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 29/01/26.
//

import UIKit

/// A horizontal toolbar for rich text formatting options
open class CometChatRichTextToolbar: UIView {
    
    // MARK: - UI Components
    
    public lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView().withoutAutoresizingMaskConstraints()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.contentInsetAdjustmentBehavior = .never
        return scrollView
    }()
    
    public lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView().withoutAutoresizingMaskConstraints()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = style.buttonSpacing
        return stackView
    }()
    
    // MARK: - Properties
    
    /// The currently active formats
    public private(set) var activeFormats: Set<FormatType> = []
    
    /// Callback when a format is selected
    public var onFormatSelected: ((FormatType) -> Void)?
    
    /// The enabled format types
    public var enabledFormats: [FormatType] = FormatType.allCases {
        didSet { rebuildButtons() }
    }
    
    /// Style configuration
    public static var style = RichTextToolbarStyle()
    public lazy var style = CometChatRichTextToolbar.style {
        didSet { applyStyle() }
    }
    
    /// Format buttons dictionary
    public private(set) var formatButtons: [FormatType: UIButton] = [:]
    
    // MARK: - Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
        applyStyle()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        buildUI()
        applyStyle()
    }
    
    // MARK: - UI Setup
    
    private func buildUI() {
        addSubview(scrollView)
        scrollView.addSubview(buttonStackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.heightAnchor.constraint(greaterThanOrEqualToConstant: 36),
            
            buttonStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: style.contentPadding.top),
            buttonStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: style.contentPadding.left),
            buttonStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -style.contentPadding.right),
            buttonStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -style.contentPadding.bottom),
            
            // Constrain height to frame to prevent vertical scrolling
            buttonStackView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor, constant: -(style.contentPadding.top + style.contentPadding.bottom))
        ])
        
        rebuildButtons()
    }
    
    private func rebuildButtons() {
        buttonStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        formatButtons.removeAll()
        
        for format in enabledFormats {
            let button = createFormatButton(for: format)
            formatButtons[format] = button
            buttonStackView.addArrangedSubview(button)
            
            // Add separator after specific formats to group related buttons
            // Group 1: bold, italic, underline, strikethrough | Group 2: link, numberedList, bulletList | Group 3: blockquote, code, codeBlock
            if format == .strikethrough || format == .bulletList {
                let separator = createSeparatorView()
                buttonStackView.addArrangedSubview(separator)
            }
        }
    }
    
    /// Creates a vertical separator view for grouping toolbar buttons
    private func createSeparatorView() -> UIView {
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = style.separatorColor
        
        NSLayoutConstraint.activate([
            separator.widthAnchor.constraint(equalToConstant: style.separatorWidth),
            separator.heightAnchor.constraint(equalToConstant: style.separatorHeight)
        ])
        
        return separator
    }
    
    private func createFormatButton(for format: FormatType) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Use the format's image property which handles custom images and SF Symbol fallback
        let image = format.image
        button.setImage(image, for: .normal)
        button.tintColor = style.iconTintColor
        button.backgroundColor = style.buttonBackgroundColor
        button.layer.cornerRadius = style.buttonCornerRadius
        
        button.accessibilityLabel = format.accessibilityLabel
        button.tag = enabledFormats.firstIndex(of: format) ?? 0
        
        // Ensure button is interactive
        button.isUserInteractionEnabled = true
        button.isEnabled = true
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: style.buttonSize),
            button.heightAnchor.constraint(equalToConstant: style.buttonSize)
        ])
        
        button.addTarget(self, action: #selector(formatButtonTapped(_:)), for: .touchUpInside)
        
        return button
    }
    
    private func applyStyle() {
        backgroundColor = style.backgroundColor
        layer.borderColor = style.borderColor.cgColor
        layer.borderWidth = style.borderWidth
//        roundViewCorners(corner: style.cornerRadius)
        
        buttonStackView.spacing = style.buttonSpacing
        
        for (format, button) in formatButtons {
            let isActive = activeFormats.contains(format)
            button.tintColor = isActive ? style.activeIconTintColor : style.iconTintColor
            button.backgroundColor = isActive ? style.activeButtonBackgroundColor : style.buttonBackgroundColor
        }
    }
    
    // MARK: - Actions
    
    @objc private func formatButtonTapped(_ sender: UIButton) {
        guard sender.tag < enabledFormats.count else { return }
        let format = enabledFormats[sender.tag]
        onFormatSelected?(format)
    }
    
    // MARK: - Public Methods
    
    /// Sets the active formats and updates button states
    /// - Parameter formats: The set of active format types
    public func setActiveFormats(_ formats: Set<FormatType>) {
        activeFormats = formats
        
        // Update button visual states immediately (without animation for responsiveness)
        for (format, button) in formatButtons {
            let isActive = formats.contains(format)
            button.tintColor = isActive ? self.style.activeIconTintColor : self.style.iconTintColor
            button.backgroundColor = isActive ? self.style.activeButtonBackgroundColor : self.style.buttonBackgroundColor
        }
    }
    
    /// Toggles a format's active state
    /// - Parameter format: The format to toggle
    public func toggleFormat(_ format: FormatType) {
        if activeFormats.contains(format) {
            activeFormats.remove(format)
        } else {
            activeFormats.insert(format)
        }
        setActiveFormats(activeFormats)
    }
    
    /// Disables all buttons except the specified format
    /// - Parameter exceptFormat: The format to keep enabled (typically .codeBlock)
    public func disableAllButtons(except exceptFormat: FormatType) {
        for (format, button) in formatButtons {
            if format != exceptFormat {
                button.isEnabled = false
                button.alpha = 0.3
            }
        }
    }
    
    /// Enables all buttons
    public func enableAllButtons() {
        for (_, button) in formatButtons {
            button.isEnabled = true
            button.alpha = 1.0
        }
    }
    
    /// Disables specific format buttons
    /// - Parameter formats: The formats to disable
    public func disableButtons(for formats: Set<FormatType>) {
        for format in formats {
            if let button = formatButtons[format] {
                button.isEnabled = false
                button.alpha = 0.3
            }
        }
    }
    
    /// Enables specific format buttons
    /// - Parameter formats: The formats to enable
    public func enableButtons(for formats: Set<FormatType>) {
        for format in formats {
            if let button = formatButtons[format] {
                button.isEnabled = true
                button.alpha = 1.0
            }
        }
    }
    
    /// Updates button states based on format compatibility rules
    /// - Parameter activeFormats: The currently active formats
    public func updateButtonStates(for activeFormats: Set<FormatType>) {
        let compatibilityEngine = RichTextFormatterManager.shared.compatibilityEngine
        let disabledFormats = compatibilityEngine.getDisabledFormats(for: activeFormats)
        
        // Update each button's state
        for (format, button) in formatButtons {
            var shouldBeEnabled = !disabledFormats.contains(format)
            
            // When no formats are active, all buttons should be enabled
            if activeFormats.isEmpty {
                shouldBeEnabled = true
            }
            
            let isActive = activeFormats.contains(format)
            
            updateButton(button, format: format, isEnabled: shouldBeEnabled, isActive: isActive)
        }
    }
    
    /// Updates a single button's visual state
    /// - Parameters:
    ///   - button: The button to update
    ///   - format: The format type
    ///   - isEnabled: Whether the button should be enabled
    ///   - isActive: Whether the format is currently active
    private func updateButton(_ button: UIButton, format: FormatType, isEnabled: Bool, isActive: Bool) {
        button.isEnabled = isEnabled
        button.alpha = isEnabled ? 1.0 : 0.3
        button.tintColor = isActive ? self.style.activeIconTintColor : self.style.iconTintColor
        button.backgroundColor = isActive ? self.style.activeButtonBackgroundColor : self.style.buttonBackgroundColor
    }
}

// MARK: - Builder Pattern
extension CometChatRichTextToolbar {
    
    @discardableResult
    public func set(style: RichTextToolbarStyle) -> Self {
        self.style = style
        return self
    }
    
    @discardableResult
    public func set(enabledFormats: [FormatType]) -> Self {
        self.enabledFormats = enabledFormats
        return self
    }
    
    @discardableResult
    public func set(onFormatSelected: @escaping (FormatType) -> Void) -> Self {
        self.onFormatSelected = onFormatSelected
        return self
    }
}
