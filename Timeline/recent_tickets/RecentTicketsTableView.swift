//
//  RecentTicketsTableView.swift
//  Timeline
//
//  Created by Hevi on 06/04/2019.
//  Copyright © 2019 Hevi. All rights reserved.
//

import Cocoa

class RecentTicketsTableView: NSTableView {
    
    var recentTickets: [Ticket]?

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    func initialize(recentTickets: [Ticket]) {
        
        self.recentTickets = recentTickets
        
        self.delegate = self
        self.dataSource = self
    }
    
}

extension RecentTicketsTableView: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .long
        
        guard let comment = recentTickets?[row] else {
            return nil
        }

        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ticketNumber"), owner: nil) as? RecentTicketCellView {
            
            cell.ticketNumberText?.stringValue = comment.ticketNumber
            cell.priorityText?.stringValue = comment.priority
            cell.sizeText?.stringValue = comment.size ?? ""
            cell.typeText?.stringValue = comment.type
            cell.titleText?.stringValue = comment.title
            
            return cell
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 100
    }
}

extension RecentTicketsTableView: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return recentTickets?.count ?? 0
    }
//
//    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
//
//    }
}
