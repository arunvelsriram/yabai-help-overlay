import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var outlineView: NSOutlineView!
    
    let groups: [Group] = loadHelpData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        outlineView.dataSource = self
        outlineView.delegate = self
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }

}

extension ViewController: NSOutlineViewDataSource {
        
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            return groups.count
        } else {
            if let group = item as? Group {
                return group.shortcutCount
            } else {
                return 1
            }
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            return groups[index]
        } else {
            if let group = item as? Group {
                return group.shortcuts[index]
            } else {
                return item!
            }
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        guard let _ = item as? Group else { return false }
        return true
    }
    
}

extension ViewController: NSOutlineViewDelegate {
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let colIdentifier = tableColumn?.identifier else { return nil }
        
        if colIdentifier == NSUserInterfaceItemIdentifier("DescriptionColID") {
            let cellIdentifier = NSUserInterfaceItemIdentifier("DescriptionCellID")
            guard let cell = outlineView.makeView(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView else { return nil }
            if let group = item as? Group {
                cell.textField?.stringValue = group.name
            } else if let shortcut = item as? Shortcut {
                cell.textField?.stringValue = shortcut.description
            }
            
            return cell
            
        } else if colIdentifier == NSUserInterfaceItemIdentifier("KeyCombinationColID") {
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "KeyCombinationCellID")
            guard let cell = outlineView.makeView(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView else { return nil }
            
            if let shortcut = item as? Shortcut {
                cell.textField?.stringValue = shortcut.keyCombination
            }
            
            return cell
            
        }
        
        return nil
        
    }
    
}
