//
//  Line.swift
//  Drawing
//
//  Created by Young on 2018/12/16.
//  Copyright © 2018 Young. All rights reserved.
//

import UIKit
import Foundation

class Line: UIBezierPath {
    var color = UIColor.black
    var initiator = Shape()
    var end = CGPoint()
    var start = CGPoint()
    
    init(initiator: Shape, temporaryTarget: CGPoint?, color: UIColor) {
        super.init()
        if let entry = temporaryTarget, let exit = initiator.entry(for: entry), let canvas = initiator.superview?.superview as? Canvas {
            end = entry
            start = exit
            move(to: exit)
            addLine(to: entry)
            let scale = canvas.scale
            let triangle = UIBezierPath()
            triangle.move(to: CGPoint())
            triangle.addLine(to: CGPoint(x: -6*scale , y: -2*scale))
            triangle.addLine(to: CGPoint(x: -6*scale , y: 2*scale))
            triangle.addLine(to: CGPoint())
            triangle.apply(CGAffineTransform(rotationAngle: Line.angle(between: start, and: end)))
            triangle.apply(CGAffineTransform(translationX: entry.x, y: entry.y))
            append(triangle)
        }
        self.color = color
        self.initiator = initiator
    }
    
    convenience init(initiator: Shape, target: Shape, color: UIColor) {
        self.init(initiator: initiator, temporaryTarget: target.entry(for: initiator.center), color: color)
    }
    
    func newLine(with temporaryTarget: CGPoint) -> Line {
        return Line(initiator: initiator, temporaryTarget: temporaryTarget, color: color)
    }
    
    override func contains(_ point: CGPoint) -> Bool {
        return isEmpty ? false : distance(to: point)! <= 10
    }
    
    var length: CGFloat {
        return sqrt(bounds.height*bounds.height+bounds.width*bounds.width)
    }
    
    var linearFunction: LinearFunction? {
        return isEmpty ? nil : LinearFunction(start: start, end: end)
    }
    
    func distance(to point: CGPoint) -> CGFloat? {
        if isEmpty { return nil }
        let line = linearFunction!
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension Line {
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
