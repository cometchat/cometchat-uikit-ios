import Foundation
import XCTest

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

    /// Maps each resolved value to the env var that supplies it in CI (where TestSecrets.swift is a placeholder stub).
    private static let requiredFields: [(env: String, value: String)] = [
        ("COMETCHAT_APP_ID", appId), ("COMETCHAT_REGION", region),
        ("COMETCHAT_AUTH_KEY", authKey), ("COMETCHAT_REST_API_KEY", restApiKey),
        ("TEST_USER_A_UID", userAUid), ("TEST_USER_B_UID", userBUid), ("TEST_GROUP_GUID", groupGuid),
        ("TEST_USER_A_NAME", userADisplayName), ("TEST_USER_B_NAME", userBDisplayName), ("TEST_GROUP_NAME", groupDisplayName),
    ]

    /// Fail fast with an actionable message when credentials are still placeholders/empty — otherwise the app just
    /// launches and times out on a failed login. Called once from AppLauncher before the first launch.
    static func validate(file: StaticString = #file, line: UInt = #line) {
        let missing = requiredFields.filter { $0.value.isEmpty || $0.value.hasPrefix("PASTE_") }
        guard missing.isEmpty else {
            let vars = missing.map(\.env).joined(separator: ", ")
            XCTFail("""
                E2E credentials are not set: \(vars).
                Fill SampleAppUITests/Helpers/TestSecrets.swift, or set these env vars (they override the file). \
                In CI, run Scripts/scaffold-test-secrets.sh and inject the vars as secrets. See SampleAppUITests/README.md.
                """, file: file, line: line)
            return
        }
    }
}
