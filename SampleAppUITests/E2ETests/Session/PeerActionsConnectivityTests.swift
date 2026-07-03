import XCTest

/// Proves REST connectivity in isolation (no app launch) before peer-driven assertions rely on it.
final class PeerActionsConnectivityTests: XCTestCase {

    func test_ensureConversationReturnsMessageID() async throws {
        let id = try await PeerActions.sendTextMessage(
            "E2E connectivity probe \(ISO8601DateFormatter().string(from: Date()))"
        )
        XCTAssertGreaterThan(id, 0, "Expected a positive message id from /v3/messages, got \(id)")
    }

    func test_M10_newPeerHelperContracts() async throws {
        let stamp = ISO8601DateFormatter().string(from: Date())

        // Parent message + reaction (emoji in PATH, empty body).
        let parentId = try await PeerActions.sendTextMessage("E2E m10 parent \(stamp)")
        XCTAssertGreaterThan(parentId, 0, "Parent message did not return a positive id")
        await PeerActions.addReaction(parentId, "🔥")
        await PeerActions.removeReaction(parentId, "🔥")

        // Thread reply under the parent → POST /messages/{parent}/thread, returns an id.
        let replyId = try await PeerActions.sendThreadReply(parentId: parentId, text: "E2E m10 reply \(stamp)")
        XCTAssertGreaterThan(replyId, 0, "Thread reply did not return a positive id")

        // Media by hosted URL (no upload).
        let imageId = try await PeerActions.sendImageToA()
        XCTAssertGreaterThan(imageId, 0, "Image message did not return a positive id")
        let fileId = try await PeerActions.sendFileToA()
        XCTAssertGreaterThan(fileId, 0, "File message did not return a positive id")

        // Presence session CRUD (no onBehalfOf) — best-effort, just must not crash.
        await PeerActions.goOnline()
        await PeerActions.goOffline()
    }
}
