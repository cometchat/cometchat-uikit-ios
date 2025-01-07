//
//  TimeConfirmationView.swift
//  CometChatUIKitSwift
//
//  Created by SuryanshBisen on 27/12/23.
//

import Foundation
import UIKit
import CometChatSDK

class ConfirmationView: UIView {
    
    private(set) weak var controller: UIViewController?
    private(set) var style = SchedulerBubbleStyle()
    private(set) var message: SchedulerMessage?
    private(set) var onBackButtonClicked: (() -> ())?
    private(set) var onScheduleButtonClicked: ((_ onFailure: @escaping (() -> Void)) -> ())?
    private(set) var onTryAgainClicked: (() -> ())?
    private(set) var date: Date?
    private(set) var timeSlot: TimeRange?
    private(set) var isTableViewUpdating: ((_: Bool) -> ())?
    
    private var headingView = UIView()
    
    private var middelView: UIStackView = {
        let middelView = UIStackView()
        middelView.translatesAutoresizingMaskIntoConstraints = false
        middelView.axis = .vertical
        middelView.spacing = 18
        middelView.distribution = .fill
        middelView.alignment = .fill
        return middelView
    } ()
    
    private var errorLabel: UILabel = {
        let errorLabel = UILabel()
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.textAlignment = .center
        errorLabel.font = CometChatTheme_v4.typography.subtitle2
        errorLabel.textColor = CometChatTheme_v4.palatte.error
        errorLabel.text = " "
        errorLabel.isHidden = true
        return errorLabel
    }()
    
    lazy private var scheduleButton: UIButton = {
        let scheduleButton = UIButton(type: .system)
        scheduleButton.setTitle("\(message?.scheduleElement?.buttonText ?? "SCHEDULE".localize())", for: .normal)
        scheduleButton.backgroundColor = style.messageTintColor
        scheduleButton.setTitleColor(.white, for: .normal)
        scheduleButton.titleLabel?.font = CometChatTheme_v4.typography.heading
        scheduleButton.roundViewCorners(corner: CometChatCornerStyle(cornerRadius: 5))
        scheduleButton.addTarget(self, action: #selector(onSubmitButtonClicked(_:)), for: .primaryActionTriggered)
        scheduleButton.translatesAutoresizingMaskIntoConstraints = false
        scheduleButton.tag = 0
        return scheduleButton
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buildUI() {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        buildHeaderView()
        buildMiddelView()
    }
    
    func buildMiddelView() {
        
        guard let message = message else { return }
        
        //adding formatted date 
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, dd MMMM yyyy"
        middelView.addArrangedSubview(getMiddelStackView(text: "\(timeSlot?.startTime.to12HFormattedTime() ?? ""), \(dateFormatter.string(from: date ?? Date()))", iconName: "calendar"))
        
        middelView.addArrangedSubview(getMiddelStackView(text: "\(TimeZone.current.getFullForm())", iconName: "time-zone-earth"))
        middelView.addArrangedSubview(scheduleButton)
        middelView.setCustomSpacing(0, after: scheduleButton)
        middelView.addArrangedSubview(errorLabel)
        
        self.addSubview(middelView)
        middelView.topAnchor.constraint(equalTo: headingView.bottomAnchor, constant: 5).isActive = true
        middelView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        middelView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
        middelView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20).isActive = true
        
    }
    
    func buildHeaderView() {
        
        guard let message = message else { return }
        headingView = SchedulerHeaderView.getHeaderView(message: message, style: style, onBackButtonClicked:  #selector(onBackButtonClickedSelector), target: self)
        headingView.translatesAutoresizingMaskIntoConstraints = false
        headingView.layoutIfNeeded()
        self.addSubview(headingView)
        headingView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        headingView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        headingView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        
    }
    
    func getMiddelStackView(text: String, iconName: String) -> UIStackView {
        
        let containerStackView = UIStackView()
        containerStackView.axis = .horizontal
        containerStackView.spacing = 10
        containerStackView.distribution = .fillProportionally
        containerStackView.alignment = .leading
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: iconName, in: CometChatUIKit.bundle, with: nil)?.withRenderingMode(.alwaysTemplate)
        image?.withTintColor(CometChatTheme_v4.palatte.accent800)
        icon.image = image
        icon.tintColor = CometChatTheme_v4.palatte.accent800
        icon.contentMode = .scaleAspectFit
        icon.widthAnchor.constraint(equalToConstant: 17).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 17).isActive = true
        containerStackView.addArrangedSubview(icon)
        
        let textLabel = UILabel()
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.textColor = CometChatTheme_v4.palatte.accent800
        textLabel.font = CometChatTheme_v4.typography.text1
        textLabel.numberOfLines = 0
        textLabel.text = text
        textLabel.sizeToFit()
        containerStackView.addArrangedSubview(textLabel)
        
        return containerStackView
        
    }
    
    @objc func onBackButtonPressedSelector() {
        onBackButtonClicked?()
    }
    
    @objc func onSubmitButtonClicked(_ sender: UIButton) {
        
        if sender.tag == 0 {
            sender.setTitle("", for: .normal)
            sender.isEnabled = false
            
            let activityIndicator = UIActivityIndicatorView(style: .medium)
            activityIndicator.center = CGPoint(x: sender.bounds.width / 2, y: sender.bounds.height / 2)
            activityIndicator.color = .white
            activityIndicator.startAnimating()
            sender.addSubview(activityIndicator)
            
            if let icsFileUrl = message?.icsFileUrl, let date = date, let timeSlot = timeSlot {
                SchedulerUtils.checkTimeSlotAvailable(icsFileURL: icsFileUrl, date: date, timeSlot: timeSlot, completion: { [weak self] isAvailable in
                    guard let this = self else { return }
                    if isAvailable {
                        this.onScheduleButtonClicked?({ [weak self] in //onFailure
                            guard let this = self else { return }
                            activityIndicator.removeFromSuperview()
                            this.errorLabel.text = "SOMETHING_WENT_WRONG_ERROR".localize()
                            this.isTableViewUpdating?(true)
                            this.errorLabel.isHidden = false
                            this.middelView.layoutSubviews()
                            this.middelView.setCustomSpacing(10, after: this.scheduleButton)
                            this.isTableViewUpdating?(false)
                            sender.tag = 0
                            sender.isEnabled = true
                            sender.setTitle("TRY_AGAIN".localize(), for: .normal)
                        })
                    } else {
                        sender.tag = 1
                        sender.isEnabled = false
                        this.errorLabel.text = "MEETING_SLOT_BOOK".localize()
                        this.isTableViewUpdating?(true)
                        this.middelView.layoutSubviews()
                        this.errorLabel.isHidden = false
                        this.middelView.setCustomSpacing(10, after: this.scheduleButton)
                        this.isTableViewUpdating?(false)
                        sender.setTitle("MEETING_BOOK_NEW_SLOT".localize(), for: .normal)
                        activityIndicator.removeFromSuperview()
                    }
                }) { [weak self] _ in
                    guard let this = self else { return }
                    this.errorLabel.text = "SOMETHING_WENT_WRONG_ERROR".localize()
                    this.isTableViewUpdating?(true)
                    this.middelView.layoutSubviews()
                    this.errorLabel.isHidden = false
                    this.middelView.setCustomSpacing(10, after: this.scheduleButton)
                    this.isTableViewUpdating?(false)
                    sender.tag = 0
                    sender.isEnabled = true
                    sender.setTitle("TRY_AGAIN".localize(), for: .normal)
                }
            }
        } else if sender.tag == 1 {
            onTryAgainClicked?()
        }
    }
    
    @objc func onBackButtonClickedSelector() {
        onBackButtonClicked?()
    }
}

extension ConfirmationView {
    
    @discardableResult
    public func set(controller: UIViewController?) -> Self {
        self.controller = controller
        return self
    }
    
    @discardableResult
    public func set(style: SchedulerBubbleStyle) -> Self {
        self.style = style
        return self
    }
    
    @discardableResult
    public func set(message: SchedulerMessage?) -> Self {
        self.message = message
        return self
    }
    
    @discardableResult
    public func set(onBackButtonClicked: (() -> ())?) -> Self {
        self.onBackButtonClicked = onBackButtonClicked
        return self
    }
    
    @discardableResult
    public func set(onTryAgainClicked: (() -> ())?) -> Self {
        self.onTryAgainClicked = onTryAgainClicked
        return self
    }
    
    @discardableResult
    public func set(onScheduleButtonClicked: ((_ onFailure: @escaping (() -> Void)) -> ())?) -> Self {
        self.onScheduleButtonClicked = onScheduleButtonClicked
        return self
    }
    
    @discardableResult
    public func set(date: Date) -> Self {
        self.date = date
        return self
    }
    
    @discardableResult
    public func set(timeSlot: TimeRange) -> Self {
        self.timeSlot = timeSlot
        return self
    }
    
    @discardableResult
    public func set(isTableViewUpdating: ((_: Bool) -> ())?) -> Self {
        self.isTableViewUpdating = isTableViewUpdating
        return self
    }
    
    @discardableResult
    public func build() -> Self {
        self.buildUI()
        return self
    }
    
}
