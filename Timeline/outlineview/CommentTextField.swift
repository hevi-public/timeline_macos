//
//  CommentTextField.swift
//  Timeline
//
//  Created by Hevi on 28/03/2019.
//  Copyright © 2019 Hevi. All rights reserved.
//

import Cocoa

class CommentTextField: NSTextField {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override var intrinsicContentSize: NSSize {
        // Guard the cell exists and wraps
        guard let cell = self.cell, cell.wraps else {return super.intrinsicContentSize}
        
        // Use intrinsic width to jive with autolayout
        let width = super.intrinsicContentSize.width
        
        // Set the frame height to a reasonable number
        self.frame.size.height = 750.0
        
        // Calcuate height
        let height = cell.cellSize(forBounds: self.frame).height
        
        return NSMakeSize(width, height);
    }
    
    override func textDidChange(_ notification: Notification) {
        super.textDidChange(notification)
        super.invalidateIntrinsicContentSize()
    }
    
}
