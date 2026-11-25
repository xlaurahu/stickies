import Foundation

struct ChecklistItem: Codable, Identifiable {
    var id = UUID()
    var text = ""
    var done = false
}

struct Note: Codable, Identifiable {
    var id = UUID()
    var text = ""
    var richText: Data? = nil
    var isChecklist = false
    var items: [ChecklistItem] = []
    var colorName = "White"
    var opacity = 1.0
    var fontName = "Arial"
    var fontSize: CGFloat = 14.0
    var fontColor: String = "Black"
    var theme = "Rose"

    init(isChecklist: Bool = false) {
        self.isChecklist = isChecklist
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        text = try c.decodeIfPresent(String.self, forKey: .text) ?? ""
        richText = try c.decodeIfPresent(Data.self, forKey: .richText)
        isChecklist = try c.decodeIfPresent(Bool.self, forKey: .isChecklist) ?? false
        items = try c.decodeIfPresent([ChecklistItem].self, forKey: .items) ?? []
        colorName = try c.decodeIfPresent(String.self, forKey: .colorName) ?? "White"
        opacity = try c.decodeIfPresent(Double.self, forKey: .opacity) ?? 0.35
        fontName = try c.decodeIfPresent(String.self, forKey:.fontName) ?? "System"
        fontSize = try c.decodeIfPresent(CGFloat.self, forKey: .fontSize) ?? 14.0
        fontColor = try c.decodeIfPresent(String.self, forKey: .fontColor) ?? "Black"
        theme = try c.decodeIfPresent(String.self, forKey: .theme) ?? "None"
    }
}
