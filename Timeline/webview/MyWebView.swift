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
    var overView: NSView?
    var selectView: NSView?
    
    var recentlyUpdatedTickets = [Ticket]()
    var recentComments = [Comment]()
    
    
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
                           descriptionTextView: NSTextView,
                           overView: NSView,
                           selectView: NSView) {
        
        self.overView = overView
        self.selectView = selectView
        
        self.selectView!.isHidden = true
        self.overView?.isHidden = false
        
        let userContentController = self.configuration.userContentController as WKUserContentController
        userContentController.add(self, name: "webviewreadyHandler")
        userContentController.add(self, name: "selectHandler")
        userContentController.add(self, name: "deselectHandler")
        
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
            
            let urlString = "http://localhost:8080/ticket"
            guard let url = URL(string: urlString) else { return }
            
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error!.localizedDescription)
                }
                
                guard let data = data else { return }
                do {
                    let ticketsData = try JSONDecoder().decode(TicketResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.recentlyUpdatedTickets.append(contentsOf: ticketsData.overview.recentlyUpdatedTickets)
                        self.recentComments.append(contentsOf: ticketsData.overview.recentComments)
                        
                        self.initGraph(timelineItems: ticketsData.tickets)
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
                    let size = body["size"] as? String,
                    let start = body["start"] as? String,
                    let end = body["end"] as? String,
                    let updatedAt = body["updatedAt"] as? String
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
                               size: size,
                               start: start,
                               end: end,
                               updatedAt: updatedAt)
                    
                    ticketNumberLabel?.stringValue = ticketNumber
                    typeLabel?.stringValue = type
                    priorityLabel?.stringValue = priority
                    statusLabel?.stringValue = status
                    assigneeLabel?.stringValue = assignee
                    reporterLabel?.stringValue = reporter
                    sizeLabel?.stringValue = size
                    
                    
                    if let descriptionTextView = descriptionTextView {
                        self.clearText(textView: descriptionTextView)
                        descriptionTextView.insertText(description)
                    }
                    
                    self.selectView?.isHidden = false
                    self.overView?.isHidden = true
                }
            }
            break
        case "deselectHandler":
            self.selectView?.isHidden = true
            self.overView?.isHidden = false
            break
        default:
            print("Adapter not implemented for " + message.name)
            break
        }
    }
    
    public func initGraph(timelineItems: [Ticket]) {
        
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

struct TicketResponse: Decodable {
    var tickets: [Ticket]
    var overview: Overview
}

struct Ticket: Decodable {
    
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
    var updatedAt: String
    
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
                "end": self.end,
                "updatedAt": self.updatedAt] as [String : Any]
    }
}

struct Overview: Decodable {
    var recentlyUpdatedTickets: [Ticket]
    var recentComments: [Comment]
}

struct Comment: Decodable {
    
}
