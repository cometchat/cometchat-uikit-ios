//
//  MarkdownParser.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 03/10/25.
//

import Foundation
import UIKit

class CombinedMarkdownBubbleView: UIView {
    private let stackView = UIStackView()
    fileprivate let inlineCodeRegex = "(?<!`)`([^`]+)`(?!`)"
    
    private lazy var parser: MarkdownParser = {
        // Custom header levels
        let h1 = MarkdownHeader(maxLevel: 1, color: CometChatTheme.textColorPrimary)
        let h2 = MarkdownHeader(maxLevel: 2, color: CometChatTheme.textColorPrimary)
        let h3 = MarkdownHeader(maxLevel: 3, color: CometChatTheme.textColorPrimary)

        let link = MarkdownLink(
            font: CometChatTypography.Body.regular,
            color: CometChatTheme.primaryColor
        )

        let parser = MarkdownParser(
            font: CometChatTypography.Body.regular,
            color: CometChatTheme.textColorPrimary,
            enabledElements: .all,
            customElements: [h1, h2, h3, MarkdownBold(), MarkdownItalic(), link]
        )

        // Disable built-in inline code to use your custom styling
        parser.enabledElements.remove(.code)

        return parser
    }()
    
    // Keep track of the last added content
    private var currentText = ""
    
    var style: AIAssistantBubbleStyle? {
        didSet {
            refreshStyle()
        }
    }
    
    private func refreshStyle() {
        for case let rowStack as UIStackView in stackView.arrangedSubviews {
            for case let label as UILabel in rowStack.arrangedSubviews {
                label.textColor = style?.textColor ?? CometChatTheme.textColorPrimary
                label.font = style?.textFont ?? CometChatTypography.Caption1.regular
            }
        }
    }
    
    init(markdown: String = "", style: AIAssistantBubbleStyle = AIAssistantBubbleStyle()) {
        self.style = style
        super.init(frame: .zero)
        setupStackView()
        if !markdown.isEmpty {
            append(markdownChunk: markdown)
        }
        parser.link.color = CometChatTheme.primaryColor
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupStackView() {
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // Incremental append function
    func append(markdownChunk: String) {
        currentText += markdownChunk

        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Parse current text
        var lines = currentText.split(separator: "\n", omittingEmptySubsequences: false)
        var i = 0
        while i < lines.count {
            let line = lines[i].trimmingCharacters(in: .whitespaces)
            
            // Code block
            if line.trimmingCharacters(in: .whitespaces).hasPrefix("```") {
                var codeLines: [String] = []
                let lang = String(line.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                i += 1
                var foundClosingFence = false
                
                while i < lines.count {
                    let current = lines[i].trimmingCharacters(in: .whitespaces)
                    if current.hasPrefix("```") {
                        foundClosingFence = true
                        i += 1
                        break
                    }
                    codeLines.append(String(lines[i]))
                    i += 1
                }
                
                // Even if the closing fence is missing, render safely
                let codeText = codeLines.joined(separator: "\n")
                let codeView = CodeBlockView(code: codeText, language: lang)
                stackView.addArrangedSubview(codeView)
                
                if !foundClosingFence {
                    print("⚠️ Missing closing code fence — rendering till end of text.")
                }
                
                continue
            }
            
            // Table
            if i + 1 < lines.count,
               line.contains("|"),
               lines[i+1].contains("|") && lines[i+1].contains("-") {
                let header = line.split(separator: "|").map { $0.trimmingCharacters(in: .whitespaces) }
                i += 2
                var rows: [[String]] = []
                while i < lines.count && lines[i].contains("|") {
                    let row = lines[i].split(separator: "|").map { $0.trimmingCharacters(in: .whitespaces) }
                    rows.append(row)
                    i += 1
                }
                let tableView = MarkdownTableView(header: header, rows: rows)
                stackView.addArrangedSubview(tableView)
                continue
            }
            
            
            // inside while-loop, paragraph branch
            let para = String(lines[i])

            // 1) parse with your base typography (paragraphs, headings, links, etc.)
            var attributed = NSMutableAttributedString(attributedString: parser.parse(para))

            // 2) apply *custom* inline code styling on the attributed string
            attributed = styleInlineCode(in: attributed)

            // 3) fix link visuals without destroying .link URLs
            fixLinkColors(attributed)

            // 4) assign once — do not override with label.font / label.textColor
            let label = UILabel()
            label.isUserInteractionEnabled = true
            label.numberOfLines = 0
            label.attributedText = attributed

            let tap = UITapGestureRecognizer(target: self, action: #selector(handleLabelTap(_:)))
            label.addGestureRecognizer(tap)

            stackView.addArrangedSubview(label)
            i += 1
            
        }
    }
    
    @objc private func handleLabelTap(_ gesture: UITapGestureRecognizer) {
        guard let label = gesture.view as? UILabel else { return }

        let location = gesture.location(in: label)
        guard let text = label.attributedText else { return }

        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: label.bounds.size)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = label.numberOfLines
        textContainer.lineBreakMode = label.lineBreakMode

        let textStorage = NSTextStorage(attributedString: text)
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)

        let index = layoutManager.characterIndex(
            for: location,
            in: textContainer,
            fractionOfDistanceBetweenInsertionPoints: nil
        )

        let rangePointer = NSRangePointer.allocate(capacity: 1)

        if let url = text.attribute(.link, at: index, effectiveRange: rangePointer) as? URL {
            UIApplication.shared.open(url)
        }
    }

    
    private func fixLinkColors(_ attributedText: NSMutableAttributedString) {
        let fullRange = NSRange(location: 0, length: attributedText.length)
        let linkColor = CometChatTheme.extendedPrimaryColor200

        attributedText.enumerateAttribute(.link, in: fullRange, options: []) { value, range, _ in
            guard value != nil else { return }
        }
    }

    func styleInlineCode(in attributed: NSMutableAttributedString) -> NSMutableAttributedString {
        let text = attributed.string
        let regex = try! NSRegularExpression(pattern: inlineCodeRegex) // (?<!`)`([^`]+)`(?!`)
        let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))

        // iterate reversed so ranges stay valid as we replace
        for match in matches.reversed() {
            let fullRange = match.range(at: 0)
            let innerRange = match.range(at: 1)

            let codeText = (text as NSString).substring(with: innerRange)
            let padded = "\(codeText)"

            let codeAttr = NSMutableAttributedString(string: padded)
            codeAttr.addAttributes([
                .font: CometChatTypography.Body.medium,
                .foregroundColor: CometChatTheme.errorColor,
                .backgroundColor: CometChatTheme.backgroundColor04,
            ], range: NSRange(location: 0, length: codeAttr.length))

            // replace whole backticked region (including backticks) with styled run
            attributed.replaceCharacters(in: fullRange, with: codeAttr)
        }
        return attributed
    }

    
    func reset() {
        currentText = ""
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
}


// MARK: - Custom Code Block View
// MARK: - Custom Code Block View
class CodeBlockView: UIView {

    private var language: String
    private var code: String

    private let textView = UITextView()
    private let copyButton = UIButton(type: .system)

    init(code: String, language: String) {
        self.code = code
        self.language = language
        super.init(frame: .zero)
        setupView()
        applySyntaxHighlighting()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupView() {
        backgroundColor = UIColor.systemGray5
        layer.cornerRadius = 12
        layer.masksToBounds = true

        // Setup text view
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 22, left: 10, bottom: 22, right: 10)
        textView.font = CometChatTypography.Body.regular
        textView.textColor = CometChatTheme.textColorPrimary
        textView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textView)

        // Setup copy button
        copyButton.setImage(UIImage(named: "copyButton", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal) ?? UIImage(), for: .normal)
        copyButton.tintColor = CometChatTheme.iconColorSecondary
        copyButton.addTarget(self, action: #selector(copyTapped), for: .touchUpInside)
        copyButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(copyButton)

        // Layout
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: topAnchor),
            textView.leadingAnchor.constraint(equalTo: leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor),

            copyButton.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            copyButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            copyButton.widthAnchor.constraint(equalToConstant: 22),
            copyButton.heightAnchor.constraint(equalToConstant: 22)
        ])
    }

    // MARK: - Syntax Highlighting
    private func applySyntaxHighlighting() {
        let attributedString = NSMutableAttributedString(string: code)
        let fullRange = NSRange(location: 0, length: attributedString.length)

        attributedString.addAttribute(.font, value: CometChatTypography.Body.regular, range: fullRange)
        attributedString.addAttribute(.foregroundColor, value: UIColor.label, range: fullRange)

        // MARK: - Swift Syntax Patterns
        let keywords = [
            "class", "struct", "enum", "protocol", "extension", "func", "var", "let",
            "if", "else", "for", "while", "switch", "case", "return", "import", "guard"
        ]
        highlight(pattern: "\\b(" + keywords.joined(separator: "|") + ")\\b",
                  color: .systemBlue, in: attributedString)
        highlight(pattern: "\"(.*?)\"",
                  color: .systemOrange, in: attributedString)
        highlight(pattern: "//.*",
                  color: .systemGreen, in: attributedString)

        textView.attributedText = attributedString
    }

    private func highlight(pattern: String, color: UIColor, in attributedString: NSMutableAttributedString) {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return }
        for match in regex.matches(in: attributedString.string,
                                   range: NSRange(location: 0, length: attributedString.length)) {
            attributedString.addAttribute(.foregroundColor, value: color, range: match.range)
        }
    }

    // MARK: - Copy Logic
    @objc private func copyTapped() {
        UIPasteboard.general.string = code
        animateCopyFeedback()
    }

    private func animateCopyFeedback() {
        UIView.animate(withDuration: 0.15, animations: {
            self.copyButton.alpha = 0.4
        }) { _ in
            UIView.animate(withDuration: 0.15) {
                self.copyButton.alpha = 1.0
            }
        }

        // Optional: haptic feedback
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.success)
    }

    // Update code dynamically
    func update(code newCode: String, language newLang: String? = nil) {
        self.code = newCode
        if let newLang = newLang { self.language = newLang }
        applySyntaxHighlighting()
    }
}


// MARK: - Custom Table View
class MarkdownTableView: UIView {
    private let verticalStack = UIStackView()
    private let parser = MarkdownParser()

    init(header: [String], rows: [[String]]) {
        super.init(frame: .zero)
        verticalStack.axis = .vertical
        verticalStack.spacing = 0
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(verticalStack)
        NSLayoutConstraint.activate([
            verticalStack.topAnchor.constraint(equalTo: topAnchor),
            verticalStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            verticalStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            verticalStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        // Apply theme background to table container
        backgroundColor = CometChatTheme.backgroundColor01   // ✅ or your chat bubble background

        // Header row
        verticalStack.addArrangedSubview(makeRow(cells: header, isHeader: true))
        
        // Data rows
        for row in rows {
            verticalStack.addArrangedSubview(makeRow(cells: row, isHeader: false))
        }

        // Border styling
        layer.borderColor = CometChatTheme.borderColorDefault.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 6
        clipsToBounds = true
    }

    required init?(coder: NSCoder) { fatalError() }

    private func makeRow(cells: [String], isHeader: Bool) -> UIStackView {
        let rowStack = UIStackView()
        rowStack.axis = .horizontal
        rowStack.distribution = .fillEqually
        rowStack.spacing = 0

        for cell in cells {
            let cellContainer = UIView()
            cellContainer.layer.borderColor = CometChatTheme.borderColorDark.cgColor
            cellContainer.layer.borderWidth = 0.5

            // Header background vs normal row
            cellContainer.backgroundColor = isHeader
            ? (CometChatTheme.backgroundColor04) // Darker themed background
            : (CometChatTheme.backgroundColor01)

            let label = UILabel()
            label.numberOfLines = 0
            label.textAlignment = .center
            label.lineBreakMode = .byWordWrapping

            // Parse markdown text inside each cell
            let parsedText = parser.parse(cell)
            let mutableAttrText = NSMutableAttributedString(attributedString: parsedText)

            // Typography
            let font = isHeader
            ? CometChatTypography.Body.bold
            : CometChatTypography.Caption1.medium

            let color = isHeader
            ? CometChatTheme.neutralColor900 // White text for contrast on dark header
            : (CometChatTheme.textColorPrimary)

            mutableAttrText.addAttributes([
                .font: font,
                .foregroundColor: color
            ], range: NSRange(location: 0, length: mutableAttrText.length))
            label.attributedText = mutableAttrText

            // Add padding
            let padding: CGFloat = 8
            cellContainer.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: cellContainer.topAnchor, constant: padding),
                label.bottomAnchor.constraint(equalTo: cellContainer.bottomAnchor, constant: -padding),
                label.leadingAnchor.constraint(equalTo: cellContainer.leadingAnchor, constant: padding),
                label.trailingAnchor.constraint(equalTo: cellContainer.trailingAnchor, constant: -padding)
            ])

            rowStack.addArrangedSubview(cellContainer)
        }

        return rowStack
    }

}


extension CombinedMarkdownBubbleView {
    private func applyMarkdownStyling(to attributedText: NSMutableAttributedString) {
        let fullRange = NSRange(location: 0, length: attributedText.length)

        // Base text style
        attributedText.addAttribute(.foregroundColor,
                                    value: style?.textColor ?? CometChatTheme.textColorPrimary,
                                    range: fullRange)
        attributedText.addAttribute(.font,
                                    value: style?.textFont ?? CometChatTypography.Heading4.regular,
                                    range: fullRange)

        // MARK: - Headings (make them bold and slightly larger)
        let headingPatterns = [
            "^# (.*?)$": CometChatTypography.Heading2.bold,
            "^## (.*?)$": CometChatTypography.Heading3.bold,
            "^### (.*?)$": CometChatTypography.Heading4.medium
        ]

        for (pattern, font) in headingPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines]) {
                let matches = regex.matches(in: attributedText.string, options: [], range: fullRange)
                for match in matches {
                    attributedText.addAttribute(.font, value: font, range: match.range)
                }
            }
        }

        // MARK: - Links (color them using theme)
        let linkPattern = "\\[([^\\]]+)\\]\\(([^\\)]+)\\)"
        if let regex = try? NSRegularExpression(pattern: linkPattern, options: []) {
            let matches = regex.matches(in: attributedText.string, options: [], range: fullRange)
            for match in matches {
                if match.numberOfRanges >= 3 {
                    let linkTextRange = match.range(at: 1)
                    attributedText.addAttribute(.foregroundColor,
                                                value: CometChatTheme.primaryColor,
                                                range: linkTextRange)
                    attributedText.addAttribute(.underlineStyle,
                                                value: NSUnderlineStyle.single.rawValue,
                                                range: linkTextRange)
                }
            }
        }
    }
    
    

}

extension CometChatTypography {
    public static let BodyMonospace = UIFont.monospacedSystemFont(ofSize: 14, weight: .bold)
}
