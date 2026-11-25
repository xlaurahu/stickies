import SwiftUI

struct ChecklistView: View {
    let noteID: UUID
    @EnvironmentObject var store: NoteStore
    @State private var newItemText = ""

    var noteIndex: Int? { store.notes.firstIndex { $0.id == noteID } }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 6) {
                if let n = noteIndex {
                    ForEach(store.notes[n].items) { item in
                        HStack {
                            Button { toggleDone(item.id) } label: {
                                Image(systemName: item.done ? "checkmark.square" : "square")
                            }
                            .buttonStyle(.borderless)
                            TextField("Item", text: textBinding(for: item.id))
                                .textFieldStyle(.plain)
                                .strikethrough(item.done)
                                .onChange(of: item.text) { oldText, newText in
                                    if newText.isEmpty && !oldText.isEmpty {
                                        let id = item.id
                                        NSApp.keyWindow?.makeFirstResponder(nil)
                                        DispatchQueue.main.async {
                                            guard let n = noteIndex else { return }
                                            store.notes[n].items.removeAll { $0.id == id }
                                        }
                                    }
                                }
                        }
                    }
                }

                HStack {
                    Image(systemName: "plus.square").foregroundStyle(.secondary)
                    TextField("Add item", text: $newItemText)
                        .textFieldStyle(.plain)
                        .onSubmit(addItem)
                }
            }
        }
    }

    // Finds the item by its id every time, instead of remembering its position.
    // If the item was just deleted, this quietly returns "" instead of crashing.
    func textBinding(for id: UUID) -> Binding<String> {
        Binding(
            get: {
                guard let n = noteIndex,
                      let i = store.notes[n].items.firstIndex(where: { $0.id == id })
                else { return "" }
                return store.notes[n].items[i].text
            },
            set: { newValue in
                guard let n = noteIndex,
                      let i = store.notes[n].items.firstIndex(where: { $0.id == id })
                else { return }
                store.notes[n].items[i].text = newValue
            }
        )
    }

    func toggleDone(_ id: UUID) {
        guard let n = noteIndex,
              let i = store.notes[n].items.firstIndex(where: { $0.id == id })
        else { return }
        store.notes[n].items[i].done.toggle()
    }

    func addItem() {
        guard let n = noteIndex, !newItemText.isEmpty else { return }
        store.notes[n].items.append(ChecklistItem(text: newItemText))
        newItemText = ""
    }
}

