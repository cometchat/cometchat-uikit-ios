//
//  CometChatListItem.swift
//  
//
//  Created by Pushpsen Airekar on 17/11/22.
//

import UIKit

@MainActor
open class CometChatListItem: UITableViewCell {

    // Lazy properties
    public lazy var statusIndicator: CometChatStatusIndicator = {
        let statusIndicator = CometChatStatusIndicator().withoutAutoresizingMaskConstraints()
        return statusIndicator
    }()

    
    public lazy var check: UIImageView = {
        let imageView = UIImageView().withoutAutoresizingMaskConstraints()
        return imageView
    }()
    
    public lazy var containerView: UIStackView = {
        let stackView = UIStackView().withoutAutoresizingMaskConstraints()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = CometChatSpacing.Spacing.s3
        return stackView
    }()
    
    public lazy var titleLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints()
        return label
    }()
    
    public lazy var tailView: UIStackView = {
        let stackView = UIStackView().withoutAutoresizingMaskConstraints()
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        return stackView
    }()
    
    public lazy var subTitleView: UIStackView = {
        let stackView = UIStackView().withoutAutoresizingMaskConstraints()
        return stackView
    }()
    
    private lazy var avatarView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints()
        return view
    }()
    
    public lazy var avatar: CometChatAvatar = {
        let avatar = CometChatAvatar(frame: CGRect(x: 0, y: 0, width: 40, height: 40)).withoutAutoresizingMaskConstraints()
        avatarWidthConstraint = avatar.widthAnchor.pin(equalToConstant: 40)
        avatarHeightConstraint = avatar.heightAnchor.pin(equalToConstant: 40)
        NSLayoutConstraint.activate([ avatarWidthConstraint, avatarHeightConstraint ])
        return avatar
    }()
    
    lazy var container: UIStackView = {
        let stackView = UIStackView().withoutAutoresizingMaskConstraints()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = CometChatSpacing.Spacing.s3
        return stackView
    }()
    
    lazy var background: CometChatGradientView = {
        let background = CometChatGradientView().withoutAutoresizingMaskConstraints()
        return background
    }()
    
    lazy var titleStack: UIStackView = {
        let stackView = UIStackView().withoutAutoresizingMaskConstraints()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 5
        return stackView
    }()
    
    // MARK: - Properties
    private var title: String?
    public var style: ListItemStyle = ListItemStyleDefault() {
        didSet {
            setupStyle()
        }
    }
    public var onItemLongClick: (() -> Void)?
    public static let identifier = "CometChatListItem"

    public var avatarHeightConstraint: NSLayoutConstraint!
    public var avatarWidthConstraint: NSLayoutConstraint!
    public var layoutMargin: NSDirectionalEdgeInsets = NSDirectionalEdgeInsets(
        top: CometChatSpacing.Spacing.s3,
        leading: CometChatSpacing.Spacing.s4,
        bottom: CometChatSpacing.Spacing.s3,
        trailing: CometChatSpacing.Spacing.s4
    ) {
        didSet {
            updateMarginConstraints()
        }
    }
    
    private weak var controller: UIViewController?
    private lazy var imageService = ImageService()
    private var statusIndicatorIconTint: UIColor = UIColor.green
    private var statusIndicatorIcon: UIImage? = UIImage()
    var selectedCellImage: UIImage = UIImage()
    var deselectedCellImage: UIImage = UIImage()

    private var topMarginAnchor: NSLayoutConstraint!
    private var bottomMarginAnchor: NSLayoutConstraint!
    private var leadingMarginAnchor: NSLayoutConstraint!
    private var trailingMarginAnchor: NSLayoutConstraint!
    
    @MainActor
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildUI()
        addLongPress()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        buildUI()
        addLongPress()
    }
    
    private func buildUI() {
        self.backgroundColor = .clear
        self.selectionStyle = .none
        contentView.embed(background)

        // Avatar Configuration
        avatarView.addSubview(avatar)
        avatarView.addSubview(statusIndicator)
        
        container.addArrangedSubview(containerView)
        containerView.addArrangedSubview(check)
        containerView.addArrangedSubview(avatarView)
        containerView.addArrangedSubview(titleStack)
        
        // Title and Subtitle Stack
        titleStack.addArrangedSubview(titleLabel)
        titleStack.addArrangedSubview(subTitleView)
        
        // Tail View
        container.addArrangedSubview(tailView)
        
        //Add Constraints
        background.addSubview(container)
        topMarginAnchor = container.topAnchor.pin(equalTo: background.topAnchor, constant: layoutMargin.top)
        bottomMarginAnchor = container.bottomAnchor.pin(equalTo: background.bottomAnchor, constant: -layoutMargin.bottom)
        leadingMarginAnchor = container.leadingAnchor.pin(equalTo: background.leadingAnchor, constant: layoutMargin.leading)
        trailingMarginAnchor = container.trailingAnchor.pin(equalTo: background.trailingAnchor, constant: -layoutMargin.trailing)
        NSLayoutConstraint.activate([topMarginAnchor, bottomMarginAnchor, leadingMarginAnchor, trailingMarginAnchor])
        
        //subTitleView will only be visible when it is passed from outside
        subTitleView.isHidden = true
        
        //check image remains to be hidden until tableView selection style changes
        check.isHidden = true
        check.pin(anchors: [.height,.width], to: 24)

        
        // Pin avatar from all sides to avatarView
        avatarView.embed(avatar)
                
        // Pin statusIndicator with relative to avatar
        statusIndicator.pin(anchors: [.width, .height], to: 14)
        statusIndicator.trailingAnchor.pin(equalTo: avatarView.trailingAnchor, constant: -1).isActive = true
        statusIndicator.bottomAnchor.pin(equalTo: avatarView.bottomAnchor).isActive = true
        
        // Ensure statusIndicator is brought to the front
        avatarView.bringSubviewToFront(statusIndicator)        
    }
    
    private func addLongPress() {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        self.background.addGestureRecognizer(longPressRecognizer)
        self.background.isUserInteractionEnabled = true
    }
    
    @objc private func longPressed() {
        onItemLongClick?()
    }
    
    open override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            check.image = selectedCellImage
            self.background.backgroundColor = style.listItemSelectedBackground
            check.tintColor = style.listItemSelectionImageTint
        } else {
            check.image = deselectedCellImage
            self.background.backgroundColor = style.listItemBackground
            check.tintColor = style.listItemDeSelectedImageTint
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.background.roundViewCorners(corner: style.listItemCornerRadius)
    }
    
    open func setupStyle() {
        titleLabel.textColor = style.listItemTitleTextColor
        titleLabel.font = style.listItemTitleFont
        background.set(backgroundColor: style.listItemBackground)
        background.borderWith(width: style.listItemBorderWidth)
        background.borderColor(color: style.listItemBorderColor)
        background.roundViewCorners(corner: style.listItemCornerRadius)
        selectedCellImage = style.listItemSelectedImage
        deselectedCellImage = style.listItemDeSelectedImage
    }
    
    func updateMarginConstraints() {
        if topMarginAnchor.constant != layoutMargin.top {
            topMarginAnchor.constant = layoutMargin.top
        }
        if bottomMarginAnchor.constant != -layoutMargin.bottom {
            bottomMarginAnchor.constant = -layoutMargin.bottom
        }
        if leadingMarginAnchor.constant != layoutMargin.leading {
            leadingMarginAnchor.constant = layoutMargin.leading
        }
        if trailingMarginAnchor.constant != -layoutMargin.trailing {
            trailingMarginAnchor.constant = -layoutMargin.trailing
        }
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
                
        title = nil
        controller = nil
        style = ListItemStyleDefault()
        statusIndicator.imageView.image = nil
        
        avatar.subviews.forEach({ $0.removeFromSuperview() })
        tailView.subviews.forEach( { $0.removeFromSuperview() })
        subTitleView.subviews.forEach({ $0.removeFromSuperview() })
        
        avatar.reset()
    }
}

//MARK: Properties
extension CometChatListItem{
    
    @discardableResult
    public func set(avatarURL: String, with title: String? = nil) -> Self {
        self.avatar.setAvatar(avatarUrl: avatarURL, with: title ?? self.title)
        return self
    }
    
    @discardableResult
    public func hide(statusIndicator: Bool) -> Self {
        self.statusIndicator.isHidden = statusIndicator
        return self
    }
    
    @discardableResult
    public func set(statusIndicatorIcon: UIImage?) -> Self {
        self.statusIndicatorIcon = statusIndicatorIcon
        self.statusIndicator.set(icon: statusIndicatorIcon, with: self.statusIndicatorIconTint)
        return self
    }
    
    @discardableResult
    public func set(statusIndicatorIconTint: UIColor) -> Self {
        self.statusIndicatorIconTint = statusIndicatorIconTint
        statusIndicator.set(icon: statusIndicatorIcon, with: statusIndicatorIconTint)
        return self
    }
    
    @discardableResult
    public func set(title: String) -> Self {
        self.title = title
        self.titleLabel.text = title
        return self
    }
    
    @discardableResult
    public func set(titleColor: UIColor) -> Self {
        self.titleLabel.textColor = titleColor
        return self
    }
    
    @discardableResult
    public func set(titleFont: UIFont) -> Self {
        self.titleLabel.font = titleFont
        return self
    }
    
    @discardableResult
    public func set(subtitle: UIView) -> Self {
        subTitleView.subviews.forEach({ $0.removeFromSuperview() })
        self.subTitleView.isHidden = false
        self.subTitleView.addArrangedSubview(subtitle)
        return self
    }
    
    @discardableResult
    public func set(tail: UIView) -> Self {
        tailView.subviews.forEach({ $0.removeFromSuperview() })
        self.tailView.addArrangedSubview(tail)
        return self
    }
    
    @discardableResult
    public func set(customView: UIView) -> Self {
        self.background.removeFromSuperview()
        self.container.embed(customView)
        return self
    }
    
    @discardableResult
    public func hide(avatar: Bool) -> Self {
        self.avatarView.isHidden = avatar
        return self
    }
    
    @discardableResult
    public func hide(titleLabel: Bool) -> Self {
        self.titleLabel.isHidden = titleLabel
        return self
    }
    
    func getTail() -> UIStackView? {
        return tailView
    }
    
    func getSubTitle() -> UIStackView? {
        return subTitleView
    }
    
    @discardableResult
    public func allow(selection: Bool) ->  Self {
        self.check.isHidden = !selection
        return self
    }
             
}
