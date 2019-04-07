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
    
    var blocks = [Block]()
    var entrance: (point: CGPoint, index: Int?) = (CGPoint(x: 40, y: 30), nil)
    
    override init() {
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        title = aDecoder.decodeString(forKey: "title")!
        blocks = aDecoder.decodeObject(forKey: "blocks") as! [Block]
        entrance.point = aDecoder.decodeCGPoint(forKey: "point")
        entrance.index = aDecoder.decodeObject(forKey: "index") as? Int
        
        let links = aDecoder.decodeObject(forKey: "links") as! [Int?]
        let linksWhenFalse = aDecoder.decodeObject(forKey: "linksWhenFalse") as! [Int?]
        let _ = blocks.setNext(links: links, { $0.next = $1 })
        let _ = blocks.setNext(links: linksWhenFalse, { $0.nextWhenFalse = $1 })
    }
    
    func encode(with aCoder: NSCoder) {
        let links = blocks.links({ $0.next })
        let linksWhenFalse = blocks.links({ $0.nextWhenFalse })
        
        aCoder.encode(title, forKey: "title")
        aCoder.encode(blocks, forKey: "blocks")
        aCoder.encode(entrance.point, forKey: "point")
        aCoder.encode(entrance.index, forKey: "index")
        aCoder.encode(links, forKey: "links")
        aCoder.encode(linksWhenFalse, forKey: "linksWhenFalse")
    }
}
