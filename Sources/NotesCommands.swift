import SwiftUI

// What the front note can do. The note fills this in, and the menu uses it.
struct FocusedNote {
    let note: Binding<Note>
    let delete: () -> Void
}

struct FocusedNoteKey: FocusedValueKey {
    typealias Value = FocusedNote
}

extension FocusedValues {
    var focusedNote: FocusedNote? {
        get { self[FocusedNoteKey.self] }
        set { self[FocusedNoteKey.self] = newValue }
    }
}

// The extra items that go in the Edit menu.
struct NoteEditCommands: View {
    @FocusedValue(\.focusedNote) var focusedNote

    var body: some View {
        Divider()
        
        Button("Delete Note") {
            focusedNote?.delete()
        }
        .disabled(focusedNote == nil)
    }
}

// The "Note Style" menu in the menu bar.
struct NoteStyleCommands: View {
    @FocusedValue(\.focusedNote) var focusedNote

    @Environment(\.openWindow) var openWindow

    var body: some View {
        if let note = focusedNote?.note {
            Picker("Color", selection: note.colorName) {
                ForEach(Notestyle.colorNames, id: \.self) { name in
                    Text(name)
                }
            }
            Picker("Font", selection: note.fontName) {
                ForEach(Notestyle.fontNames, id: \.self) { name in
                    Text(name)
                }
            }
            Picker("Font Size", selection: note.fontSize) {
                ForEach(Notestyle.fontSizes, id: \.self) { size in
                    Text("\(Int(size))")
                }
            }
            Picker("Font Color", selection: note.fontColor) {
                ForEach(Notestyle.fontcolors, id: \.self) { name in
                    Text(name)
                }
            }
            Button("Theme") {
                openWindow(value: ThemeTarget(noteID: note.wrappedValue.id  ))
            }
            Divider()
            Toggle("Translucent", isOn: Binding(
                get: { note.wrappedValue.opacity < 1 },
                set: { isOn in note.wrappedValue.opacity = isOn ? 0.35 : 1.0 }
            ))
        } else {
            Text("Click a note first")
        }
    }
}