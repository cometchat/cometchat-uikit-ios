//
//  CometChatInlineVoiceRecorder.swift
//  CometChatUIKitSwift
//
//  Created on 05/02/26.
//

import Foundation
import UIKit
import AVFAudio

/// State enum for the inline voice recorder
public enum InlineVoiceRecorderState {
    case idle
    case recording
    case paused
    case playing
    case completed
}

/// A compact inline voice recorder view that displays in the message composer area
public class CometChatInlineVoiceRecorder: UIView {
    
    // MARK: - UI Components
    
    private lazy var containerStackView: UIStackView = {
        let stackView = UIStackView().withoutAutoresizingMaskConstraints()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = CometChatSpacing.Spacing.s2
        return stackView
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton().withoutAutoresizingMaskConstraints()
        button.addTarget(self, action: #selector(onDeletePressed), for: .touchUpInside)
        button.pin(anchors: [.height, .width], to: 32)
        return button
    }()
    
    private lazy var recordPlayButton: UIButton = {
        let button = UIButton().withoutAutoresizingMaskConstraints()
        button.addTarget(self, action: #selector(onRecordPlayPressed), for: .touchUpInside)
        button.pin(anchors: [.height, .width], to: 32)
        return button
    }()
    
    private lazy var recordingIndicatorView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints()
        view.pin(anchors: [.height, .width], to: 10)
        view.layer.cornerRadius = 5
        return view
    }()
    
    private lazy var waveformView: AudioWaveformView = {
        let view = AudioWaveformView().withoutAutoresizingMaskConstraints()
        view.pin(anchors: [.height], to: 32)
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return view
    }()
    
    private lazy var durationLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints()
        label.text = "0:00"
        label.textAlignment = .center
        return label
    }()
    
    private lazy var pauseResumeButton: UIButton = {
        let button = UIButton().withoutAutoresizingMaskConstraints()
        button.addTarget(self, action: #selector(onPauseResumePressed), for: .touchUpInside)
        button.pin(anchors: [.height, .width], to: 32)
        return button
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton().withoutAutoresizingMaskConstraints()
        button.addTarget(self, action: #selector(onSendPressed), for: .touchUpInside)
        button.pin(anchors: [.height, .width], to: 36)
        return button
    }()

    
    // MARK: - Properties
    
    public static var style = InlineVoiceRecorderStyle()
    public lazy var style = CometChatInlineVoiceRecorder.style
    
    private(set) var onSubmit: ((String) -> Void)?
    private(set) var onCancel: (() -> Void)?
    
    private var currentState: InlineVoiceRecorderState = .recording
    private var audioViewModel = ViewModel()
    private var timer: Timer?
    private var totalSeconds: Int = 0
    private var amplitudes: [Float] = []
    
    // Playback
    private var player: AVAudioPlayer?
    private var playbackTimer: Timer?
    private var playbackDuration: TimeInterval = 0
    
    // MARK: - Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
        setupAudioCallbacks()
        setupNotificationObserver()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        stopTimer()
        stopPlaybackTimer()
        player?.stop()
        player = nil
        
        // Stop recording if still active
        if currentState == .recording || currentState == .paused {
            do {
                try audioViewModel.stopRecording()
            } catch {
                print("Error stopping recording in deinit: \(error)")
            }
        }
        
        // Reset the recorder
        do {
            try audioViewModel.resetRecording()
        } catch {
            print("Error resetting recording in deinit: \(error)")
        }
    }
    
    // MARK: - Setup
    
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleThemeChange),
            name: NSNotification.Name("CometChatThemeChanged"),
            object: nil
        )
    }
    
    @objc private func handleThemeChange() {
        setupStyle()
    }
    
    private func setupAudioCallbacks() {
        audioViewModel.audioMeteringLevelUpdate = { [weak self] level in
            DispatchQueue.main.async {
                self?.amplitudes.append(level)
                self?.waveformView.addAmplitude(level)
            }
        }
        
        audioViewModel.audioDidFinish = { [weak self] in
            DispatchQueue.main.async {
                self?.handlePlaybackFinished()
            }
        }
        
        // Setup seek callback for waveform
        waveformView.onSeek = { [weak self] progress in
            self?.handleSeek(to: progress)
        }
    }
    
    private func handleSeek(to progress: Float) {
        guard let player = player, playbackDuration > 0 else { return }
        
        let newTime = TimeInterval(progress) * playbackDuration
        player.currentTime = newTime
        
        // Update duration label to show current position
        updateDurationLabel(seconds: Int(newTime))
        
        // If we were in completed state and user seeks, stay in paused state
        if currentState == .completed {
            currentState = .paused
            updateUIForState()
        }
    }
    
    public override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if newWindow != nil {
            setupStyle()
            setupRecorder()
        }
    }
    
    // MARK: - UI Building
    
    private func buildUI() {
        addSubview(containerStackView)
        
        containerStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12).isActive = true
        containerStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12).isActive = true
        containerStackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        containerStackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
                
        // Add subviews to stack
        containerStackView.addArrangedSubview(deleteButton)
        containerStackView.addArrangedSubview(recordPlayButton)
        containerStackView.addArrangedSubview(waveformView)
        containerStackView.addArrangedSubview(durationLabel)
        containerStackView.addArrangedSubview(pauseResumeButton)
        containerStackView.addArrangedSubview(sendButton)
        
        // Add recording indicator to recordPlayButton
        recordPlayButton.addSubview(recordingIndicatorView)
        recordingIndicatorView.pin(anchors: [.centerX, .centerY], to: recordPlayButton)
        recordingIndicatorView.isHidden = true
    }
    
    private func setupStyle() {
        backgroundColor = style.backgroundColor
        layer.borderWidth = style.borderWidth
        layer.borderColor = style.borderColor.cgColor
        if let cornerRadius = style.cornerRadius {
            roundViewCorners(corner: cornerRadius)
        }
        
        // Delete button
        deleteButton.setImage(style.deleteButtonImage, for: .normal)
        deleteButton.tintColor = style.deleteButtonImageTintColor
        deleteButton.backgroundColor = style.deleteButtonBackgroundColor
        
        // Recording indicator
        recordingIndicatorView.backgroundColor = style.recordingIndicatorColor
        
        // Waveform
        waveformView.barColor = style.waveformBarColor
        waveformView.activeBarColor = style.waveformActiveBarColor
        waveformView.barWidth = style.waveformBarWidth
        waveformView.barSpacing = style.waveformBarSpacing
        waveformView.barCornerRadius = style.waveformBarCornerRadius
        
        // Duration label
        durationLabel.font = style.durationTextFont
        durationLabel.textColor = style.durationTextColor
        
        // Send button
        sendButton.setImage(style.sendButtonImage, for: .normal)
        sendButton.tintColor = style.sendButtonImageTintColor
        sendButton.backgroundColor = style.sendButtonBackgroundColor
        sendButton.roundViewCorners(corner: style.sendButtonCornerRadius ?? .init(cornerRadius: 18))
        
        updateUIForState()
    }

    
    // MARK: - State Management
    
    private func updateUIForState() {
        switch currentState {
        case .idle:
            // Initial state - should start recording immediately
            recordingIndicatorView.isHidden = true
            recordPlayButton.setImage(style.playButtonImage, for: .normal)
            recordPlayButton.tintColor = style.playButtonImageTintColor
            pauseResumeButton.setImage(style.resumeRecordingButtonImage, for: .normal)
            pauseResumeButton.tintColor = style.resumeRecordingButtonImageTintColor
            waveformView.setSeekingEnabled(false)
            
        case .recording:
            // Show red pulsing dot, pause button on right
            recordingIndicatorView.isHidden = false
            recordPlayButton.setImage(nil, for: .normal)
            startRecordingIndicatorAnimation()
            pauseResumeButton.setImage(style.pauseRecordingButtonImage, for: .normal)
            pauseResumeButton.tintColor = style.pauseRecordingButtonImageTintColor
            waveformView.setPlaybackMode(false)
            waveformView.setSeekingEnabled(false)
            
        case .paused:
            // Show play button, mic button on right
            recordingIndicatorView.isHidden = true
            stopRecordingIndicatorAnimation()
            recordPlayButton.setImage(style.playButtonImage, for: .normal)
            recordPlayButton.tintColor = style.playButtonImageTintColor
            pauseResumeButton.setImage(style.resumeRecordingButtonImage, for: .normal)
            pauseResumeButton.tintColor = style.resumeRecordingButtonImageTintColor
            waveformView.setPlaybackMode(true)
            waveformView.setSeekingEnabled(player != nil)
            
        case .playing:
            // Show pause button, mic button on right
            recordingIndicatorView.isHidden = true
            recordPlayButton.setImage(style.pausePlaybackButtonImage, for: .normal)
            recordPlayButton.tintColor = style.pausePlaybackButtonImageTintColor
            pauseResumeButton.setImage(style.resumeRecordingButtonImage, for: .normal)
            pauseResumeButton.tintColor = style.resumeRecordingButtonImageTintColor
            waveformView.setPlaybackMode(true)
            waveformView.setSeekingEnabled(true)
            
        case .completed:
            // Show play button, mic button on right
            recordingIndicatorView.isHidden = true
            recordPlayButton.setImage(style.playButtonImage, for: .normal)
            recordPlayButton.tintColor = style.playButtonImageTintColor
            pauseResumeButton.setImage(style.resumeRecordingButtonImage, for: .normal)
            pauseResumeButton.tintColor = style.resumeRecordingButtonImageTintColor
            waveformView.setPlaybackMode(true)
            waveformView.setPlaybackProgress(0)
            waveformView.setSeekingEnabled(true)
        }
    }
    
    private func startRecordingIndicatorAnimation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.repeat, .autoreverse], animations: {
            self.recordingIndicatorView.alpha = 0.3
        })
    }
    
    private func stopRecordingIndicatorAnimation() {
        recordingIndicatorView.layer.removeAllAnimations()
        recordingIndicatorView.alpha = 1.0
    }
    
    // MARK: - Recording
    
    private func setupRecorder() {
        audioViewModel.askAudioRecordingPermission { [weak self] granted in
            DispatchQueue.main.async {
                if granted {
                    self?.startRecording()
                } else {
                    self?.showPermissionDeniedAlert()
                }
            }
        }
    }
    
    private func startRecording() {
        // Stop any playing audio bubbles
        NotificationCenter.default.post(name: Notification.Name("RecordingStarted"), object: nil)
        
        // Update UI immediately to recording state
        currentState = .recording
        updateUIForState()
        startTimer()
        
        // Set the metering interval for waveform updates (50ms = 20 updates per second)
        audioViewModel.audioVisualizationTimeInterval = 0.05
        
        audioViewModel.startRecording { [weak self] soundRecord, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.currentState = .idle
                    self?.updateUIForState()
                    self?.stopTimer()
                    self?.parentViewController?.showAlert(error: error)
                }
                return
            }
        }
    }
    
    private func pauseRecording() {
        // Validate that there's actually an active recording before trying to pause
        if !AudioRecorderManager.shared.isRunning {
            print("Warning: Attempted to pause recording but recorder is not running")
            // If we're in recording state but recorder isn't running, something went wrong
            // Reset to a safe state
            currentState = .idle
            updateUIForState()
            return
        }
        
        do {
            try audioViewModel.pause()
            stopTimer()
            currentState = .paused
            updateUIForState()
        } catch {
            print("Failed to pause recording: \(error)")
            // If pause fails, check the actual recorder state
            if !AudioRecorderManager.shared.isRunning {
                // Recorder is not running, update state accordingly
                currentState = .idle
                updateUIForState()
            } else {
                parentViewController?.showAlert(error: error)
            }
        }
    }
    
    private func resumeRecording() {
        // Check if the recorder is still available (not stopped for playback)
        if !AudioRecorderManager.shared.isRunning && AudioRecorderManager.shared.currentRecordPath == nil {
            // Recording was stopped for playback, need to re-record
            reRecord()
            return
        }
        
        do {
            _ = try audioViewModel.resume()
            currentState = .recording
            updateUIForState()
            startTimer()
            waveformView.setPlaybackMode(false)
        } catch {
            // If resume fails (e.g., recorder was stopped), start fresh
            print("Resume recording failed: \(error)")
            // Check if it's because the recorder was stopped
            if !AudioRecorderManager.shared.isRunning && AudioRecorderManager.shared.currentRecordPath == nil {
                reRecord()
            } else {
                parentViewController?.showAlert(error: error)
            }
        }
    }
    
    private func stopRecording() {
        do {
            try audioViewModel.stopRecording()
            stopTimer()
            currentState = .completed
            updateUIForState()
            setupPlayback()
        } catch {
            parentViewController?.showAlert(error: error)
        }
    }
    
    // MARK: - Playback
    
    private func setupPlayback() {
        // Try to get the audio file path from the view model first, then fall back to the recorder manager
        var audioFilePath: URL?
        
        if let audioRecord = audioViewModel.currentAudioRecord,
           let path = audioRecord.audioFilePathLocal {
            audioFilePath = path
        } else if let path = AudioRecorderManager.shared.currentRecordPath {
            audioFilePath = path
        }
        
        guard let filePath = audioFilePath else {
            print("No audio file path available for playback")
            return
        }
        
        // Verify the file exists before trying to play it
        if !FileManager.default.fileExists(atPath: filePath.path) {
            print("Audio file does not exist at path: \(filePath.path)")
            return
        }
        
        do {
            // Configure audio session for playback
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: filePath)
            player?.delegate = self
            player?.prepareToPlay()
            playbackDuration = player?.duration ?? 0
            waveformView.setAmplitudes(amplitudes)
            print("Successfully setup playback for file: \(filePath.path)")
        } catch {
            print("Error setting up playback: \(error)")
            print("Failed to setup audio player")
        }
    }
    
    private func startPlayback() {
        // If we don't have a player yet, we need to set it up
        if player == nil {
            // Check if there's an active recording session (paused or running)
            let hasActiveRecordingSession = AudioRecorderManager.shared.isRunning || 
                                           (AudioRecorderManager.shared.currentRecordPath != nil && currentState == .paused)
            
            if hasActiveRecordingSession {
                // We need to stop the recording to finalize the file for playback
                // After this, user will need to start a new recording if they want to add more
                print("Stopping recording to finalize file for playback")
                do {
                    try audioViewModel.stopRecording()
                    print("Recording stopped successfully")
                } catch {
                    print("Error stopping recording for playback: \(error)")
                    return
                }
                
                // Give a longer delay for the file to be finalized and written to disk
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                    print("Attempting to setup playback after delay")
                    self?.setupAndStartPlayback()
                }
                return
            }
            
            setupPlayback()
        }
        
        guard let player = player else {
            print("Failed to setup audio player")
            return
        }
        
        player.play()
        startPlaybackTimer()
        currentState = .playing
        updateUIForState()
        waveformView.setPlaybackMode(true)
    }
    
    private func setupAndStartPlayback() {
        setupPlayback()
        
        guard let player = player else {
            print("Failed to setup audio player after delay")
            // Reset to paused state if playback setup failed
            currentState = .paused
            updateUIForState()
            return
        }
        
        print("Starting playback")
        player.play()
        startPlaybackTimer()
        currentState = .playing
        updateUIForState()
        waveformView.setPlaybackMode(true)
    }
    
    private func pausePlayback() {
        player?.pause()
        stopPlaybackTimer()
        // When pausing playback, go to completed state
        // Recording was stopped to allow playback, so it's now completed
        currentState = .completed
        updateUIForState()
    }
    
    private func handlePlaybackFinished() {
        stopPlaybackTimer()
        player?.currentTime = 0
        waveformView.setPlaybackProgress(0)
        currentState = .completed
        updateUIForState()
        updateDurationLabel(seconds: Int(playbackDuration))
    }

    
    // MARK: - Timer Management
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerTick), userInfo: nil, repeats: true)
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc private func timerTick() {
        totalSeconds += 1
        updateDurationLabel(seconds: totalSeconds)
    }
    
    private func startPlaybackTimer() {
        playbackTimer?.invalidate()
        playbackTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(playbackTimerTick), userInfo: nil, repeats: true)
    }
    
    private func stopPlaybackTimer() {
        playbackTimer?.invalidate()
        playbackTimer = nil
    }
    
    @objc private func playbackTimerTick() {
        guard let player = player, playbackDuration > 0 else { return }
        let progress = Float(player.currentTime / playbackDuration)
        waveformView.setPlaybackProgress(progress)
        updateDurationLabel(seconds: Int(player.currentTime))
    }
    
    private func updateDurationLabel(seconds: Int) {
        let minutes = seconds / 60
        let secs = seconds % 60
        durationLabel.text = String(format: "%d:%02d", minutes, secs)
    }
    
    // MARK: - Button Actions
    
    @objc private func onDeletePressed() {
        // Stop all timers first
        stopTimer()
        stopPlaybackTimer()
        
        // Stop playback if playing
        player?.stop()
        player = nil
        
        // Stop recording if currently recording
        if currentState == .recording || currentState == .paused {
            do {
                try audioViewModel.stopRecording()
            } catch {
                print("Error stopping recording: \(error)")
            }
        }
        
        // Reset the audio recorder manager
        do {
            try audioViewModel.resetRecording()
        } catch {
            print("Error resetting recording: \(error)")
        }
        
        // Reset state
        currentState = .idle
        totalSeconds = 0
        amplitudes = []
        playbackDuration = 0
        
        onCancel?()
    }
    
    @objc private func onRecordPlayPressed() {
        switch currentState {
        case .idle:
            startRecording()
        case .recording:
            // During recording, this button shows the red dot - no action
            break
        case .paused:
            // In paused recording state, play button should play the recording
            // (User can use pause/resume button to continue recording)
            startPlayback()
        case .completed:
            // In completed state (recording was stopped/finalized), play the recording
            startPlayback()
        case .playing:
            pausePlayback()
        }
    }
    
    @objc private func onPauseResumePressed() {
        switch currentState {
        case .recording:
            // Validate that recorder is actually running before trying to pause
            if AudioRecorderManager.shared.isRunning {
                pauseRecording()
            } else {
                print("Warning: In recording state but recorder is not running")
                // Reset to idle state if recorder isn't actually running
                currentState = .idle
                updateUIForState()
            }
        case .paused:
            // We're in paused recording mode - resume the recording
            resumeRecording()
        case .playing:
            // Pause playback
            pausePlayback()
        case .completed:
            // Recording is completed and finalized - cannot resume to same file
            // Start a new recording session (will need to merge audio files later)
            print("Starting new recording session after playback")
            continueRecordingAfterPlayback()
        case .idle:
            break
        }
    }
    
    @objc private func onSendPressed() {
        // Stop any ongoing recording/playback
        if currentState == .recording {
            stopRecording()
        }
        
        player?.stop()
        stopTimer()
        stopPlaybackTimer()
        
        // Get the file path and submit
        if let audioRecord = audioViewModel.currentAudioRecord,
           let audioFilePath = audioRecord.audioFilePathLocal?.absoluteURL {
            let fileURLString = "file://" + audioFilePath.absoluteString
            onSubmit?(fileURLString)
        }
    }
    
    private func reRecord() {
        // Reset everything
        stopTimer()
        stopPlaybackTimer()
        player?.stop()
        player = nil
        totalSeconds = 0
        amplitudes = []
        waveformView.reset()
        updateDurationLabel(seconds: 0)
        
        do {
            try audioViewModel.resetRecording()
            currentState = .idle
            startRecording()
        } catch {
            parentViewController?.showAlert(error: error)
        }
    }
    
    private func continueRecordingAfterPlayback() {
        // Save the current recording duration and amplitudes
        let previousDuration = totalSeconds
        let previousAmplitudes = amplitudes
        
        // Stop playback if active
        player?.stop()
        player = nil
        stopPlaybackTimer()
        
        // Start a new recording session
        // Note: This creates a new file. In a production app, you would need to:
        // 1. Merge the audio files when sending
        // 2. Or use a more sophisticated audio recording approach
        
        print("Continuing recording after playback - previous duration: \(previousDuration)s")
        
        // For now, we'll start fresh recording (matching WhatsApp behavior)
        // The previous recording is preserved and can be merged later
        do {
            try audioViewModel.resetRecording()
            // Keep the previous duration and amplitudes for display continuity
            totalSeconds = previousDuration
            amplitudes = previousAmplitudes
            startRecording()
        } catch {
            parentViewController?.showAlert(error: error)
        }
    }
    
    // MARK: - Permission Alert
    
    private func showPermissionDeniedAlert() {
        let alert = UIAlertController(
            title: "Permission Denied",
            message: "You need to enable audio recording permissions in Settings.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString),
               UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.onCancel?()
        })
        parentViewController?.present(alert, animated: true)
    }
    
    // MARK: - Public API
    
    @discardableResult
    public func setSubmit(onSubmit: @escaping ((String) -> Void)) -> Self {
        self.onSubmit = onSubmit
        return self
    }
    
    @discardableResult
    public func setCancel(onCancel: @escaping (() -> Void)) -> Self {
        self.onCancel = onCancel
        return self
    }
}

// MARK: - AVAudioPlayerDelegate

extension CometChatInlineVoiceRecorder: AVAudioPlayerDelegate {
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        handlePlaybackFinished()
    }
}

// MARK: - Helper Extension

extension UIView {
    var parentViewController: UIViewController? {
        var responder: UIResponder? = self
        while let nextResponder = responder?.next {
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            responder = nextResponder
        }
        return nil
    }
}
