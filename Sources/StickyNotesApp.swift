import SwiftUI

@main
struct StickyNotesApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var store = NoteStore()

    var body: some Scene {
        WindowGroup(for: UUID.self) { $noteID in
            NoteWindow(noteID: $noteID)
                .environmentObject(store)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 250, height: 250)
        .commands{
            CommandGroup(replacing: .newItem) {
                NewNoteButtons(store: store)
            }
            CommandGroup(after: .pasteboard){
                NoteEditCommands()
            }
            CommandMenu("Format") {
                FormatCommands()
            }
            CommandMenu("Note Style") {
                NoteStyleCommands()
            }
        }
        // window that shows the themes, floating above the note windows. It opens when you click "Theme" in the Note Style menu.
        WindowGroup("Themes", for: ThemeTarget.self) { $target in 
            if let target {
                ThemePickerView(noteID: target.noteID)
                    .environmentObject(store)
            } }
            .windowLevel(.floating)
            .defaultSize(width: 460, height: 420)
    }

}

struct NoteWindow: View {
    @Binding var noteID: UUID?
    @EnvironmentObject var store: NoteStore
    @Environment(\.openWindow) var openWindow

    var body: some View {
        Group {
            if let id = noteID {
                NoteView(noteID: id)
            } else {
                Color.clear
            }
        }
        .onAppear {
            if noteID == nil {
                if !AppDelegate.didRestore && !store.notes.isEmpty {
                    AppDelegate.didRestore = true
                    noteID = store.notes[0].id
                    for note in store.notes.dropFirst() {
                        openWindow(value: note.id)
                    }
                } else {
                    AppDelegate.didRestore = true
                    noteID = store.newNote()
                }
            }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    @MainActor static var didRestore = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }
}

struct NewNoteButtons: View {
    @Environment(\.openWindow) var openWindow
    let store: NoteStore

    var body: some View {
        Button("New Note") {
            openWindow(value: store.newNote())
        }
        .keyboardShortcut("n")
    }
}