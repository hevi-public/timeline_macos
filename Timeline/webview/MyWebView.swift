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
    
    var outlineView: MyOutlineView?
    
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
    var recentTicketsView: RecentTicketsTableView?
    
    var tickets = [Ticket]()
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
                           selectView: NSView,
                           recentTicketsView: RecentTicketsTableView,
                           outlineView: MyOutlineView) {
        
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
        self.recentTicketsView = recentTicketsView
        
        self.outlineView = outlineView
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
                        
                        let recentTickets = ticketsData.tickets.sorted(by: { (ticketA, ticketB) -> Bool in
                            return ticketA.updatedAt > ticketB.updatedAt
                        })
                        
                        self.recentTicketsView?.initialize(recentTickets: recentTickets, webView: self)
                        
                        self.tickets = ticketsData.tickets
                        
                        self.initGraph(timelineItems: ticketsData.tickets)
                    }
                } catch let jsonError {
                    print(jsonError)
                }
            }.resume()
            break
        case "selectHandler":
                do {
                    let id = (message.body as! Int)
                
                    let ticket = tickets.filter { filteredTicket -> Bool in
                        filteredTicket.id == id
                    }.first
                
                    if let ticket = ticket {
                    
                        let typeDisplayString = DisplayString.getTypeDisplayString(ticket.type)

                        ticketNumberLabel?.stringValue = ticket.ticketNumber
                        typeLabel?.attributedStringValue = typeDisplayString
                        priorityLabel?.stringValue = ticket.priority
                        statusLabel?.stringValue = ticket.status
                        assigneeLabel?.stringValue = ticket.assignee
                        reporterLabel?.stringValue = ticket.reporter
                        sizeLabel?.stringValue = ticket.size ?? "0"
                    
                    
                        if let descriptionTextView = descriptionTextView {
                            descriptionTextView.font = NSFont(descriptor: NSFontDescriptor(name: "Helvetica", size: 16), size: 16)
                            descriptionTextView.textColor = NSColor.init(rgb: 0xE0E8E9)
                            
                            self.clearText(textView: descriptionTextView)
                            descriptionTextView.insertText(ticket.description)
                        }
                    
                        self.selectView?.isHidden = false
                        self.overView?.isHidden = true
                    
                        outlineView?.initialize(comments: ticket.comments)
                    }
                } catch let error {
                    print(error)
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
    
    public func selectTicket(ticket: Ticket) {
        let script = NSString(format: "selectTicket(%@);", String(ticket.id))
        self.evaluateJavaScript(script as String, completionHandler: { (result, error) in
            if error != nil {
                print("error: " + (error! as NSError).debugDescription)
            }
        })
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

struct Ticket: Codable {
    
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
    var comments: [Comment]
    var attachments: [String]
    var size: String?
    var start: String
    var end: String
    var updatedAt: String
    

    private enum CodingKeys : String, CodingKey {
        case id = "id"
        case ticketNumber = "ticketNumber"
        case description = "description"
        case title = "title"
        case type = "type"
        case priority = "priority"
        case status = "status"
        case assignee = "assignee"
        case reporter = "reporter"
        case comments = "comments"
        case attachments = "attachments"
        case size = "size"
        case start = "start"
        case end = "end"
        case updatedAt = "updatedAt"
    }
    
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
                "comments": self.comments.description,
                "attachments": self.attachments,
                "size": self.size as Any,
                "start": self.start,
                "end": self.end,
                "updatedAt": self.updatedAt] as [String : Any]
    }
}

struct Overview: Decodable {
    var recentlyUpdatedTickets: [Ticket]
    var recentComments: [Comment]
}

struct Comment: Codable {
    
    var commentId: String
    var author: String
    var content: String
    var createdAt: String
    var children: [Comment]
    var parentId: String?
    
    
    public func asDict() -> [String : Any] {
        
        let dictChildren = self.children.map { child -> [String : Any] in
            return child.asDict()
        }
        
        return ["commentId": self.commentId,
                "author": self.author,
                "content": self.content,
                "createdAt": self.createdAt,
                "parentId": self.parentId,
                "children": dictChildren] as [String : Any]
    }
}
