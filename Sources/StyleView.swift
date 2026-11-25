import SwiftUI

struct StyleView: View {
    @Binding var note: Note

    var body: some View{
        Form {
            Picker("Color", selection: $note.colorName) {
                ForEach(Notestyle.colorNames, id: \.self) { colorName in
                    Text(colorName)
                }
            }
            Slider(value: $note.opacity, in: 0...1, step: 0.01) {
                Text("Opacity")
            }
            Picker("Font", selection: $note.fontName) {
                ForEach(Notestyle.fontNames, id: \.self) { fontName in
                    Text(fontName)  
                }
            }
            Picker("Font Size", selection: $note.fontSize) {
                ForEach(Notestyle.fontSizes, id: \.self) { fontSize in
                    Text("\(Int(fontSize))")
                }
            }
            Picker("Font Color", selection: $note.fontColor) {
                ForEach(Notestyle.fontcolors, id: \.self) { fontColor in
                    Text(fontColor.description.capitalized)     
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}