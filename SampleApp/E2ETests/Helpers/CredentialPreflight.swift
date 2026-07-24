import Foundation
import XCTest

/// Fails fast — with a specific message — when `TestSecrets`/env values are wrong, instead of letting
/// the app silently fail to log in and every test collapse into a misleading timeout errors.

enum CredentialPreflight {

    struct PreflightError: Error, CustomStringConvertible {
        let reason: String
        var description: String { reason }
    }

    private static var baseURL: String {
        "https://\(TestConfig.appId).api-\(TestConfig.region).cometchat.io/v3"
    }

    private static var restHeaders: [String: String] {
        [
            "Content-Type": "application/json",
            "apiKey": TestConfig.restApiKey,
            "appId": TestConfig.appId,
        ]
    }

    /// Runs the preflight exactly once per process; caches the result so every `launch` doesn't re-probe.
    private static var cachedResult: Result<Void, PreflightError>?

    /// Called from `AppLauncher.launch` before the app starts. Records an XCTFail with a precise reason
    /// on the first misconfiguration; a no-op on success and on every call after the first.
    static func runOnce(file: StaticString = #file, line: UInt = #line) {
        if let cached = cachedResult {
            if case let .failure(error) = cached {
                XCTFail(error.reason, file: file, line: line)
            }
            return
        }

        let result: Result<Void, PreflightError>
        do {
            try runBlockingPreflight()
            result = .success(())
        } catch let error as PreflightError {
            result = .failure(error)
        } catch {
            result = .failure(PreflightError(reason: "Credential preflight could not complete: \(error)"))
        }
        cachedResult = result

        if case let .failure(error) = result {
            XCTFail(error.reason, file: file, line: line)
        }
    }

    // MARK: - Probes

    /// Bridges the async probes into `runOnce`'s synchronous context (this file has no XCTestCase to
    /// borrow `runBlocking` from, so it spins its own semaphore).
    private static func runBlockingPreflight() throws {
        let semaphore = DispatchSemaphore(value: 0)
        var thrown: Error?
        Task {
            do { try await validateAll() } catch { thrown = error }
            semaphore.signal()
        }
        // Generous ceiling: 4 sequential probes over a shared backend. Far under the 45s UI timeout.
        if semaphore.wait(timeout: .now() + 30) == .timedOut {
            throw PreflightError(reason: """
                ❌ Credential preflight timed out (30s) reaching \(baseURL).
                Check network access and that TestSecrets.appId/.region form a valid CometChat host.
                """)
        }
        if let thrown { throw thrown }
    }

    private static func validateAll() async throws {
        // 1) appId + region + restApiKey — a bad triple 401/404s here.
        try await validateRestCredentials()

        // 2) Each configured UID must exist in this app.
        try await validateUserExists(TestConfig.userAUid, field: "userAUid")
        try await validateUserExists(TestConfig.userBUid, field: "userBUid")

        // 3) authKey — the value the app actually logs in with. Best-effort: a rejection is definitive,
        //    a non-auth error (e.g. endpoint quirk) is NOT treated as a failure to avoid false negatives.
        try await validateAuthKey()
    }

    private static func validateRestCredentials() async throws {
        let (status, body) = try await get("\(baseURL)/users?perPage=1")
        guard status != 401, status != 403 else {
            throw PreflightError(reason: """
                ❌ REST auth rejected (HTTP \(status)) by \(baseURL).
                Check TestSecrets.appId, .region, and .restApiKey — one of them is wrong.
                Server said: \(body)
                """)
        }
        guard status != 404 else {
            throw PreflightError(reason: """
                ❌ Endpoint not found (HTTP 404) at \(baseURL).
                TestSecrets.appId or .region is likely wrong (the host is built from both).
                """)
        }
        guard (200..<300).contains(status) else {
            throw PreflightError(reason: """
                ❌ Unexpected HTTP \(status) validating REST credentials at \(baseURL).
                Server said: \(body)
                """)
        }
    }

    private static func validateUserExists(_ uid: String, field: String) async throws {
        let (status, body) = try await get("\(baseURL)/users/\(uid)")
        if status == 404 {
            throw PreflightError(reason: """
                ❌ TestSecrets.\(field) = "\(uid)" does not exist in this app.
                Create the user in the CometChat dashboard, or set \(field) to a uid that exists.
                """)
        }
        guard (200..<300).contains(status) else {
            throw PreflightError(reason: """
                ❌ Could not verify TestSecrets.\(field) = "\(uid)" (HTTP \(status)).
                Server said: \(body)
                """)
        }
    }

    /// Mints an auth token with the configured `authKey` — the same secret the app uses to log in.
    /// A 401/403/ERR_AUTH_* here means login WILL fail in-app; surface it now with the reason.
    private static func validateAuthKey() async throws {
        let path = "\(baseURL)/users/\(TestConfig.userAUid)/auth_tokens"
        let bodyData = try? JSONSerialization.data(withJSONObject: ["authOnly": true])
        let (status, body) = try await request(path, method: "POST", body: bodyData, useAuthKey: true)

        if status == 401 || status == 403 || body.contains("ERR_AUTH") {
            throw PreflightError(reason: """
                ❌ TestSecrets.authKey was rejected by the backend (HTTP \(status)).
                In-app login uses this key and will fail. Copy the app's Auth Key from the \
                CometChat dashboard (Chat > Settings > Auth Keys).
                Server said: \(body)
                """)
        }
        // Any other status (2xx, or a non-auth quirk) is accepted — this probe is best-effort so it
        // never blocks a run on an endpoint difference unrelated to the key's validity.
    }

    // MARK: - HTTP

    private static func get(_ urlString: String) async throws -> (status: Int, body: String) {
        try await request(urlString, method: "GET", body: nil, useAuthKey: false)
    }

    /// `useAuthKey` swaps the REST `apiKey` header for the `authKey` (the auth_tokens probe needs it).
    private static func request(
        _ urlString: String,
        method: String,
        body: Data?,
        useAuthKey: Bool
    ) async throws -> (status: Int, body: String) {
        guard let url = URL(string: urlString) else {
            throw PreflightError(reason: "❌ Malformed preflight URL \(urlString) — check TestSecrets.appId/.region.")
        }
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.httpBody = body
        var headers = restHeaders
        if useAuthKey { headers["apiKey"] = TestConfig.authKey }
        for (k, v) in headers { req.setValue(v, forHTTPHeaderField: k) }

        do {
            let (data, response) = try await URLSession.shared.data(for: req)
            let status = (response as? HTTPURLResponse)?.statusCode ?? -1
            let text = String(data: data, encoding: .utf8) ?? "<non-text body>"
            return (status, text)
        } catch {
            throw PreflightError(reason: """
                ❌ Network error reaching \(url) during credential preflight: \(error.localizedDescription).
                Check connectivity and that TestSecrets.appId/.region form a valid host.
                """)
        }
    }
}
