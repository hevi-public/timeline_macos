//
//  TableView.swift
//  Timeline
//
//  Created by Hevi on 06/04/2019.
//  Copyright © 2019 Hevi. All rights reserved.
//

import Cocoa

class TodoTableView: NSTableView {
    
    var todos: [Todo]?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.delegate = self
        self.dataSource = self
    }
    
    func initialize(todos: [Todo]) {
        self.todos = todos
        self.reloadData()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}

extension TodoTableView: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let todo = todos?[row] else {
            return nil
        }
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "todoTableCell"), owner: nil) as? TodoTableCellView {
            
            cell.checkBox?.state = todo.done ? NSButton.StateValue.on : NSButton.StateValue.off
            cell.label?.stringValue = todo.content
            
            return cell
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 80
    }
}

extension TodoTableView: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return todos?.count ?? 0
    }
}

struct Todo: Codable {
    
    var content: String
    var done: Bool
    
    private enum CodingKeys : String, CodingKey {
        case content = "content"
        case done = "done"
    }
    
    public func asDict() -> [String : Any] {
        
        return ["content": self.content,
                "done": self.done] as [String : Any]
    }
}
