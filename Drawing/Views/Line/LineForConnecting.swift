//
//  Line.swift
//  Drawing
//
//  Created by Young on 2018/12/16.
//  Copyright © 2018 Young. All rights reserved.
//

import UIKit
import Foundation

class LineForConnecting: Line {

    var initiator = Shape()
    
    override var end: CGPoint {
        return currentPoint
    }
    override var start: CGPoint {
        return initiator.entry(for: end) ?? CGPoint()
    }
    
    init(initiator: Shape, point: CGPoint?, color: UIColor) {
        super.init()
        if let end = point, let start = initiator.entry(for: end) {
            move(to: start)
            addLine(to: end)
            let triangle = UIBezierPath()
            triangle.move(to: CGPoint())
            triangle.addLine(to: CGPoint(x: -6, y: -2))
            triangle.addLine(to: CGPoint(x: -6, y: 2))
            triangle.addLine(to: CGPoint())
            triangle.apply(CGAffineTransform(rotationAngle: Line.angle(between: start, and: end)))
            triangle.apply(CGAffineTransform(translationX: end.x, y: end.y))
            append(triangle)
        }
        self.color = color
        self.initiator = initiator
    }
    
    convenience init(initiator: Shape, target: Shape, color: UIColor) {
        self.init(initiator: initiator, point: target.entry(for: initiator.center), color: color)
    }
    
    func new(point: CGPoint) -> LineForConnecting {
        return LineForConnecting(initiator: initiator, point: point, color: color)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
