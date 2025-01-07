//
//  CometChatCallLogParticipants.swift
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

public class CallLogParticipantsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    public var participants = [Participant]()
    public var callLog: CallLog?
    
    public lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CometChatListItem.self, forCellReuseIdentifier: "CometChatListItem")
        return tableView
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        tableView.separatorStyle = .none
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return callLog?.participants.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let listItem = tableView.dequeueReusableCell(withIdentifier: CometChatListItem.identifier, for: indexPath) as? CometChatListItem {
            
            let participant = callLog?.participants[indexPath.row]
            
            listItem.selectionStyle = .none
            listItem.style.listItemSelectedBackground = .clear
            listItem.statusIndicator.isHidden = true
            listItem.titleLabel.text = participant?.name ?? ""
            listItem.titleLabel.textColor = CometChatTheme.textColorPrimary
            listItem.titleLabel.font = CometChatTypography.Heading4.medium
            listItem.avatarHeightConstraint.constant = 48
            listItem.avatarWidthConstraint.constant = 48
            
            listItem.set(avatarURL: participant?.avatar ?? "", with: participant?.name ?? "")
            
            let dateLabel = UILabel()
            dateLabel.textColor = CometChatTheme.textColorSecondary
            dateLabel.font = CometChatTypography.Body.regular
            dateLabel.text = convertTimeStampToCallDate(timestamp: Double(callLog?.initiatedAt ?? 0))
            listItem.set(subtitle: dateLabel)
            
            let tailViewContainer = UIStackView()
            tailViewContainer.axis = .horizontal
            tailViewContainer.alignment = .trailing
            tailViewContainer.translatesAutoresizingMaskIntoConstraints = false
            tailViewContainer.spacing = 5
            
            let durationLabel = UILabel()
            durationLabel.font = CometChatTypography.Caption1.medium
            if participant?.totalDurationInMinutes ?? 0 <= 0{
                durationLabel.textColor = CometChatTheme.textColorTertiary
            }else{
                durationLabel.textColor = CometChatTheme.textColorPrimary
            }
            durationLabel.text = formatTime(seconds: (participant?.totalDurationInMinutes ?? 0.0)*60)
            durationLabel.textAlignment = .left
            tailViewContainer.addArrangedSubview(durationLabel)
            listItem.set(tail: tailViewContainer)
            
            return listItem
        }
        
        return UITableViewCell()
    }
}
#endif
