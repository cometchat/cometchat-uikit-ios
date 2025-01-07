//
//  CometChatCallLogRecordings.swift
//  Sample App
//
//  Created by Dawinder on 30/10/24.
//

import Foundation

#if canImport(CometChatCallsSDK)

import UIKit
import CometChatSDK
import CometChatUIKitSwift
import AVFoundation
import AVKit
import CometChatCallsSDK

public class CallLogRecordingsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    public var callLog: CallLog?
    
    public lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CallRecordingTVC.self, forCellReuseIdentifier: "CometChatCallRecordingTVC")
        tableView.separatorStyle = .none
        return tableView
    }()
    
    public lazy var emptyStateView: UIView = {
        let stateView = StateView(
            title: "No Call Recordings",
            subtitle: "Record a call to see call recordings listed here.",
            image: UIImage(systemName: "phone.fill")
        )
        stateView.translatesAutoresizingMaskIntoConstraints = false
        stateView.isHidden = callLog?.recordings.count ?? 0 > 0
        return stateView
    }()
    
    public var downloadingStatus = [Int: (status: DownloadingStatus, url: URL?)]()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    public func setupViews() {
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        configureEmptyStateView()
    }
    
    public func configureEmptyStateView() {
        guard let emptyStateView = emptyStateView as? StateView else { return }
        emptyStateView.titleLabel.font = CometChatTypography.Heading3.bold
        emptyStateView.titleLabel.textColor = CometChatTheme.textColorPrimary
        emptyStateView.subtitleLabel.font = CometChatTypography.Body.regular
        emptyStateView.subtitleLabel.textColor = CometChatTheme.textColorSecondary
        emptyStateView.imageView.tintColor = CometChatTheme.neutralColor300
    }
    
    public func downloadRecording(url: URL, completion: @escaping (_ fileLocation: URL?) -> Void) {
        let destinationUrl = FileManager.default.temporaryDirectory.appendingPathComponent(url.lastPathComponent)
        
        if FileManager.default.fileExists(atPath: destinationUrl.path) {
            completion(destinationUrl)
        } else {
            URLSession.shared.downloadTask(with: url) { location, _, error in
                guard let tempLocation = location, error == nil else {
                    completion(nil)
                    return
                }
                
                do {
                    try FileManager.default.moveItem(at: tempLocation, to: destinationUrl)
                    DispatchQueue.main.async {
                        completion(destinationUrl)
                    }
                } catch {
                    completion(nil)
                }
            }.resume()
        }
    }
    
    @objc public func onDownloadButtonClicked(_ sender: UIButton) {
        guard let recordingURL = URL(string: callLog?.recordings[sender.tag].recordingURL ?? "") else { return }
        
        updateDownloadingStatus(for: sender.tag, to: .downloading)
        
        downloadRecording(url: recordingURL) { [weak self] downloadedRecording in
            guard let self = self else { return }
            let status: DownloadingStatus = downloadedRecording == nil ? .failed : .downloaded
            self.updateDownloadingStatus(for: sender.tag, to: status, url: downloadedRecording)
            if let downloadedRecording{
                self.copyMedia(downloadedRecording)
            }
        }
    }
    
    public func updateDownloadingStatus(for index: Int, to status: DownloadingStatus, url: URL? = nil) {
        downloadingStatus[index] = (status, url)
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    func copyMedia(_ item: Any) {
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            let activityViewController = UIActivityViewController(activityItems: [item], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = this.view
            activityViewController.excludedActivityTypes = [.airDrop]
            this.present(activityViewController, animated: true)
        }
    }
    
    @objc public func onPlayButtonClicked(_ sender: UIButton) {
        guard let videoURLString = callLog?.recordings[sender.tag].recordingURL, let url = URL(string: videoURLString) else { return }
        
        let player = AVPlayer(url: url)
        let playViewController = AVPlayerViewController()
        playViewController.player = player
        present(playViewController, animated: true) {
            playViewController.player?.play()
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return callLog?.recordings.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CallRecordingTVC.identifier, for: indexPath) as? CallRecordingTVC else {
            return UITableViewCell()
        }
        
        configureCell(cell, forRowAt: indexPath)
        return cell
    }
    
    public func configureCell(_ cell: CallRecordingTVC, forRowAt indexPath: IndexPath) {
        guard let recording = callLog?.recordings[indexPath.row] else { return }
        
        cell.titleLabel.text = recording.rid
        cell.dateLabel.text = convertTimeStampToCallDate(timestamp: Double(recording.startTime ?? 0))
        cell.downloadButton.tag = indexPath.row
        cell.playButton.tag = indexPath.row
        cell.downloadButton.addTarget(self, action: #selector(onDownloadButtonClicked(_:)), for: .touchUpInside)
        cell.playButton.addTarget(self, action: #selector(onPlayButtonClicked(_:)), for: .touchUpInside)
        
        let status = downloadingStatus[indexPath.row]?.status ?? .none
        if let status{
            cell.configure(with: status)
        }
    }
}


#endif


public enum DownloadingStatus {
    case failed
    case downloading
    case downloaded
}
