//
//  CometChatComposerInput.swift
//  CometChatUIKitSwift
//

import UIKit

/// A live handle onto the message composer's text input, handed to
/// `CometChatRichTextToolbarAction.onClick` so a custom toolbar button can read
/// and mutate what the user is composing.
///
/// Valid only for the duration of the `onClick` call. The text view is held
/// weakly, so a retained handle degrades to no-ops rather than crashing.
///
/// Mutations apply immediately. Composer state that derives from the text — the
/// toolbar's active formats and the send button — is resynced once when
/// `onClick` returns, not per mutation, so a multi-step edit resyncs once. Call
/// `commit()` to resync earlier.
///
/// Attributes applied here are composer-local. The composer serializes to
/// markdown on send, which has no representation for arbitrary attributes, so
/// anything beyond the built-in formats is dropped from the sent message.
public final class CometChatComposerInput {

    private weak var textView: GrowingTextView?

    /// Supplies the composer's mention ranges. A closure, not a stored array, so
    /// the value is read at call time and can't go stale across mutations.
    private let mentionRangesProvider: () -> [NSRange]

    /// Brackets a programmatic change so the composer's own selection handling
    /// stands down, mirroring the built-in format path.
    private let programmaticChangeHandler: (_ isChanging: Bool) -> Void

    /// Resyncs composer state after a mutation. A no-op when the input is built
    /// standalone, as in tests.
    private let syncHandler: () -> Void

    internal init(
        textView: GrowingTextView?,
        mentionRangesProvider: @escaping () -> [NSRange],
        programmaticChangeHandler: @escaping (Bool) -> Void = { _ in },
        syncHandler: @escaping () -> Void = { }
    ) {
        self.textView = textView
        self.mentionRangesProvider = mentionRangesProvider
        self.programmaticChangeHandler = programmaticChangeHandler
        self.syncHandler = syncHandler
    }

    // MARK: - Reading

    /// The input's contents, including formatting attributes.
    public var attributedText: NSAttributedString {
        get { textView?.attributedText ?? NSAttributedString() }
        set { setAttributedText(newValue) }
    }

    /// The input's contents without attributes.
    public var text: String {
        textView?.text ?? ""
    }

    /// The current selection, or a zero-length range at the caret.
    public var selectedRange: NSRange {
        get { textView?.selectedRange ?? NSRange(location: 0, length: 0) }
        set { setSelectedRange(newValue) }
    }

    /// Whether text is selected, as opposed to a caret being placed.
    public var hasSelection: Bool {
        selectedRange.length > 0
    }

    /// Attributes the next typed character inherits. Set this to make a format
    /// apply to text typed next rather than to a selection.
    public var typingAttributes: [NSAttributedString.Key: Any] {
        get { textView?.typingAttributes ?? [:] }
        set { textView?.typingAttributes = newValue }
    }

    /// The ranges currently occupied by mentions.
    ///
    /// Mentions carry styling the composer restores on its own schedule, so
    /// writing over them gets reverted. The mutating methods skip these by
    /// default.
    ///
    /// Read at call time — ranges shift as the text changes, so re-read after a
    /// mutation rather than caching.
    public var mentionRanges: [NSRange] {
        mentionRangesProvider()
    }

    /// The attributes at a location, or empty if out of bounds.
    public func attributes(at location: Int) -> [NSAttributedString.Key: Any] {
        let current = attributedText
        guard location >= 0, location < current.length else { return [:] }
        return current.attributes(at: location, effectiveRange: nil)
    }

    /// The built-in formats in force over the selection, read from the text
    /// rather than from the toolbar's mode flags, so it describes what the user
    /// has selected rather than what they are about to type.
    ///
    /// A format is reported only when it covers the selection completely — a
    /// selection half in bold is not bold. With a collapsed caret, the formats at
    /// the caret are reported.
    ///
    /// Use it to reflect state on a custom button, and to disable one where its
    /// styling would not survive: text inside `.code` or `.codeBlock` is sent as
    /// raw text, so a token written there travels literally.
    public var activeFormats: Set<FormatType> {
        let current = attributedText
        guard current.length > 0 else { return [] }
        let range = clamp(selectedRange, to: current.length)

        if range.length == 0 {
            let location = min(max(range.location - 1, 0), current.length - 1)
            return formats(in: current.attributes(at: location, effectiveRange: nil))
        }

        var common: Set<FormatType>?
        current.enumerateAttributes(in: range) { attributes, _, _ in
            let here = self.formats(in: attributes)
            common = common.map { $0.intersection(here) } ?? here
        }
        return common ?? []
    }

    /// Built-in formats recorded on one attribute run.
    private func formats(in attributes: [NSAttributedString.Key: Any]) -> Set<FormatType> {
        guard let raw = attributes[RichTextFormatterManager.formatTypeKey] as? Set<String> else { return [] }
        return Set(raw.compactMap(FormatType.init(rawValue:)))
    }

    // MARK: - Mutating

    /// Replaces the contents.
    /// - Parameter preservingSelection: keeps the selection where it was, clamped
    ///   to the new length. Pass `false` to let it collapse to the end.
    public func setAttributedText(_ newText: NSAttributedString, preservingSelection: Bool = true) {
        guard let textView else { return }
        let previousSelection = textView.selectedRange
        programmaticChangeHandler(true)
        textView.attributedText = newText
        if preservingSelection {
            textView.selectedRange = clamp(previousSelection, to: newText.length)
        }
        programmaticChangeHandler(false)
    }

    /// Moves the caret or changes the selection, clamped to the current length.
    public func setSelectedRange(_ range: NSRange) {
        guard let textView else { return }
        programmaticChangeHandler(true)
        textView.selectedRange = clamp(range, to: textView.attributedText?.length ?? 0)
        programmaticChangeHandler(false)
    }

    /// Inserts at the caret, replacing the selection if there is one, and leaves
    /// the caret after the inserted text.
    public func insertAtCaret(_ insertion: NSAttributedString) {
        guard let textView else { return }
        let mutable = NSMutableAttributedString(attributedString: textView.attributedText ?? NSAttributedString())
        let target = clamp(textView.selectedRange, to: mutable.length)
        mutable.replaceCharacters(in: target, with: insertion)
        programmaticChangeHandler(true)
        textView.attributedText = mutable
        textView.selectedRange = NSRange(location: target.location + insertion.length, length: 0)
        programmaticChangeHandler(false)
    }

    /// Inserts plain text at the caret, replacing the selection if there is one.
    ///
    /// The text takes the styling in force at the caret, so an insertion does not
    /// punch an unstyled hole in the run it lands in.
    public func insertAtCaret(_ insertion: String) {
        insertAtCaret(NSAttributedString(string: insertion, attributes: attributesForInsertion()))
    }

    /// Replaces the current selection with plain text, keeping the styling in
    /// force at the selection. Degrades to an insertion when the caret is
    /// collapsed.
    ///
    /// This is the string-level path a formatter-owned token needs: read
    /// `selectedText`, wrap it in the token, and write it back — the token
    /// characters stay in the field and travel on the wire, and the consumer's
    /// `CometChatTextFormatter` renders them.
    public func replaceSelection(_ replacement: String) {
        insertAtCaret(replacement)
    }

    /// The selected substring, or `""` when the caret is collapsed.
    ///
    /// Read from the attributed text rather than `text` so the offsets match
    /// `selectedRange`, which is in UTF-16 units.
    public var selectedText: String {
        guard let textView, let current = textView.attributedText else { return "" }
        let range = clamp(textView.selectedRange, to: current.length)
        guard range.length > 0 else { return "" }
        return (current.string as NSString).substring(with: range)
    }

    /// Attributes an insertion should carry: the field's typing attributes, or
    /// the attributes at the caret when the field has not set any yet.
    private func attributesForInsertion() -> [NSAttributedString.Key: Any] {
        guard let textView else { return [:] }
        let typing = textView.typingAttributes
        if !typing.isEmpty { return typing }
        let current = textView.attributedText ?? NSAttributedString()
        let location = clamp(textView.selectedRange, to: current.length).location
        guard current.length > 0 else { return [:] }
        return current.attributes(at: min(location, current.length - 1), effectiveRange: nil)
    }

    /// Adds attributes over a range, leaving existing ones in place — so a colour
    /// applied over bold text keeps the bold, and vice versa.
    /// - Parameter protectingKitRuns: when true, mention runs are left untouched.
    ///   Links, code and the other runs the kit repaints are the consumer's to
    ///   skip — read `mentionRanges` and the field's own attributes and decide,
    ///   the way the Kotlin and Compose kits leave it to the integrator.
    public func applyAttributes(
        _ attributes: [NSAttributedString.Key: Any],
        to range: NSRange,
        protectingKitRuns: Bool = true
    ) {
        mutate(range, protectingKitRuns: protectingKitRuns) { text, subRange in
            text.addAttributes(attributes, range: subRange)
        }
    }

    /// Removes the named attributes over a range, leaving every other attribute
    /// in place. Removal strips only these keys — the text falls back to the
    /// input's own styling rather than to an explicit value. To reset to a
    /// specific value instead, call `applyAttributes` with it.
    public func removeAttributes(
        _ keys: [NSAttributedString.Key],
        from range: NSRange,
        protectingKitRuns: Bool = true
    ) {
        mutate(range, protectingKitRuns: protectingKitRuns) { text, subRange in
            for key in keys { text.removeAttribute(key, range: subRange) }
        }
    }

    /// Applies attributes over the current selection.
    /// - Returns: whether there was a selection to act on.
    @discardableResult
    public func applyAttributesToSelection(
        _ attributes: [NSAttributedString.Key: Any],
        protectingKitRuns: Bool = true
    ) -> Bool {
        let range = selectedRange
        guard range.length > 0 else { return false }
        applyAttributes(attributes, to: range, protectingKitRuns: protectingKitRuns)
        return true
    }

    /// Removes attributes over the current selection.
    /// - Returns: whether there was a selection to act on.
    @discardableResult
    public func removeAttributesFromSelection(
        _ keys: [NSAttributedString.Key],
        protectingKitRuns: Bool = true
    ) -> Bool {
        let range = selectedRange
        guard range.length > 0 else { return false }
        removeAttributes(keys, from: range, protectingKitRuns: protectingKitRuns)
        return true
    }

    /// Resyncs the toolbar and send button now. Called automatically when
    /// `onClick` returns; call it directly only to make the composer consistent
    /// partway through a long edit.
    public func commit() {
        syncHandler()
    }

    // MARK: - Private

    private func mutate(
        _ range: NSRange,
        protectingKitRuns: Bool,
        _ body: (NSMutableAttributedString, NSRange) -> Void
    ) {
        guard let textView else { return }
        let mutable = NSMutableAttributedString(attributedString: textView.attributedText ?? NSAttributedString())
        let target = clamp(range, to: mutable.length)
        guard target.length > 0 else { return }

        // Collected before mutating: `body` can change attributes, and re-reading
        // the run structure mid-enumeration would shift the ranges underfoot.
        let subRanges = protectingKitRuns
            ? CometChatComposerInput.subtracting(mentionRanges, from: target)
            : [target]
        for subRange in subRanges where subRange.length > 0 {
            body(mutable, subRange)
        }

        let previousSelection = textView.selectedRange
        programmaticChangeHandler(true)
        textView.attributedText = mutable
        textView.selectedRange = clamp(previousSelection, to: mutable.length)
        programmaticChangeHandler(false)
    }

    private func clamp(_ range: NSRange, to length: Int) -> NSRange {
        let location = min(max(range.location, 0), length)
        return NSRange(location: location, length: min(max(range.length, 0), length - location))
    }

    /// The parts of `range` not covered by any of `excluded`.
    ///
    /// Mirrors `RichTextFormatterManager.calculateNonOverlappingRanges`, which is
    /// private to that type, so custom and built-in formats skip mentions alike.
    internal static func subtracting(_ excluded: [NSRange], from range: NSRange) -> [NSRange] {
        let overlapping = excluded
            .map { NSIntersectionRange($0, range) }
            .filter { $0.length > 0 }
            .sorted { $0.location < $1.location }
        guard !overlapping.isEmpty else { return [range] }

        var result: [NSRange] = []
        var cursor = range.location
        for skip in overlapping {
            if skip.location > cursor {
                result.append(NSRange(location: cursor, length: skip.location - cursor))
            }
            cursor = max(cursor, skip.location + skip.length)
        }
        let end = range.location + range.length
        if cursor < end {
            result.append(NSRange(location: cursor, length: end - cursor))
        }
        return result
    }
}
