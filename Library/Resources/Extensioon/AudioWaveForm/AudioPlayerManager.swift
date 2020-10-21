//
//  AudioPlayerManager.swift
//  ela
//
//  Created by Bastien Falcou on 4/14/16.
//  Copyright © 2016 Fueled. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

final class AudioPlayerManager: NSObject {
	static let shared = AudioPlayerManager()

	var isRunning: Bool {
		guard let audioPlayer = self.audioPlayer, audioPlayer.isPlaying else {
			return false
		}
		return true
	}

	private var audioPlayer: AVAudioPlayer?
	private var audioMeteringLevelTimer: Timer?

	// MARK: - Reinit and play from the beginning

	func play(at url: URL, with audioVisualizationTimeInterval: TimeInterval = 0.05) throws -> TimeInterval {
		if AudioRecorderManager.shared.isRunning {
			print("Audio Player did fail to start: AVFoundation is recording")
			throw AudioErrorType.alreadyRecording
		}

		if self.isRunning {
			print("Audio Player did fail to start: already playing a file")
			throw AudioErrorType.alreadyPlaying
		}

		if !URL.checkPath(url.path) {
			print("Audio Player did fail to start: file doesn't exist")
			throw AudioErrorType.audioFileWrongPath
		}

		try self.audioPlayer = AVAudioPlayer(contentsOf: url)
		self.setupPlayer(with: audioVisualizationTimeInterval)
		print("Started to play sound")

		return self.audioPlayer!.duration
	}

	func play(_ data: Data, with audioVisualizationTimeInterval: TimeInterval = 0.05) throws -> TimeInterval {
		try self.audioPlayer = AVAudioPlayer(data: data)
		self.setupPlayer(with: audioVisualizationTimeInterval)
		print("Started to play sound")

		return self.audioPlayer!.duration
	}
	
	private func setupPlayer(with audioVisualizationTimeInterval: TimeInterval) {
		if let player = self.audioPlayer {
			player.play()
			player.isMeteringEnabled = true
			player.delegate = self
			
			self.audioMeteringLevelTimer = Timer.scheduledTimer(timeInterval: audioVisualizationTimeInterval, target: self,
				selector: #selector(AudioPlayerManager.timerDidUpdateMeter), userInfo: nil, repeats: true)
		}
	}

	// MARK: - Resume and pause current if exists

	func resume() throws -> TimeInterval {
		if self.audioPlayer?.play() == false {
			print("Audio Player did fail to resume for internal reason")
			throw AudioErrorType.internalError
		}

		print("Resumed sound")
		return self.audioPlayer!.duration - self.audioPlayer!.currentTime
	}

	func pause() throws {
		if !self.isRunning {
			print("Audio Player did fail to start: there is nothing currently playing")
			throw AudioErrorType.notCurrentlyPlaying
		}

		self.audioPlayer?.pause()
		print("Paused current playing sound")
	}

	func stop() throws {
		if !self.isRunning {
			print("Audio Player did fail to stop: there is nothing currently playing")
			throw AudioErrorType.notCurrentlyPlaying
		}
		
		self.audioPlayer?.stop()
		print("Audio player stopped")
	}
	
	// MARK: - Private

	@objc private func timerDidUpdateMeter() {
		if self.isRunning {
			self.audioPlayer!.updateMeters()
			let averagePower = self.audioPlayer!.averagePower(forChannel: 0)
			let percentage: Float = pow(10, (0.05 * averagePower))
			NotificationCenter.default.post(name: .audioPlayerManagerMeteringLevelDidUpdateNotification, object: self, userInfo: [audioPercentageUserInfoKey: percentage])
		}
	}
}

extension AudioPlayerManager: AVAudioPlayerDelegate {
	func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
		NotificationCenter.default.post(name: .audioPlayerManagerMeteringLevelDidFinishNotification, object: self)
	}
}

extension Notification.Name {
	static let audioPlayerManagerMeteringLevelDidUpdateNotification = Notification.Name("AudioPlayerManagerMeteringLevelDidUpdateNotification")
	static let audioPlayerManagerMeteringLevelDidFinishNotification = Notification.Name("AudioPlayerManagerMeteringLevelDidFinishNotification")
}



enum AudioErrorType: Error {
    case alreadyRecording
    case alreadyPlaying
    case notCurrentlyPlaying
    case audioFileWrongPath
    case recordFailed
    case playFailed
    case recordPermissionNotGranted
    case internalError
}

extension AudioErrorType: LocalizedError {
     var errorDescription: String? {
        switch self {
        case .alreadyRecording:
            return "The application is currently recording sounds"
        case .alreadyPlaying:
            return "The application is already playing a sound"
        case .notCurrentlyPlaying:
            return "The application is not currently playing"
        case .audioFileWrongPath:
            return "Invalid path for audio file"
        case .recordFailed:
            return "Unable to record sound at the moment, please try again"
        case .playFailed:
            return "Unable to play sound at the moment, please try again"
        case .recordPermissionNotGranted:
            return "Unable to record sound because the permission has not been granted. This can be changed in your settings."
        case .internalError:
            return "An error occured while trying to process audio command, please try again"
        }
    }
}


extension URL {
    static func checkPath(_ path: String) -> Bool {
        let isFileExist = FileManager.default.fileExists(atPath: path)
        return isFileExist
    }
    
    static func documentsPath(forFileName fileName: String) -> URL? {
        let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let writePath = URL(string: documents)!.appendingPathComponent(fileName)
        
        var directory: ObjCBool = ObjCBool(false)
        if FileManager.default.fileExists(atPath: documents, isDirectory:&directory) {
            return directory.boolValue ? writePath : nil
        }
        return nil
    }
}

extension UIViewController {
    func showAlert(with error: Error) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel) { _ in
            alertController.dismiss(animated: true, completion: nil)
        })
         alertController.view.tintColor = UIKitSettings.primaryColor
        DispatchQueue.main.async { [weak self] in
        guard let this = self else { return }
            this.present(alertController, animated: true, completion: nil)
        }
    }
}
