//
//  EditingView.swift
//  Drawing
//
//  Created by Young on 2019/4/6.
//  Copyright © 2019 Young. All rights reserved.
//

import UIKit

class EditingView: UIView {
    
    var boundsForPath = CGRect()
    
    var path = UIBezierPath()
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        UIColor.black.setStroke()
        path.stroke()
    }
    
    // Paths. Remember to use frame elements of boundingView here.
    
    var rectPath: UIBezierPath {
        return Rect.path(within: boundsForPath)
    }
    
    var diamondPath: UIBezierPath {
        let width = bounds.width*1.4
        let height = width/13*8
        return Diamond.path(within: CGRect(x: -bounds.width*0.2, y: boundsForPath.midY-height/2, width: width, height: height))
    }
    
    var ovalPath: UIBezierPath {
        let width = bounds.width*1.1
        let height = width/12*7
        return Oval.path(within: CGRect(x: -width*0.05, y: boundsForPath.midY-height/2, width: width, height: height))
    }
}
