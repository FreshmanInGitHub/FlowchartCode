//
//  Entrance.swift
//  Drawing
//
//  Created by Young on 2019/1/17.
//  Copyright © 2019 Young. All rights reserved.
//

import UIKit

class Entrans: UIView {
    
    var shape: Shape?
    
    var angle: CGFloat = 0
    
    var position = CGPoint() {
        didSet {
            if let shape = shape, let canvas = superview as? Canv {
                angle = LineForConnecting.angle(between: position, and: canvas.position(for: shape.center))
            }
            setPath()
        }
    }
    
    var isHighlighted = false {
        didSet { setNeedsDisplay() }
    }
    
    var path = UIBezierPath()
    
    func setPath() {
        let path = UIBezierPath()
        if let canvas = superview as? Canv {
            path.move(to: CGPoint(x: -10, y: 7.5))
            path.addLine(to: CGPoint())
            path.addLine(to: CGPoint(x: -10, y: -7.5))
            path.move(to: CGPoint())
            path.addLine(to: CGPoint(x: -40, y: 0))
            if let shape = shape {
                path.apply(CGAffineTransform(rotationAngle: angle))
                path.apply(CGAffineTransform(translation: canvas.position(for: shape.extendedEntry(for: path.currentPoint+shape.center)!)))
            } else {
                path.apply(CGAffineTransform(translationX: position.x+20, y: position.y))
            }
        }
        self.path = path
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        if let canvas = superview as? Canv {
        if isHighlighted {
            path.lineWidth = 1 + 2 * canvas.scale
            UIColor.lightGray.setStroke()
        } else {
            path.lineWidth = 1 + canvas.scale
            UIColor.gray.setStroke()
        }
        path.stroke()
        }
    }
    
    override func didMoveToSuperview() {
        if shape == nil {
            position = center
        }
        setPath()
    }
    
    override func scale(by scale: CGFloat) {
        path.apply(CGAffineTransform(scale: scale))
        setNeedsDisplay()
    }
    
    override func translate(with translation: CGPoint) {
        path.apply(CGAffineTransform(translation: translation))
        setNeedsDisplay()
    }
}
