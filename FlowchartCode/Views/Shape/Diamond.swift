//
//  Diamond.swift
//  Drawing
//
//  Created by Young on 2018/12/14.
//  Copyright © 2018 Young. All rights reserved.
//

import Foundation
import UIKit

class Diamond: Shape {
    
    init(center: CGPoint) {
        super.init(frame: CGRect(x: center.x-65, y: center.y-40, width: 130, height: 80))
    }
    
    convenience init(block: Block) {
        self.init(center: block.center)
        instructions = block.instructions
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override var path: UIBezierPath {
        return Diamond.path(within: bounds)
    }
    
    var nextShapeWhenFalse: Shape? {
        didSet {
            resetLine(true)
        }
    }
    
    override func resetLine(_ shouldResetLine: Bool) {
        super.resetLine(shouldResetLine)
        if shouldResetLine {
            if let line = line {
                line.color = UIColor.green
            }
            lineWhenFalse = nextShapeWhenFalse == nil ? nil : Line(initiator: self, target: nextShapeWhenFalse!, color: UIColor.red)
        }
    }
    
    var lineWhenFalse: Line?
    
    override func related(to shape: Shape?) -> Bool {
        return super.related(to: shape) || nextShapeWhenFalse == shape
    }
    
    override func lineForPanning(to point: CGPoint) -> Line? {
        if let line = super.lineForPanning(to: point) {
            line.color = .green
            return line
        }
        return nextShapeWhenFalse == nil ? Line(initiator: self, point: point, color: .red) : nil
    }
    
    override func extendedEntry(for positionInShapeView: CGPoint) -> CGPoint {
        if positionInShapeView != center {
            let line = LinearFunction(start: center, end: positionInShapeView) ?? LinearFunction(start: center, end: center+CGPoint(x: 1, y: 0))!
            let lineOfFrame: LinearFunction
            switch (positionInShapeView.x>center.x, positionInShapeView.y>center.y) {
            case (true, true): lineOfFrame = LinearFunction(start: frame.rightCenter, end: frame.bottomCenter)!
            case (true, false): lineOfFrame = LinearFunction(start: frame.rightCenter, end: frame.upperCenter)!
            case (false, true): lineOfFrame = LinearFunction(start: frame.leftCenter, end: frame.bottomCenter)!
            default: lineOfFrame = LinearFunction(start: frame.leftCenter, end: frame.upperCenter)!
            }
            return line.intersection(with: lineOfFrame)!
        }
        return frame.leftCenter
    }
    
    override func deleteConnection(to shape: Shape) {
        super.deleteConnection(to: shape)
        if nextShapeWhenFalse == shape {
            nextShapeWhenFalse = nil
        }
    }
    
    override func deleteConnection(with color: UIColor) {
        if color == .green {
            nextShape = nil
        } else if color == .red {
            nextShapeWhenFalse = nil
        }
    }
    
    override func canConnect(to target: Shape) -> Bool {
        return super.canConnect(to: target) && nextShapeWhenFalse != target
    }
    
    override func connect(to target: Shape, with color: UIColor) {
        if color == .green {
            nextShape = target
        } else if color == .red {
            nextShapeWhenFalse = target
        }
    }
    
    static func path(within bounds: CGRect) -> UIBezierPath {
        let actualBounds = CGRect(x: bounds.minX+1, y: bounds.minY+1, width: bounds.width-2, height: bounds.height-2)
        let path = UIBezierPath()
        path.move(to: actualBounds.leftCenter)
        path.addLine(to: actualBounds.upperCenter)
        path.addLine(to: actualBounds.rightCenter)
        path.addLine(to: actualBounds.bottomCenter)
        path.addLine(to: actualBounds.leftCenter)
        return path
    }
    
}

