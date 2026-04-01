//
//  InlineVoiceRecorderStyle.swift
//  CometChatUIKitSwift
//
//  Created on 05/02/26.
//

import UIKit

/// Style configuration for CometChatInlineVoiceRecorder
public struct InlineVoiceRecorderStyle {
    
    // MARK: - Container Style
    public var backgroundColor: UIColor = CometChatTheme.backgroundColor01
    public var borderWidth: CGFloat = 1
    public var borderColor: UIColor = CometChatTheme.borderColorLight
    public var cornerRadius: CometChatCornerStyle? = nil
    
    // MARK: - Delete Button Style
    public var deleteButtonImage: UIImage = UIImage(named: "mediaRecorderDelete", in: CometChatUIKit.bundle, with: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    public var deleteButtonImageTintColor: UIColor = CometChatTheme.iconColorSecondary
    public var deleteButtonBackgroundColor: UIColor = .clear
    
    // MARK: - Record/Play Button Style (Left center button)
    public var recordingIndicatorColor: UIColor = CometChatTheme.errorColor
    public var playButtonImage: UIImage = UIImage(systemName: "play.fill")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    private var _playButtonImageTintColor: UIColor?
    public var playButtonImageTintColor: UIColor {
        get { _playButtonImageTintColor ?? CometChatTheme.primaryColor }
        set { _playButtonImageTintColor = newValue }
    }
    public var playButtonBackgroundColor: UIColor = .clear
    
    public var pausePlaybackButtonImage: UIImage = UIImage(named: "mediaRecorderPause", in: CometChatUIKit.bundle, with: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    private var _pausePlaybackButtonImageTintColor: UIColor?
    public var pausePlaybackButtonImageTintColor: UIColor {
        get { _pausePlaybackButtonImageTintColor ?? CometChatTheme.primaryColor }
        set { _pausePlaybackButtonImageTintColor = newValue }
    }
    
    // MARK: - Waveform Style
    public var waveformBarColor: UIColor = CometChatTheme.borderColorDefault
    private var _waveformActiveBarColor: UIColor?
    public var waveformActiveBarColor: UIColor {
        get { _waveformActiveBarColor ?? CometChatTheme.primaryColor }
        set { _waveformActiveBarColor = newValue }
    }
    public var waveformBarWidth: CGFloat = 3
    public var waveformBarSpacing: CGFloat = 2
    public var waveformBarCornerRadius: CGFloat = 1.5
    
    // MARK: - Duration Label Style
    public var durationTextFont: UIFont = CometChatTypography.Body.regular
    public var durationTextColor: UIColor = CometChatTheme.textColorSecondary
    
    // MARK: - Pause/Resume Recording Button Style (Right center button)
    public var pauseRecordingButtonImage: UIImage = UIImage(named: "mediaRecorderPause", in: CometChatUIKit.bundle, with: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    private var _pauseRecordingButtonImageTintColor: UIColor?
    public var pauseRecordingButtonImageTintColor: UIColor {
        get { _pauseRecordingButtonImageTintColor ?? CometChatTheme.iconColorSecondary }
        set { _pauseRecordingButtonImageTintColor = newValue }
    }
    public var pauseRecordingButtonBackgroundColor: UIColor = .clear
    
    public var resumeRecordingButtonImage: UIImage = UIImage(named: "mediaRecorder", in: CometChatUIKit.bundle, with: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    private var _resumeRecordingButtonImageTintColor: UIColor?
    public var resumeRecordingButtonImageTintColor: UIColor {
        get { _resumeRecordingButtonImageTintColor ?? CometChatTheme.iconColorSecondary }
        set { _resumeRecordingButtonImageTintColor = newValue }
    }
    public var resumeRecordingButtonBackgroundColor: UIColor = .clear
    
    // MARK: - Send Button Style
    public var sendButtonImage: UIImage = UIImage(named: "custom-send", in: CometChatUIKit.bundle, with: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    public var sendButtonImageTintColor: UIColor = CometChatTheme.white
    private var _sendButtonBackgroundColor: UIColor?
    public var sendButtonBackgroundColor: UIColor {
        get { _sendButtonBackgroundColor ?? CometChatTheme.primaryColor }
        set { _sendButtonBackgroundColor = newValue }
    }
    public var sendButtonCornerRadius: CometChatCornerStyle? = nil
    
    public init() { }
}
