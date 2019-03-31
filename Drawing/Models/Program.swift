//
//  Program.swift
//  Drawing
//
//  Created by Young on 2019/2/20.
//  Copyright © 2019 Young. All rights reserved.
//

import Foundation
import UIKit

class Program: NSObject, NSCoding {    
    
    var title = "Program" {
        didSet {
            if title.isEmpty {
                title = "Program"
            }
        }
    }
    var scale: CGFloat = 1
    var blocks = [Block]()
    var entrance: (index: Int, angle: CGFloat)?
    
    override init() {
    }
    
    func set(scale: CGFloat, shapes: [Shape], entrance: Entrans) {
        self.scale = scale
        blocks = [Block]()
        for shape in shapes {
            blocks.append(Block(shape: shape))
        }
        for index in shapes.indices {
            if let next = shapes[index].nextShape {
                blocks[index].next = shapes.firstIndex(of: next)!
            }
            if let diamond = shapes[index] as? Diamond, let nextWhenFalse = diamond.nextShapeWhenFalse {
                blocks[index].nextWhenFalse = shapes.firstIndex(of: nextWhenFalse)!
            }
        }
        if let shape = entrance.shape {
            self.entrance = (shapes.firstIndex(of: shape)!, entrance.angle)
        } else {
            self.entrance = nil
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        title = aDecoder.decodeString(forKey: "title")!
        scale = aDecoder.decodeCGFloat(forKey: "scale")!
        blocks = aDecoder.decodeObject(forKey: "blocks") as! [Block]
        if aDecoder.containsValue(forKey: "index"), aDecoder.containsValue(forKey: "angle") {
            entrance = (aDecoder.decodeInteger(forKey: "index"), aDecoder.decodeCGFloat(forKey: "angle")!)
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: "title")
        aCoder.encode(scale, forKey: "scale")
        aCoder.encode(blocks, forKey: "blocks")
        if entrance != nil {
            aCoder.encode(entrance!.index, forKey: "index")
            aCoder.encode(entrance!.angle, forKey: "angle")
        }
    }
}
