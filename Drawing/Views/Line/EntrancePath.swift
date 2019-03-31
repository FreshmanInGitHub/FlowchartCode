//
//  Entrance.swift
//  Drawing
//
//  Created by Young on 2019/3/29.
//  Copyright © 2019 Young. All rights reserved.
//

import UIKit

class EntrancePath: Line {
    
    override var end: CGPoint { return CGPoint(x: 40, y: 40) }
    
    override var start: CGPoint { return currentPoint }
    
    init(angle: CGFloat) {
        super.init()
        move(to: CGPoint(x: -10, y: 7.5))
        addLine(to: CGPoint())
        addLine(to: CGPoint(x: -10, y: -7.5))
        move(to: CGPoint())
        addLine(to: CGPoint(x: -40, y: 0))
        apply(CGAffineTransform(rotationAngle: angle))
        apply(CGAffineTransform(translation: end))
        lineWidth = 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
