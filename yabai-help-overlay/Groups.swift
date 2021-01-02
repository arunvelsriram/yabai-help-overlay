import Cocoa

public class Shortcut {
    let description: String
    let keyCombination: String
    
    init(description: String, keyCombination: String) {
        self.description = description
        self.keyCombination = keyCombination
    }
}

public class Group {
    let name: String
    var shortcuts: [Shortcut]
    var shortcutCount: Int { get { return shortcuts.count }}
    
    init(name: String, shortcuts: [Shortcut]) {
        self.name = name
        self.shortcuts = shortcuts
    }
}

func loadHelpData() -> [Group] {
    struct HelpDataItem: Decodable {
        let group: String
        let description: String
        let keyCombination: String
    }
    
    let jsonData = """
        [
          {
            "group": "Launch",
            "description": "Terminal",
            "keyCombination": "hyper + return"
          },
          {
            "group": "Launch",
            "description": "Browser",
            "keyCombination": "hyper + b"
          },
          {
            "group": "Launch",
            "description": "Browser",
            "keyCombination": "hyper + b"
          },
          {
            "group": "Launch",
            "description": "Browser",
            "keyCombination": "hyper + b"
          },
          {
            "group": "Focus",
            "description": "Browser",
            "keyCombination": "hyper + b"
          },
          {
            "group": "Focus",
            "description": "Browser",
            "keyCombination": "hyper + b"
          }
        ]
    """.data(using: .utf8)!
    let helpDataItems = try! JSONDecoder().decode([HelpDataItem].self, from: jsonData)
    
    var groups: [Group] = []
    for helpDataItem: HelpDataItem in helpDataItems {
        let shortcut:  Shortcut = Shortcut(
            description: helpDataItem.description,
            keyCombination: helpDataItem.keyCombination
        )
        if let i = groups.firstIndex(where: { $0.name == helpDataItem.group }) {
            groups[i].shortcuts.append(shortcut)
        } else {
            let group: Group = Group(
                name: helpDataItem.group,
                shortcuts: [shortcut]
            )
            groups.append(group)
        }
    }
    
    return groups
    
}
