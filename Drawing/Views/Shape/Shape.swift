//
//  Shape.swift
//  Drawing
//
//  Created by Young on 2018/12/15.
//  Copyright © 2018 Young. All rights reserved.
//

import UIKit

class Shape: UIView, Customized {
    
    func contains(_ point: CGPoint) -> Bool {
        return path.contains(point)
    }
    
    override var frame: CGRect {
        didSet {
            canvas?.resetLines(relatedTo: self)
        }
    }
    
    
    static func generateShape(with block: Block) -> Shape {
        switch block.type {
        case .diamond: return Diamond(block: block)
        case .oval: return Oval(block: block)
        default: return Rect(block: block)
        }
    }
    
    var nextShape: Shape? {
        didSet {
            canvas?.resetLines(relatedTo: self)
        }
    }
    
    var canvas: Canvas? {
        return superview as? Canvas
    }
    
    var instructions = [Instruction]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    lazy var tableView = UITableView(frame: CGRect(x: bounds.minX+1, y: bounds.minY+bounds.height*0.4, width: bounds.width-2, height: bounds.height*0.2))
    
    func deleteConnection(to shape: Shape) {
        if nextShape == shape { nextShape = nil }
    }
    
    func deleteConnection(with color: UIColor) {
        nextShape = nil
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
    
    func connect(to target: Shape, with color: UIColor) {
        if color == .black {
            nextShape = target
        }
    }
    
    func entry(for positionInShapeView: CGPoint) -> CGPoint? {
        return path.contains(positionInView(point: positionInShapeView)) ? nil : extendedEntry(for: positionInShapeView)
    }
    
    func extendedEntry(for positionInShapeView: CGPoint) -> CGPoint? {
        return nil
    }
    
    var line: LineForConnecting?
    
    func setLine() {
        line = nextShape == nil ? nil : LineForConnecting(initiator: self, target: nextShape!, color: UIColor.black)
    }
    
    func lineForPanning(to point: CGPoint) -> LineForConnecting? {
        return nextShape == nil ? LineForConnecting(initiator: self, point: point, color: .black) : nil
    }
    
    func related(to shape: Shape) -> Bool {
        return self == shape || nextShape == shape
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
    
    
    func keepInFrame() {
        let origin = frame.origin
        switch (origin.x < 0, origin.y < 0) {
        case (true, true): slide(with: -origin)
        case (true, false): slide(with: CGPoint(x: -origin.x, y: 0))
        case (false, true): slide(with: CGPoint(x: 0, y: -origin.y))
        default: break
        }
    }
    
    private func slide(with translation: CGPoint) {
        UIView.animate(withDuration: 0.4, animations: {self.translate(with: translation)}, completion: {_ in
            if let canvas = self.superview as? Canvas {
                canvas.resetLines(relatedTo: self)
            }
        })
    }
    
}

extension Shape: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return instructions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.font = cell.textLabel?.font.withSize(tableView.rowHeight)
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.baselineAdjustment = .alignCenters
        cell.textLabel?.text = instructions[indexPath.row].description
        cell.backgroundColor = .clear
        return cell
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        clipsToBounds = false
        backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        tableView.separatorInset = .zero
        tableView.isScrollEnabled = false
        tableView.backgroundColor = UIColor.clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.rowHeight = tableView.bounds.height
        addSubview(tableView)
    }
    
}

