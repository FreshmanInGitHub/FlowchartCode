//
//  Entrance.swift
//  Drawing
//
//  Created by Young on 2019/1/17.
//  Copyright © 2019 Young. All rights reserved.
//

import UIKit

class Entrance: UIView {
    
    var shape: Shape? {
        didSet { angle = 0 }
    }
    
    var angle: CGFloat = 0 {
        didSet { setPath() }
    }
    
    var position = CGPoint() {
        didSet { setPath() }
    }
    
    var isHighlighted = false {
        didSet { setPath() }
    }
    
    var path = UIBezierPath()
    
    func setPath() {
        let path = UIBezierPath()
        if let canvas = superview as? Canvas {
            let width = canvas.scale*40
            let height = canvas.scale*15
            path.move(to: CGPoint(x: -width/4, y: height/2))
            path.addLine(to: CGPoint())
            path.addLine(to: CGPoint(x: -width/4, y: -height/2))
            path.move(to: CGPoint())
            path.addLine(to: CGPoint(x: -width, y: 0))
            if let shape = shape {
                path.apply(CGAffineTransform(rotationAngle: angle))
                path.apply(CGAffineTransform(translation: canvas.position(for: shape.extendedEntry(for: path.currentPoint+shape.center)!)))
            } else {
                path.apply(CGAffineTransform(translationX: position.x+canvas.scale*20, y: position.y))
            }
            if isHighlighted {
                path.lineWidth = 3*canvas.scale
            } else {
                path.lineWidth = 2*canvas.scale
            }
        }
        self.path = path
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        if isHighlighted {
            UIColor.lightGray.setStroke()
        } else {
            UIColor.gray.setStroke()
        }
        path.stroke()
    }
    
    override func didMoveToSuperview() {
        position = center
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
