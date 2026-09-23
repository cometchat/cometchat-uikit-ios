//
//  LoggedInUserInformation.swift
//
//
//  Created by Abdullah Ansari on 01/12/22.
//

import Foundation
import CometChatSDK


final class LoggedInUserInformation {

    /// Test seam. Inside `$overrideUser.withValue(user) { … }` every query below
    /// answers for that user instead of the SDK session — the hermetic test bundle
    /// has no login, so without it every message is "incoming" and the outgoing
    /// half of the Kit is unreachable. Task-local so parallel suites cannot see
    /// each other's user. Never bound from product code.
    @TaskLocal static var overrideUser: User?

    private static var current: User? { overrideUser ?? CometChat.getLoggedInUser() }

    static func isLoggedInUser(uid: String?) -> Bool {
        guard let loggedInUID = current?.uid, let uid = uid else { return false }
        return uid == loggedInUID
    }

    static func getName() -> String {
        guard let name = current?.name else { return ""}
        return name
    }

    static func getUID() -> String {
        guard let uid = current?.uid else { return "" }
        return uid
    }

    static func getUser() -> User? {
        guard let user = current else { return nil }
        return user
    }

}
