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
    @IBOutlet weak var ticketNumberLabel: NSTextFieldCell!
    @IBOutlet weak var descriptionView: NSClipView!
    @IBOutlet var descriptionTextView: NSTextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webView.initialize(ticketNameLabel: ticketNumberLabel, descriptionTextView: descriptionTextView)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

