//
//  RecentTicketCellView.swift
//  Timeline
//
//  Created by Hevi on 06/04/2019.
//  Copyright © 2019 Hevi. All rights reserved.
//

import Cocoa

class RecentTicketCellView: NSTableCellView {

    @IBOutlet weak var ticketNumberText: NSTextField!
    @IBOutlet weak var priorityText: NSTextField!
    @IBOutlet weak var sizeText: NSTextField!
    @IBOutlet weak var typeText: NSTextField!
    @IBOutlet weak var titleText: NSTextField!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
