import SwiftUI
import ColorTokensKit

enum Notestyle {
    static let colorNames = ["White", "Pink", "Blue", "Yellow", "Purple", "Orange"]
    static let fontNames = ["System", "Helvetica Neue", "Arial", "Marker Felt", "Courier New", "Georgia", "Times New Roman"]
    static let fontSizes: [CGFloat] = [10, 12, 14, 16, 18, 20, 24, 28, 32]
    static let fontcolors = ["Black", "White", "Red", "Green", "Blue", "Yellow", "Purple", "Orange"]
    static func color(for name: String) -> Color {
        switch name {
        case "White": return Color.white
        case "Pink": return Color.pink
        case "Blue": return Color.blue
        case "Yellow": return Color.yellow
        case "Purple": return Color.purple
        case "Orange": return Color.orange
        default: return Color.white
        }
    }


    static func fontSize(for size: CGFloat) -> Font {
        return Font.system(size: size)
    }

    static func font(for name: String, size: CGFloat) -> Font {
        switch name {
        case "System": return Font.system(size: size)
        case "Helvetica Neue": return Font.custom("Helvetica Neue", size: size)
        case "Arial": return Font.custom("Arial", size: size)
        case "Marker Felt": return Font.custom("Marker Felt", size: size)
        case "Courier New": return Font.custom("Courier New", size: size)
        case "Georgia": return Font.custom("Georgia", size: size)
        case "Times New Roman": return Font.custom("Times New Roman", size: size)
        default: return Font.system(size: size)
        }
    }

    static func fontColor(for name: String) -> Color {
        switch name {
        case "Black": return Color.black
        case "White": return Color.white
        case "Red": return Color.red
        case "Green": return Color.green
        case "Blue": return Color.blue
        case "Yellow": return Color.yellow
        case "Purple": return Color.purple
        case "Orange": return Color.orange
        default: return Color.black
        }
    }

    // MARK: Themes (from ColorTokensKit)
    // "None" first, then the 37 themes in rainbow order.
    static let themeNames: [String] = ["None"] + Color.allProHues
        .sorted { $0.value.h < $1.value.h }
        .map { $0.key }

    // Find a theme by its name. "None" gives back nil (no theme).
    static func theme(for name: String) -> ProTheme? {
        Color.allProHues[name]
    }

    // The note's paper color: the theme's light shade, or your own Color.
    static func backgroundColor(for note: Note) -> Color {
        if let theme = theme(for: note.theme) {
            return theme._200.toColor()
        }
        return color(for: note.colorName)
    }

    // The note's words: the theme's dark shade, or your own Font Color.
    static func textColor(for note: Note) -> Color {
        if let theme = theme(for: note.theme) {
            return theme._900.toColor()
        }
        return fontColor(for: note.fontColor)
    }

}