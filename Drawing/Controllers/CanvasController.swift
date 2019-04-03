//
//  CanvasController.swift
//  Drawing
//
//  Created by Young on 2019/3/13.
//  Copyright © 2019 Young. All rights reserved.
//

import UIKit

class CanvasController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    var canvas = Canvas()
    @IBOutlet weak var bottomBar: BottomBar!
    @IBOutlet weak var bottomBarFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var sourceView: SourceView!
    @IBOutlet weak var shapeForEditing: ShapeForEditing!
    
    var formerPosition = CGPoint()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        bottomBar.dataSource = self
        canvas.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPressedInCanvas(_:))))
        scrollView.addSubview(canvas)
        
        // Notifications
        let defaultCenter = NotificationCenter.default
        defaultCenter.addObserver(forName: .init(rawValue: "updateLinesForShape"), object: nil, queue: OperationQueue.main, using: didReceiveNotification(_:))
        defaultCenter.addObserver(forName: .init(rawValue: "redrawCanvas"), object: nil, queue: OperationQueue.main, using: didReceiveNotification(_:))
    }
    
    public func didReceiveNotification(_ notification: Notification) {
        switch notification.name {
        case .init(rawValue: "updateLinesForShape"):
            updateLines(for: notification.object as? Shape)
        case .init(rawValue: "redrawCanvas"):
            canvas.setNeedsDisplay()
        default:
            break
        }
    }
    
    func updateLines(for shape: Shape?) {
        for otherShape in canvas.shapes {
            otherShape.resetLine(otherShape.related(to: shape))
        }
    }
    
    func keepInBounds(_ shape: Shape) {
        var origin = shape.frame.origin
        if canvas.entrance.shape == shape {
            let otherOrigin = canvas.entrancePath.bounds.origin
            origin = CGPoint(x: min(origin.x, otherOrigin.x), y: min(origin.y, otherOrigin.y))
        }
        let translation: CGPoint
        switch (origin.x < 0, origin.y < 0) {
        case (true, true): translation = -origin
        case (true, false): translation = CGPoint(x: -origin.x, y: 0)
        case (false, true): translation = CGPoint(x: 0, y: -origin.y)
        default: translation = CGPoint()
        }
        UIView.animate(withDuration: 0.1) {
            shape.translate(with: translation)
        }
        if canvas.entrance.shape == shape {
            canvas.entrancePath.translate(with: translation)
        }
    }
    
    
    @IBAction func dragShape(_ sender: UILongPressGestureRecognizer) {
        let position = sender.location(in: canvas)
        bottomBar.deleteLabel.isHighlighted = bottomBar.frame.contains(sender.location(in: view))
        let shape = sender.view as! Shape
        switch sender.state {
        case .began:
            canvas.bringSubviewToFront(shape)
            shape.isHighlighted = true
            bottomBar.state = .deleteLabel
        case .changed:
            let translation = position - formerPosition
            shape.translate(with: translation)
            if canvas.entrance.shape == shape {
                canvas.entrancePath.translate(with: translation)
            }
        default:
            shape.isHighlighted = false
            if bottomBar.frame.contains(sender.location(in: view)) {
                delete(shape)
            } else {
                keepInBounds(shape)
                canvas.updateSizes()
            }
            bottomBar.state = .hidden
        }
        formerPosition = position
    }
    
    @IBAction func createLine(_ sender: UIPanGestureRecognizer) {
        let position = sender.location(in: canvas)
        let shape = sender.view as! Shape
        switch sender.state {
        case .began: canvas.draggingLine = shape.lineForPanning(to: position)
        case .changed: let _ = tryMovingLine(to: position)
        default: let _ = tryDroppingLine(at: position)
        }
    }
    
    
    func tryDraggingLine(at point: CGPoint) -> Bool {
        for shape in canvas.shapes.reversed() {
            if let line = shape.line, line.contains(point) {
                canvas.draggingLine = line.new(point: point)
                shape.line = nil
                return true
            }
            if let diamond = shape as? Diamond, let line = diamond.lineWhenFalse, line.contains(point) {
                canvas.draggingLine = line.new(point: point)
                diamond.lineWhenFalse = nil
                return true
            }
        }
        return false
    }
    
    func tryMovingLine(to point: CGPoint) -> Bool {
        if let line = canvas.draggingLine {
            canvas.draggingLine = line.new(point: point)
            return true
        }
        return false
    }
    
    func tryDroppingLine(at position: CGPoint) -> Bool {
        if let line = canvas.draggingLine {
            canvas.draggingLine = nil
            if let shape = shape(at: position), line.initiator.canConnect(to: shape) {
                line.initiator.connect(to: shape, with: line.color)
                return true
            }
        }
        return false
    }
    
    func shape(at point: CGPoint) -> Shape? {
        for shape in canvas.shapes {
            if shape.contains(shape.positionInView(point: point)) {
                return shape
            }
        }
        return nil
    }
    
    @IBAction func bringShapeToFront(_ sender: UITapGestureRecognizer) {
        if let shape = sender.view as? Shape {
            canvas.bringSubviewToFront(shape)
            canvas.setNeedsDisplay()
        }
    }
    
    @IBAction func doubleTappedInShape(_ sender: UITapGestureRecognizer) {
        if let shape = sender.view as? Shape {
            shapeForEditing.shape = shape
            bottomBar.state = .editing
            navigationItem.rightBarButtonItem = shape is Rect ? editButtonItem : nil
            isEditing = false
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(quitEditingShape(_:)))
        }
    }
    
    @IBAction func longPressedInCanvas(_ sender: UILongPressGestureRecognizer) {
        let point = sender.location(in: canvas)
        switch sender.state {
        case .began:
            if tryDraggingLine(at: point) {
                bottomBar.state = .deleteLabel
            } else if canvas.entrancePath.contains(point) {
                canvas.entrance.isHighlighted = true
            } else {
                sourceView.frame.origin = sender.location(in: view) - CGPoint(x: sourceView.frame.width/2, y: sourceView.frame.height*3/4)
                sourceView.isHidden = false
                formerPosition = sender.location(in: canvas)
            }
        case .changed:
            if tryMovingLine(to: point) {
                bottomBar.deleteLabel.isHighlighted = bottomBar.bounds.contains(sender.location(in: bottomBar))
            } else if canvas.entrance.isHighlighted {
                canvas.entrance = (point, self.shape(at: point), true)
            } else if !sourceView.isHidden {
                sourceView.selectePath(sender.location(in: sourceView))
            }
        default:
            if let line = canvas.draggingLine {
                if bottomBar.bounds.contains(sender.location(in: bottomBar)) {
                    line.initiator.deleteConnection(with: line.color)
                    canvas.draggingLine = nil
                } else if !tryDroppingLine(at: point) {
                    line.initiator.resetLine(true)
                }
                bottomBar.state = .hidden
            } else if canvas.entrance.isHighlighted {
                canvas.entrance.isHighlighted = false
                //entrance.keepInFrame()
                canvas.updateSizes()
            } else if !sourceView.isHidden {
                sourceView.isHidden = true
                if let index = sourceView.selectedPathIndex {
                    let shape = generateShape(with: index)
                    canvas.addSubview(shape)
                    keepInBounds(shape)
                }
            }
        }
    }
    
    
    @IBAction func quitEditingShape(_ sender: UIBarButtonItem) {
        if shapeForEditing.shape.canQuitEditing {
            shapeForEditing.isHidden = true
            shapeForEditing.shape.tableView.reloadData()
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveProgram(_:)))
            navigationItem.leftBarButtonItem = navigationItem.backBarButtonItem
            bottomBar.state = .hidden
        }
    }
    
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        shapeForEditing.tableView.setEditing(editing, animated: true)
        shapeForEditing.tableView.reloadData()
    }
    
    var label = UILabel()
    @IBAction func dragLabel(_ sender: UILongPressGestureRecognizer) {
        if let cell = sender.view as? CollectionViewCellWithLabel {
            let position = sender.location(in: view)
            switch sender.state {
            case .began:
                label.textColor = .lightGray
                label.font = cell.label.font
                label.text = cell.label.text
                let size = label.intrinsicContentSize
                label.frame = CGRect(origin: position-CGPoint(x: size.width*3/4, y: size.height), size: size)
                view.addSubview(label)
            case .changed:
                label.translate(with: position - formerPosition)
            default:
                label.removeFromSuperview()
                if shapeForEditing.path.contains(sender.location(in: shapeForEditing)) {
                    shapeForEditing.append(label.text!)
                }
            }
            formerPosition = position
        }
    }
    
    private func generateShape(with sourceIndex: Int) -> Shape {
        let shape: Shape
        switch sourceIndex {
        case 1: shape = Diamond(center: formerPosition)
        case 2: shape = Oval(center: formerPosition)
        default: shape = Rect(center: formerPosition)
        }
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(createLine(_:)))
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(dragShape(_:)))
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(bringShapeToFront(_:)))
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTappedInShape(_:)))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        doubleTapGestureRecognizer.delegate = self
        panGestureRecognizer.delegate = self
        longPressGestureRecognizer.delegate = self
        tapGestureRecognizer.delegate = self
        shape.addGestureRecognizer(panGestureRecognizer)
        shape.addGestureRecognizer(longPressGestureRecognizer)
        shape.addGestureRecognizer(tapGestureRecognizer)
        shape.addGestureRecognizer(doubleTapGestureRecognizer)
        return shape
    }
    
    private func delete(_ shape: Shape) {
        shape.removeFromSuperview()
        for otherShape in canvas.shapes {
            otherShape.deleteConnection(to: shape)
        }
        if canvas.entrance.shape == shape {
            canvas.entrance = (canvas.entrancePath.end, nil, false)
        }
    }
    
    @IBAction func saveProgram(_ sender: UIBarButtonItem) {
        //program.set(scale: canvas.scale, shapes: canvas.shapes, entrance: canvas.entrance)
        //        DataBase.savePrograms()
    }
    
    
    
}

extension CanvasController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        bottomBarFlowLayout.itemSize = CGSize(width: 55, height: 55)
        switch bottomBar.state {
        case .editing:
            if shapeForEditing.shape is Oval {
                bottomBarFlowLayout.itemSize = CGSize(width: 65, height: 55)
                return 3
            }
            return 5
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell
        switch shapeForEditing.shape {
        case is Diamond: cell = bottomBar.labelCellForDiamond(forItemAt: indexPath)
        case is Oval: cell = bottomBar.labelCellForOval(forItemAt: indexPath)
        default: cell = bottomBar.labelCellForRect(forItemAt: indexPath)
        }
        cell.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(dragLabel(_:))))
        return cell
    }
}

extension CanvasController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return canvas
    }
}

extension CanvasController: UIGestureRecognizerDelegate {
    
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
//        if let shape = gestureRecognizer.view as? Shape, !shape.contains(touch.location(in: shape)) {
//            return false
//        }
//        if let entrance = gestureRecognizer.view as? EntranceView {
//            if !entrance.contains(touch.location(in: entrance)) {
//                return false
//            } else {
//                if let shape = entrance.shape, shape.contains(touch.location(in: shape)) {
//                    return false
//                }
//            }
//        }
//        return true
//    }
    
}


