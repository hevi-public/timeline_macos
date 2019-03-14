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
            
            let urlString = "http://localhost:8080/ticket"
            guard let url = URL(string: urlString) else { return }
            
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error!.localizedDescription)
                }
                
                guard let data = data else { return }
                do {
                    let articlesData = try JSONDecoder().decode([Ticket].self, from: data)
                    DispatchQueue.main.async {
                        timelineData.append(contentsOf: articlesData)
                        self.initGraph(timelineItems: articlesData)
                    }
                } catch let jsonError {
                    print(jsonError)
                }
            }.resume()
            break
        case "selectHandler":
            let body = message.body as! [String : Any]
            
            if let id = body["id"] as? Int,
                let ticketNumber = body["ticketNumber"] as? String,
                let description = body["description"] as? String,
                let start = body["start"] as? String,
                let end = body["end"] as? String
            {
                
                _ = Ticket(id: id, ticketNumber: ticketNumber, description: description, start: start, end: end)
                ticketNumberLabel?.stringValue = ticketNumber
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
    var ticketNumber: String { get set }
    var description: String { get set }
    var start: String { get set }
    var end: String { get set }
    
    func asDict() -> [String : Any]
}

struct Ticket: TimelineItem, Decodable {
    
    typealias StringToAnyDict = [String : Any]
    
    var id: Int
    var ticketNumber: String
    var description: String
    var start: String
    var end: String
    
    public func asDict() -> [String : Any] {
        return ["id": self.id,
                "content": self.ticketNumber,
                "ticketNumber": self.ticketNumber,
                "description": self.description,
                "start": self.start,
                "end": self.end] as [String : Any]
    }
}
