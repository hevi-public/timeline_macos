//
//  MyOutlineView.swift
//  Timeline
//
//  Created by Hevi on 26/03/2019.
//  Copyright © 2019 Hevi. All rights reserved.
//

import Cocoa

class MyOutlineView: NSOutlineView {
    
    var comments: [Comment] = []
    
    func initialize(comments: [Comment]) {
        self.comments = comments
        
        self.delegate = self
        self.dataSource = self
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}

extension MyOutlineView: NSOutlineViewDelegate {
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        var view: NSTableCellView?
        if let comment = item as? Comment {
            view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ContentCell"), owner: self) as? NSTableCellView
            if let textField = view?.textField {
                textField.stringValue = comment.content
                //textField.sizeToFit()
            }
        }
        return view
    }
}

extension MyOutlineView: NSOutlineViewDataSource {
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let comments = item as? Comment {
            return comments.children.count
        }
        return comments.count
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let comment = item as? Comment {
            return comment.children.count > 0
        }
        return false
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let comment = item as? Comment {
            return comment.children[index]
        }
        
        return comments[index]
    }
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        let comment = item as! Comment

        let fakefield = NSTextField()
        fakefield.stringValue = comment.content
        fakefield.font = NSFont(name: "Helvetica", size: 13)
        
        let newHeight = fakefield.cell!.cellSize(forBounds: NSMakeRect(CGFloat(0.0), CGFloat(0.0), outlineView.tableColumns[0].width, CGFloat(Float.greatestFiniteMagnitude))).height
        return newHeight
    }
}
