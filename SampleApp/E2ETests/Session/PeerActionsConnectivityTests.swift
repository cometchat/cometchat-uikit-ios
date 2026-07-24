import XCTest

/// Proves REST connectivity in isolation.
final class PeerActionsConnectivityTests: XCTestCase {

    func test_newPeerHelperContracts() async throws {
        let stamp = ISO8601DateFormatter().string(from: Date())

        let parentId = try await PeerActions.sendTextMessage("E2E peer-helper parent \(stamp)")
        XCTAssertGreaterThan(parentId, 0, "Parent message did not return a positive id")
        await PeerActions.addReaction(parentId, "🔥")
        await PeerActions.removeReaction(parentId, "🔥")

        let replyId = try await PeerActions.sendThreadReply(parentId: parentId, text: "E2E peer-helper reply \(stamp)")
        XCTAssertGreaterThan(replyId, 0, "Thread reply did not return a positive id")

        let imageId = try await PeerActions.sendImageToA()
        XCTAssertGreaterThan(imageId, 0, "Image message did not return a positive id")
        let fileId = try await PeerActions.sendFileToA()
        XCTAssertGreaterThan(fileId, 0, "File message did not return a positive id")

        await PeerActions.goOnline()
        await PeerActions.goOffline()
    }
}
