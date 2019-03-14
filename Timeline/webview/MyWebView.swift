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
    
    var ticketNumberLabel: NSTextFieldCell?
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }

    public func initialize(ticketNameLabel: NSTextFieldCell) {
        let userContentController = self.configuration.userContentController as WKUserContentController
        userContentController.add(self, name: "webviewreadyHandler")
        userContentController.add(self, name: "selectHandler")
        
        let urlpath = Bundle.main.path(forResource: "static/index", ofType: "html")
        if let urlpath = urlpath, let requesturl = URL(string: "file://" + urlpath) {
            self.loadFileURL(requesturl, allowingReadAccessTo: requesturl)
        } else {
            print("Problem while loading index.html")
        }
        
        self.ticketNumberLabel = ticketNameLabel
    }
    
    func userContentController(_ userContentConvarller: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "webviewreadyHandler":
            
            var timelineData = [TimelineItem]()
            timelineData.append(Ticket(id: 1, content: "TICKET-431", ticketNumber: "TICKET-431", description: "", start: "2019-02-20", end: "2019-02-25"))
            timelineData.append(Ticket(id: 2, content: "TICKET-422", ticketNumber: "TICKET-422", description: "", start: "2019-02-14", end: "2019-02-18"))
            timelineData.append(Ticket(id: 3, content: "TICKET-434", ticketNumber: "TICKET-434", description: "", start: "2019-02-15", end: "2019-02-23"))
            timelineData.append(Ticket(id: 4, content: "TICKET-426", ticketNumber: "TICKET-426", description: "", start: "2019-02-22", end: "2019-02-28"))
            timelineData.append(Ticket(id: 5, content: "TICKET-415", ticketNumber: "TICKET-415", description: "", start: "2019-02-12", end: "2019-02-14"))
            timelineData.append(Ticket(id: 6, content: "TICKET-457", ticketNumber: "TICKET-457", description: "", start: "2019-02-17", end: "2019-02-20"))
            
          
            self.initGraph(timelineItems: timelineData)
            break
        case "selectHandler":
            //let msgbody = message.body as! String
            let body = message.body as! [String : Any]
            
            if let id = body["id"] as? Int,
                let content = body["content"] as? String,
                let ticketNumber = body["ticketNumber"] as? String,
                let description = body["description"] as? String,
                let start = body["start"] as? String,
                let end = body["end"] as? String
            {
                
                let ticket = Ticket(id: id, content: content, ticketNumber: ticketNumber, description: description, start: start, end: end)
                ticketNumberLabel?.stringValue = ticketNumber
                //print(ticket)
            }
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
    var ticketNumber: String { get set }
    var description: String { get set }
    var start: String { get set }
    var end: String { get set }
    
    func asDict() -> [String : Any]
}

struct Ticket: TimelineItem {
    
    typealias StringToAnyDict = [String : Any]
    
    var id: Int
    var content: String
    var ticketNumber: String
    var description: String
    var start: String
    var end: String
    
    public func asDict() -> [String : Any] {
        return ["id": self.id,
                "content": self.content,
                "ticketNumber": self.ticketNumber,
                "description": self.description,
                "start": self.start,
                "end": self.end] as [String : Any]
    }
}
