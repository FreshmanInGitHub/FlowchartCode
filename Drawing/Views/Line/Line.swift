//
//  Line.swift
//  Drawing
//
//  Created by Young on 2019/3/29.
//  Copyright © 2019 Young. All rights reserved.
//

import UIKit

class Line: UIBezierPath {
    var color = UIColor.black
    var start: CGPoint { return CGPoint() }
    var end: CGPoint { return CGPoint() }
    
    var linearFunction: LinearFunction? {
        return LinearFunction(start: start, end: end)
    }
    
    var length: CGFloat {
        let d = start - end
        return sqrt(d.x.square+d.y.square)
    }
    
    override func contains(_ point: CGPoint) -> Bool {
        return distance(point: point) ?? 11 <= 10
    }
    
    var angle: CGFloat {
        return Line.angle(between: start, and: end)
    }
    
    func distance(point: CGPoint) -> CGFloat? {
        if let line = LinearFunction(start: start, end: end) {
            let returnDistanceToLine: Bool
            if line.isHorizontal {
                returnDistanceToLine = (point.x > min(start.x, end.x) && point.x < max(start.x, end.x))
            } else {
                let upperEdge = start.isAbove(of: end) ? line.rightAngleLine(with: start) : line.rightAngleLine(with: end)
                let bottomEdge = start.isBelow(end) ? line.rightAngleLine(with: start) : line.rightAngleLine(with: end)
                returnDistanceToLine = (upperEdge.isAbove(of: point) && bottomEdge.isBelow(point))
            }
            return returnDistanceToLine ? line.distance(to: point) : min(point.distance(to: start), point.distance(to: end))
        }
        return nil
    }
    
    static func angle(between initiator: CGPoint, and target: CGPoint) -> CGFloat {
        let d = initiator - target
        switch (d.y<0, d.x<0) {
        case (true, true): return atan(abs(d.y/d.x))
        case (true, false): return atan(abs(d.x/d.y))+CGFloat.pi/2
        case (false, true): return -atan(abs(d.y/d.x))
        case (false, false): return -atan(abs(d.x/d.y))-CGFloat.pi/2
        }
    }
}
