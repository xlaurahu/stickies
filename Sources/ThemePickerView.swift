import SwiftUI
import ColorTokensKit

// Which note the Themes window is changing.
struct ThemeTarget: Codable, Hashable {
    let noteID: UUID
}

// The Themes window: a grid with one tile for every theme.
struct ThemePickerView: View {
    let noteID: UUID
    @EnvironmentObject var store: NoteStore

    // As many columns as fit, each at least 100 points wide.
    let columns = [GridItem(.adaptive(minimum: 100), spacing: 12)]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(Notestyle.themeNames, id: \.self) { name in
                    Button {
                        pick(name)
                    } label: {
                        ThemeTile(name: name, isPicked: name == currentTheme)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .frame(minWidth: 360, minHeight: 300)
    }

    // The theme this note has right now.
    var currentTheme: String {
        store.notes.first { $0.id == noteID }?.theme ?? "None"
    }

    // Save the theme on the note. The note window updates by itself.
    func pick(_ name: String) {
        if let i = store.notes.firstIndex(where: { $0.id == noteID }) {
            store.notes[i].theme = name
        }
    }
}

// One tile: a mini sticky note in that theme's colors.
struct ThemeTile: View {
    let name: String
    let isPicked: Bool

    var body: some View {
        let theme = Notestyle.theme(for: name)
        VStack(alignment: .leading, spacing: 4) {
            Text("Aa")
                .font(.title2.bold())
            Text(name == "None" ? "No theme" : name)
                .font(.caption)
        }
        // Same shades the note uses: _900 for words, _200 for paper.
        .foregroundStyle(theme?._900.toColor() ?? Color.black)
        .padding(10)
        .frame(maxWidth: .infinity, minHeight: 70, alignment: .topLeading)
        .background(theme?._200.toColor() ?? Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isPicked ? Color.accentColor : Color.gray.opacity(0.3),
                        lineWidth: isPicked ? 3 : 1)
        )
    }
}