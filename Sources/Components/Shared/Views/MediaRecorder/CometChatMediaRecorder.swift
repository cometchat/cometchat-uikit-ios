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
    
    var buttonImage: UIImage {
        switch self {
        case .ready, .recording:
            if #available(iOS 13.0, *) {
                return UIImage(systemName: "pause.fill") ?? UIImage(named: "play")!
            } else {}
        case .recorded, .paused:
            if #available(iOS 13.0, *) {
                return UIImage(systemName: "play.fill") ?? UIImage(named: "play")!
            } else {}
        case .playing:
            if #available(iOS 13.0, *) {
                return UIImage(systemName: "pause.fill") ?? UIImage(named: "play")!
            } else {}
        }
        return UIImage(named: "microphone")!
        
        
    }
    
    var audioVisualizationMode: AudioVisualizationView.AudioVisualizationMode {
        switch self {
        case .ready, .recording:
            return .write
        case .paused, .playing, .recorded:
            return .read
        }
    }
}

public class CometChatMediaRecorder: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UIGestureRecognizerDelegate {
    
    private var mediaRecorderStyle = MediaRecorderStyle()
    private (set) var startIcon: UIImage = UIImage(named: "start", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    private (set) var playIcon: UIImage = UIImage(systemName: "play.fill") ?? UIImage()
    private (set) var pauseIcon: UIImage = UIImage(systemName: "pause.fill") ?? UIImage()
    private (set) var closeIcon: UIImage = UIImage(named: "messages-delete", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    private (set) var stopIcon: UIImage = UIImage(systemName: "stop.fill") ?? UIImage()
    private (set) var submitIcon: UIImage = UIImage(named: "message-composer-send", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    private (set) var pauseIconTint:UIColor = CometChatTheme.palatte.primary
    private (set) var playIconTint:UIColor = CometChatTheme.palatte.primary
    private (set) var deleteIconTint:UIColor = CometChatTheme.palatte.error
    private (set) var submitIconTint:UIColor  = CometChatTheme.palatte.error
    private (set) var startIconTint:UIColor = CometChatTheme.palatte.secondary
    private (set) var stopIconTint:UIColor = CometChatTheme.palatte.error
    private (set) var timerTextFont:UIFont = CometChatTheme.typography.text1
    private (set) var timerTextColor:UIColor = CometChatTheme.palatte.primary
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var audioVisualizationView: AudioVisualizationView!
    @IBOutlet weak var audioNoteStopButton: UIButton!
    @IBOutlet weak var audioNotePlayButton: UIButton!
    @IBOutlet weak var audioNoteTimer: UILabel!
    @IBOutlet weak var audioNoteSendButton: UIButton!
    @IBOutlet weak var audioNoteDeleteButton: UIButton!
    private (set) var onSubmit: ((String) -> Void)?
    private (set) var onClose: (() -> ())?
    private var currentState: AudioRecodingState = .ready {
        didSet {
            self.audioNoteStopButton.setImage(self.currentState.buttonImage, for: .normal)
            self.audioVisualizationView.audioVisualizationMode = self.currentState.audioVisualizationMode
            
//            if !self.audioViewModel.isPlaying {
//                self.audioNotePlayButton.setImage(playIcon, for: .normal)
//            }
        }
    }
    var audioViewModel = ViewModel()
    var viewModel: MediaRecorderViewModel?
    private var chronometer: Chronometer?
    var timer:Timer?
    var totalSecond = 0
    var totalFinalSecond = 0

    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        set(style: mediaRecorderStyle)
        customInit()
    }
    
    func customInit() {
        self.contentView.backgroundColor = mediaRecorderStyle.background
        self.audioNotePlayButton.setImage(self.pauseIcon, for: .normal)
        self.audioNotePlayButton.tintColor = playIconTint
        self.audioNoteDeleteButton.setImage(self.closeIcon, for: .normal)
        self.audioNoteDeleteButton.tintColor = deleteIconTint
        self.audioNoteTimer.font = self.timerTextFont
        self.audioNoteTimer.textColor = self.timerTextColor
        self.audioNoteSendButton.setImage(self.submitIcon, for: .normal)
        self.audioNoteSendButton.tintColor = submitIconTint
        self.audioNoteStopButton.setImage(self.stopIcon, for: .normal)
        self.audioNoteStopButton.tintColor = stopIconTint
        contentView.layer.cornerRadius = 16
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        self.audioVisualizationView.reset()
        timer?.invalidate()
    }
    
    public override func loadView() {
        super.loadView()
        setupRecorder()
    }
    
    func setupRecorder(){
        self.audioViewModel.askAudioRecordingPermission {_ in
            DispatchQueue.main.async {
                self.audioViewModel.audioMeteringLevelUpdate = { [weak self] meteringLevel in
                    guard let strongSelf = self, strongSelf.audioVisualizationView.audioVisualizationMode == .write else {
                        return
                    }
                    strongSelf.audioVisualizationView.add(meteringLevel: meteringLevel)
                }
                self.audioViewModel.audioDidFinish = { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.currentState = .recorded
                    strongSelf.audioVisualizationView.stop()
                }
                if self.currentState == .ready {
                    //            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    do {
                        try self.audioViewModel.stopRecording()
                        try self.audioViewModel.resetRecording()
                    } catch {
                        
                    }
                    self.audioViewModel.startRecording { [weak self] soundRecord, error in
                        if let error = error {
                            self?.showAlert(with: error)
                            return
                        }
                        DispatchQueue.main.async {
                            self?.audioNoteDeleteButton.tintColor = .systemGray
                            self?.currentState = .recording
                            self?.chronometer = Chronometer()
                            self?.chronometer?.start()
                            self?.startTimer()
                        }
                    }
                }
            }
        }
    }
    
    func restartTimer() {
        if totalFinalSecond == 0 {
            totalFinalSecond = totalSecond
        }
        startTimer()
    }
    
    func startTimer(){
        self.audioNoteTimer.text = ""
        timer?.invalidate()
        self.totalSecond = 0
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countdown), userInfo: nil, repeats: true)
    }
    
    @objc func countdown() {
        var hours: Int
        var minutes: Int
        var seconds: Int
        hours = totalSecond / 3600
        minutes = totalSecond / 60
        seconds = totalSecond % 60
        
        totalSecond = totalSecond + 1
        if currentState == .recording{
            audioNoteTimer.text = "\(hours):\(minutes):\(seconds)"
        } else if totalFinalSecond >= totalSecond {
            audioNoteTimer.text = "\(hours):\(minutes):\(seconds)"
            if totalSecond == totalFinalSecond {
                self.audioNotePlayButton.setImage(playIcon, for: .normal)
            }
        }
    }
    
    public func set(style: MediaRecorderStyle) {
        mediaRecorderStyle = style
        
        set(pauseIconTint: style.pauseIconTint)
        set(playIconTint: style.playIconTint)
        set(deleteIconTint: style.deleteIconTint)
        set(timerTextFont: style.timerTextFont)
        set(timerTextColor: style.timerTextColor)
        set(submitIconTint: style.submitIconTint)
        set(startIconTint: style.startIconTint)
        set(stopIconTint: style.stopIconTint)
//        set(borderColor: style.borderColor)
    }
    
    
    public func set(pauseIconTint: UIColor) {
        self.pauseIconTint = pauseIconTint
    }
    
    
    public func set(playIconTint: UIColor) {
        self.playIconTint = playIconTint
    }
    
    
    public func set(deleteIconTint: UIColor) {
        self.deleteIconTint = deleteIconTint
    }
    
    
    public func set(timerTextFont: UIFont) {
        self.timerTextFont = timerTextFont
    }
    
    
    public func set(timerTextColor: UIColor) {
        self.timerTextColor = timerTextColor
    }
    
    
    public func set(submitIconTint: UIColor) {
        self.submitIconTint = submitIconTint
    }
    
    
    public func set(startIconTint: UIColor) {
        self.startIconTint = startIconTint
    }
    
    
    public func set(stopIconTint: UIColor) {
        self.stopIconTint = stopIconTint
    }
    
    @discardableResult
    public func setSubmit(onSubmit: @escaping ((String) -> Void)) -> Self {
        self.onSubmit = onSubmit
        return self
    }
    
    @IBAction func onSubmitButtonPressed(_ sender: UIButton) {
        let url = didAudioNoteSendPressed()
        if let onSubmit = onSubmit {
            if let url = url {
                onSubmit(url)
            }
        }
    }
    
    @IBAction func didAudioNoteDeletePressed(_ sender: UIButton) {
        if currentState == .playing {
            do {
                try self.audioViewModel.pausePlaying()
                self.currentState = .paused
                self.audioVisualizationView.pause()
            } catch {
                self.showAlert(with: error)
            }
        }
        do {
            try self.audioViewModel.resetRecording()
            self.audioVisualizationView.reset()
            self.currentState = .ready
        } catch {
            self.showAlert(with: error)
        }
        
        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            AudioServicesPlayAlertSound(SystemSoundID(1519))
            self.dismiss(animated: true)
//            self.isAudioPaused = false
        })
    }
    
    @IBAction func didAudioNoteStopPressed(_ sender: UIButton) {
        if currentState == .recording {
            do {
                try self.audioViewModel.stopRecording()
                self.currentState = .recorded
                self.audioVisualizationView.stop()
                
            } catch {
                self.showAlert(with: error)
            }
        }
        do {
            let duration = try self.audioViewModel.startPlaying()
            self.currentState = .playing
            self.audioVisualizationView.meteringLevels = self.audioViewModel.currentAudioRecord!.meteringLevels
            self.audioVisualizationView.play(for: duration)
            restartTimer()
            self.audioNoteStopButton.isHidden = true
            self.audioNotePlayButton.isHidden = false
        } catch {
            self.showAlert(with: error)
        }
    }
    
    func didAudioNoteSendPressed() -> String? {
        switch self.currentState {
        case .recording:
            self.chronometer?.stop()
            self.chronometer = nil
            self.audioViewModel.currentAudioRecord!.meteringLevels = self.audioVisualizationView.scaleSoundDataToFitScreen()
            self.audioVisualizationView.audioVisualizationMode = .read
            self.audioNotePlayButton.isHidden = true
            
            do {
                try self.audioViewModel.stopRecording()
                self.currentState = .recorded
            } catch {
                self.currentState = .ready
                self.showAlert(with: error)
            }
        case .recorded, .paused:
            do {
                let duration = try self.audioViewModel.startPlaying()
                self.currentState = .playing
                self.audioVisualizationView.meteringLevels = self.audioViewModel.currentAudioRecord!.meteringLevels
            } catch {
                self.showAlert(with: error)
            }
        case .playing:
            do {
                try self.audioViewModel.pausePlaying()
                self.currentState = .paused
            } catch {
                self.showAlert(with: error)
            }
        default:
            break
        }
        if let url = self.audioViewModel.currentAudioRecord?.audioFilePathLocal?.absoluteURL {
            let newURL = "file://" + url.absoluteString
            UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
                AudioServicesPlayAlertSound(SystemSoundID(1519))
                self.dismiss(animated: true)
            })
            return newURL
        } else {
            return nil
        }
    }
    
    @IBAction func didAudioNotePausePressed(_ sender: UIButton) {
       switch self.currentState {
       case .recording:
           self.chronometer?.stop()
           self.chronometer = nil
           self.audioViewModel.currentAudioRecord!.meteringLevels = self.audioVisualizationView.scaleSoundDataToFitScreen()
           self.audioVisualizationView.audioVisualizationMode = .read
           self.audioNotePlayButton.isHidden = true
           
           do {
               try self.audioViewModel.stopRecording()
               self.currentState = .recorded
           } catch {
               self.currentState = .ready
               self.showAlert(with: error)
           }
       case .recorded, .paused:
           do {
               let duration = try self.audioViewModel.startPlaying()
               self.currentState = .playing
               self.audioVisualizationView.meteringLevels = self.audioViewModel.currentAudioRecord!.meteringLevels
               restartTimer()
               self.audioVisualizationView.play(for: duration)
               self.audioNotePlayButton.setImage(pauseIcon, for: .normal)
               self.audioNotePlayButton.isHidden = false
           } catch {
               self.showAlert(with: error)
           }
       case .playing:
           do {
               try self.audioViewModel.pausePlaying()
               self.currentState = .paused
               self.audioVisualizationView.pause()
               self.audioNotePlayButton.setImage(playIcon, for: .normal)
               self.audioNotePlayButton.isHidden = false
           } catch {
               self.showAlert(with: error)
           }
       default:
           break
       }
   }
}
