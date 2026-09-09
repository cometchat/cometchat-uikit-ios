//
//  PinnedMessagesBuilder.swift
//  CometChatUIKitSwift
//

import UIKit
import CometChatSDK

enum PinnedMessagesBuilderResult {
    case success([BaseMessage])
    case failure(CometChatException)
}

public class PinnedMessagesBuilder {

    /// The pinned list is the message list filtered by `pinned`. The server caps pins at
    /// 100 per conversation, so asking for 100 fetches the whole list in one page — the
    /// fetch-all-and-count the panel's title needs (design doc §6.3, §8-Q10).
    public static func getDefaultRequestBuilder() -> CometChatSDK.MessagesRequest.MessageRequestBuilder {
        return CometChatSDK.MessagesRequest.MessageRequestBuilder().set(limit: 100).set(pinned: true)
    }

    /// Scoped to one channel — `uid` and `guid` are mutually exclusive.
    static func getRequestBuilder(user: User?, group: Group?) -> CometChatSDK.MessagesRequest.MessageRequestBuilder {
        let builder = getDefaultRequestBuilder()
        if let guid = group?.guid, !guid.isEmpty {
            return builder.set(guid: guid)
        }
        if let uid = user?.uid, !uid.isEmpty {
            return builder.set(uid: uid)
        }
        return builder
    }

    /// `fetchPrevious` walks backwards from the newest, which is the order the panel shows.
    /// Both callback arguments are optional on `MessagesRequest`, unlike the pin-specific
    /// request it replaced.
    static func fetchPinnedMessages(request: MessagesRequest, completion: @escaping (PinnedMessagesBuilderResult) -> Void) {
        request.fetchPrevious { messages in
            completion(.success(messages ?? []))
        } onError: { error in
            completion(.failure(error ?? PinnedMessagesBuilder.unknownError))
        }
    }

    /// `CometChatConstants.Errors` is internal to the SDK, so the code is spelled out.
    private static let unknownError = CometChatException(errorCode: "ERROR_NO_DATA_FOUND",
                                                        errorDescription: "")
}
