//
//  RecentUpdatesTableView.swift
//  Timeline
//
//  Created by Hevi on 06/04/2019.
//  Copyright © 2019 Hevi. All rights reserved.
//

import Cocoa

class RecentUpdatesTableView: NSTableView {
    
    var recentUpdates: [Update]?

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }

    func initialize(recentUpdates: [Update]) {
        
        self.recentUpdates = recentUpdates
        
        self.delegate = self
        self.dataSource = self
        
        self.reloadData()
    }
    
}

extension RecentUpdatesTableView: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let update = recentUpdates?[row] else {
            return nil
        }
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "recentUpdateCell"), owner: nil) as? RecentUpdatesCellView {
            
            cell.eventLabel?.stringValue = update.event
            cell.ticketNumberLabel?.stringValue = update.ticketNumber
            cell.descriptionLabel?.stringValue = update.description
            cell.dateLabel?.stringValue = update.date
            
            return cell
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 70
        
    }
    
//    func tableViewSelectionDidChange(_ notification: Notification) {
//        let tableView = notification.object as! RecentTicketsTableView
//        let selectedRow = tableView.selectedRow
//        if let update = recentUpdates?[selectedRow] {
//            webView?.selectTicket(ticket: ticket)
//        }
//
//
//    }
}

extension RecentUpdatesTableView: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return recentUpdates?.count ?? 0
    }
}


struct Update: Codable {
    
    var event: String
    var ticketNumber: String
    var description: String
    var date: String
    
    private enum CodingKeys : String, CodingKey {
        case event = "event"
        case ticketNumber = "ticketNumber"
        case description = "description"
        case date = "date"
    }
    
    public func asDict() -> [String : Any] {
        
        return ["event": self.event,
                "ticketNumber": self.ticketNumber,
                "description": self.description,
                "date": self.date] as [String : Any]
    }
}
