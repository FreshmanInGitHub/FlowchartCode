//
//  Source.swift
//  Drawing
//
//  Created by Young on 2019/4/9.
//  Copyright © 2019 Young. All rights reserved.
//

import UIKit

class Source: UIView {
    
    var style = Shape.style.rect {
        didSet {
            switch style {
            case .rect: path = Rect.path(within: CGRect(x: 5, y: 7.5, width: 60, height: 35))
            case .diamond: path = Diamond.path(within: CGRect(x: 2.5, y: 5, width: 65, height: 40))
            case .oval: path = Oval.path(within: CGRect(x: 5, y: 7.5, width: 60, height: 35))
            }
            setNeedsDisplay()
        }
    }
    
    var path = UIBezierPath()
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        UIColor.gray.setStroke()
        UIColor.white.setFill()
        path.fill()
        path.stroke()
    }

}
