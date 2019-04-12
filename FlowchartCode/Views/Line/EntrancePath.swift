//
//  Entrance.swift
//  Drawing
//
//  Created by Young on 2019/3/29.
//  Copyright © 2019 Young. All rights reserved.
//

import UIKit

class EntrancePath: BasicLine {
    
    override var end: CGPoint { return endValue }
    
    override var start: CGPoint { return currentPoint }
    
    var endValue = CGPoint()
    
    init(point: CGPoint, shape: Shape?) {
        super.init()
        move(to: CGPoint(x: -10, y: 7.5))
        addLine(to: CGPoint())
        addLine(to: CGPoint(x: -10, y: -7.5))
        move(to: CGPoint())
        addLine(to: CGPoint(x: -40, y: 0))
        if let shape = shape {
            apply(CGAffineTransform(rotationAngle: BasicLine.angle(between: point, and: shape.center)))
            apply(CGAffineTransform(translation: shape.extendedEntry(for: point)))
            endValue = endValue+shape.extendedEntry(for: point)
        } else {
            apply(CGAffineTransform(translation: point+CGPoint(x: 20, y: 0)))
            endValue = endValue+point+CGPoint(x: 20, y: 0)
        }
        lineWidth = 2
    }
    
    override func translate(with translation: CGPoint) {
        super.translate(with: translation)
        endValue = endValue + translation
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
