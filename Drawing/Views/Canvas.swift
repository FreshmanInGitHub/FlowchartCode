//
//  Canva.swift
//  Drawing
//
//  Created by Young on 2019/3/13.
//  Copyright © 2019 Young. All rights reserved.
//

import UIKit

class Canvas: UIView {
    
    var scrollView = UIScrollView()
    
    var shapes: [Shape] {
        var shapes = [Shape]()
        for view in subviews {
            if let shape = view as? Shape {
                shapes.append(shape)
            }
        }
        return shapes
    }
    
    var lines = [LineForConnecting]()
    var draggingLine: LineForConnecting? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    func tryDraggingLine(at point: CGPoint) -> Bool {
        for line in lines.reversed() {
            if line.contains(point) {
                draggingLine = line.new(point: point)
                lines.remove(at: lines.firstIndex(of: line)!)
                return true
            }
        }
        return false
    }
    
    func tryMovingLine(to point: CGPoint) -> Bool {
        if let line = draggingLine {
            draggingLine = line.new(point: point)
            return true
        }
        return false
    }
    
    func tryDroppingLine(at position: CGPoint) -> Bool {
        if let line = draggingLine {
            draggingLine = nil
            if let shape = shape(at: position), line.initiator.canConnect(to: shape) {
                line.initiator.connect(to: shape, with: line.color)
                setLines()
                return true
            }
        }
        return false
    }
    
    func resetLines(relatedTo shape: Shape) {
        for otherShape in shapes {
            if otherShape.related(to: shape) {
                otherShape.setLine()
            }
        }
        if shape == entrance.shape {
            entrance.
        }
        setLines()
    }
    
    func setLines() {
        lines.removeAll()
        for shape in shapes {
            if let line = shape.line {
                lines.append(line)
            }
            if let diamond = shape as? Diamond, let line = diamond.lineWhenFalse {
                lines.append(line)
            }
        }
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        for line in lines {
            line.color.set()
            line.stroke()
            line.fill()
        }
        if let line = draggingLine {
            line.color.set()
            line.lineWidth = 2
            line.stroke()
            line.fill()
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if let scrollView = superview as? UIScrollView {
            self.scrollView = scrollView
            backgroundColor = .clear
            updateSizes()
        }
        addSubview(entrance)
    }
    
    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        updateSizes()
    }
    
    func updateSizes() {
        frame.size = (scrollView.frame.size/2 + minSize) * scrollView.zoomScale
        scrollView.contentSize = frame.size
        scrollView.minimumZoomScale = max(max(scrollView.frame.width/frame.width, scrollView.frame.height/frame.height), 0.3)
    }
    
    override var frame: CGRect {
        didSet {
            setNeedsDisplay()
        }
    }

    private var minSize: CGSize {
        var corner = CGPoint()
        if subviews.contains(entrance) {
            corner = entrance.positionInSuperview(point: entrance.path.bounds.bottomRight)
        }
        for shape in shapes {
            corner.x = max(shape.frame.maxX, corner.x)
            corner.y = max(shape.frame.maxY, corner.y)
        }
        return CGSize(width: max(corner.x, scrollView.frame.width/2), height: max(corner.y, scrollView.frame.height/2))
    }
    
    var entrance = EntranceView(frame: CGRect(x: 20, y: 0, width: 80, height: 80))
    
    func shape(at point: CGPoint) -> Shape? {
        for shape in shapes {
            if shape.contains(shape.positionInView(point: point)) {
                return shape
            }
        }
        return nil
    }
    
}
