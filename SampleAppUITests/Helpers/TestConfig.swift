import Foundation

/// Credentials and fixtures for the E2E tests.
///
/// Values come from the git-ignored `TestSecrets.swift` — copy it once per clone:
///
///     cp SampleAppUITests/Helpers/TestSecrets.swift.example SampleAppUITests/Helpers/TestSecrets.swift
///
/// then fill in your CometChat app's values. This file (the logic) stays in git; only your keys,
/// in `TestSecrets.swift`, are ignored. An environment variable of the same name still wins when
/// set, so CI can override without editing the file.
enum TestConfig {
    static let appId      = env("COMETCHAT_APP_ID")       ?? TestSecrets.appId
    static let region     = env("COMETCHAT_REGION")       ?? TestSecrets.region
    static let authKey    = env("COMETCHAT_AUTH_KEY")     ?? TestSecrets.authKey
    static let restApiKey = env("COMETCHAT_REST_API_KEY") ?? TestSecrets.restApiKey

    static let userAUid  = env("TEST_USER_A_UID") ?? TestSecrets.userAUid
    static let userBUid  = env("TEST_USER_B_UID") ?? TestSecrets.userBUid
    static let groupGuid = env("TEST_GROUP_GUID") ?? TestSecrets.groupGuid

    /// Backend display names, used to locate cells by content.
    static let userADisplayName = env("TEST_USER_A_NAME") ?? TestSecrets.userAName
    static let userBDisplayName = env("TEST_USER_B_NAME") ?? TestSecrets.userBName
    static let groupDisplayName = env("TEST_GROUP_NAME")  ?? TestSecrets.groupName

    private static func env(_ key: String) -> String? {
        let value = ProcessInfo.processInfo.environment[key]
        return (value?.isEmpty == false) ? value : nil
    }
}
