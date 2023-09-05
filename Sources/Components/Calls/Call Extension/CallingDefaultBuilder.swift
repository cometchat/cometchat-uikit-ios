//
//  File.swift
//  
//
//  Created by Admin on 01/08/23.
//

import Foundation
#if canImport(CometChatCallsSDK)
import CometChatCallsSDK

public class CallingDefaultBuilder {
    public static var callSettingsBuilder = CometChatCalls.callSettingsBuilder
        .setDefaultLayout(true)
        .setIsAudioOnly(false)
        .setIsSingleMode(true)
        .setShowSwitchToVideoCall(false)
        .setEnableVideoTileClick(true)
        .setEnableDraggableVideoTile(true)
        .setEndCallButtonDisable(false)
        .setShowRecordingButton(false)
        .setSwitchCameraButtonDisable(false)
        .setMuteAudioButtonDisable(false)
        .setPauseVideoButtonDisable(false)
        .setAudioModeButtonDisable(false)
        .setStartAudioMuted(false)
        .setStartVideoMuted(false)
        .setMode("DEFAULT")
        .setDefaultAudioMode("SPEAKER")
}
#endif
