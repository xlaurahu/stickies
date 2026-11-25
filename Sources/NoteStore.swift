import Foundation

class NoteStore: ObservableObject {
    @Published var notes: [Note] = [] {
        didSet { save() }
    }

    private let fileURL: URL = {
        let folder = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("StickyNotes")
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder.appendingPathComponent("notes.json")
    }()

    init() {
        if let data = try? Data(contentsOf: fileURL),
           let saved = try? JSONDecoder().decode([Note].self, from: data) {
            notes = saved
        }

        for i in notes.indices where !notes[i].items.isEmpty {
            let lines = notes[i].items.map { ($0.done ? "☑ " : "☐ ") + $0.text }
            let checklist = lines.joined(separator: "\n")
            notes[i].text = notes[i].text.isEmpty ? checklist : notes[i].text + "\n" + checklist
            notes[i].richText = nil
            notes[i].items = []
            notes[i].isChecklist = false
        }

        notes.removeAll { $0.text.isEmpty && $0.items.isEmpty }

        save()
    }


    func save() {
        if let data = try? JSONEncoder().encode(notes) {
            try? data.write(to: fileURL)
        }
    }

    func newNote(isChecklist: Bool = false) -> UUID {
        let note = Note(isChecklist: isChecklist)
        notes.append(note)
        return note.id
    }

    func delete(_ id: UUID) {
        notes.removeAll { $0.id == id }
    }
}