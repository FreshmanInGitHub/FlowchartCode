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
        aCoder.encode(type.rawValue, forKey: "type")
        aCoder.encode(instructions, forKey: "instructions")
    }
    
    required init?(coder aDecoder: NSCoder) {
        type = ShapeType(rawValue: aDecoder.decodeInteger(forKey: "type"))!
        center = aDecoder.decodeCGPoint(forKey: "center")
        instructions = aDecoder.decodeObject(forKey: "instructions") as! [Instruction]
    }
    
    init(shape: Shape) {
        switch shape {
        case is Oval: type = .oval
        case is Diamond: type = .diamond
        default: type = .rect
        }
        instructions = shape.instructions
        center = shape.center
    }
    
    var instructions: [Instruction]
    var type: ShapeType
    var center: CGPoint
    var next: Block?
    var nextWhenFalse: Block?
    
    enum ShapeType: Int {
        case rect
        case oval
        case diamond
    }
    
}
