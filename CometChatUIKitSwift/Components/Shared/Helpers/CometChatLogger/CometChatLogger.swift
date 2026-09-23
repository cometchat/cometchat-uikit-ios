//
//  CometChatLogger.swift
//  CometChatUIKitSwift
//
//  The UI Kit's single diagnostic output. Nothing in the library should call
//  `print` or `debugPrint` directly — see the tier rules below.
//

import Foundation

/// Verbosity of the UI Kit's diagnostic output.
///
/// Ordered from quietest to noisiest. Setting a level enables that level and
/// every quieter one, so `.warning` emits warnings and errors but nothing else.
public enum CometChatLogLevel: Int, Comparable {

    /// Emit nothing. The default.
    case none = 0

    /// A failure the integrator can act on — a rejected request, a missing
    /// resource, an unrecoverable state.
    case error = 1

    /// Something unexpected that the Kit recovered from.
    case warning = 2

    /// Flow-level tracing. **Never present in a release build of the Kit.**
    case debug = 3

    /// High-frequency tracing. **Never present in a release build of the Kit.**
    case verbose = 4

    public static func < (lhs: CometChatLogLevel, rhs: CometChatLogLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

/// The UI Kit's diagnostic logger.
///
/// ## Two tiers, deliberately different
///
/// `error` and `warning` are **runtime-gated**: they exist in the shipped
/// binary but emit nothing unless an integrator opts in by raising
/// ``logLevel``. They are there so support can ask for logs.
///
/// `debug` and `verbose` are **compiled out** of the shipped binary. Their
/// bodies are wrapped in `#if DEBUG`, and the framework ships built for
/// Release, so those statements are not present in the artifact an integrator
/// links — no matter how the integrator builds their own app. They exist only
/// for engineers building the Kit from source.
///
/// ## The rule that keeps this safe
///
/// **Never pass user data to `error` or `warning`.** No `User`, `Group` or
/// `BaseMessage` object, no uid/guid, no message content, no push token, no
/// display name. Those tiers can reach a customer's device console.
///
/// Log codes, counts, booleans and enum cases instead:
///
/// ```swift
/// // wrong — reaches a real device
/// CometChatLogger.error("scope change failed for \(user.uid)")
///
/// // right
/// CometChatLogger.error("scope change failed: \(error?.errorCode ?? "unknown")")
/// ```
///
/// Identifiers and objects are acceptable in `debug`/`verbose`, which cannot
/// ship. This split is enforced by the linter — see LINT1.
///
/// ## Usage
///
/// ```swift
/// CometChatLogger.logLevel = .warning
/// ```
public enum CometChatLogger {

    private static let lock = NSLock()
    private static var _logLevel: CometChatLogLevel = .none

    /// The minimum level to emit. Defaults to ``CometChatLogLevel/none``.
    ///
    /// Only affects `error` and `warning`; `debug` and `verbose` are absent
    /// from a release build of the Kit regardless of this value.
    public static var logLevel: CometChatLogLevel {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _logLevel
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            _logLevel = newValue
        }
    }

    // MARK: - Shipping tiers (runtime-gated, no user data)

    /// Logs a failure. Present in release builds; silent unless ``logLevel`` allows it.
    ///
    /// - Important: Must not contain user data. See the type documentation.
    static func error(
        _ message: @autoclosure () -> String,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        emit(.error, message(), file: file, function: function, line: line)
    }

    /// Logs a recovered-from anomaly. Present in release builds; silent unless ``logLevel`` allows it.
    ///
    /// - Important: Must not contain user data. See the type documentation.
    static func warning(
        _ message: @autoclosure () -> String,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        emit(.warning, message(), file: file, function: function, line: line)
    }

    // MARK: - Development tiers (compiled out of release)

    /// Logs flow-level tracing. The body is compiled out of release builds of the Kit,
    /// so the message is never constructed or emitted there.
    static func debug(
        _ message: @autoclosure () -> String,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        #if DEBUG
        emit(.debug, message(), file: file, function: function, line: line)
        #endif
    }

    /// Logs high-frequency tracing. The body is compiled out of release builds of the Kit,
    /// so the message is never constructed or emitted there.
    static func verbose(
        _ message: @autoclosure () -> String,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        #if DEBUG
        emit(.verbose, message(), file: file, function: function, line: line)
        #endif
    }

    // MARK: - Private

    private static func emit(
        _ level: CometChatLogLevel,
        _ message: String,
        file: String,
        function: String,
        line: Int
    ) {
        guard logLevel >= level, logLevel != .none else { return }
        let name = (file as NSString).lastPathComponent
        print("[CometChatUIKit][\(label(for: level))] \(name):\(line) \(function) — \(message)")
    }

    private static func label(for level: CometChatLogLevel) -> String {
        switch level {
        case .none: return ""
        case .error: return "error"
        case .warning: return "warning"
        case .debug: return "debug"
        case .verbose: return "verbose"
        }
    }
}
