import Foundation

/// Values come from git-ignored TestSecrets.swift (copy TestSecrets.swift.example; env vars of the same name win). See SampleAppUITests/README.md.
enum TestConfig {
    static let appId      = env("COMETCHAT_APP_ID")       ?? TestSecrets.appId
    static let region     = env("COMETCHAT_REGION")       ?? TestSecrets.region
    static let authKey    = env("COMETCHAT_AUTH_KEY")     ?? TestSecrets.authKey
    static let restApiKey = env("COMETCHAT_REST_API_KEY") ?? TestSecrets.restApiKey

    static let userAUid  = env("TEST_USER_A_UID") ?? TestSecrets.userAUid
    static let userBUid  = env("TEST_USER_B_UID") ?? TestSecrets.userBUid
    static let groupGuid = env("TEST_GROUP_GUID") ?? TestSecrets.groupGuid

    static let userADisplayName = env("TEST_USER_A_NAME") ?? TestSecrets.userAName
    static let userBDisplayName = env("TEST_USER_B_NAME") ?? TestSecrets.userBName
    static let groupDisplayName = env("TEST_GROUP_NAME")  ?? TestSecrets.groupName

    private static func env(_ key: String) -> String? {
        let value = ProcessInfo.processInfo.environment[key]
        return (value?.isEmpty == false) ? value : nil
    }
}
