//
//  Canvas.swift
//  Drawing
//
//  Created by Young on 2018/12/15.
//  Copyright © 2018 Young. All rights reserved.
//

import UIKit

class Canv: UIScrollView {
    
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
    
    override func didMoveToWindow() {
        scrollView.contentSize = shapeView.frame.size
        bottomBar.dataSource = self
        resetLines()
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var shapeView: ShapeView!
    @IBOutlet weak var bottomBar: BottomBar!
    @IBOutlet weak var bottomBarFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var entrance: Entrans!
    
    var shapes: [Shape] {
        var shapes = [Shape]()
        let subviews = shapeView.subviews
        for view in subviews {
            if let shape = view as? Shape {
                shapes.append(shape)
            }
        }
        return shapes
    }
    
    func positionInShapeView(with positionInCanvas: CGPoint) -> CGPoint {
        return shapeView?.positionInView(point: positionInCanvas) ?? positionInCanvas
    }
    
    func position(for positionInShapeView: CGPoint) -> CGPoint {
        return shapeView.positionInSuperview(point: positionInShapeView)
    }
    
    var draggingView: UIView? {
        didSet {
            if draggingView is Entrans || oldValue is Entrans {
                entrance.isHighlighted = !entrance.isHighlighted
            } else if let shape = draggingView as? Shape {
                shape.isHighlighted = true
                shapeView.addSubview(shape)
                bottomBar.state = .deleteLabel
            } else if let shape = oldValue as? Shape {
                shape.isHighlighted = false
                bottomBar.state = .hidden
            }
        }
    }
    
    var editingShape: Shape? {
        didSet {
            if let shape = editingShape {
//                shape.formerCenter = shape.center
                bottomBar.state = .editing
                shapeView.bringSubviewToFront(shape)
                sendSubviewToBack(entrance)
            } else if let _ = oldValue {
//                shape.formerCenter = nil
                bottomBar.state = .hidden
                bringSubviewToFront(entrance)
            }
            resetLinesRelated(to: editingShape ?? oldValue!)
        }
    }
    
    var draggingLine: LineForConnecting? {
        didSet {
            if draggingLine == nil, let shape = oldValue?.initiator {
                shape.isHighlighted = false
                resetLines()
            } else {
                if let shape = draggingLine?.initiator, oldValue == nil {
                    shapeView.bringSubviewToFront(shape)
                    shape.isHighlighted = true
                }
            }
            setNeedsDisplay()
        }
    }
    
    var lines = [LineForConnecting]() {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var maxScale: CGFloat {
        return bounds.width/130
    }
    
    var scale: CGFloat = 1.0 {
        didSet {
            let ratio = scale/oldValue
            let translation = CGPoint(x: bounds.midX*(1-ratio), y: bounds.midY*(1-ratio))
            shapeView.scale(by: ratio)
            shapeView.translate(with: translation)
            for line in lines {
                line.scale(by: ratio)
                line.translate(with: translation)
            }
            entrance.scale(by: ratio)
            entrance.translate(with: translation)
            setNeedsDisplay()
        }
    }
    
    
    override func translate(with translation: CGPoint) {
        shapeView.translate(with: translation)
        for line in lines {
            line.translate(with: translation)
        }
        entrance.translate(with: translation)
        setNeedsDisplay()
    }
    
    func resetLinesRelated(to shape: Shape) {
        for otherShape in shapes {
            if otherShape.related(to: shape) {
                otherShape.setLine()
            }
        }
        setLines()
    }
    
    func setLines() {
        var lines = [LineForConnecting]()
        for shape in shapes {
            if let line = shape.line {
                lines.append(line)
            }
            if let diamond = shape as? Diamond, let line = diamond.lineWhenFalse {
                lines.append(line)
            }
        }
        self.lines = lines
        entrance.setPath()
    }
    
    func resetLines() {
        for shape in shapes {
            shape.setLine()
        }
        setLines()
    }
    
    func line(positionInCanvas: CGPoint) -> LineForConnecting? {
        for line in lines.reversed() {
            if line.contains(positionInCanvas) {
                return line
            }
        }
        return nil
    }
    
    func shape(at positionInCanvas: CGPoint) -> Shape? {
        let positionInShapeView = self.positionInShapeView(with: positionInCanvas)
        for shape in shapes.reversed() {
            if shape.contains(positionInShapeView) {
                return shape
            }
        }
        return nil
    }
    
    func source(at positionInCanvas: CGPoint) -> Shape? {
        let positionInShapeView = self.positionInShapeView(with: positionInCanvas)
        switch cell(at: positionInCanvas) {
        case 0: return Rect(center: positionInShapeView)
        case 1: return Diamond(center: positionInShapeView)
        case 2: return Oval(center: positionInShapeView)
        default: return nil
        }
    }
    
    func instruction(at positionInCanvas: CGPoint) -> UILabel? {
        if let row = cell(at: positionInCanvas), let cell = bottomBar.cellForItem(at: IndexPath(row: row, section: 0)) as? CollectionViewCellWithLabel {
            let label = UILabel(frame: CGRect(x: positionInCanvas.x-cell.label.frame.width/2, y: positionInCanvas.y-cell.label.frame.height, width: cell.label.frame.width, height: cell.label.frame.height))
            label.text = cell.label.text
            label.font = cell.label.font
            label.textColor = UIColor.gray
            return label
        }
        return nil
    }
    
    func delete(shape: Shape) {
        shape.removeFromSuperview()
        for otherShape in shapes {
            otherShape.deleteConnection(to: shape)
        }
        if entrance.shape == shape {
            entrance.shape = nil
            entrance.position = center
        }
        resetLines()
    }
    
    func moveToCenterOfShapes() {
        translate(with: center-shapeView.centerOfShapes)
    }
    
}

extension Canv: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        bottomBarFlowLayout.itemSize = CGSize(width: 55, height: 55)
        switch bottomBar.state {
        case .hidden: return 3
        case .editing:
            if editingShape is Oval {
                bottomBarFlowLayout.itemSize = CGSize(width: 65, height: 55)
                return 3
            }
            return 5
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            switch editingShape {
            case is Diamond: return bottomBar.labelCellForDiamond(forItemAt: indexPath)
            case is Oval: return bottomBar.labelCellForOval(forItemAt: indexPath)
            default: return bottomBar.labelCellForRect(forItemAt: indexPath)
            }
    }
    
    func cell(at positionInCanvas: CGPoint) -> Int? {
        let positionInBottomBar = bottomBar.positionInView(point: positionInCanvas)
        for cell in bottomBar.visibleCells {
            if cell.frame.contains(positionInBottomBar) {
                return bottomBar.indexPath(for: cell)!.row
            }
        }
        return nil
    }
    
}
