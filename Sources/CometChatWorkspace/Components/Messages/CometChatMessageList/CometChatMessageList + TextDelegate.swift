//
//  CometChatMessageList + TextMessage.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 05/12/21.
//

import Foundation
import CometChatPro
import AudioToolbox

extension CometChatMessageList: TextDelegate {

    func didLongPressedOnTextMessage(message: TextMessage, cell: UITableViewCell) {
        
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))

    }

}
