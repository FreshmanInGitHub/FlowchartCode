//
//  ShapeView.swift
//  Drawing
//
//  Created by Young on 2019/3/1.
//  Copyright © 2019 Young. All rights reserved.
//

import UIKit

class ShapeView: UIView {    
    
    override func scale(by scale: CGFloat) {
        super.scale(by: scale)
        for view in subviews {
            view.scale(by: scale)
        }
    }
    
    var centerOfShapes: CGPoint {
        if let shapes = subviews as? [Shape] {
            var upperLeft = bounds.center
            var bottomRight = bounds.center
            for shape in shapes {
                upperLeft.x = min(upperLeft.x, shape.frame.minX)
                upperLeft.y = min(upperLeft.y, shape.frame.minY)
                bottomRight.x = max(bottomRight.x, shape.frame.maxX)
                bottomRight.y = max(bottomRight.y, shape.frame.maxY)
            }
            return positionInSuperview(point: CGPoint(x: (upperLeft.x+bottomRight.x)/2, y: (upperLeft.y+bottomRight.y)/2))
        }
        return center
    }
    
}
