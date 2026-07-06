import XCTest

/// Bridges async REST into synchronous test bodies; spins the run loop so the continuation can hop back to the main thread without deadlocking.
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

    func waitForBackend(timeout: TimeInterval, _ condition: @escaping () async throws -> Bool) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        repeat {
            if (try? runBlocking { try await condition() }) == true { return true }
            pause(1.0)
        } while Date() < deadline
        return false
    }

    func waitForCondition(timeout: TimeInterval, _ condition: () -> Bool) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if condition() { return true }
            pause(0.4)
        }
        return condition()
    }

    /// A fresh `XCTWaiter` times out silently, unlike `XCTestCase.wait` which records a failure.
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
