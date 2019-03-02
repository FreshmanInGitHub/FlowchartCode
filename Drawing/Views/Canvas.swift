//
//  Canvas.swift
//  Drawing
//
//  Created by Young on 2018/12/15.
//  Copyright © 2018 Young. All rights reserved.
//

import UIKit

class Canvas: UIView {
    
    override func awakeFromNib() {
        bottomBar.dataSource = self
        shapeView.canvas = self
    }
    
    @IBOutlet weak var shapeView: ShapeView!
    @IBOutlet weak var bottomBar: BottomBar!
    @IBOutlet weak var bottomBarFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var entrance: Entrance!
    
    var shapes: [Shape] {
        if let shapes = shapeView?.subviews as? [Shape] {
            return shapes
        }
        return [Shape]()
    }
    
    func positionInShapeView(with positionInCanvas: CGPoint) -> CGPoint {
        return shapeView?.positionInView(point: positionInCanvas) ?? positionInCanvas
    }
    
    func position(for positionInShapeView: CGPoint) -> CGPoint {
        return shapeView.positionInSuperview(point: positionInShapeView)
    }
    
    var draggingView: UIView? {
        didSet {
            if draggingView is Entrance || oldValue is Entrance {
                entrance.isHighlighted = !entrance.isHighlighted
            } else if let shape = draggingView as? Shape {
                shape.isHighlighted = true
                if shape != entrance {
                    shapeView.addSubview(shape)
                    bottomBar.state = .deleteLabel
                }
                resetLines()
            } else if let shape = oldValue as? Shape {
                shape.isHighlighted = false
                bottomBar.state = .sources
            }
        }
    }
    
    var selectedShape: Shape? {
        didSet {
            if let shape = selectedShape {
                shape.formerCenter = shape.center
                bottomBar.state = .editing
                shapeView.bringSubviewToFront(shape)
            } else if let shape = oldValue {
                shape.formerCenter = nil
                bottomBar.state = .sources
            }
            exchangeSubview(at: 0, withSubviewAt: 1)
        }
    }
    
    var draggingLine: Line? {
        didSet {
            if draggingLine == nil, let shape = oldValue?.initiator {
                shape.isHighlighted = false
                resetLines()
            } else {
                if let shape = draggingLine?.initiator, oldValue == nil {
                    shapeView.bringSubviewToFront(shape)
                    shape.isHighlighted = true
                }
                shapeView.setNeedsDisplay()
            }
        }
    }
    
    var lines = [Line]()
    
    var maxScale: CGFloat {
        return bounds.width/130
    }
    
    var scale: CGFloat = 1.0 {
        didSet {
            let ratio = scale/oldValue
            let translation = CGPoint(x: bounds.midX*(1-ratio), y: bounds.midY*(1-ratio))
            shapeView.scale(by: ratio)
            shapeView.translate(with: translation)
            entrance.scale(by: ratio)
            entrance.translate(with: translation)
        }
    }
    
    
    override func translate(with translation: CGPoint) {
        shapeView.translate(with: translation)
        entrance.translate(with: translation)
    }
    
    func resetLines() {
        lines = [Line]()
        for shape in shapes {
            if let line = shape.line {
                lines.append(line)
            }
            if let diamond = shape as? Diamond, let line = diamond.lineWhenFalse {
                lines.append(line)
            }
        }
        entrance.setNeedsDisplay()
        shapeView.setNeedsDisplay()
    }
    
    func line(at positionInCanvas: CGPoint) -> Line? {
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
            if shape.contains(positionInSuperview: positionInShapeView) {
                return shape
            }
        }
        return nil
    }
    
    func source(at positionInCanvas: CGPoint) -> Shape? {
        let positionInShapeView = self.positionInShapeView(with: positionInCanvas)
        switch cell(at: positionInCanvas) {
        case 0: return Rect(center: positionInShapeView, scale: scale)
        case 1: return Diamond(center: positionInShapeView, scale: scale)
        case 2: return Oval(center: positionInShapeView, scale: scale)
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
    
}

extension Canvas: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        bottomBarFlowLayout.itemSize = CGSize(width: 55, height: 55)
        switch bottomBar.state {
        case .sources: return 3
        case .editing:
            if selectedShape is Oval {
                bottomBarFlowLayout.itemSize = CGSize(width: 65, height: 55)
                return 3
            }
            return 5
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch bottomBar.state {
        case .editing:
            switch selectedShape {
            case is Diamond: return bottomBar.labelCellForDiamond(forItemAt: indexPath)
            case is Oval: return bottomBar.labelCellForOval(forItemAt: indexPath)
            default: return bottomBar.labelCellForRect(forItemAt: indexPath)
            }
        default: return bottomBar.sourceCell(forItemAt: indexPath)
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
