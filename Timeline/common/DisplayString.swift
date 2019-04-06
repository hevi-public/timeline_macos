//
//  DisplayString.swift
//  Timeline
//
//  Created by Hevi on 06/04/2019.
//  Copyright © 2019 Hevi. All rights reserved.
//

import Cocoa

class DisplayString: NSString {

    static func getTypeDisplayString(_ type: String) -> NSAttributedString {
        var typeColor = NSColor.cyan
        switch type {
        case "BUG":
            typeColor = NSColor.orange
            break
        case "STORY":
            typeColor = NSColor.green
            break
        case "TASK":
            typeColor = NSColor.cyan
            break
        default:
            print(type + " type not implemented")
        }
        let typeDisplayString: NSMutableAttributedString =  NSMutableAttributedString(string: type)
        typeDisplayString.addAttribute(NSAttributedString.Key.foregroundColor, value: typeColor, range: NSMakeRange(0, typeDisplayString.length))
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .right
        
        typeDisplayString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraph, range: NSMakeRange(0, typeDisplayString.length))
        return typeDisplayString
    }
    
    static func getSizeDisplayString(_ size: String) -> NSAttributedString {
        var sizeColor = NSColor.cyan
        switch size {
        case "S":
            sizeColor = NSColor(rgb: 0xA6CC9F)
            break
        case "M":
            sizeColor = NSColor(rgb: 0x93C6D6)
            break
        case "L":
            sizeColor = NSColor(rgb: 0xF9A47F)
            break
        case "XL":
            sizeColor = NSColor(rgb: 0xF98452)
            break
        default:
            print(size + " type not implemented")
        }
        let sizeDisplayString: NSMutableAttributedString =  NSMutableAttributedString(string: size)
        sizeDisplayString.addAttribute(NSAttributedString.Key.foregroundColor, value: sizeColor, range: NSMakeRange(0, sizeDisplayString.length))
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .right
        
        sizeDisplayString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraph, range: NSMakeRange(0, sizeDisplayString.length))
        return sizeDisplayString
    }
    
    static func getPriorityDisplayString(_ size: String) -> NSAttributedString {
        var priorityColor = NSColor.cyan
        switch size {
        case "P0":
            priorityColor = NSColor(rgb: 0xF25C54)
            break
        case "P1":
            priorityColor = NSColor(rgb: 0xF27059)
            break
        case "P2":
            priorityColor = NSColor(rgb: 0xF79D65)
            break
        case "P3":
            priorityColor = NSColor(rgb: 0x7DCFB6)
            break
        case "P4":
            priorityColor = NSColor(rgb: 0x00B2CA)
            break
        case "P5":
            priorityColor = NSColor(rgb: 0x1D4E89)
            break
        default:
            print(size + " type not implemented")
        }
        let priorityDisplayString: NSMutableAttributedString =  NSMutableAttributedString(string: size)
        priorityDisplayString.addAttribute(NSAttributedString.Key.foregroundColor, value: priorityColor, range: NSMakeRange(0, priorityDisplayString.length))
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .right
        
        priorityDisplayString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraph, range: NSMakeRange(0, priorityDisplayString.length))
        return priorityDisplayString
    }
    
    
}

extension NSColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}
