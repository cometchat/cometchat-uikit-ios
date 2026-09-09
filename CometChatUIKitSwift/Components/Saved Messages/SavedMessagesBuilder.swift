//
//  SavedMessagesBuilder.swift
//  CometChatUIKitSwift
//

import UIKit
import CometChatSDK

enum SavedMessagesBuilderResult {
    case success([BaseMessage])
    case failure(CometChatException)
}

public class SavedMessagesBuilder {

    /// Unlike the pinned builder there is no `uid`/`guid` to set: saved messages are a
    /// per-user collection that spans every conversation (doc §6.4). The server caps saves
    /// at 100, so asking for 100 fetches the whole list in one page (§8-Q10).
    public static func getDefaultRequestBuilder() -> CometChatSDK.MessagesRequest.MessageRequestBuilder {
        return CometChatSDK.MessagesRequest.MessageRequestBuilder().set(limit: 100).set(saved: true)
    }

    /// `fetchPrevious` walks backwards from the newest, which is the order the screen shows.
    /// Both callback arguments are optional on `MessagesRequest`, unlike the save-specific
    /// request it replaced.
    static func fetchSavedMessages(request: MessagesRequest, completion: @escaping (SavedMessagesBuilderResult) -> Void) {
        request.fetchPrevious { messages in
            completion(.success(messages ?? []))
        } onError: { error in
            completion(.failure(error ?? SavedMessagesBuilder.unknownError))
        }
    }

    /// `CometChatConstants.Errors` is internal to the SDK, so the code is spelled out.
    private static let unknownError = CometChatException(errorCode: "ERROR_NO_DATA_FOUND",
                                                        errorDescription: "")
}
