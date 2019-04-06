//
//  RecentUpdatesCellView.swift
//  Timeline
//
//  Created by Hevi on 06/04/2019.
//  Copyright © 2019 Hevi. All rights reserved.
//

import Cocoa

class RecentUpdatesCellView: NSTableCellView {

    @IBOutlet weak var eventLabel: NSTextField!
    @IBOutlet weak var ticketNumberLabel: NSTextField!
    @IBOutlet weak var descriptionLabel: NSTextField!
    @IBOutlet weak var dateLabel: NSTextField!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
