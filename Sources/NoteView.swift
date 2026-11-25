import SwiftUI

struct NoteView: View {
    let noteID: UUID
    @EnvironmentObject var store: NoteStore
    @Environment(\.dismiss) var dismiss

    var textBinding: Binding<String> {
        Binding(
            get: { store.notes.first { $0.id == noteID }?.text ?? "" },
            set: { newText in
                if let i = store.notes.firstIndex(where: { $0.id == noteID }) {
                    store.notes[i].text = newText
                }
            }
        )
    }


    var body: some View {
            RichTextEditor(note: noteBinding)
            .font(Notestyle.font(for: note.fontName, size: note.fontSize))
            .foregroundColor(Notestyle.textColor(for: note))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(.top, 35)
            .padding(.horizontal, 20)
            .background(Notestyle.backgroundColor(for: note).opacity(note.opacity))
            .overlay(alignment: .top) {
                titleBar
            }
            .ignoresSafeArea()
            .focusedSceneValue(\.focusedNote, FocusedNote(
                note: noteBinding,
                delete: {
                    dismiss()
                    store.delete(noteID)
                }
            ))
            .background(FloatingWindow())
    }

    // The old-school bar at the top: three square buttons, then a line.
    var titleBar: some View {
        VStack(spacing: 0) {
            HStack(spacing: 6) {
                Button { dismiss() } label: {
                    Image(systemName: "xmark.square")
                }
                Button { NSApp.keyWindow?.miniaturize(nil) } label: {
                    Image(systemName: "minus.square")
                }
                Button { NSApp.keyWindow?.toggleFullScreen(nil) } label: {
                    Image(systemName: "plus.square")
                }
                Spacer()
            }
            .buttonStyle(.borderless)
            .font(.system(size: 14))
            .padding(.horizontal, 8)
            .frame(height: 28)

            Rectangle()
                .frame(height: 1)
        }
        .foregroundColor(Notestyle.textColor(for: note))
    }


    var noteBinding: Binding<Note> {
        Binding(
            get: { store.notes.first { $0.id == noteID } ?? Note() },
            set: { newNote in
                if let i = store.notes.firstIndex(where: { $0.id == noteID }) {
                    store.notes[i] = newNote
                }
            }
        )
    }

    var note: Note{ noteBinding.wrappedValue }

}