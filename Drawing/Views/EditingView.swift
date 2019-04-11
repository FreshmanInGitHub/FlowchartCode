//
//  EditingView.swift
//  Drawing
//
//  Created by Young on 2019/4/6.
//  Copyright © 2019 Young. All rights reserved.
//

import UIKit

class EditingView: UIView {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var boundingView: UIView!
    
    var shapeType = Shape.style.rect {
        didSet {
            
            // Setting tableView.
            if shapeType == .rect {
                tableView.frame = CGRect(x: 0, y: 2, width: boundingView.bounds.width, height: boundingView.bounds.height-4)
                tableView.isScrollEnabled = true
                tableView.separatorStyle = .singleLine
            } else {
                tableView.frame = CGRect(x: 0, y: boundingView.bounds.midY-25, width: boundingView.bounds.width, height: 50)
                tableView.isScrollEnabled = false
                tableView.separatorStyle = .none
            }
            // Setting path.
            switch shapeType {
            case .rect: path = rectPath
            case .diamond: path = diamondPath
            case .oval: path = ovalPath
            }
            
            tableView.setNeedsDisplay()
            setNeedsDisplay()
        }
    }
    
    var path = UIBezierPath()
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        UIColor.black.setStroke()
        path.stroke()
    }
    
    // Paths. Remember to use frame elements of boundingView here.
    
    var rectPath: UIBezierPath {
        return Rect.path(within: boundingView.frame)
    }
    
    var diamondPath: UIBezierPath {
        let width = bounds.width*1.4
        let height = width/13*8
        return Diamond.path(within: CGRect(x: -bounds.width*0.2, y: boundingView.frame.midY-height/2, width: width, height: height))
    }
    
    var ovalPath: UIBezierPath {
        let width = bounds.width*1.1
        let height = width/12*7
        return Oval.path(within: CGRect(x: -width*0.05, y: boundingView.frame.midY-height/2, width: width, height: height))
    }
}
