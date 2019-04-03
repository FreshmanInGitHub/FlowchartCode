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
    
    var lines: [LineForConnecting] {
        var lines = [LineForConnecting]()
        for shape in shapes {
            if let line = shape.line {
                lines.append(line)
            }
            if let diamond = shape as? Diamond, let line = diamond.lineWhenFalse {
                lines.append(line)
            }
        }
        return lines
    }
    
    var draggingLine: LineForConnecting?
    
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
        if entrance.isHighlighted {
            UIColor.lightGray.set()
        } else {
            UIColor.gray.set()
        }
        entrancePath.stroke()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if let scrollView = superview as? UIScrollView {
            self.scrollView = scrollView
            backgroundColor = .clear
            updateSizes()
        }
    }
    
    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        updateSizes()
    }
    
    func updateSizes() {
        let sizeForUpdate = (scrollView.frame.size/2 + minSize) * scrollView.zoomScale
        frame.size = CGSize(width: max(frame.size.width, sizeForUpdate.width), height: max(frame.size.height, sizeForUpdate.height))
    }
    
    override var frame: CGRect {
        didSet {
            scrollView.contentSize = frame.size
            scrollView.minimumZoomScale = max(max(scrollView.frame.width/frame.width, scrollView.frame.height/frame.height), 0.3)
            setNeedsDisplay()
        }
    }
    
    private var minSize: CGSize {
        var corner = entrancePath.bounds.bottomRight
        for shape in shapes {
            corner.x = max(shape.frame.maxX, corner.x)
            corner.y = max(shape.frame.maxY, corner.y)
        }
        return CGSize(width: max(corner.x, scrollView.frame.width/2), height: max(corner.y, scrollView.frame.height/2))
    }
    
    var entrancePath = EntrancePath(point: CGPoint(x: 40, y: 30), shape: nil)
    var entrance: (point: CGPoint, shape: Shape?, isHighlighted: Bool) = (CGPoint(x: 40, y: 30), nil, false) {
        didSet {
            entrancePath = EntrancePath(point: entrance.point, shape: entrance.shape)
        }
    }
    
}
