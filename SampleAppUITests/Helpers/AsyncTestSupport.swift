import XCTest

/// Bridges async REST helpers into synchronous test bodies. `XCUIApplication.launch()` requires the
/// main thread, but an `async` XCTest method runs its body on a background cooperative thread, so UI
/// tests stay synchronous and run REST work to completion here. Spins the run loop on an expectation
/// so the awaited continuation can hop back to the main actor without deadlocking.
extension XCTestCase {

    func runBlocking<T>(timeout: TimeInterval = 60,
                        _ operation: @escaping () async throws -> T) throws -> T {
        let expectation = expectation(description: "runBlocking")
        let box = ResultBox<T>()
        Task {
            do { box.result = .success(try await operation()) }
            catch { box.result = .failure(error) }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: timeout)
        return try box.unwrap()
    }

    func runBlocking(timeout: TimeInterval = 60, _ operation: @escaping () async -> Void) {
        let expectation = expectation(description: "runBlocking")
        Task {
            await operation()
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: timeout)
    }

    /// Poll an async (REST) backend condition until it's true or `timeout` elapses. A thrown error (e.g.
    /// a transient REST failure) counts as "not yet". Lets a test assert the source of truth — the
    /// backend — instead of a UI that may lag or have a refresh glitch.
    func waitForBackend(timeout: TimeInterval, _ condition: @escaping () async throws -> Bool) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        repeat {
            if (try? runBlocking { try await condition() }) == true { return true }
            pause(1.0)
        } while Date() < deadline
        return false
    }

    /// Poll a synchronous UI condition until it's true or `timeout` elapses — waits on a deterministic
    /// signal rather than sleeping on a fixed delay.
    func waitForCondition(timeout: TimeInterval, _ condition: () -> Bool) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if condition() { return true }
            pause(0.4)
        }
        return condition()
    }

    /// Spin the run loop for `seconds` without failing the test — a fresh `XCTWaiter` on an unfulfilled
    /// expectation times out silently (unlike `XCTestCase.wait`, which records a failure). Used only to
    /// pace polling loops, never as a substitute for waiting on a real element.
    private func pause(_ seconds: TimeInterval) {
        _ = XCTWaiter().wait(for: [XCTestExpectation(description: "poll-pace")], timeout: seconds)
    }
}

private final class ResultBox<T> {
    var result: Result<T, Error>?

    func unwrap() throws -> T {
        switch result {
        case let .success(value): return value
        case let .failure(error): throw error
        case .none:
            throw NSError(
                domain: "AsyncTestSupport", code: 1,
                userInfo: [NSLocalizedDescriptionKey: "runBlocking timed out"]
            )
        }
    }
}
