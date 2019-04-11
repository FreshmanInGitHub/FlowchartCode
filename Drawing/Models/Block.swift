//
//  Block.swift
//  Drawing
//
//  Created by Young on 2019/2/25.
//  Copyright © 2019 Young. All rights reserved.
//

import Foundation
import UIKit

class Block: NSObject, NSCoding {
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(center, forKey: "center")
        aCoder.encode(style.rawValue, forKey: "style")
        aCoder.encode(instructions, forKey: "instructions")
    }
    
    required init?(coder aDecoder: NSCoder) {
        style = Shape.style(rawValue: aDecoder.decodeInteger(forKey: "style"))!
        center = aDecoder.decodeCGPoint(forKey: "center")
        instructions = aDecoder.decodeObject(forKey: "instructions") as! [Instruction]
    }
    
    init(shape: Shape) {
        switch shape {
        case is Oval: style = .oval
        case is Diamond: style = .diamond
        default: style = .rect
        }
        instructions = shape.instructions
        center = shape.center
    }
    
    var instructions: [Instruction]
    var style: Shape.style
    var center: CGPoint
    var next: Block?
    var nextWhenFalse: Block?
    
    
}
