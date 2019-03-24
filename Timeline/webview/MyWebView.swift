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
    var descriptionTextView: NSTextView?
    var typeLabel: NSTextField?
    var priorityLabel: NSTextField?
    var statusLabel: NSTextField?
    var assigneeLabel: NSTextField?
    var reporterLabel: NSTextField?
    var sizeLabel: NSTextField?
    
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }

    public func initialize(ticketNameLabel: NSTextFieldCell,
                           typeLabel: NSTextField,
                           priorityLabel: NSTextField,
                           statusLabel: NSTextField,
                           assigneeLabel: NSTextField,
                           reporterLabel: NSTextField,
                           sizeLabel: NSTextField,
                           descriptionTextView: NSTextView) {
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
        self.typeLabel = typeLabel
        self.priorityLabel = priorityLabel
        self.statusLabel = statusLabel
        self.assigneeLabel = assigneeLabel
        self.reporterLabel = reporterLabel
        self.sizeLabel = sizeLabel
        
        self.descriptionTextView = descriptionTextView
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
            if let body = message.body as? [String : Any] {
                
                if let id = body["id"] as? Int,
                    let ticketNumber = body["ticketNumber"] as? String,
                    let description = body["description"] as? String,
                    let title = body["ticketTitle"] as? String,
                    let type = body["ticketType"] as? String,
                    let priority = body["priority"] as? String,
                    let status = body["status"] as? String,
                    let assignee = body["assignee"] as? String,
                    let reporter = body["reporter"] as? String,
                    let comments = body["comments"] as? [String],
                    let attachments = body["attachments"] as? [String],
                    //let size = body["size"] as? String,
                    let start = body["start"] as? String,
                    let end = body["end"] as? String
                {
                    
                    _ = Ticket(id: id,
                               ticketNumber: ticketNumber,
                               description: description,
                               title: title,
                               type: type,
                               priority: priority,
                               status: status,
                               assignee: assignee,
                               reporter: reporter,
                               comments: comments,
                               attachments: attachments,
                               size: nil,
                               start: start,
                               end: end)
                    
                    ticketNumberLabel?.stringValue = ticketNumber
                    typeLabel?.stringValue = type
                    priorityLabel?.stringValue = priority
                    statusLabel?.stringValue = status
                    assigneeLabel?.stringValue = assignee
                    reporterLabel?.stringValue = reporter
                    sizeLabel?.stringValue = "size"
                    
                    
                    if let descriptionTextView = descriptionTextView {
                        self.clearText(textView: descriptionTextView)
                        descriptionTextView.insertText(description)
                    }
                }
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
    
    private func clearText(textView: NSTextView) {
        textView.selectAll(nil)
        textView.deleteBackward(nil)
    }
}

protocol TimelineItem {
    var id: Int { get set }
    var ticketNumber: String { get set }
    var description: String { get set }
    var title: String { get set }
    var type: String { get set }
    var priority: String { get set }
    var status: String { get set }
    var assignee: String { get set }
    var reporter: String { get set }
    var comments: [String] { get set }
    var attachments: [String] { get set }
    var size: String? { get set }
    var start: String { get set }
    var end: String { get set }
    
    func asDict() -> [String : Any]
}

struct Ticket: TimelineItem, Decodable {
    
    typealias StringToAnyDict = [String : Any]
    
    var id: Int
    var ticketNumber: String
    var description: String
    var title: String
    var type: String
    var priority: String
    var status: String
    var assignee: String
    var reporter: String
    var comments: [String]
    var attachments: [String]
    var size: String?
    var start: String
    var end: String
    
    public func asDict() -> [String : Any] {
        return ["id": self.id,
                "content": self.ticketNumber,
                "ticketNumber": self.ticketNumber + " - " + self.title,
                "description": self.description,
                "ticketTitle": self.title,
                "ticketType": self.type,
                "priority": self.priority,
                "status": self.status,
                "assignee": self.assignee,
                "reporter": self.reporter,
                "comments": self.comments,
                "attachments": self.attachments,
                "size": self.size,
                "start": self.start,
                "end": self.end] as [String : Any]
    }
    
    
}
