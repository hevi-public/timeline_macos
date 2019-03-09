//
//  MyWebView.swift
//  Timeline
//
//  Created by Hevi on 08/03/2019.
//  Copyright © 2019 Hevi. All rights reserved.
//

import Cocoa
import WebKit

class MyWebView: WKWebView, WKScriptMessageHandler {
    
    

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }

    public func initialize() {
        let userContentController = self.configuration.userContentController as WKUserContentController
        userContentController.add(self, name: "webviewreadyHandler")
        
        let urlpath = Bundle.main.path(forResource: "static/index", ofType: "html")
        if let urlpath = urlpath, let requesturl = URL(string: "file://" + urlpath) {
            self.loadFileURL(requesturl, allowingReadAccessTo: requesturl)
        } else {
            print("Problem while loading index.html")
        }
    }
    
    func userContentController(_ userContentConvarller: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "webviewreadyHandler":
            self.initGraph()
            break
        case "linkNodesHandler":
            let body = message.body as! [String : String]
            break
        default:
            break
        }
    }
    
    public func initGraph() {
        do {
//            let jsonGraph = try JSONSerialization.data(withJSONObject: graph, options: .prettyPrinted)
//            let jsonGraphString = String(data: jsonGraph, encoding: .utf8) ?? ""
//
            let script = NSString(format: "init();")
            self.evaluateJavaScript(script as String, completionHandler: { (result, error) in
                if error != nil {
                    print("error: " + (error! as NSError).debugDescription)
                }
            })
        } catch {
            print("Problem")
        }
    }
}
