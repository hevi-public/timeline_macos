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
            
            var timelineData = [TimelineItem]()
            timelineData.append(ExampleDataItem(id: 1, content: "TICKET-431", start: "2019-02-20", end: "2019-02-25"))
            timelineData.append(ExampleDataItem(id: 2, content: "TICKET-422", start: "2019-02-14", end: "2019-02-18"))
            timelineData.append(ExampleDataItem(id: 3, content: "TICKET-434", start: "2019-02-15", end: "2019-02-23"))
            timelineData.append(ExampleDataItem(id: 4, content: "TICKET-426", start: "2019-02-22", end: "2019-02-28"))
            timelineData.append(ExampleDataItem(id: 5, content: "TICKET-415", start: "2019-02-12", end: "2019-02-14"))
            timelineData.append(ExampleDataItem(id: 6, content: "TICKET-457", start: "2019-02-17", end: "2019-02-20"))
            
          
            self.initGraph(timelineItems: timelineData)
            break
        case "linkNodesHandler":
            let body = message.body as! [String : String]
            break
        default:
            break
        }
    }
    
    public func initGraph(timelineItems: [TimelineItem]) {
        
        let items = timelineItems.map { timelineItem -> [String:Any] in
            return timelineItem.asDict()
        }
        
        do {
            let jsonGraph = try JSONSerialization.data(withJSONObject: items, options: .prettyPrinted)
            let jsonGraphString = String(data: jsonGraph, encoding: .utf8) ?? ""

            let script = NSString(format: "init(%@);", jsonGraphString)
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

protocol TimelineItem {
    var id: Int { get set }
    var content: String { get set }
    var start: String { get set }
    var end: String { get set }
    
    func asDict() -> [String : Any]
}

struct ExampleDataItem: TimelineItem {
    
    typealias StringToAnyDict = [String : Any]
    
    var id: Int
    var content: String
    var start: String
    var end: String
    
    public func asDict() -> [String : Any] {
        return ["id": self.id,
                "content": self.content,
                "start": self.start,
                "end": self.end] as [String : Any]
    }
}
