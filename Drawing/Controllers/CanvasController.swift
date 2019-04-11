//
//  CanvasController.swift
//  Drawing
//
//  Created by Young on 2019/3/13.
//  Copyright © 2019 Young. All rights reserved.
//

import UIKit

class CanvasController: UIViewController {
    @IBOutlet weak var rectSource: Source!
    @IBOutlet weak var diamondSource: Source!
    @IBOutlet weak var ovalSource: Source!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var deleteLabel: UILabel!
    var formerPosition = CGPoint()
    var canvas = Canvas()
    var program = Program()
    var newShape: Shape?
    
    // Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCanvas()
        
        scrollView.delegate = self
        canvas.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPressedInCanvas(_:))))
        scrollView.addSubview(canvas)
        
        rectSource.style = .rect
        diamondSource.style = .diamond
        ovalSource.style = .oval
        
        rectSource.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPressedInSources(_:))))
        diamondSource.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPressedInSources(_:))))
        ovalSource.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPressedInSources(_:))))
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let controller = segue.destination as? EditingViewController, let shape = sender as? Shape {
            controller.shape = shape
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        setProgram()
        DataBase.savePrograms()
        super.viewWillDisappear(animated)
    }
    
    func setCanvas() {
        let blocks = program.blocks
        let entrance = program.entrance
        let links = blocks.links({$0.next})
        let linksWhenFalse = blocks.links({$0.nextWhenFalse})
        
        var shapes = [Shape]()
        for block in blocks {
            shapes.append(generateShape(with: block))
        }
        let _ = shapes.setNext(links: links, {$0.nextShape = $1})
        let _ = shapes.setNext(links: linksWhenFalse) { shape, nextShapeWhenFalse in
            if let diamond = shape as? Diamond {
                diamond.nextShapeWhenFalse = nextShapeWhenFalse
            }
        }
        for shape in shapes {
            shape.resetLine(true)
            canvas.addSubview(shape)
        }
        
        if let index = entrance.index {
            canvas.entrance = (entrance.point, shapes[index], false)
        } else {
            canvas.entrance = (entrance.point, nil, false)
        }
        
        canvas.setNeedsDisplay()
    }
    
    func setProgram() {
        let shapes = canvas.shapes
        let entrance = canvas.entrance
        let links = shapes.links({$0.nextShape})
        let linksWhenFalse = shapes.links { (shape) -> Shape? in
            if let diamond = shape as? Diamond {
                return diamond.nextShapeWhenFalse
            }
            return nil
        }
        
        var blocks = [Block]()
        shapes.forEach({ blocks.append(Block(shape: $0)) })
        let _ = blocks.setNext(links: links, {$0.next = $1})
        let _ = blocks.setNext(links: linksWhenFalse, {$0.nextWhenFalse = $1})
        program.blocks = blocks
        
        if let shape = entrance.shape, let index = shapes.firstIndex(of: shape) {
            program.entrance = (entrance.point, index)
        } else {
            program.entrance = (entrance.point, nil)
        }
    }
    
    func hideSources(_ shouldHideSources: Bool) {
        rectSource.isHidden = shouldHideSources
        diamondSource.isHidden = shouldHideSources
        ovalSource.isHidden = shouldHideSources
    }
    
    func updateLines(for shape: Shape?) {
        for otherShape in canvas.shapes {
            otherShape.resetLine(otherShape.related(to: shape))
        }
        canvas.setNeedsDisplay()
    }
    
    func keepInBounds(_ shape: Shape) {
        var origin = shape.frame.origin
        if canvas.entrance.shape == shape {
            let otherOrigin = canvas.entrancePath.bounds.origin
            origin = CGPoint(x: min(origin.x, otherOrigin.x), y: min(origin.y, otherOrigin.y))
        }
        UIView.animate(withDuration: 0.1) {
            self.translate(shape, with: self.translationForKeepingInBounds(with: origin))
        }
    }
    
    private func translate(_ shape: Shape, with translation: CGPoint) {
        shape.translate(with: translation)
        self.updateLines(for: shape)
        if canvas.entrance.shape == shape {
            translateEntrance(with: translation)
        }
    }
    
    private func translateEntrance(with translation: CGPoint) {
        canvas.entrance = (canvas.entrance.point+translation, canvas.entrance.shape, canvas.entrance.isHighlighted)
    }
    
    func keepEntranceInBounds() {
        if let shape = canvas.entrance.shape {
            keepInBounds(shape)
        } else {
            translateEntrance(with: translationForKeepingInBounds(with: canvas.entrancePath.bounds.origin))
        }
    }
    
    private func translationForKeepingInBounds(with origin: CGPoint) -> CGPoint {
        switch (origin.x < 0, origin.y < 0) {
        case (true, true): return -origin
        case (true, false): return CGPoint(x: -origin.x, y: 0)
        case (false, true): return CGPoint(x: 0, y: -origin.y)
        default: return CGPoint()
        }
    }
    
    func tryDraggingLine(at point: CGPoint) -> Bool {
        for shape in canvas.shapes.reversed() {
            if let line = shape.line, line.contains(point) {
                shape.line = nil
                canvas.draggingLine = line.new(point: point)
                return true
            } else if let diamond = shape as? Diamond, let line = diamond.lineWhenFalse, line.contains(point) {
                diamond.lineWhenFalse = nil
                canvas.draggingLine = line.new(point: point)
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
    
    private func generateShape(with sourceIndex: Int) -> Shape {
        let shape: Shape
        switch sourceIndex {
        case 1: shape = Diamond(center: formerPosition)
        case 2: shape = Oval(center: formerPosition)
        default: shape = Rect(center: formerPosition)
        }
        addGestureRecognizers(for: shape)
        return shape
    }
    
    private func generateShape(with block: Block) -> Shape {
        let shape: Shape
        switch block.style {
        case .rect: shape = Rect(block: block)
        case .diamond: shape = Diamond(block: block)
        case .oval: shape = Oval(block: block)
        }
        addGestureRecognizers(for: shape)
        return shape
    }
    
    private func addGestureRecognizers(for shape: Shape) {
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
    }
    
    private func delete(_ shape: Shape) {
        shape.removeFromSuperview()
        canvas.shapes.forEach({ $0.deleteConnection(to: shape) })
        if canvas.entrance.shape == shape {
            canvas.entrance = (canvas.entrance.point, nil, false)
            keepEntranceInBounds()
        }
    }
    
// IBActions
    
    @IBAction func dragShape(_ sender: UILongPressGestureRecognizer) {
        let position = sender.location(in: canvas)
        deleteLabel.isHighlighted = deleteLabel.bounds.contains(sender.location(in: deleteLabel))
        let shape = sender.view as! Shape
        switch sender.state {
        case .began:
            canvas.bringSubviewToFront(shape)
            shape.isHighlighted = true
            deleteLabel.isHidden = false
            hideSources(true)
        case .changed:
            translate(shape, with: position - formerPosition)
        default:
            shape.isHighlighted = false
            if deleteLabel.bounds.contains(sender.location(in: deleteLabel)) {
                delete(shape)
            } else {
                keepInBounds(shape)
                canvas.updateSizes()
            }
            deleteLabel.isHidden = true
            hideSources(false)
        }
        formerPosition = position
        canvas.setNeedsDisplay()
    }
    
    @IBAction func createLine(_ sender: UIPanGestureRecognizer) {
        let position = sender.location(in: canvas)
        let shape = sender.view as! Shape
        switch sender.state {
        case .began:
            canvas.draggingLine = shape.lineForPanning(to: position)
            hideSources(true)
        case .changed: let _ = tryMovingLine(to: position)
        default:
            let _ = tryDroppingLine(at: position)
            hideSources(false)
        }
        canvas.setNeedsDisplay()
    }
    
    @IBAction func bringShapeToFront(_ sender: UITapGestureRecognizer) {
        if let shape = sender.view as? Shape {
            canvas.bringSubviewToFront(shape)
            canvas.setNeedsDisplay()
        }
    }
    
    @IBAction func doubleTappedInShape(_ sender: UITapGestureRecognizer) {
        if let shape = sender.view as? Shape {
            self.performSegue(withIdentifier: "editShape", sender: shape)
        }
    }
    
    @IBAction func longPressedInCanvas(_ sender: UILongPressGestureRecognizer) {
        let point = sender.location(in: canvas)
        deleteLabel.isHighlighted = deleteLabel.bounds.contains(sender.location(in: deleteLabel))
        switch sender.state {
        case .began:
            if tryDraggingLine(at: point) {
                deleteLabel.isHidden = false
                hideSources(true)
            } else if canvas.entrancePath.contains(point) {
                canvas.entrance.isHighlighted = true
                hideSources(true)
            }
        case .changed:
            if tryMovingLine(to: point) {
                // Do nothing.
            } else if canvas.entrance.isHighlighted {
                // Shape that Entrance is pointing to could change, can't use translate here!!!
                canvas.entrance = (point, self.shape(at: point), true)
            }
        default:
            if let line = canvas.draggingLine {
                if deleteLabel.bounds.contains(sender.location(in: deleteLabel)) {
                    line.initiator.deleteConnection(with: line.color)
                    canvas.draggingLine = nil
                } else if !tryDroppingLine(at: point) {
                    line.initiator.resetLine(true)
                }
                deleteLabel.isHidden = true
            } else if canvas.entrance.isHighlighted {
                canvas.entrance.isHighlighted = false
                keepEntranceInBounds()
                canvas.updateSizes()
            }
            hideSources(false)
        }
        canvas.setNeedsDisplay()
    }
    
    @IBAction func longPressedInSources(_ sender: UILongPressGestureRecognizer) {
        let point = sender.location(in: canvas)
        deleteLabel.isHighlighted = deleteLabel.bounds.contains(sender.location(in: deleteLabel))
        switch sender.state {
        case .began:
            if let source = sender.view as? Source {
                switch source.style {
                case .rect: newShape = Rect(center: point)
                case .diamond: newShape = Diamond(center: point)
                case .oval: newShape = Oval(center: point)
                }
                addGestureRecognizers(for: newShape!)
                canvas.addSubview(newShape!)
                hideSources(true)
                deleteLabel.isHidden = false
            }
        case .changed:
            newShape?.translate(with: point - formerPosition)
        default:
            if deleteLabel.bounds.contains(sender.location(in: deleteLabel)) {
                newShape?.removeFromSuperview()
            }
            newShape = nil
            hideSources(false)
            deleteLabel.isHidden = true
        }
        formerPosition = point
    }
    
    
}

extension CanvasController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return canvas
    }
}

extension CanvasController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let shape = gestureRecognizer.view as? Shape {
            return shape.contains(gestureRecognizer.location(in: shape))
        }
        return true
    }
    
}


