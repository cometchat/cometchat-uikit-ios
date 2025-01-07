//
//  CometChatPollsBubble.swift
//  DemoCometChat
//
//  Created by Suryansh Bisen
//

import UIKit
import CometChatSDK

/// A view that displays a poll message bubble in CometChat, allowing users to view poll options and cast votes.
open class CometChatPollsBubble: UIView {
    
    /// A label that displays the poll question.
    public lazy var headingLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints()
        label.numberOfLines = 0
        return label
    }()
    
    /// A stack view that contains and organizes the poll options.
    public lazy var optionsContainerStackView: UIStackView = {
        let stackView = UIStackView().withoutAutoresizingMaskConstraints()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = CometChatSpacing.Padding.p5
        return stackView
    }()
    
    /// The message object associated with the poll bubble.
    public var message: BaseMessage?
    
    /// Stores the poll data parsed from the message metadata.
    public var pollsData = PollsData()
    
    /// The style object used to customize the appearance of the poll bubble.
    public var style = PollBubbleStyle()
    
    /// Height constraint for the options container, used to control the layout dynamically.
    private var optionsContainerViewHeightAnchor: NSLayoutConstraint?
    
    /// An array to hold all the `PollsOptionView` instances for the poll options.
    var optionViews: [PollsOptionView] = [PollsOptionView]()
    
    /// An image used as the icon for a selected poll option.
    public var optionCheckIcon: UIImage? = UIImage(systemName: "checkmark.circle.fill")?.withRenderingMode(.alwaysTemplate)
    
    /// An image used as the icon for an unselected poll option.
    public var optionUncheckIcon: UIImage? = UIImage(systemName: "circle")?.withRenderingMode(.alwaysTemplate)
    
    // MARK: - Initializers
    
    /// Initializes the poll bubble with a default frame.
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    /// Initializes the poll bubble with a coder, which is not supported in this class.
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Initializes the poll bubble with default values.
    public init() {
        super.init(frame: .zero)
    }
    
    // MARK: - Lifecycle
    
    /// Called when the poll bubble is about to be added to a superview.
    /// This sets up the style for the poll bubble.
    open override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview != nil {
            setupStyle()
        }
    }
    
    // MARK: - Public Methods
    
    /// Sets the poll message and builds the UI based on the poll data.
    /// - Parameter pollMessage: The `CustomMessage` object containing the poll data.
    /// - Returns: The `CometChatPollsBubble` instance for method chaining.
    @discardableResult
    public func set(pollMessage: CustomMessage) -> Self {
        pollsData = PollUtils().parsePolls(forMessage: pollMessage)
        buildUI()
        return self
    }
    
    /// Sets the parent controller, if needed, for additional interaction.
    /// - Parameter controller: The parent view controller.
    /// - Returns: The `CometChatPollsBubble` instance for method chaining.
    @discardableResult
    public func set(controller: UIViewController) -> Self {
        return self
    }
    
    /// Sets the poll bubble's configuration.
    /// - Parameter configuration: A `PollBubbleConfiguration` object that provides style settings.
    /// - Returns: The `CometChatPollsBubble` instance for method chaining.
    @discardableResult
    public func set(configuration: PollBubbleConfiguration) -> Self {
        if let style = configuration.style {
            self.style = style
        }
        return self
    }
    
    // MARK: - Private Methods
    
    /// Applies the style settings to the poll bubble and its components.
    func setupStyle() {
        headingLabel.textColor = style.pollTextColor
        headingLabel.font = style.pollTextFont
        optionViews.forEach({ $0.set(style: style) })
    }
    
    /// Builds the poll UI by adding and positioning the poll question and options.
    open func buildUI() {
        withoutAutoresizingMaskConstraints()
        
        headingLabel.text = pollsData.question
        addSubview(headingLabel)
        addSubview(optionsContainerStackView)
        
        headingLabel.pin(anchors: [.top, .leading], to: self, with: CometChatSpacing.Padding.p3)
        headingLabel.pin(anchors: [.trailing], to: self, with: -CometChatSpacing.Padding.p3)

        optionsContainerStackView.pin(anchors: [.trailing, .bottom], to: self, with: -CometChatSpacing.Padding.p3)
        optionsContainerStackView.pin(anchors: [.leading], to: self, with: CometChatSpacing.Padding.p3)
        optionsContainerStackView.topAnchor.pin(equalTo: headingLabel.bottomAnchor, constant: CometChatSpacing.Padding.p4).isActive = true
        
        buildPollOptions()
    }
    
    /// Builds the individual poll option views and adds them to the options container.
    open func buildPollOptions() {
        for option in pollsData.options {
            let optionView = PollsOptionView(pollOption: option, total: pollsData.total)
            optionView.optionCheckIcon = optionCheckIcon
            optionView.optionUncheckIcon = optionUncheckIcon
            optionView.set(onClicked: { [weak self] pollOption in
                guard let self else { return }
                self.onSelected(pollOptions: pollOption)
            })
            optionViews.append(optionView)
            optionsContainerStackView.addArrangedSubview(optionView)
        }
    }
    
    /// Handles the event when a poll option is selected by the user, submitting the vote.
    /// - Parameter pollOptions: The selected poll option.
    open func onSelected(pollOptions: PollOptions) {
        let body = [
            "vote": pollOptions.index,
            "id": pollsData.id,
        ]
        
        CometChat.callExtension(slug: "polls", type: .post, endPoint: "v2/vote", body: body as [String : Any]) { extensionResponseData in
            print("Success")
        } onError: { error in
            print("Error")
        }
    }

}

/// A gesture recognizer class for passing additional information (option and ID) with each gesture.
class UITapGestureRecognizer_WithOptionInfo: UITapGestureRecognizer {
    var option: String?
    var id: String?
}

// MARK: - Indicator Class

/// A helper class for displaying a loading indicator while voting in the poll.
class Indicator {
    
    /// A loading indicator displayed during the voting process.
    private static var loadingIndicator: UIActivityIndicatorView!
    
    /// An alert controller used to display the loading indicator.
    private static var alert: UIAlertController!
    
    /// Shows a loading indicator with a specified message.
    /// - Parameter messages: The message to display while voting (default is "VOTING").
    static func show(messages: String = "VOTING".localize()) {
        loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator?.color = CometChatTheme_v4.palatte.accent600
        loadingIndicator.startAnimating()
        
        alert = UIAlertController(title: nil, message: messages, preferredStyle: .alert)
        alert.view.addSubview(loadingIndicator)
        
        DispatchQueue.main.async {
            if let window = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).flatMap({$0.windows }).first(where: { $0.isKeyWindow }) {
                window.rootViewController?.presentedViewController?.present(alert, animated: true)
            }
        }
    }
    
    /// Hides the loading indicator and optionally calls a completion handler.
    /// - Parameter completion: A closure that gets executed after the indicator is hidden.
    static func hide(completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            alert.dismiss(animated: true, completion: completion)
        }
    }
}
