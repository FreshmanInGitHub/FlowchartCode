//
//  Entr.swift
//  Drawing
//
//  Created by Young on 2019/3/29.
//  Copyright © 2019 Young. All rights reserved.
//

import UIKit

class EntranceView: UIView, Customized {
    var canvas = UIView()
    var shape: Shape?
    
    var isHighlighted = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var path = EntrancePath(angle: 0)
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if isHighlighted {
            UIColor.lightGray.setStroke()
        } else {
            UIColor.gray.setStroke()
        }
        path.stroke()
    }
    
    func set(point: CGPoint, shape: Shape?) {
        if let shape = shape {
            path = EntrancePath(angle: Line.angle(between: point, and: shape.center))
            translate(with: shape.extendedEntry(for: point)! - center)
        } else {
            path = EntrancePath(angle: 0)
            translate(with: point - center + CGPoint(x: 20, y: 0))
        }
        self.shape = shape
        setNeedsDisplay()
    }
    
    func contains(_ point: CGPoint) -> Bool {
        return path.contains(point)
    }
    
    func keepInFrame() {
        if shape == nil {
            let origin = positionInSuperview(point: path.bounds.origin)
            slide(with: -CGPoint(x: min(origin.x, 0), y: min(origin.y, 0)))
        }
    }
    
    private func slide(with translation: CGPoint) {
        UIView.animate(withDuration: 0.4, animations: {self.translate(with: translation)})
    }
}
