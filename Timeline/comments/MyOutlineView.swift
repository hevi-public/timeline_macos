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

        self.comments = self.comments.map { comment -> Comment in
            var comment2 = comment
            comment2.children.append(Comment(commentId: "", author: "", content: "", createdAt: "", children: [], parentId: comment.commentId))
            return comment2
        }
        self.comments.append(Comment(commentId: "", author: "", content: "", createdAt: "", children: [], parentId: nil))
        
        self.delegate = self
        self.dataSource = self
        
        self.reloadData()
        self.expandItem(nil, expandChildren: true)
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
            switch tableColumn?.identifier {
            case NSUserInterfaceItemIdentifier(rawValue: "ContentColumn"):
                
                    view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ContentColumn"), owner: self) as? NSTableCellView
                    if let textField = view?.textField {
                        let parent = findParent(comment)
                        if comment.content != "" {
                            textField.stringValue = comment.content
                            textField.isEditable = false
                        } else {
                            if let parent = parent {
                                textField.placeholderString = "Reply to: " + parent.content
                            } else {
                                textField.placeholderString = "Reply to ticket"
                            }
                        }
                    }
                
                break
            case NSUserInterfaceItemIdentifier(rawValue: "AuthorColumn"):
                view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "AuthorColumn"), owner: self) as? NSTableCellView
                if let textField = view?.textField {
                    textField.stringValue = comment.author
                }
                break
            case NSUserInterfaceItemIdentifier(rawValue: "DateColumn"):
                view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DateColumn"), owner: self) as? NSTableCellView
                if let textField = view?.textField {
                    textField.stringValue = comment.createdAt
                }
                break
            default:
                print("not implemented")
            }
        } else {
            
        }
        
        return view
    }
    
    private func findParent(_ comment: Comment) -> Comment? {
        return comments.filter { possibleParentComment -> Bool in
            return comment.parentId == possibleParentComment.commentId && comment.parentId != ""
//            return possibleParentComment.children.filter { possibleParentCommentChild -> Bool in
//                return possibleParentCommentChild.commentId == comment.commentId
//            }.count > 0
        }.first
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldEdit tableColumn: NSTableColumn?, item: Any) -> Bool {
        return false
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
        fakefield.font = NSFont(name: "Helvetica", size: 15)
        
        let newHeight = fakefield.cell!.cellSize(forBounds: NSMakeRect(CGFloat(0.0), CGFloat(0.0), outlineView.tableColumns[0].width, CGFloat(Float.greatestFiniteMagnitude))).height
        return newHeight
    }
    
    
   
}
