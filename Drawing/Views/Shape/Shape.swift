//
//  Shape.swift
//  Drawing
//
//  Created by Young on 2018/12/15.
//  Copyright © 2018 Young. All rights reserved.
//

import UIKit

class Shape: UIView {
    
    static func generateShape(with block: Block) -> Shape {
        switch block.type {
        case .diamond: return Diamond(block: block)
        case .oval: return Oval(block: block)
        default: return Rect(block: block)
        }
    }
    
    var nextShape: Shape? {
        didSet {
            if let canvas = superview?.superview as? Canvas {
                canvas.resetLines()
            }
        }
    }
    
    var canvas: Canvas? {
        return superview?.superview as? Canvas
    }
    var instructions = [Instruction]()
    
    var formerCenter: CGPoint? {
        didSet {
            if let canvas = canvas {
                if formerCenter != nil, oldValue == nil {
                    let translation = CGPoint(x: canvas.center.x-center.x, y: canvas.center.y-center.y)
                    translate(with: translation)
                    scale(by: canvas.maxScale/canvas.scale)
                } else if formerCenter == nil, let center = oldValue {
                    scale(by: canvas.scale/canvas.maxScale)
                    translate(with: CGPoint(x: center.x-self.center.x, y: center.y-self.center.y))
                }
            }
        }
    }
    
    var tableView = UITableView()
    
    override func didMoveToWindow() {
        backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        tableView.separatorInset = .zero
        tableView.isScrollEnabled = false
        tableView.backgroundColor = UIColor.clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = false
        tableView.register(InstructionCell.classForCoder(), forCellReuseIdentifier: "InstructionCell")
        tableView.register(SingleTextFieldCell.classForCoder(), forCellReuseIdentifier: "SingleTextFieldCell")
        tableView.register(DoubleTextFieldCell.classForCoder(), forCellReuseIdentifier: "DoubleTextFieldCell")
        tableView.register(TrippleTextFieldCell.classForCoder(), forCellReuseIdentifier: "TrippleTextFieldCell")
        addSubview(tableView)
    }
    
    override var frame: CGRect {
        didSet {
            tableView.frame = CGRect(x: bounds.minX+bounds.width*0.1, y: bounds.minY+bounds.height*0.4, width: bounds.width*0.8, height: bounds.height*0.2)
            tableView.rowHeight = tableView.bounds.height
            tableView.reloadData()
            setNeedsDisplay()
            canvas?.resetLines()
        }
    }
    
    func deleteConnection(to shape: Shape) {
        if nextShape == shape { nextShape = nil }
    }
    
    var canQuitEditing: Bool {
        if let cells = tableView.visibleCells as? [InstructionCell] {
            for cell in cells {
                if !cell.isFinished { return false }
            }
        }
        return true
    }
    
    func canConnect(to target: Shape) -> Bool {
        return target != self && target != nextShape
    }
    
    func entry(for positionInCanvas: CGPoint) -> CGPoint? {
        return path.contains(positionInView(point: positionInCanvas)) ? nil : extendedEntry(for: positionInCanvas)
    }
    
    func extendedEntry(for positionInCanvas: CGPoint) -> CGPoint? {
        return nil
    }
    
    func append(text: String) {
    }
    
    var line: Line? {
        return nextShape == nil ? nil : Line(initiator: self, target: nextShape!, color: UIColor.black)
    }
    
    
    var isHighlighted = false {
        didSet { setNeedsDisplay() }
    }
    
    var path: UIBezierPath {
        return UIBezierPath()
    }
    
    override func draw(_ rect: CGRect) {
        let path = self.path
        UIColor.white.setFill()
        if isHighlighted { UIColor.lightGray.setStroke() }
        else { UIColor.black.setStroke() }
        path.fill()
        path.stroke()
    }
    
    func contains(positionInSuperview: CGPoint) -> Bool {
        return path.contains(positionInView(point: positionInSuperview))
    }
    
}

extension Shape: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return instructions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "InstructionCell", for: indexPath)
    }
}


