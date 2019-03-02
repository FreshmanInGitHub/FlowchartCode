//
//  ShapeView.swift
//  Drawing
//
//  Created by Young on 2019/3/1.
//  Copyright © 2019 Young. All rights reserved.
//

import UIKit

class ShapeView: UIView {
    var canvas = Canvas()
    
    override func draw(_ rect: CGRect) {
        for line in canvas.lines {
            line.color.set()
            line.stroke()
            line.fill()
        }
        if let line = canvas.draggingLine {
            line.color.set()
            line.lineWidth = 2
            line.stroke()
            line.fill()
        }
    }
    
    override func scale(by scale: CGFloat) {
        super.scale(by: scale)
        for view in subviews {
            view.scale(by: scale)
        }
    }
}
