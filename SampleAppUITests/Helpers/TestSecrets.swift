import Foundation

/// E2E credentials. Replace each `PASTE_…` below with your CometChat app's values to run the suite
/// (see SampleAppUITests/README.md for where each comes from). A same-named environment variable
/// (`COMETCHAT_*` / `TEST_*`) overrides the value here if set.
///
/// This file is committed with placeholders only. **Never commit real keys** — treat your edits
/// as a local-only change and do not `git add` them.
enum TestSecrets {
    static let appId      = "PASTE_APP_ID"
    static let region     = "in"                 // us | eu | in
    static let authKey    = "PASTE_AUTH_KEY"
    static let restApiKey = "PASTE_REST_API_KEY"

    static let userAUid  = "PASTE_USER_A_UID"
    static let userBUid  = "PASTE_USER_B_UID"
    static let groupGuid = "PASTE_GROUP_GUID"    // a group User A owns

    static let userAName = "PASTE_USER_A_NAME"
    static let userBName = "PASTE_USER_B_NAME"
    static let groupName = "PASTE_GROUP_NAME"
}
