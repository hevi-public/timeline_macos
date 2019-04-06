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
    var webView: MyWebView?

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    func initialize(recentTickets: [Ticket], webView: MyWebView) {
        
        self.recentTickets = recentTickets
        self.webView = webView
        
        self.delegate = self
        self.dataSource = self
        
        self.reloadData()
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
            cell.priorityText?.attributedStringValue = DisplayString.getPriorityDisplayString(comment.priority)
            cell.sizeText?.attributedStringValue = DisplayString.getSizeDisplayString(comment.size ?? "")
            cell.typeText?.attributedStringValue = DisplayString.getTypeDisplayString(comment.type)
            cell.titleText?.stringValue = comment.title
            
            return cell
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 100
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let tableView = notification.object as! RecentTicketsTableView
        let selectedRow = tableView.selectedRow
        if let ticket = recentTickets?[selectedRow] {
            webView?.selectTicket(ticket: ticket)
        }
        
        
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
