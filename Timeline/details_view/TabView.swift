//
//  TabView.swift
//  Timeline
//
//  Created by Hevi on 06/04/2019.
//  Copyright © 2019 Hevi. All rights reserved.
//

import Cocoa

class TabView: NSTabView {
    
    var storedTabViewItems: [NSTabViewItem] = []
    
    var ticketSelected: Bool? {
        didSet {
            self.tabView(self, shouldSelect: nil)
        }
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.delegate = self
        
        self.storedTabViewItems = self.tabViewItems
        
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}

extension TabView: NSTabViewDelegate {
    
    func tabView(_ tabView: NSTabView, shouldSelect tabViewItem: NSTabViewItem?) -> Bool {
        if let tabViewItem = tabViewItem {
            let index = tabView.indexOfTabViewItem(tabViewItem)
            
            if index > 0 && (ticketSelected ?? false) || index == 0 {
                return true
            }
            return false
        }
        return true
    }

}
