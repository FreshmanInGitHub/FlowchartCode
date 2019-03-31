//
//  DrawingController.swift
//  Drawing
//
//  Created by Young on 2018/12/15.
//  Copyright © 2018 Young. All rights reserved.
//

import UIKit

class DrawingController: UIViewController {
    var program = Program()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        canvas.scale = program.scale
        for block in program.blocks {
            canvas.shapeView.addSubview(Shape.generateShape(with: block))
        }
        let shapes = canvas.shapes
        for block in program.blocks {
            let index = program.blocks.firstIndex(of: block)!
            let shape = shapes[index]
            if let nextIndex = block.next {
                shape.nextShape = shapes[nextIndex]
            }
            if let nextIndexWhenFalse = block.nextWhenFalse, let diamond = shape as? Diamond {
                diamond.nextShapeWhenFalse = canvas.shapes[nextIndexWhenFalse]
            }
        }
        if let entrance = program.entrance {
            canvas.entrance.angle = entrance.angle
            canvas.entrance.shape = canvas.shapes[entrance.index]
        }
        canvas.moveToCenterOfShapes()
    }

    
    @IBOutlet var canvas: Canv!
    var formerPosition = CGPoint()
    
    @IBAction func longPressed(_ sender: UILongPressGestureRecognizer) {
        let position = sender.location(in: canvas)
        if let deleteLabel = canvas.bottomBar.backgroundView as? UILabel {
            deleteLabel.isHighlighted = canvas.bottomBar.frame.contains(position)
        }
        switch sender.state {
        case .began:
            if canvas.entrance.path.bounds.contains(position), let entrance = canvas.entrance {
                canvas.draggingView = entrance
            } else if let shape = canvas.source(at: position) ?? canvas.shape(at: position) {
                canvas.draggingView = shape
            } else if let line = canvas.line(positionInCanvas: position) {
                canvas.lines.remove(at: canvas.lines.firstIndex(of: line)!)
                canvas.draggingLine = line.new(point: position)
                canvas.bottomBar.state = .deleteLabel
            }
        case .changed:
            if let entrance = canvas.draggingView as? Entrans {
                entrance.shape = canvas.shape(at: position)
                UIView.animate(withDuration: 2, animations: {entrance.position = position})
            } else if let shape = canvas.draggingView as? Shape {
                shape.translate(with: position - formerPosition)
                canvas.resetLinesRelated(to: shape)
            } else if let line = canvas.draggingLine {
                canvas.draggingLine = line.new(point: position)
            } else {
                canvas.translate(with: position - formerPosition)
            }
        default:
            if canvas.draggingView != nil {
                if let shape = canvas.draggingView as? Shape, canvas.bottomBar.frame.contains(position) {
                    self.canvas.delete(shape: shape)
                }
                canvas.draggingView = nil
            } else if let line = canvas.draggingLine {
                if let target = canvas.shape(at: position), line.initiator.canConnect(to: target) {
                    line.initiator.connect(to: target, with: line.color)
                } else if canvas.bottomBar.frame.contains(position) {
                    line.initiator.deleteConnection(with: line.color)
                }
                canvas.draggingLine = nil
                canvas.bottomBar.state = .hidden
            }
        }
        formerPosition = position
    }
    
    @IBAction func panned(_ sender: UIPanGestureRecognizer) {
        let position = sender.location(in: canvas)
        switch sender.state {
        case .began:
            if let shape = canvas.shape(at: position), let line = shape.lineForPanning(to: position) {
                canvas.draggingLine = line
            }
        case .changed:
            if let line = canvas.draggingLine {
                canvas.draggingLine = line.new(point: position)
            } else {
                canvas.translate(with: position - formerPosition)
            }
        default:
            if let line = canvas.draggingLine {
                if let target = canvas.shape(at: position), line.initiator.canConnect(to: target) {
                    line.initiator.connect(to: target, with: line.color)
                }
                canvas.draggingLine = nil
            }
        }
        formerPosition = position
    }
    
    @IBAction func pinched(_ sender: UIPinchGestureRecognizer) {
        let newScale = sender.scale * canvas.scale
        if newScale < 0.4 {
            canvas.scale = 0.4
        } else if newScale > canvas.maxScale {
            canvas.scale = canvas.maxScale
        } else {
            canvas.scale = newScale
        }
        sender.scale = 1
    }
    
    @IBAction func tapped(_ sender: UITapGestureRecognizer) {
        let position = sender.location(in: canvas)
        if let shape = canvas.shape(at: position) {
            canvas.shapeView.bringSubviewToFront(shape)
            canvas.setLines()
        }
    }
    
    @IBAction func doubleTapped(_ sender: UITapGestureRecognizer) {
        let position = sender.location(in: canvas)
        if let shape = canvas.shape(at: position) {
            canvas.editingShape = shape
            navigationItem.rightBarButtonItem = shape is Rect ? editButtonItem : nil
            isEditing = false
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(quitEditingShape(_:)))
        } else {
            canvas.moveToCenterOfShapes()
        }
    }
    
    @IBAction func quitEditingShape(_ sender: UIBarButtonItem) {
        if let shape = canvas.editingShape, shape.canQuitEditing {
            canvas.editingShape = nil
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveProgram(_:)))
            navigationItem.leftBarButtonItem = navigationItem.backBarButtonItem
        }
    }
    
    @IBAction func saveProgram(_ sender: UIBarButtonItem) {
        program.set(scale: canvas.scale, shapes: canvas.shapes, entrance: canvas.entrance)
        DataBase.savePrograms()
    }
    
    
    @IBAction func longPressedInBottomBar(_ sender: UILongPressGestureRecognizer) {
        let position = sender.location(in: canvas)
        switch sender.state {
        case .began:
            if let label = canvas.instruction(at: position) {
                canvas.draggingView = label
                canvas.addSubview(label)
            }
        case .changed:
            if let label = canvas.draggingView as? UILabel {
                label.translate(with: position - formerPosition)
            }
        default:
            if let shape = canvas.editingShape, shape.path.contains(sender.location(in: shape)), let label = canvas.draggingView as? UILabel {
                //shape.append(text: label.text!)
            }
            canvas.draggingView?.removeFromSuperview()
            canvas.draggingView = nil
        }
        formerPosition = position
    }
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
     }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if let rect = canvas.editingShape as? Rect {
            rect.tableView.isEditing = !editing
        }
    }
    
}

