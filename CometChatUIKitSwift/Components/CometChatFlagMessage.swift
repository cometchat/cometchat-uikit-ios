//
//  CometChatFlagMessage.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 20/11/25.
//

import Foundation
import UIKit
import CometChatSDK

final class CometChatFlagMessage: UIViewController, UITextViewDelegate {

    // MARK: - Dynamic Data
    var reasons: [FlagReason] = [] {
        didSet { collectionView.reloadData() }
    }

    private var selectedReasons: [FlagReason] = [] {
        didSet { updateReportButtonState() }
    }

    // MARK: - UI Components

    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    private let mainStack = UIStackView()

    private var collectionView: UICollectionView!

    private let reasonTitleLabel = UILabel()
    private let textView = UITextView()
    private let placeholderLabel = UILabel()

    private let errorLabel = UILabel()

    private let cancelButton = UIButton(type: .system)
    private let reportButton = UIButton(type: .system)

    private var collectionViewHeightConstraint: NSLayoutConstraint!
    
    var messageId : Int?
    
    private let reportLoader = UIActivityIndicatorView(style: .medium)
    private var isReporting = false
    
    public var hideFlagRemarkFeild: Bool = false
    
    //MARK: Styling
    public static var style = FlagMessageStyle() //global styling
    public lazy var style = CometChatFlagMessage.style //component level styling
    
    /// Developers can override this closure to localize dynamic reason IDs
    public var flagReasonLocalizer: ((String) -> String)?
    
    private var defaultTranslatedReasons: [String: String] = [:]



    // MARK: - Lifecycle

    init() {
        super.init(nibName: nil, bundle: nil)

        DispatchQueue.main.async { [weak self] in
            self?.loadDefaultReasonTranslations()
            self?.reasons = FlagReasonsManager.shared.flagReasons
            self?.updateCollectionHeight()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)

        setupKeyboardDismissGesture()
        
        setupContainer()
        setupMainStack()
        setupHeader()
        setupCollectionView()
        setupTextView()
        setupFooterButtons()
        setupErrorLabel()
        setupStyle()
        updateReportButtonState()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateCollectionHeight()
    }

    // MARK: - UI Setup
    private func setupKeyboardDismissGesture() {
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false // ✅ important so buttons & cells still work
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func setupContainer() {
        containerView.backgroundColor = CometChatTheme.backgroundColor01
        containerView.layer.cornerRadius = 18

        view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor,
                                                  multiplier: 0.90)
        ])
    }
    
    private func setupMainStack() {
        mainStack.axis = .vertical
        mainStack.spacing = CometChatSpacing.Padding.p4
        mainStack.alignment = .fill
        mainStack.distribution = .fill

        containerView.addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: CometChatSpacing.Padding.p4),
            mainStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: CometChatSpacing.Padding.p4),
            mainStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -CometChatSpacing.Padding.p4),
            mainStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -CometChatSpacing.Padding.p5)
        ])
    }
    
    private func setupHeader() {
        
        titleLabel.text = "REPORT_A_MESSAGE".localize()

        subtitleLabel.text = "REPORT_MESSAGE_SUBTITLE".localize()
        subtitleLabel.numberOfLines = 0
        
        let headerStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        headerStack.axis = .vertical
        headerStack.spacing = CometChatSpacing.Padding.p2

        mainStack.addArrangedSubview(headerStack)
    }


    private func setupStyle() {
        // Header
        titleLabel.font = style.titleTextFont
        titleLabel.textColor = style.titleTextColor

        subtitleLabel.font = style.subtitleTextFont
        subtitleLabel.textColor = style.subtitleTextColor

        // Reason title
        reasonTitleLabel.font = style.reasonTitleTextFont
        reasonTitleLabel.textColor = style.reasonTitleTextColor

        // Text view
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 1
        textView.layer.borderColor = CometChatTheme.borderColorDefault.cgColor
        textView.font = style.reasonTextFont
        textView.textColor = style.reasonTextColor
        textView.backgroundColor = CometChatTheme.backgroundColor02
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)

        placeholderLabel.font = CometChatTypography.Button.regular
        placeholderLabel.textColor = CometChatTheme.textColorTertiary

        // Buttons
        reportButton.backgroundColor = style.reportButtonBackgroundColor
        reportButton.tintColor = style.reportButtonTintColor
        reportButton.layer.cornerRadius = 8

        cancelButton.titleLabel?.font = style.cancelButtonTextFont
        reportButton.titleLabel?.font = style.reportButtonTextFont

        // Error
        errorLabel.textColor = style.errorTColor
        errorLabel.font = style.errorTextFont
    }

    private func setupCollectionView() {
        let layout = LeftAlignedFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 9999
        layout.minimumLineSpacing = 8
        layout.sectionInset = .zero

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.allowsMultipleSelection = true

        collectionView.register(
            FlagMessageCell.self,
            forCellWithReuseIdentifier: FlagMessageCell.reuseId
        )
        collectionView.dataSource = self
        collectionView.delegate = self

        mainStack.addArrangedSubview(collectionView)

        // height constraint still required to auto-expand
        collectionViewHeightConstraint =
            collectionView.heightAnchor.constraint(equalToConstant: 10)
        collectionViewHeightConstraint.isActive = true
    }
    
    private func setupTextView() {
        reasonTitleLabel.text = "\("REASON".localize()) (\("OPTIONAL".localize()))"

        textView.delegate = self
        textView.heightAnchor.constraint(equalToConstant: 90).isActive = true

        placeholderLabel.text = "REPORT_MESSAGE_PLACEHOLDER".localize()
        textView.addSubview(placeholderLabel)
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 8),
            placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: 8)
        ])

        let reasonStack = UIStackView(arrangedSubviews: [reasonTitleLabel, textView])
        reasonStack.axis = .vertical
        reasonStack.spacing = 6

        mainStack.addArrangedSubview(reasonStack)
        
        reasonStack.isHidden = hideFlagRemarkFeild
    }

    private func setupFooterButtons() {
        cancelButton.setTitle("CANCEL".localize(), for: .normal)
        reportButton.setTitle("REPORT".localize(), for: .normal)
        reportButton.isEnabled = false

        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        reportButton.addTarget(self, action: #selector(reportTapped), for: .touchUpInside)

        let buttonsStack = UIStackView(arrangedSubviews: [cancelButton, reportButton])
        buttonsStack.axis = .horizontal
        buttonsStack.spacing = 12
        buttonsStack.distribution = .fillEqually
        buttonsStack.heightAnchor.constraint(equalToConstant: 44).isActive = true
        mainStack.addArrangedSubview(buttonsStack)

        reportButton.addSubview(reportLoader)
        reportLoader.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            reportLoader.centerXAnchor.constraint(equalTo: reportButton.centerXAnchor),
            reportLoader.centerYAnchor.constraint(equalTo: reportButton.centerYAnchor)
        ])

    }

    private func setupErrorLabel() {
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true
        mainStack.addArrangedSubview(errorLabel)
    }

    // MARK: - Logic

    private func updateCollectionHeight() {
        collectionView.layoutIfNeeded()
        let contentHeight = collectionView.collectionViewLayout.collectionViewContentSize.height
        // Each item is ~34pt + 8pt spacing = ~42pt per item. Cap at 5 items (~210pt)
        let maxHeight: CGFloat = 210
        if contentHeight > maxHeight {
            collectionViewHeightConstraint.constant = maxHeight
            collectionView.isScrollEnabled = true
        } else {
            collectionViewHeightConstraint.constant = contentHeight + 10
            collectionView.isScrollEnabled = false
        }
        view.layoutIfNeeded()
    }

    private func updateReportButtonState() {
        let isValid = !selectedReasons.isEmpty
        reportButton.isEnabled = isValid
        reportButton.alpha = isValid ? 1.0 : 0.4
    }

    @objc private func cancelTapped() {
        dismiss(animated: false, completion: nil)
    }

    @objc private func reportTapped() {
        guard !selectedReasons.isEmpty, messageId ?? 0 > 0 else {
            errorLabel.text =
            "Unable to submit. Please select a reason before reporting this message"
            errorLabel.isHidden = false
            return
        }
        startReportingLoader()
        if let id = messageId {
            CometChat.flagMessage(messageId: id, detail: FlagDetail(messageId: id, reasonId: (selectedReasons.first?.id)!, remark: textView.text)) { message in
                DispatchQueue.main.async { [weak self] in
                    self?.stopReportingLoader()
                    let presenter = self?.presentingViewController
                    self?.dismiss(animated: false, completion: {
                        self?.showReportedAlert(on: presenter)
                    })
                }
            } onError: { error in
                print(error?.errorDescription ?? "")
            }
        }
    }
    
    private func showReportedAlert(on presenter: UIViewController?) {
        guard let presenter = presenter else { return }

        let alert = UIAlertController(
            title: "Reported",
            message: "Your report has been submitted successfully.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default))

        presenter.present(alert, animated: true, completion: nil)
    }


    // MARK: - UITextViewDelegate

    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    private func startReportingLoader() {
        isReporting = true
        reportButton.isEnabled = false
        reportButton.setTitle("", for: .normal) 
        reportLoader.startAnimating()
    }

    private func stopReportingLoader() {
        isReporting = false
        reportLoader.stopAnimating()
        reportButton.setTitle("Report", for: .normal)
        updateReportButtonState()
    }
    
    private func loadDefaultReasonTranslations() {
        defaultTranslatedReasons = [
            "spam": "SPAM".localize(),
            "sexual": "SEXUAL_CONTENT".localize(),
            "harassment": "HARASSMENT_BULLYING".localize()
        ]
    }
    
    func getLocalizedReason(reasonId: String, reasonName: String?) -> String {
        let normalizedId = reasonId.lowercased()

        if let custom = flagReasonLocalizer?(normalizedId), !custom.isEmpty {
            return custom
        }

        if let translated = defaultTranslatedReasons[normalizedId] {
            return translated
        }

        if let name = reasonName, !name.isEmpty {
            return name
        }

        return ""
    }

}

// MARK: - Collection View

extension CometChatFlagMessage: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        reasons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = reasons[indexPath.item]
        let text = getLocalizedReason(reasonId: item.id, reasonName: item.name)
        let font = CometChatTypography.Body.regular
        let textWidth = (text as NSString).size(withAttributes: [.font: font]).width
        let cellWidth = textWidth + 28
        return CGSize(width: min(cellWidth, collectionView.bounds.width), height: 34)
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let item = reasons[indexPath.item]
        let localizedText = getLocalizedReason(
            reasonId: item.id,
            reasonName: item.name
        )

        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: FlagMessageCell.reuseId,
                for: indexPath
            ) as? FlagMessageCell
        else {
            return UICollectionViewCell()
        }

        cell.configure(localizedText)

        // Restore selection appearance based on selectedReasons
        let isSelected = selectedReasons.contains { $0.id == item.id }
        cell.isSelected = isSelected
        if isSelected {
            collectionView.selectItem(at: indexPath,
                                      animated: false,
                                      scrollPosition: [])
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {

        let reason = reasons[indexPath.item]
        if !selectedReasons.contains(where: { $0.id == reason.id }) {
            selectedReasons.append(reason)
        }

        errorLabel.isHidden = true
    }

    func collectionView(_ collectionView: UICollectionView,
                        didDeselectItemAt indexPath: IndexPath) {

        let reason = reasons[indexPath.item]
        if let idx = selectedReasons.firstIndex(where: { $0.id == reason.id }) {
            selectedReasons.remove(at: idx)
        }
    }
}

// MARK: - Custom Layout that forces one item per line
class LeftAlignedFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil }
        
        var y: CGFloat = sectionInset.top
        var prevMaxY: CGFloat = -1
        
        for attribute in attributes {
            // Each item goes to a new line
            if attribute.frame.origin.y >= prevMaxY {
                y = attribute.frame.origin.y
            }
            attribute.frame.origin.x = sectionInset.left
            attribute.frame.origin.y = y
            prevMaxY = attribute.frame.maxY + minimumLineSpacing
            y = prevMaxY
        }
        
        return attributes
    }
}
