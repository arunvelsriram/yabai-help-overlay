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

@discardableResult func shell(_ command: String) -> (String?, Int32) {
    print("Command:", command)
    let task = Process()

    task.launchPath = "/bin/bash"
    task.arguments = ["-c", command]

    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe
    task.launch()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)
    task.waitUntilExit()
    return (output, task.terminationStatus)
}

func loadHelpData() -> [Group] {
    struct HelpDataItem: Decodable {
        let group: String
        let description: String
        let keyCombination: String
    }
    
    guard let awkScript = Bundle.main.path(forResource: "extract-help-data", ofType: "awk") else { return [] }
    print("Using awk script:", awkScript)

    let homeDir = FileManager.default.homeDirectoryForCurrentUser.path
    let skhdConfig: String = "\(homeDir)/.skhdrc"
    if (!FileManager.default.fileExists(atPath: skhdConfig)) {
        print("skhd config \(skhdConfig) not found")
        return []
    }
    print("Using skhd config:", skhdConfig)

    let (output, awkExitStatus) = shell("awk -f '\(awkScript)' '\(skhdConfig)'")
    print("awk exit status:", awkExitStatus)
    if awkExitStatus > 0 { return [] }
    guard let awkOutput = output else { print("awk output is nil"); return [] }
    print("awk output:", awkOutput)

    guard let jsonData = awkOutput.data(using: .utf8) else { return [] }
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
