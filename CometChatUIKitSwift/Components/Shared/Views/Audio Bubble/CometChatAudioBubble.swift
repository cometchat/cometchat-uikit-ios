//
//  CometChatAudioBubble.swift
//
//  Created by Abdullah Ansari on 23/05/22.
//

import Foundation
import UIKit
import AVFoundation

/// A custom UIView for displaying and interacting with audio messages in a CometChat message bubble.
public class CometChatAudioBubble: UIView {
    
    /// A view that acts as the play/pause button for the audio player.
    public lazy var playView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints()
        view.pin(anchors: [.height, .width], to: 32)
        view.roundViewCorners(corner: .init(cornerRadius: 16))
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onPlayPauseViewClicked)))
        view.addSubview(playImageView)
        playImageView.pin(anchors: [.centerX, .centerY], to: view)
        return view
    }()
    
    /// An image view inside the `playView`, used to display the play/pause icon.
    public lazy var playImageView: UIImageView = {
        let imageView = UIImageView().withoutAutoresizingMaskConstraints()
        imageView.contentMode = .scaleAspectFit
        imageView.pin(anchors: [.height, .width], to: 20)
        return imageView
    }()
    
    /// A custom image view that displays an audio waveform as a GIF.
    public lazy var audioWaveView: GIFImageView = {
        let imageView = GIFImageView().withoutAutoresizingMaskConstraints()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.pin(anchors: [.height], to: 24)
        return imageView
    }()
    
    /// A label that shows the audio timeline in "currentTime/totalTime" format.
    public lazy var audioTimeLineLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints()
        label.text = "00:00/00:00"
        return label
    }()
    
    /// A token used for observing the time during playback.
    public var timeObserverToken: Any?
    
    /// The image used for the play button.
    public var playImage = UIImage(systemName: "play.fill")?.withRenderingMode(.alwaysTemplate)
    
    /// The image used for the pause button.
    public var pauseImage = UIImage(systemName: "pause.fill")?.withRenderingMode(.alwaysTemplate)
    
    /// The URL string for the audio file to be played.
    private var fileURL: String?
    
    /// A weak reference to the parent view controller, used for managing audio playback.
    weak var controller: UIViewController?
    
    /// The AVPlayer instance used for playing the audio file.
    private var player: AVPlayer?
    
    internal static var audioCashing: [String: CometChatAudioBubble] = [:]
    
    /// The styling configuration for the audio bubble.
    public var style = AudioBubbleStyle()
    
    /// The total duration of the audio file in "MM:SS" format.
    var duration = "00:00"
    
    static var durationCache: [String: String] = [:]
    
    /// Initializes the view and builds its UI.
    override init(frame: CGRect) {
        super.init(frame: frame)
        NotificationCenter.default.addObserver(self, selector: #selector(handleRecordingStarted), name: Notification.Name("RecordingStarted"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleThemeChange), name: NSNotification.Name("CometChatThemeChanged"), object: nil)
        buildUI()
    }
    
    public override func removeFromSuperview() {
        super.removeFromSuperview()
        playerDidFinishPlaying()
    }

    /// This initializer is required but not implemented for this custom view.
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func handleThemeChange() {
        
        // Update colors from the style's computed properties
        playImageView.tintColor = style.playImageTintColor

    }
    
    @objc private func handleRecordingStarted() {
        // Stop all playing audio bubbles when recording starts
        CometChatAudioBubble.audioCashing.forEach({ $0.value.playerDidFinishPlaying() })
    }
    
    /// Called when the view is about to be added to a window. This sets up the style if the window exists.
    public override func willMove(toWindow newWindow: UIWindow?) {
        if newWindow != nil {
            setUpStyle()
        } else {
            playerDidFinishPlaying()
        }
    }
    
    /// Builds the UI components and adds them to the view.
    public func buildUI() {
        var constraintsToActive = [NSLayoutConstraint]()
        
        withoutAutoresizingMaskConstraints()
        
        // Audio wave container that holds the waveform and timeline label.
        let audioWaveContainerView = UIView().withoutAutoresizingMaskConstraints()
        audioWaveContainerView.addSubview(audioWaveView)
        audioWaveContainerView.addSubview(audioTimeLineLabel)
        audioWaveView.pin(anchors: [.leading, .top], to: audioWaveContainerView)
        audioTimeLineLabel.pin(anchors: [.leading, .trailing], to: audioWaveContainerView)
        audioTimeLineLabel.pin(anchors: [.bottom], to: -2)
        
        constraintsToActive += [
            audioWaveView.bottomAnchor.pin(equalTo: audioTimeLineLabel.topAnchor, constant: -CometChatSpacing.Spacing.s2),
            audioWaveView.trailingAnchor.pin(equalTo: audioWaveContainerView.trailingAnchor)
        ]
        
        addSubview(playView)
        addSubview(audioWaveContainerView)
        
        constraintsToActive += [
            playView.leadingAnchor.pin(equalTo: self.leadingAnchor, constant: CometChatSpacing.Padding.p3),
            playView.topAnchor.pin(equalTo: self.topAnchor, constant: CometChatSpacing.Padding.p3),
            audioWaveContainerView.leadingAnchor.pin(equalTo: playView.trailingAnchor, constant: CometChatSpacing.Padding.p3),
            audioWaveContainerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -CometChatSpacing.Padding.p3),
            audioWaveContainerView.topAnchor.constraint(equalTo: topAnchor, constant: CometChatSpacing.Padding.p3),
            audioWaveContainerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -CometChatSpacing.Padding.p),
            audioWaveContainerView.heightAnchor.constraint(equalToConstant: 50)
        ]
        
        NSLayoutConstraint.activate(constraintsToActive)
    }
    
    /// Applies the style configuration to various components of the audio bubble.
    public func setUpStyle() {
        audioTimeLineLabel.font = style.audioTimeLineFont
        audioTimeLineLabel.textColor = style.audioTimeLineTextColor
        
        playImageView.image = playImage
        playImageView.tintColor = style.playImageTintColor
        playView.backgroundColor = style.playImageBackgroundColor
        
        if let data = AudioWaveformGIFCache.shared.data {
            audioWaveView.setGIFData(data as NSData, tintColor: style.audioWaveFormTintIcon)
        }
    }
    
    /// Sets the file URL of the audio file to be played.
    /// - Parameters:
    ///   - fileURL: A string representing the remote file URL.
    ///   - localFileURL: An optional local file URL to use as fallback for duration calculation.
    ///   - audioDuration: An optional duration in seconds from metadata.
    public func set(fileURL: String, localFileURL: String? = nil, audioDuration: Int? = nil) {
        self.fileURL = fileURL.isEmpty ? localFileURL : fileURL
        updateDurationLabel(localFileURL: localFileURL, audioDuration: audioDuration)
    }

    private func updateDurationLabel(localFileURL: String? = nil, audioDuration: Int? = nil) {
        guard let fileURL = fileURL, !fileURL.isEmpty else { return }

        // If we have duration from metadata, use it immediately
        if let audioDuration = audioDuration, audioDuration > 0 {
            let duration = formatTime(seconds: Double(audioDuration))
            self.duration = duration
            self.audioTimeLineLabel.text = "00:00/\(duration)"
            CometChatAudioBubble.durationCache[fileURL] = duration
            return
        }
        
        if let cached = CometChatAudioBubble.durationCache[fileURL] {
            self.duration = cached
            self.audioTimeLineLabel.text = "00:00/\(cached)"
            return
        }
        
        // Also check cache with local file URL key
        if let localFileURL = localFileURL, let cached = CometChatAudioBubble.durationCache[localFileURL] {
            self.duration = cached
            self.audioTimeLineLabel.text = "00:00/\(cached)"
            CometChatAudioBubble.durationCache[fileURL] = cached
            return
        }

        // Always prefer local file for duration (it's instant, no network needed)
        if let localFileURL = localFileURL, !localFileURL.isEmpty {
            var path = localFileURL
            while path.hasPrefix("file://") {
                path = String(path.dropFirst(7))
            }
            if path.hasPrefix("/") {
                let localURL = URL(fileURLWithPath: path)
                if FileManager.default.fileExists(atPath: path) {
                    do {
                        let audioPlayer = try AVAudioPlayer(contentsOf: localURL)
                        let seconds = audioPlayer.duration
                        if seconds > 0 {
                            let duration = formatTime(seconds: seconds)
                            self.duration = duration
                            self.audioTimeLineLabel.text = "00:00/\(duration)"
                            CometChatAudioBubble.durationCache[fileURL] = duration
                            CometChatAudioBubble.durationCache[localFileURL] = duration
                            return
                        }
                    } catch { }
                }
            }
        }

        // Fallback: load from remote URL asynchronously
        guard let url = URL(string: fileURL) else { return }

        let asset = AVURLAsset(url: url, options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
        asset.loadValuesAsynchronously(forKeys: ["duration"]) { [weak self] in
            var error: NSError?
            let status = asset.statusOfValue(forKey: "duration", error: &error)
            if status == .loaded {
                let seconds = CMTimeGetSeconds(asset.duration)
                if seconds.isNaN || seconds.isInfinite { return }
                let duration = self?.formatTime(seconds: seconds) ?? "00:00"

                DispatchQueue.main.async {
                    self?.duration = duration
                    self?.audioTimeLineLabel.text = "00:00/\(duration)"
                    CometChatAudioBubble.durationCache[fileURL] = duration
                }
            }
        }
    }

    
    public func set(fileSize: Double) {
        DispatchQueue.main.async { [weak self] in
            self?.audioTimeLineLabel.text = "\(String(format: "%.2f", fileSize/1_048_576)) MB"
        }
    }
    
    /// Sets up the AVPlayer to play the audio file from the specified URL.
    func setupAudioPlayer() {
        
        guard let fileURL = fileURL, !fileURL.isEmpty else { return }
        
        let url: URL?
        if fileURL.hasPrefix("file://") {
            var path = fileURL
            while path.hasPrefix("file://") {
                path = String(path.dropFirst(7))
            }
            url = URL(fileURLWithPath: path)
        } else {
            url = URL(string: fileURL)
        }
        
        guard let playerURL = url else { return }
        let item = AVPlayerItem(url: playerURL)

        player = AVPlayer(playerItem: item)
        let session = AVAudioSession.sharedInstance()
        do{
            try session.setCategory(.playback)
            try session.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
            try session.setActive(true)
        } catch {
            print ("\(#file) - \(#function) error: \(error.localizedDescription)")
        }
        
        // Observe when the audio finishes playing.
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
        
        // Add a periodic time observer to update the timeline.
        let interval = CMTime(seconds: 1.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let this = self else { return }
            let currentTimeInSeconds = this.formatTime(seconds: Double(CMTimeGetSeconds(time)))
            
            // If duration wasn't loaded yet, try to get it from the player item
            if this.duration == "00:00", let playerItem = this.player?.currentItem {
                let totalSeconds = CMTimeGetSeconds(playerItem.duration)
                if !totalSeconds.isNaN && !totalSeconds.isInfinite && totalSeconds > 0 {
                    this.duration = this.formatTime(seconds: totalSeconds)
                }
            }
            
            this.audioTimeLineLabel.text = "\(currentTimeInSeconds)/\(this.duration)"
        }
        
    }
    
    /// Called when the audio finishes playing. Resets the player and UI components.
    @objc public func playerDidFinishPlaying() {
        if let fileURL = fileURL {
            CometChatAudioBubble.audioCashing.removeValue(forKey: fileURL)
        }
        player?.pause()
        player?.seek(to: .zero)
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            this.audioWaveView.stopAnimation()
            if let playImage = this.playImage {
                if #available(iOS 17.0, *) {
                    this.playImageView.setSymbolImage(playImage, contentTransition: .replace.downUp.wholeSymbol)
                } else {
                    this.playImageView.image = playImage
                }
            }
        }
    }

    /// Deinitializes the view and removes the time observer.
    deinit {
        NotificationCenter.default.removeObserver(self)
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
        }
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("CometChatThemeChanged"), object: nil)
    }
    
    /// Sets the view controller that manages the audio bubble.
    /// - Parameter controller: The parent view controller.
    public func set(controller: UIViewController) {
        self.controller = controller
    }
    
    /// Handles the play/pause action when the playView is tapped.
    @objc func onPlayPauseViewClicked() {
        guard let fileURL = fileURL else { return }
        
        if player == nil {
            setupAudioPlayer()
        }
        if let player = player {
            if (player.rate != 0 && player.error == nil) { // isPlaying
                player.pause()
                CometChatAudioBubble.audioCashing.removeValue(forKey: fileURL)
                audioWaveView.stopAnimation()
                if let playImage = playImage {
                    if #available(iOS 17.0, *) {
                        playImageView.setSymbolImage(playImage, contentTransition: .replace.downUp.wholeSymbol)
                    } else {
                        playImageView.image = playImage
                    }
                }
            } else {
                audioWaveView.startAnimation()
                CometChatAudioBubble.audioCashing.forEach({ $0.value.playerDidFinishPlaying() })
                CometChatAudioBubble.audioCashing[fileURL] = self
                player.play()
                if let pauseImage = pauseImage {
                    if #available(iOS 17.0, *) {
                        playImageView.setSymbolImage(pauseImage, contentTransition: .replace.downUp.wholeSymbol)
                    } else {
                        playImageView.image = pauseImage
                    }
                }
            }
        }
    }
    
    /// Helper method to format time into "MM:SS" format.
    /// - Parameter seconds: The time in seconds to format.
    /// - Returns: A string formatted as "MM:SS".
    private func formatTime(seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let seconds = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

final class AudioWaveformGIFCache {
    static let shared = AudioWaveformGIFCache()
    let data: Data?

    private init() {
        if let url = CometChatUIKit.bundle.url(forResource: "audio-waveform", withExtension: "gif") {
            self.data = try? Data(contentsOf: url)
        } else {
            self.data = nil
        }
    }
}
