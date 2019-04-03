//
//  Oval.swift
//  Drawing
//
//  Created by Young on 2018/12/14.
//  Copyright © 2018 Young. All rights reserved.
//

import Foundation
import UIKit

class Oval: Shape {
    
    init(center: CGPoint) {
        super.init(frame: CGRect(x: center.x-60, y: center.y-35, width: 120, height: 70))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init(block: Block) {
        self.init(center: block.center)
        instructions = block.instructions
    }
    
    override var path: UIBezierPath {
        return Oval.path(within: bounds)
    }
    
    override func extendedEntry(for positionInShapeView: CGPoint) -> CGPoint {
        if positionInShapeView != center {
            let squareA = (frame.minX-center.x).square
            let squareB = (frame.minY-center.y).square
            let targetInView = positionInShapeView - center
            let squareX = targetInView.x.square
            let line = LinearFunction(start: targetInView, end: CGPoint()) ?? LinearFunction(k: 0, b: 0)
            if line.b == 0 {
                let dY = sqrt(squareB*(1-squareX/squareA))
                return targetInView.y>0 ? CGPoint(x: targetInView.x+center.x, y: dY+center.y):CGPoint(x: targetInView.x+center.x, y: center.y-dY)
            } else {
                let a = squareB+squareA*line.a*line.a/(line.b*line.b)
                let b = squareA*line.a*line.c*2/(line.b*line.b)
                let c = squareA*line.c*line.c/(line.b*line.b)-squareA*squareB
                let x = targetInView.x >= 0 ? (-b+sqrt(b*b-4*a*c))/(2*a):(-b-sqrt(b*b-4*a*c))/(2*a)
                let y = -(line.a*x+line.c)/line.b
                return CGPoint(x: x+center.x, y: y+center.y)
            }
        }
        return frame.leftCenter
    }
    
    static func path(within bounds: CGRect) -> UIBezierPath {
        return UIBezierPath(ovalIn: CGRect(x: bounds.minX+1, y: bounds.minY+1, width: bounds.width-2, height: bounds.height-2))
    }
}

