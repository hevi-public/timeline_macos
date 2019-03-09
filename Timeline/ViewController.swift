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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webView.initialize()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

