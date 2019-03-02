//
//  Extensions.swift
//  Drawing
//
//  Created by Young on 2019/2/28.
//  Copyright © 2019 Young. All rights reserved.
//

import Foundation
import UIKit

extension Numeric {
    var square: Self {
        return self * self
    }
}

extension CGRect {
    var upperLeft: CGPoint { return CGPoint(x: minX, y: minY) }
    var upperRight: CGPoint { return CGPoint(x: maxX, y: minY) }
    var bottomLeft: CGPoint { return CGPoint(x: minX, y: maxY) }
    var bottomRight: CGPoint { return CGPoint(x: maxX, y: maxY) }
    
    var center: CGPoint { return CGPoint(x: midX, y: midY) }
    var upperCenter: CGPoint { return CGPoint(x: midX, y: minY) }
    var bottomCenter: CGPoint { return CGPoint(x: midX, y: maxY) }
    var leftCenter: CGPoint { return CGPoint(x: minX, y: midY) }
    var rightCenter: CGPoint { return CGPoint(x: maxX, y: midY) }
}

extension CGPoint {
    func isAbove(of point: CGPoint) -> Bool { return y<point.y }
    func isBelow(_ point: CGPoint) -> Bool { return y>point.y }
    func distance(to point: CGPoint) -> CGFloat {
        let d = self-point
        return sqrt(d.x*d.x+d.y*d.y)
    }
    
    static func + (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x+right.x, y: left.y+right.y)
    }
    static func - (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x-right.x, y: left.y-right.y)
    }
    static func * (left: CGPoint, right: CGFloat) -> CGPoint {
        return CGPoint(x: left.x*right, y: left.y*right)
    }
    static func * (left: CGFloat, right: CGPoint) -> CGPoint {
        return CGPoint(x: right.x*left, y: right.y*left)
    }
}

extension CGAffineTransform {
    init(translation: CGPoint) {
        self.init(translationX: translation.x, y: translation.y)
    }
    
    init(scale: CGFloat) {
        self.init(scaleX: scale, y: scale)
    }
}

extension UIView {
    var centerInSuperview: CGPoint? {
        return superview == nil ? nil : CGPoint(x: frame.midX, y: frame.midY)
    }
    
    func positionInSuperview(point: CGPoint) -> CGPoint {
        return CGPoint(x: point.x+frame.minX, y: point.y+frame.minY)
    }
    func positionInView(point: CGPoint) -> CGPoint {
        return CGPoint(x: point.x-frame.minX, y: point.y-frame.minY)
    }
    
    @objc func translate(with translation: CGPoint) {
        frame = frame.applying(CGAffineTransform(translation: translation))
    }
    
    @objc func scale(by scale: CGFloat) {
        frame = frame.applying(CGAffineTransform(scale: scale))
    }
}

extension String {
    var isDouble: Bool {
        return Double(self) != nil
    }
}

extension NSCoder {
    func decodeString(forKey key: String) -> String? {
        if let string = decodeObject(forKey: key) as? String {
            return string
        }
        return nil
    }
    
    func decodeCGFloat(forKey key: String) -> CGFloat? {
        if let value = decodeObject(forKey: key) as? CGFloat {
            return value
        }
        return nil
    }
}
