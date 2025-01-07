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
        label.text = "00:00/--:--"
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
    
    /// Initializes the view and builds its UI.
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
    }
    
    /// This initializer is required but not implemented for this custom view.
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        audioTimeLineLabel.pin(anchors: [.leading, .trailing, .bottom], to: audioWaveContainerView)
        
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
            audioWaveContainerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: CometChatSpacing.Padding.p),
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
        
        if let url = CometChatUIKit.bundle.url(forResource: "audio-waveform", withExtension: "gif") {
            if let data = NSData(contentsOf: url) {
                audioWaveView.setGIFData(data, tintColor: style.audioWaveFormTintIcon)
            }
        }
    }
    
    /// Sets the file URL of the audio file to be played.
    /// - Parameter fileURL: A string representing the file URL.
    public func set(fileURL: String) {
        self.fileURL = fileURL
    }
    
    public func set(fileSize: Double) {
        DispatchQueue.main.async { [weak self] in
            self?.audioTimeLineLabel.text = "\(String(format: "%.2f", fileSize/1_048_576)) MB"
        }
    }
    
    /// Sets up the AVPlayer to play the audio file from the specified URL.
    func setupAudioPlayer() {
        
        guard let fileURL = fileURL, let url = URL(string: fileURL) else { return }
        let item = AVPlayerItem(url: url)
        
        // Format the duration of the audio file.
        duration = formatTime(seconds: (Double(item.asset.duration.value) / Double(item.asset.duration.timescale)))
        audioTimeLineLabel.text = "00:00/\(duration)"
        
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
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
        }
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
