//
//  LinearFunction.swift
//  Drawing
//
//  Created by Young on 2019/2/26.
//  Copyright © 2019 Young. All rights reserved.
//

import Foundation
import UIKit

struct LinearFunction {
    
    init?(start: CGPoint, end: CGPoint) {
        if start.equalTo(end) { return nil }
        let dX = start.x-end.x
        let dY = start.y-end.y
        if dX == 0 {
            a = 1
            b = 0
            c = -start.x
        } else if dY == 0 {
            a = 0
            b = 1
            c = -start.y
        } else {
            let k = dY/dX
            let b = start.y-k*start.x
            a = -k
            self.b = 1
            c = -b
        }
    }
    
    init(k: CGFloat, b: CGFloat) {
        self.a = -k
        self.b = 1
        self.c = -b
    }
    
    // ax+by+c=0
    // y=kx+b  k=-a  b=-c
    var a: CGFloat
    var b: CGFloat
    var c: CGFloat
    var k: CGFloat? {
        return isHorizontal ? nil : -a
    }
    
    var isHorizontal: Bool { return b == 0 }
    var isVertical: Bool { return a == 0 }
    
    func x(with y: CGFloat) -> CGFloat? {
        return isHorizontal ? nil : -(b*y+c)/a
    }
    
    func y(with x: CGFloat) -> CGFloat? {
        return isVertical ? nil : -(a*x+c)/b
    }
    
    func point(x: CGFloat) -> CGPoint? {
        return isVertical ? nil : CGPoint(x: x, y: y(with: x)!)
    }
    
    func point(y: CGFloat) -> CGPoint? {
        return isHorizontal ? nil : CGPoint(x: x(with: y)!, y: y)
    }
    
    func contains(point: CGPoint) -> Bool {
        return a * point.x + b * point.y + c == 0
    }
    
    func isAbove(of point: CGPoint) -> Bool {
        return isVertical ? false : (point.y > y(with: point.x)!)
    }
    
    func isBelow(_ point: CGPoint) -> Bool {
        return isVertical ? false : (point.y < y(with: point.x)!)
    }
    
    func distance(to point: CGPoint) -> CGFloat {
        return intersection(with: rightAngleLine(with: point))!.distance(to: point)
    }
    
    func rightAngleLine(with point: CGPoint) -> LinearFunction {
        if isVertical {
            return LinearFunction(start: CGPoint(x: x(with: point.y)!, y: point.y), end: point)!
        } else if isHorizontal {
            return LinearFunction(start: CGPoint(x: point.x, y: y(with: point.x)!), end: point)!
        } else {
            let otherK = 1/a
            let otherB = point.y-otherK*point.x
            return LinearFunction(k: otherK, b: otherB)
        }
    }
    
    func isParallel(with line: LinearFunction) -> Bool { return k == line.k }
    
    func intersection(with line: LinearFunction) -> CGPoint? {
        if isParallel(with: line) { return nil }
        switch (isHorizontal, line.isHorizontal) {
        case (true, true): return nil
        case (true, false): return CGPoint(x: line.x(with: -c)!, y: -c)
        case (false, true): return CGPoint(x: x(with: -line.c)!, y: -line.c)
        case (false, false):
            let x = (c-line.c)/(k!-line.k!)
            return CGPoint(x: x, y: y(with: x) ?? line.y(with: x)!)
        }
    }
}

