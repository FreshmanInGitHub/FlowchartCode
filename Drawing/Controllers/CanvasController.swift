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
    lazy var entrance = canvas.entrance
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
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(dragEntrance(_:)))
        gestureRecognizer.delegate = self
        entrance.addGestureRecognizer(gestureRecognizer)
        entrance.canvas = canvas
    }
    
    @IBAction func dragShape(_ sender: UILongPressGestureRecognizer) {
        let position = sender.location(in: canvas)
        bottomBar.deleteLabel.isHighlighted = bottomBar.frame.contains(sender.location(in: view))
        let shape = sender.view as! Shape
        switch sender.state {
        case .began:
            canvas.bringSubviewToFront(shape)
            canvas.setLines()
            shape.isHighlighted = true
            bottomBar.state = .deleteLabel
        case .changed:
            let translation = position - formerPosition
            shape.translate(with: translation)
            if entrance.shape == shape {
                entrance.translate(with: translation)
            }
            canvas.resetLines(relatedTo: shape)
        default:
            shape.isHighlighted = false
            if bottomBar.frame.contains(sender.location(in: view)) {
                shape.removeFromSuperview()
                for otherShape in canvas.shapes {
                    otherShape.deleteConnection(to: shape)
                }
                canvas.setLines()
            } else {
                shape.keepInFrame()
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
        case .began:
            if let line = shape.lineForPanning(to: position) {
                canvas.draggingLine = line
            }
        case .changed: let _ = canvas.tryMovingLine(to: position)
        default: let _ = canvas.tryDroppingLine(at: position)
        }
    }
    
    @IBAction func bringShapeToFront(_ sender: UITapGestureRecognizer) {
        if let shape = sender.view as? Shape {
            canvas.bringSubviewToFront(shape)
            canvas.setLines()
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
        let position = sender.location(in: canvas)
        switch sender.state {
        case .began:
            if canvas.tryDraggingLine(at: position) {
                bottomBar.state = .deleteLabel
            } else {
                sourceView.frame.origin = sender.location(in: view) - CGPoint(x: sourceView.frame.width/2, y: sourceView.frame.height*3/4)
                sourceView.isHidden = false
                formerPosition = sender.location(in: canvas)
            }
        case .changed:
            if canvas.tryMovingLine(to: position) {
                bottomBar.deleteLabel.isHighlighted = bottomBar.bounds.contains(sender.location(in: bottomBar))
            } else {
                sourceView.selectePath(sender.location(in: sourceView))
            }
        default:
            if let line = canvas.draggingLine {
                if !canvas.tryDroppingLine(at: position), bottomBar.bounds.contains(sender.location(in: bottomBar)) {
                    line.initiator.deleteConnection(with: line.color)
                    canvas.draggingLine = nil
                }
                canvas.setLines()
                bottomBar.state = .hidden
            } else {
                sourceView.isHidden = true
                if let index = sourceView.selectedPathIndex {
                    let shape = generateShape(with: index)
                    canvas.addSubview(shape)
                    shape.keepInFrame()
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
    
//    @IBAction func saveProgram(_ sender: UIBarButtonItem) {
//        //program.set(scale: canvas.scale, shapes: canvas.shapes, entrance: canvas.entrance)
//        DataBase.savePrograms()
//    }
    
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
    
    @IBAction func saveProgram(_ sender: UIBarButtonItem) {
        
    }
    
    @IBAction func dragEntrance(_ sender: UILongPressGestureRecognizer) {
        let position = sender.location(in: canvas)
        switch sender.state {
        case .began:
            entrance.isHighlighted = true
            UIView.animate(withDuration: 0.25, animations: {self.entrance.set(point: position, shape: self.canvas.shape(at: position))})
        case .changed:
            entrance.set(point: position, shape: canvas.shape(at: position))
        default:
            entrance.isHighlighted = false
            entrance.keepInFrame()
            canvas.updateSizes()
        }
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
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive press: UIPress) -> Bool {
        if let view = gestureRecognizer.view as? Customized, view.contains(gestureRecognizer.location(in: gestureRecognizer.view)) {
            if view is EntranceView, let shape = entrance.shape, shape.contains(gestureRecognizer.location(in: shape)) {
                return false
            }
            return true
        }
        return false
    }
}


