//
//  CometChatCallLogHistory.swift
//  Sample App
//
//  Created by Dawinder on 30/10/24.
//

#if canImport(CometChatCallsSDK)

import Foundation
import UIKit
import CometChatSDK
import CometChatUIKitSwift
import CometChatCallsSDK


public class CallLogHistoryVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // MARK: - Properties
    var callLog: [CallLog] = []
    
    public lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CallHistoyTVC.self, forCellReuseIdentifier: "CometChatCallHistoyTVC")
        return tableView
    }()
    
    // MARK: - Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    // MARK: - Setup
    public func setupTableView() {
        view.addSubview(tableView)
        tableView.separatorStyle = .none
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - UITableViewDataSource
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return callLog.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CometChatCallHistoyTVC", for: indexPath) as? CallHistoyTVC else {
            return UITableViewCell()
        }
        
        let call = callLog[indexPath.row]
        configureCell(cell, with: call)
        
        return cell
    }
    
    // MARK: - Cell Configuration
    public func configureCell(_ cell: CallHistoyTVC, with call: CallLog) {
        
        let isInitiator = CometChat.getLoggedInUser()?.uid == (call.initiator as? CallUser)?.uid
        
        if call.status == .cancelled || call.status == .busy || call.status == .rejected || call.status == .unanswered{
            cell.nameLabel.text = "Missed call"
        }else{
            if isInitiator{
                cell.nameLabel.text = "Outgoing call"
            }else{
                cell.nameLabel.text = "Incoming call"
            }
        }
        
        cell.dateLabel.text = convertTimeStampToCallDate(timestamp: Double(call.initiatedAt))
        
        if call.totalDurationInMinutes == 0 {
            cell.durationLabel.text = "----"
            cell.durationLabel.textColor = CometChatTheme.textColorTertiary
        } else {
            cell.durationLabel.text = formatTime(seconds: (call.totalDurationInMinutes*60))
            cell.durationLabel.textColor = CometChatTheme.textColorPrimary
        }
        
        configureCellImage(for: cell, with: call.status, call: call)
    }
    
    public func configureCellImage(for cell: CallHistoyTVC, with status: CallStatus, call: CallLog) {
        switch status {
        case .busy, .unanswered, .rejected, .cancelled:
            cell.cellImageView.image = UIImage(named: "missed_call_image")
            cell.cellImageView.tintColor = CometChatTheme.errorColor
        case .initiated, .ongoing, .ended:
            let isInitiator = CometChat.getLoggedInUser()?.uid == (call.initiator as? CallUser)?.uid
            if isInitiator{
                cell.cellImageView.image = UIImage(systemName: "arrow.up.right")
                cell.cellImageView.tintColor = CometChatTheme.successColor
            }else{
                cell.cellImageView.image = UIImage(systemName: "arrow.down.left")
                cell.cellImageView.tintColor = CometChatTheme.errorColor
            }
        @unknown default:
            break
        }
    }
    
    // MARK: - UITableViewDelegate
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
}

#endif
