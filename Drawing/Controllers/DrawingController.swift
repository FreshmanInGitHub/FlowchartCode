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
    
    @IBOutlet var pinchGestureRecognizer: UIPinchGestureRecognizer!
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet var longPressGestureRecognizer: UILongPressGestureRecognizer!
    @IBOutlet var doubleTapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet var longPressGestureRecognizerInTableView: UILongPressGestureRecognizer!
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
    var enableGestureRecognizers = true {
        didSet {
            pinchGestureRecognizer.isEnabled = enableGestureRecognizers
            panGestureRecognizer.isEnabled = enableGestureRecognizers
            longPressGestureRecognizer.isEnabled = enableGestureRecognizers
            doubleTapGestureRecognizer.isEnabled = enableGestureRecognizers
            tapGestureRecognizer.isEnabled = enableGestureRecognizers
            longPressGestureRecognizerInTableView.isEnabled = !enableGestureRecognizers
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enableGestureRecognizers = true
        canvas.scale = program.scale
        for block in program.blocks {
            canvas.shapeView.addSubview(Shape.generateShape(with: block))
        }
        for block in program.blocks {
            let index = program.blocks.firstIndex(of: block)!
            let shape = canvas.shapes[index]
            if let nextIndex = block.next {
                shape.nextShape = canvas.shapes[nextIndex]
            }
            if let nextIndexWhenFalse = block.nextWhenFalse, let diamond = shape as? Diamond {
                diamond.nextShapeWhenFalse = canvas.shapes[nextIndexWhenFalse]
            }
        }
        if let entrance = program.entrance {
            canvas.entrance.angle = entrance.angle
            canvas.entrance.shape = canvas.shapes[entrance.index]
        }
    }

    
    @IBOutlet var canvas: Canvas!
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
                if entrance.shape != nil {
                    entrance.shape = nil
                    entrance.position = position
                }
            } else if let shape = canvas.source(at: position) ?? canvas.shape(at: position) {
                canvas.draggingView = shape
            } else if let line = canvas.line(at: position) {
                canvas.lines.remove(at: canvas.lines.firstIndex(of: line)!)
                canvas.draggingLine = line.newLine(with: position)
                canvas.bottomBar.state = .deleteLabel
            }
        case .changed:
            if let entrance = canvas.draggingView as? Entrance {
                entrance.translate(with: position - formerPosition)
                if let shape = canvas.shape(at: position) {
                    entrance.shape = shape
                    entrance.angle = Line.angle(between: position, and: canvas.position(for: shape.center))
                } else {
                    entrance.shape = nil
                    entrance.angle = 0
                }
            } else if let shape = canvas.draggingView as? Shape {
                shape.translate(with: position - formerPosition)
            } else if let line = canvas.draggingLine {
                canvas.draggingLine = line.newLine(with: position)
            } else {
                canvas.translate(with: position - formerPosition)
            }
        default:
            if canvas.draggingView != nil {
                if let shape = canvas.draggingView as? Shape, canvas.bottomBar.frame.contains(position) {
                    canvas.delete(shape: shape)
                }
                canvas.draggingView = nil
            } else if let line = canvas.draggingLine {
                if let target = canvas.shape(at: position), line.initiator.canConnect(to: target) {
                    if line.color == .red, let diamond = line.initiator as? Diamond {
                        diamond.nextShapeWhenFalse = target
                    } else {
                        line.initiator.nextShape = target
                    }
                } else if canvas.bottomBar.frame.contains(position) {
                    if line.color == .red, let diamond = line.initiator as? Diamond {
                        diamond.nextShapeWhenFalse = nil
                    } else {
                        line.initiator.nextShape = nil
                    }
                }
                canvas.draggingLine = nil
                canvas.bottomBar.state = .sources
            }
        }
        formerPosition = position
    }
    
    @IBAction func panned(_ sender: UIPanGestureRecognizer) {
        let position = sender.location(in: canvas)
        if let deleteLabel = canvas.bottomBar.backgroundView as? UILabel {
            deleteLabel.isHighlighted = canvas.bottomBar.frame.contains(position)
        }
        switch sender.state {
        case .began:
            if let shape = canvas.shape(at: position) {
                if shape.nextShape == nil {
                    canvas.draggingLine = Line(initiator: shape, temporaryTarget: position, color: shape is Diamond ? .green : .black)
                } else if let diamond = shape as? Diamond, diamond.nextShapeWhenFalse == nil {
                    canvas.draggingLine = Line(initiator: shape, temporaryTarget: position, color: .red)
                }
            }
        case .changed:
            if let line = canvas.draggingLine {
                canvas.draggingLine = line.newLine(with: canvas.positionInShapeView(with: position))
            } else {
                canvas.translate(with: position - formerPosition)
            }
        default:
            if let line = canvas.draggingLine {
                if let target = canvas.shape(at: position), line.initiator.canConnect(to: target) {
                    if line.color == .red, let diamond = line.initiator as? Diamond {
                        diamond.nextShapeWhenFalse = target
                    } else {
                        line.initiator.nextShape = target
                    }
                }
                canvas.draggingLine = nil
            }
        }
        formerPosition = position
    }
    
    @IBAction func pinched(_ sender: UIPinchGestureRecognizer) {
        let newScale = sender.scale * canvas.scale
        if newScale < 0.3 {
            canvas.scale = 0.3
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
            canvas.resetLines()
        }
    }
    
    @IBAction func doubleTapped(_ sender: UITapGestureRecognizer) {
        let position = sender.location(in: canvas)
        if let shape = canvas.shape(at: position) {
            canvas.selectedShape = shape
            enableGestureRecognizers = false
            navigationItem.rightBarButtonItem = shape is Rect ? editButtonItem : nil
            isEditing = false
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(backButtonTapped(_:)))
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        if let shape = canvas.selectedShape, shape.canQuitEditing {
            canvas.selectedShape = nil
            enableGestureRecognizers = true
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
                label.frame = label.frame.applying(CGAffineTransform(translation: position - formerPosition))
            }
        default:
            if let shape = canvas.selectedShape, shape.path.contains(shape.positionInView(point: position)), let label = canvas.draggingView as? UILabel {
                shape.append(text: label.text!)
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
        if let rect = canvas.selectedShape as? Rect {
            rect.tableView.isEditing = !editing
            rect.editing = editing
        }
    }
    
}

