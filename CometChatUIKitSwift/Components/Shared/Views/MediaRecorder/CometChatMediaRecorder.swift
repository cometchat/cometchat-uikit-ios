//
//  CometChatMediaRecorder.swift
//  
//
//  Created by Abhishek Saralaya on 10/08/23.
//

import Foundation
import UIKit
import AVFAudio

enum AudioRecodingState {
    case ready
    case recording
    case recorded
    case playing
    case paused
}

public class CometChatMediaRecorder: UIViewController, PanModalPresentable {
    
    var panScrollable: UIScrollView?
        
    private lazy var backView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints()
        return view
    }()
    
    private lazy var audioNoteReRecordButton: UIButton = {
        let button = UIButton().withoutAutoresizingMaskConstraints()
        button.addTarget(self, action: #selector(didAudioNoteReRecordPressed), for: .touchUpInside)
        button.pin(anchors: [.height, .width], to: 40)
        return button
    }()
    
    private lazy var audioNoteStopButton: UIButton = {
        let button = UIButton().withoutAutoresizingMaskConstraints()
        button.addTarget(self, action: #selector(didAudioNoteStopPressed), for: .touchUpInside)
        button.pin(anchors: [.height, .width], to: 40)
        return button
    }()
    
    private lazy var audioNoteStartButton: UIButton = {
        let button = UIButton().withoutAutoresizingMaskConstraints()
        button.addTarget(self, action: #selector(didAudioNoteStartPressed), for: .touchUpInside)
        button.pin(anchors: [.height, .width], to: 48)
        return button
    }()
    
    private lazy var audioNotePauseButton: UIButton = {
        let button = UIButton().withoutAutoresizingMaskConstraints()
        button.addTarget(self, action: #selector(didAudioNotePausePressed), for: .touchUpInside)
        button.pin(anchors: [.height, .width], to: 48)
        return button
    }()
    
    private lazy var audioNoteSendButton: UIButton = {
        let button = UIButton().withoutAutoresizingMaskConstraints()
        button.addTarget(self, action: #selector(onSubmitButtonPressed), for: .touchUpInside)
        button.pin(anchors: [.height, .width], to: 48)
        return button
    }()
    
    private lazy var audioNoteDeleteButton: UIButton = {
        let button = UIButton().withoutAutoresizingMaskConstraints()
        button.addTarget(self, action: #selector(didAudioNoteDeletePressed), for: .touchUpInside)
        button.pin(anchors: [.height, .width], to: 40)
        return button
    }()
    
    public lazy var mediaRecorderBackView: GIFImageView = {
        let imageView = GIFImageView().withoutAutoresizingMaskConstraints()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.pin(anchors: [.height, .width], to: 120)
        return imageView
    }()
    
    private lazy var mediaRecorderView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints()
        view.layer.cornerRadius = 40 // Adjust size if necessary
        view.pin(anchors: [.height, .width], to: 80)
        view.backgroundColor = .gray // Customize as needed
        return view
    }()
    
    private lazy var mediaRecorderImage: UIImageView = {
        let imageView = UIImageView().withoutAutoresizingMaskConstraints()
        imageView.image = UIImage(systemName: "mic.fill")?.withRenderingMode(.alwaysTemplate)
        imageView.contentMode = .scaleAspectFit
        imageView.pin(anchors: [.height, .width], to: 48)
        return imageView
    }()
    
    private lazy var audioTimerLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints()
        label.textAlignment = .center
        label.text = "00:00:00"
        label.font = UIFont.systemFont(ofSize: 16) // Customize font size
        return label
    }()
    
    private lazy var audioBubbleBackView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints()
        view.backgroundColor = .lightGray // Customize as needed
        return view
    }()
    
    private lazy var recordingView: CometChatAudioBubble = {
        let view = CometChatAudioBubble().withoutAutoresizingMaskConstraints()
        return view
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [audioNoteDeleteButton, audioNoteStartButton, audioNoteStopButton])
        stackView.axis = .horizontal
        stackView.spacing = CometChatSpacing.Spacing.s5
        stackView.distribution = .fill
        stackView.alignment = .center
        return stackView
    }()
    
    private lazy var upperStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [mediaRecorderBackView, audioTimerLabel])
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.alignment = .center
        return stackView
    }()
    
    private lazy var recordingStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [upperStackView, audioBubbleBackView, buttonsStackView])
        stackView.axis = .vertical
        stackView.spacing = CometChatSpacing.Spacing.s5
        stackView.alignment = .center
        return stackView
    }()
    
    private(set) var onSubmit: ((String) -> Void)?
    private var currentState: AudioRecodingState = .ready
    var audioViewModel = ViewModel()
    var viewModel: MediaRecorderViewModel?
    private var timer: Timer?
    private var totalSecond = 0
    private var totalFinalSecond = 0
    private var recorder: AVAudioRecorder?
    
    
    public static var style = MediaRecorderStyle()
    public lazy var style = CometChatMediaRecorder.style
    
    // MARK: - View Lifecycle
    public override func loadView() {
        super.loadView()
        setupRecorder()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupStyle()
    }
    
    open func buildUI() {
        backView.backgroundColor = .clear
        mediaRecorderBackView.backgroundColor = .clear

        // Embed views with insets
        view.embed(backView, insets: .init(
            top: CometChatSpacing.Padding.p3,
            leading: 0,
            bottom: CometChatSpacing.Padding.p5,
            trailing: 0
        ))

        backView.embed(recordingStackView, insets: .init(
            top: CometChatSpacing.Padding.p5,
            leading: CometChatSpacing.Padding.p5,
            bottom: CometChatSpacing.Padding.p5,
            trailing: CometChatSpacing.Padding.p5
        ))

        // Add arranged subviews to recording stack
        recordingStackView.addArrangedSubview(upperStackView)
        recordingStackView.addArrangedSubview(audioBubbleBackView)
        recordingStackView.addArrangedSubview(buttonsStackView)

        // Add buttons to buttons stack
        buttonsStackView.addArrangedSubview(audioNoteDeleteButton)
        buttonsStackView.addArrangedSubview(audioNoteStartButton)
        buttonsStackView.addArrangedSubview(audioNoteStopButton)

        // Configure media recorder views
        mediaRecorderView.addSubview(mediaRecorderImage)
        upperStackView.addArrangedSubview(mediaRecorderBackView)
        upperStackView.addArrangedSubview(audioTimerLabel)

        mediaRecorderBackView.addSubview(mediaRecorderView)
        mediaRecorderView.pin(anchors: [.centerX, .centerY], to: mediaRecorderBackView)

        audioBubbleBackView.pin(anchors: [.leading, .trailing], to: recordingStackView)

        // Embed recording view with insets
        audioBubbleBackView.embed(recordingView, insets: .init(
            top: 0,
            leading: 0,
            bottom: CometChatSpacing.Padding.p2,
            trailing: 0
        ))

        // Pin media recorder image
        mediaRecorderImage.pin(anchors: [.centerX, .centerY], to: mediaRecorderView)

        // Set visibility
        audioTimerLabel.alpha = 1
        mediaRecorderBackView.isHidden = false
        audioBubbleBackView.isHidden = true
        didAudioNoteStartPressed()
    }

    open func setupStyle() {
        // Set background, border, and corner styles
        view.backgroundColor = style.backgroundColor
        view.roundViewCorners(corner: style.cornerRadius ?? .init(cornerRadius: CometChatSpacing.Radius.r6))
        view.borderWith(width: style.borderWidth)
        view.borderColor(color: style.borderColor)

        // Style audioNoteStartButton
        audioNoteStartButton.setImage(style.startButtonImage, for: .normal)
        audioNoteStartButton.tintColor = style.startButtonImageTintColor
        audioNoteStartButton.backgroundColor = style.startButtonBackgroundColor
        audioNoteStartButton.borderColor(color: style.startButtonBorderColor)
        audioNoteStartButton.borderWith(width: style.startButtonBorderWidth)
        audioNoteStartButton.roundViewCorners(corner: style.startButtonCornerRadius ?? .init(cornerRadius: 24))

        // Style audioNotePauseButton
        audioNotePauseButton.setImage(style.pausebuttonImage, for: .normal)
        audioNotePauseButton.tintColor = style.pauseButtonImageTintColor
        audioNotePauseButton.backgroundColor = style.pauseButtonBackgroundColor
        audioNotePauseButton.borderColor(color: style.pauseButtonBorderColor)
        audioNotePauseButton.borderWith(width: style.pauseButtonBorderWidth)
        audioNotePauseButton.roundViewCorners(corner: style.pauseButtonCornerRadius ?? .init(cornerRadius: 24))

        // Style audioNoteDeleteButton
        audioNoteDeleteButton.setImage(style.deleteButtonImage, for: .normal)
        audioNoteDeleteButton.tintColor = style.deleteButtonImageTintColor
        audioNoteDeleteButton.backgroundColor = style.deleteButtonBackgroundColor
        audioNoteDeleteButton.borderColor(color: style.deleteButtonBorderColor)
        audioNoteDeleteButton.borderWith(width: style.deleteButtonBorderWidth)
        audioNoteDeleteButton.roundViewCorners(corner: style.deleteButtonCornerRadius ?? .init(cornerRadius: 20))

        // Style audioNoteSendButton
        audioNoteSendButton.setImage(style.sendButtonImage, for: .normal)
        audioNoteSendButton.tintColor = style.sendButtonImageTintColor
        audioNoteSendButton.backgroundColor = style.sendButtonBackgroundColor
        audioNoteSendButton.borderColor(color: style.sendButtonBorderColor)
        audioNoteSendButton.borderWith(width: style.sendButtonBorderWidth)
        audioNoteSendButton.roundViewCorners(corner: style.sendButtonCornerRadius ?? .init(cornerRadius: 24))

        // Style audioNoteStopButton
        audioNoteStopButton.setImage(style.stopButtonImage, for: .normal)
        audioNoteStopButton.tintColor = style.stopButtonImageTintColor
        audioNoteStopButton.backgroundColor = style.stopButtonBackgroundColor
        audioNoteStopButton.borderColor(color: style.stopButtonBorderColor)
        audioNoteStopButton.borderWith(width: style.stopButtonBorderWidth)
        audioNoteStopButton.roundViewCorners(corner: style.stopButtonCornerRadius ?? .init(cornerRadius: 20))

        // Style audioNoteReRecordButton
        audioNoteReRecordButton.setImage(style.reRecordImage, for: .normal)
        audioNoteReRecordButton.tintColor = style.reRecordButtonImageTintColor
        audioNoteReRecordButton.backgroundColor = style.reRecordButtonBackgroundColor
        audioNoteReRecordButton.borderColor(color: style.reRecordButtonBorderColor)
        audioNoteReRecordButton.borderWith(width: style.reRecordButtonBorderWidth)
        audioNoteReRecordButton.roundViewCorners(corner: style.reRecordButtonCornerRadius ?? .init(cornerRadius: 20))

        // Style media recorder
        mediaRecorderImage.tintColor = style.recordingButtonImageTintColor
        mediaRecorderView.backgroundColor = style.recordingButtonBackgroundColor
        if let radius = style.recordingButtonCornerRadius{
            mediaRecorderView.roundViewCorners(corner: radius)
        }
        mediaRecorderView.borderWith(width: style.recordingButtonBorderWidth)
        mediaRecorderView.borderColor(color: style.recordingButtonBorderColor)
        mediaRecorderImage.image = style.recordingButtonImage

        // Style timer label
        audioTimerLabel.font = style.textFont
        audioTimerLabel.textColor = style.textColor

        // Style recording view
        recordingView.style = CometChatMessageBubble.style.outgoing.audioBubbleStyle
        audioBubbleBackView.backgroundColor = CometChatMessageBubble.style.outgoing.audioBubbleStyle.backgroundColor ?? CometChatTheme.primaryColor
        audioBubbleBackView.borderWith(width: CometChatMessageBubble.style.outgoing.audioBubbleStyle.borderWidth ?? 0)
        audioBubbleBackView.borderColor(color: CometChatMessageBubble.style.outgoing.audioBubbleStyle.borderColor ?? .clear)
        audioBubbleBackView.roundViewCorners(corner: CometChatMessageBubble.style.outgoing.audioBubbleStyle.cornerRadius ?? .init(cornerRadius: CometChatSpacing.Radius.r3))
        
        if #available(iOS 15.0, *) {
            if let sheetView = self.sheetPresentationController?.containerView {
                // Set the corner radius
                sheetView.layer.cornerRadius = style.cornerRadius?.cornerRadius ?? CometChatSpacing.Radius.r6
                sheetView.layer.masksToBounds = true
            }
        } else {
            // Fallback on earlier versions
        }

        // Set GIF for media recorder
//        if let url = CometChatUIKit.bundle.url(forResource: "voice-recording-wavefrom", withExtension: "gif"),
//           let data = NSData(contentsOf: url) {
//            mediaRecorderBackView.setGIFData(data, tintColor: nil)
//        }

        // Add shadow to buttons
        addShadowToButtons()
    }

    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        timer?.invalidate()
        
        do {
            currentState = .recorded
            try audioViewModel.stopRecording()
        } catch {
            showAlert(with: error)
        }
    }

    func startTimer() {
//        mediaRecorderBackView.startAnimation()
        currentState = .recording
        
        // Invalidate any existing timer
        timer?.invalidate()
        
        audioTimerLabel.alpha = 1
        
        // Schedule timer for countdown
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countdown), userInfo: nil, repeats: true)
        timer?.fire()
    }

    @objc func countdown() {
        // Calculate hours, minutes, and seconds
        let hours = totalSecond / 3600
        let minutes = (totalSecond % 3600) / 60
        let seconds = totalSecond % 60
        
        totalSecond += 1
        
        // Format time as hh:mm:ss
        let formattedTime = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        
        // Update the timer label only if not paused
        if currentState != .paused {
            audioTimerLabel.text = formattedTime
        }
        
        // Update the timer label if within the total final seconds limit
        if totalFinalSecond >= totalSecond {
            audioTimerLabel.text = formattedTime
        }
    }

    func setupRecorder() {
        audioViewModel.askAudioRecordingPermission { [weak self] setupDone in
            DispatchQueue.main.async {
                    if !setupDone {
                        // If permission was denied, inform the user
                        self?.dismiss(animated: true)
                        self?.showPermissionDeniedAlert()
                    }
                }
        }
    }
    
    func showPermissionDeniedAlert() {
        let alert = UIAlertController(title: "Permission Denied",
                                      message: "You need to enable audio recording permissions in Settings.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            self.dismiss(animated: true)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    @objc func didAudioNoteStartPressed() {
        // Update the UI by removing start button and adding pause button
        audioNoteStartButton.removeFromSuperview()
        buttonsStackView.insertArrangedSubview(audioNotePauseButton, at: 1)
        
        if currentState == .ready {
            audioViewModel.startRecording { [weak self] soundRecord, error in
                if let error = error {
                    self?.showAlert(with: error)
                    return
                }
                DispatchQueue.main.async {
                    self?.currentState = .recording
                    self?.startTimer()
                }
            }
        } else if currentState == .paused {
            do {
                let duration = try audioViewModel.resume()
                totalSecond = Int(duration)
                currentState = .playing
                startTimer()
                removePlayButtonAndAddPauseButton()
            } catch {
                showAlert(with: error)
            }
        }
    }

    @objc func didAudioNoteDeletePressed(_ sender: UIButton) {
        if currentState == .playing {
            do {
                try audioViewModel.pausePlaying()
                currentState = .paused
            } catch {
                showAlert(with: error)
            }
        }
        
        do {
            currentState = .recorded
            try audioViewModel.stopRecording()
        } catch {
            showAlert(with: error)
        }
        
        // Dismiss the view after stopping recording
        dismiss(animated: true)
    }

    @objc func onSubmitButtonPressed(sender: UIButton) {
        // Handle submission logic
        if let url = didAudioNoteSendPressed() {
            onSubmit?(url)
            dismiss(animated: true, completion: nil)
        }
    }


    @objc func didAudioNoteStopPressed(_ sender: UIButton) {
        stopRecordingAndUpdateUI()
    }

    @objc func didAudioNotePausePressed(_ sender: UIButton) {
//        mediaRecorderBackView.stopAnimation()
        do {
            try audioViewModel.pause()
            currentState = .paused
            removePauseButtonAndAddPlayButton()
        } catch {
            showAlert(with: error)
        }
    }
    
    @objc func didAudioNoteReRecordPressed(_ sender: UIButton) {
        audioTimerLabel.text = "00:00:00"
//        mediaRecorderBackView.stopAnimation()
        do {
            try audioViewModel.resetRecording()
            currentState = .ready
            removePauseButtonAndAddPlayButton()
        } catch {
            showAlert(with: error)
        }
        
        reRecordAudio()
    }

    private func stopRecordingAndUpdateUI() {
//        mediaRecorderBackView.stopAnimation()
        do {
            try audioViewModel.stopRecording()
            currentState = .recorded

            removePauseButtonAndAddSendButton()
            mediaRecorderBackView.isHidden = true
            audioTimerLabel.alpha = 0
            audioBubbleBackView.isHidden = false

            if let url = didAudioNoteSendPressed() {
                recordingView.set(fileURL: url)
            }

        } catch {
            showAlert(with: error)
        }
    }

    private func removePauseButtonAndAddSendButton() {
        // Remove pause button and add send button
        audioNoteStartButton.removeFromSuperview()
        audioNotePauseButton.removeFromSuperview()
        audioNoteStopButton.removeFromSuperview()
        buttonsStackView.insertArrangedSubview(audioNoteSendButton, at: 1)
        buttonsStackView.insertArrangedSubview(audioNoteReRecordButton, at: 2)
        if #available(iOS 15.0, *) {
            let newHeight = (2 * CometChatSpacing.Padding.p5) + (2 * CometChatSpacing.Spacing.s5) + 105
            manageSheetHeight(height: newHeight)
        } else {
            // Fallback on earlier versions
        }
    }
    
    private func removePauseButtonAndAddPlayButton() {
        // Remove pause button and add play button
        audioNotePauseButton.removeFromSuperview()
        buttonsStackView.insertArrangedSubview(audioNoteStartButton, at: 1)
    }
    
    private func removePlayButtonAndAddPauseButton() {
        // Remove pause button and add play button
        audioNoteStartButton.removeFromSuperview()
        buttonsStackView.insertArrangedSubview(audioNotePauseButton, at: 1)
    }
    
    private func reRecordAudio() {
        // Remove pause button and add play button
        let height = (2 * CometChatSpacing.Padding.p3) + (2 * CometChatSpacing.Padding.p5) + (CometChatSpacing.Spacing.s5) + 170
        manageSheetHeight(height: height)
        totalSecond = 0
        mediaRecorderBackView.isHidden = false
        audioTimerLabel.alpha = 1
        audioBubbleBackView.isHidden = true
        audioNoteReRecordButton.removeFromSuperview()
        audioNoteSendButton.removeFromSuperview()
        buttonsStackView.insertArrangedSubview(audioNotePauseButton, at: 1)
        buttonsStackView.insertArrangedSubview(audioNoteStopButton, at: 2)
        didAudioNoteStartPressed()
    }

    @objc func didAudioNoteSendPressed() -> String? {
        if let audioRecord = audioViewModel.currentAudioRecord,
           let audioFilePath = audioRecord.audioFilePathLocal?.absoluteURL {
            return "file://" + audioFilePath.absoluteString
        }
        return nil
    }
    
    private func manageSheetHeight(height: CGFloat){
        if #available(iOS 15.0, *) {
            if let sheetController = self.sheetPresentationController {
                if #available(iOS 16.0, *) {
                    let customDetent = UISheetPresentationController.Detent.custom { _ in
                        return CGFloat(height)
                    }
                    sheetController.detents = [customDetent]
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    @discardableResult
    public func setSubmit(onSubmit: @escaping ((String) -> Void)) -> Self {
        self.onSubmit = onSubmit
        return self
    }
    
    private func addShadowToButtons(){
        audioNoteDeleteButton.applyCornerRadiusAndShadow(cornerRadius: audioNoteDeleteButton.layer.cornerRadius, shadowColor: UIColor(red: 0.063, green: 0.094, blue: 0.157, alpha: 0.06), shadowOpacity: 1, shadowOffset: CGSize(width: 0, height: 2), shadowRadius: 4)
        audioNotePauseButton.applyCornerRadiusAndShadow(cornerRadius: audioNotePauseButton.layer.cornerRadius, shadowColor: UIColor(red: 0.063, green: 0.094, blue: 0.157, alpha: 0.06), shadowOpacity: 1, shadowOffset: CGSize(width: 0, height: 2), shadowRadius: 4)
        audioNoteSendButton.applyCornerRadiusAndShadow(cornerRadius: audioNoteSendButton.layer.cornerRadius, shadowColor: UIColor(red: 0.063, green: 0.094, blue: 0.157, alpha: 0.06), shadowOpacity: 1, shadowOffset: CGSize(width: 0, height: 2), shadowRadius: 4)
        audioNoteStopButton.applyCornerRadiusAndShadow(cornerRadius: audioNoteStopButton.layer.cornerRadius, shadowColor: UIColor(red: 0.063, green: 0.094, blue: 0.157, alpha: 0.06), shadowOpacity: 1, shadowOffset: CGSize(width: 0, height: 2), shadowRadius: 4)
        audioNoteStartButton.applyCornerRadiusAndShadow(cornerRadius: audioNoteStartButton.layer.cornerRadius, shadowColor: UIColor(red: 0.063, green: 0.094, blue: 0.157, alpha: 0.06), shadowOpacity: 1, shadowOffset: CGSize(width: 0, height: 2), shadowRadius: 4)
        audioNoteReRecordButton.applyCornerRadiusAndShadow(cornerRadius: audioNoteReRecordButton.layer.cornerRadius, shadowColor: UIColor(red: 0.063, green: 0.094, blue: 0.157, alpha: 0.06), shadowOpacity: 1, shadowOffset: CGSize(width: 0, height: 2), shadowRadius: 4)
    }
}
