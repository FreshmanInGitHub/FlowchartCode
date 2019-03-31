//
//  SourceView.swift
//  Drawing
//
//  Created by Young on 2019/3/28.
//  Copyright © 2019 Young. All rights reserved.
//

import Foundation
import UIKit

class SourceView: UIView {
    lazy var paths = [
        Rect.path(within: CGRect(x: 0, y: 45, width: 60, height: 35)),
        Diamond.path(within: CGRect(x: 60, y: 0, width: 65, height: 40)),
        Oval.path(within: CGRect(x: 125, y: 45, width: 60, height: 35))
    ]
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        UIColor.white.setFill()
        for path in paths {
            if path == selectedPath {
                UIColor.lightGray.setStroke()
            } else {
                UIColor.black.setStroke()
            }
            path.stroke()
            path.fill()
        }
    }
    
    var selectedPath: UIBezierPath? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    func selectePath(_ point: CGPoint) {
        for path in paths {
            if path.contains(point) {
                selectedPath = path
                return
            }
        }
        selectedPath = nil
    }
    
    var selectedPathIndex: Int? {
        if let selectedPath = selectedPath {
            self.selectedPath = nil
            return paths.firstIndex(of: selectedPath)
        }
        return nil
    }
    
}
