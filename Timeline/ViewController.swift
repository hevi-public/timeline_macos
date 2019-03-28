//
//  ViewController.swift
//  Timeline
//
//  Created by Hevi on 08/03/2019.
//  Copyright © 2019 Hevi. All rights reserved.
//

import Cocoa
import WebKit

class ViewController: NSViewController {
    
    @IBOutlet weak var webView: MyWebView!
    @IBOutlet weak var outlineView: MyOutlineView!
    
    @IBOutlet weak var ticketNumberLabel: NSTextFieldCell!
    @IBOutlet weak var descriptionView: NSClipView!
    @IBOutlet var descriptionTextView: NSTextView!
    @IBOutlet weak var typeLabel: NSTextField!
    @IBOutlet weak var priorityLabel: NSTextField!
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var assigneeLabel: NSTextField!
    @IBOutlet weak var reporterLabel: NSTextField!
    @IBOutlet weak var sizeLabel: NSTextField!
    
    @IBOutlet weak var overView: NSView!
    @IBOutlet weak var selectView: NSView!
    
    @IBOutlet weak var recentTicketsView: NSStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.initialize(ticketNameLabel: self.ticketNumberLabel,
                           typeLabel: self.typeLabel,
                           priorityLabel: self.priorityLabel,
                           statusLabel: self.statusLabel,
                           assigneeLabel: self.assigneeLabel,
                           reporterLabel: self.reporterLabel,
                           sizeLabel: self.sizeLabel,
                           descriptionTextView: self.descriptionTextView,
                           overView: self.overView,
                           selectView: self.selectView,
                           recentTicketsView: self.recentTicketsView,
                           outlineView: self.outlineView)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

