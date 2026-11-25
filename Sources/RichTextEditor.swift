import SwiftUI
import AppKit

// PART A: the Mac text box that knows how to do bold, italic, and so on.
final class RichTextView: NSTextView {

    @objc func toggleBold(_ sender: Any?) { toggleFontTrait(.boldFontMask) }
    @objc func toggleItalic(_ sender: Any?) { toggleFontTrait(.italicFontMask) }

    @objc func toggleUnderlineStyle(_ sender: Any?) {
        toggleAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue)
    }
    @objc func toggleStrikethrough(_ sender: Any?) {
        toggleAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue)
    }
    @objc func toggleHighlight(_ sender: Any?) {
        toggleAttribute(.backgroundColor, value: NSColor.systemYellow)
    }

    // Bold and italic: swap each piece of text's font for its bold/italic version.
    private func toggleFontTrait(_ trait: NSFontTraitMask) {
        let fm = NSFontManager.shared
        let range = selectedRange()
        let fallback = NSFont.systemFont(ofSize: 14)

        // Nothing selected: change what you type next.
        if range.length == 0 {
            let font = typingAttributes[.font] as? NSFont ?? fallback
            let hasIt = fm.traits(of: font).contains(trait)
            typingAttributes[.font] = hasIt ? fm.convert(font, toNotHaveTrait: trait)
                                            : fm.convert(font, toHaveTrait: trait)
            return
        }

        guard let storage = textStorage,
              shouldChangeText(in: range, replacementString: nil) else { return }
        let firstFont = storage.attribute(.font, at: range.location, effectiveRange: nil) as? NSFont ?? fallback
        let turnOn = !fm.traits(of: firstFont).contains(trait)
        storage.beginEditing()
        storage.enumerateAttribute(.font, in: range) { value, piece, _ in
            let font = value as? NSFont ?? fallback
            let newFont = turnOn ? fm.convert(font, toHaveTrait: trait)
                                 : fm.convert(font, toNotHaveTrait: trait)
            storage.addAttribute(.font, value: newFont, range: piece)
        }
        storage.endEditing()
        didChangeText()
    }

    // Underline, strikethrough, highlight: add the effect, or take it off if it's already there.
    private func toggleAttribute(_ key: NSAttributedString.Key, value: Any) {
        let range = selectedRange()

        if range.length == 0 {
            if typingAttributes[key] == nil {
                typingAttributes[key] = value
            } else {
                typingAttributes.removeValue(forKey: key)
            }
            return
        }

        guard let storage = textStorage,
              shouldChangeText(in: range, replacementString: nil) else { return }
        let alreadyOn = storage.attribute(key, at: range.location, effectiveRange: nil) != nil
        if alreadyOn {
            storage.removeAttribute(key, range: range)
        } else {
            storage.addAttribute(key, value: value, range: range)
        }
        didChangeText()
    }

    // PART B: bullet points.
    @objc func toggleBullets(_ sender: Any?) {
        let text = string as NSString
        let lines = text.lineRange(for: selectedRange())

        var lineStarts: [Int] = []
        text.enumerateSubstrings(in: lines, options: [.byLines, .substringNotRequired]) { _, lineRange, _, _ in
            lineStarts.append(lineRange.location)
        }
        if lineStarts.isEmpty { lineStarts = [lines.location] }

        let allBulleted = lineStarts.allSatisfy { start in
            start + 2 <= text.length && text.substring(with: NSRange(location: start, length: 2)) == "• "
        }

        let original = selectedRange()
        var change = 0

        // Go from the last line up, so earlier positions don't shift.
        for start in lineStarts.reversed() {
            if allBulleted {
                insertText("", replacementRange: NSRange(location: start, length: 2))
                change -= 2
            } else if !(start + 2 <= text.length && text.substring(with: NSRange(location: start, length: 2)) == "• ") {
                insertText("• ", replacementRange: NSRange(location: start, length: 0))
                change += 2
            }
        }

        // Put the selection back where it was.
        if original.length == 0 {
            setSelectedRange(NSRange(location: max(lines.location, original.location + change), length: 0))
        } else {
            setSelectedRange(NSRange(location: lines.location, length: max(0, lines.length + change)))
        }
    }

    // PART B2: checklists. A checklist line starts with "☐ " (not done) or "☑ " (done).
    @objc func toggleChecklist(_ sender: Any?) {
        let text = string as NSString
        let lines = text.lineRange(for: selectedRange())

        var lineStarts: [Int] = []
        text.enumerateSubstrings(in: lines, options: [.byLines, .substringNotRequired]) { _, lineRange, _, _ in
            lineStarts.append(lineRange.location)
        }
        if lineStarts.isEmpty { lineStarts = [lines.location] }

        let allChecklist = lineStarts.allSatisfy { isChecklistLine(at: $0) }
        let original = selectedRange()
        var change = 0

        for start in lineStarts.reversed() {
            if allChecklist {
                insertText("", replacementRange: NSRange(location: start, length: 2))
                change -= 2
            } else if !isChecklistLine(at: start) {
                insertText("☐ ", replacementRange: NSRange(location: start, length: 0))
                change += 2
            }
        }
        enlargeBoxes()  // make the ☐ and ☑ bigger than the font size

        if original.length == 0 {
            setSelectedRange(NSRange(location: max(lines.location, original.location + change), length: 0))
        } else {
            setSelectedRange(NSRange(location: lines.location, length: max(0, lines.length + change)))
        }
    }

    // Does the line starting here begin with a box?
    func isChecklistLine(at start: Int) -> Bool {
        let text = string as NSString
        guard start + 2 <= text.length else { return false }
        let firstTwo = text.substring(with: NSRange(location: start, length: 2))
        return firstTwo == "☐ " || firstTwo == "☑ "
    }

    // PART B3: clicking a box checks it off (☑) and crosses out the line.
    override func mouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        let index = characterIndexForInsertion(at: point)
        let text = string as NSString
        let line = text.lineRange(for: NSRange(location: min(index, text.length), length: 0))

        // Only count clicks right on the box at the start of a checklist line.
        if index <= line.location + 1 && isChecklistLine(at: line.location) {
            toggleCheck(lineStart: line.location)
            return
        }
        super.mouseDown(with: event)
    }

    func toggleCheck(lineStart: Int) {
        let text = string as NSString
        let line = text.lineRange(for: NSRange(location: lineStart, length: 0))
        let lineText = text.substring(with: line).trimmingCharacters(in: .newlines) as NSString
        let wasDone = lineText.hasPrefix("☑")
        // The words after "☐ " (skip the box and the space).
        let words = NSRange(location: lineStart + 2, length: max(0, lineText.length - 2))

        guard let storage = textStorage,
              shouldChangeText(in: line, replacementString: nil) else { return }
        storage.beginEditing()
        storage.replaceCharacters(in: NSRange(location: lineStart, length: 1), with: wasDone ? "☐" : "☑")
        if wasDone {
            storage.removeAttribute(.strikethroughStyle, range: words)
        } else {
            storage.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: words)
        }
        storage.endEditing()
        didChangeText()
    }

    // How big the boxes are. The note sets this from its font size.
    var boxSize: CGFloat = 20

    // Makes every ☐ and ☑ in the note use the bigger box size.
    func enlargeBoxes() {
        guard let storage = textStorage else { return }
        let text = string as NSString
        let boxFont = NSFont.systemFont(ofSize: boxSize)
        storage.beginEditing()
        for i in 0..<text.length {
            let c = text.character(at: i)
            if c == 0x2610 || c == 0x2611 {   // the codes for ☐ and ☑
                storage.addAttribute(.font, value: boxFont, range: NSRange(location: i, length: 1))
            }
        }
        storage.endEditing()
    }


    // Pressing Return on a bullet line starts a new bullet.
    // Pressing Return on an empty bullet ends the list.
    override func insertNewline(_ sender: Any?) {
        let text = string as NSString
        let cursor = selectedRange().location
        let line = text.lineRange(for: NSRange(location: cursor, length: 0))
        let lineText = text.substring(with: line).trimmingCharacters(in: .newlines)

        if lineText == "• " || lineText == "☐ " || lineText == "☑ " {
            insertText("", replacementRange: NSRange(location: line.location, length: 2))
            return
        }
        super.insertNewline(sender)
        if lineText.hasPrefix("• ") {
            insertText("• ", replacementRange: selectedRange())
        } else if lineText.hasPrefix("☐ ") || lineText.hasPrefix("☑ ") {
            typingAttributes.removeValue(forKey: .strikethroughStyle) // new items start un-crossed
            insertText("☐ ", replacementRange: selectedRange())
            enlargeBoxes()
        }
    }
}

// PART C: puts RichTextView inside your SwiftUI note, and saves what you type.
struct RichTextEditor: NSViewRepresentable {
    @Binding var note: Note

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeNSView(context: Context) -> NSScrollView {
        // Apple's ready-made "text box inside a scroll area", using our RichTextView.
        let scrollView = RichTextView.scrollableTextView()
        scrollView.drawsBackground = false
        let textView = scrollView.documentView as! RichTextView
        textView.isRichText = true
        textView.allowsUndo = true
        textView.drawsBackground = false
        textView.delegate = context.coordinator

        // Load the saved note. Old notes only have plain text, so use that.
        if let data = note.richText,
           let saved = NSAttributedString(rtf: data, documentAttributes: nil) {
            textView.textStorage?.setAttributedString(saved)
        } else {
            textView.string = note.text
        }
        context.coordinator.applyStyle(to: textView, note: note)
        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        context.coordinator.parent = self
        guard let textView = scrollView.documentView as? RichTextView else { return }
        // Only re-style when the Note Style menu changed something.
        let style = "\(note.fontName)|\(note.fontSize)|\(note.fontColor)|\(note.theme)"
        if style != context.coordinator.lastStyle {
            context.coordinator.applyStyle(to: textView, note: note)
        }
    }

    @MainActor
    final class Coordinator: NSObject, NSTextViewDelegate {
        var parent: RichTextEditor
        var lastStyle = ""

        init(_ parent: RichTextEditor) { self.parent = parent }

        // Every time you type, save both the formatted version and the plain words.
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            let all = textView.attributedString()
            parent.note.richText = all.rtf(from: NSRange(location: 0, length: all.length))
            parent.note.text = all.string
        }

        // Use the note's font, size and color, but keep each word's bold/italic.
        func applyStyle(to textView: NSTextView, note: Note) {
            lastStyle = "\(note.fontName)|\(note.fontSize)|\(note.fontColor)|\(note.theme)"
            let fm = NSFontManager.shared
            let base = NSFont(name: note.fontName, size: note.fontSize)
                ?? NSFont.systemFont(ofSize: note.fontSize)
            let color = NSColor(Notestyle.textColor(for: note))

            func restyled(_ old: NSFont?) -> NSFont {
                var font = base
                if let old {
                    let traits = fm.traits(of: old)
                    if traits.contains(.boldFontMask) { font = fm.convert(font, toHaveTrait: .boldFontMask) }
                    if traits.contains(.italicFontMask) { font = fm.convert(font, toHaveTrait: .italicFontMask) }
                }
                return font
            }

            if let storage = textView.textStorage {
                let all = NSRange(location: 0, length: storage.length)
                storage.beginEditing()
                storage.enumerateAttribute(.font, in: all) { value, piece, _ in
                    storage.addAttribute(.font, value: restyled(value as? NSFont), range: piece)
                }
                storage.addAttribute(.foregroundColor, value: color, range: all)
                storage.endEditing()
            }
            textView.typingAttributes[.font] = restyled(textView.typingAttributes[.font] as? NSFont)
            textView.typingAttributes[.foregroundColor] = color

            if let richView = textView as? RichTextView {
                richView.boxSize = note.fontSize * 1.5
                richView.enlargeBoxes()
            }
        }
    }
}

// PART D: the Format menu. Each item asks the text box you're typing in to do it.
struct FormatCommands: View {
    var body: some View {
        Button("Bold") { send(#selector(RichTextView.toggleBold(_:))) }
            .keyboardShortcut("b")
        Button("Italic") { send(#selector(RichTextView.toggleItalic(_:))) }
            .keyboardShortcut("i")
        Button("Underline") { send(#selector(RichTextView.toggleUnderlineStyle(_:))) }
            .keyboardShortcut("u")
        Button("Strikethrough") { send(#selector(RichTextView.toggleStrikethrough(_:))) }
            .keyboardShortcut("x", modifiers: [.command, .shift])
        Button("Highlight") { send(#selector(RichTextView.toggleHighlight(_:))) }
            .keyboardShortcut("h", modifiers: [.command, .shift])
        Divider()
        Button("Bullet List") { send(#selector(RichTextView.toggleBullets(_:))) }
            .keyboardShortcut("l", modifiers: [.command, .shift])
        Button("Checklist") { send(#selector(RichTextView.toggleChecklist(_:))) }
            .keyboardShortcut("k", modifiers: [.command, .shift])
    }

    func send(_ action: Selector) {
        NSApp.sendAction(action, to: nil, from: nil)
    }
}
