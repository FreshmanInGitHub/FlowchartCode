//
//  Shape.swift
//  Drawing
//
//  Created by Young on 2018/12/15.
//  Copyright © 2018 Young. All rights reserved.
//

import UIKit

class Shape: UIView, Customized {
    
    enum style: Int {
    case rect
    case oval
    case diamond
    }
    
    func contains(_ point: CGPoint) -> Bool {
        return path.contains(point)
    }
    
    var nextShape: Shape? {
        didSet {
            resetLine(true)
        }
    }
    
//    var instructions = [Instruction]() {
//        didSet {
//            tableView.reloadData()
//        }
//    }
    
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
    
    func extendedEntry(for positionInShapeView: CGPoint) -> CGPoint {
        return CGPoint()
    }
    
    var line: LineForConnecting?
    
    func resetLine(_ shouldResetLine: Bool) {
        if shouldResetLine {
            line = nextShape == nil ? nil : LineForConnecting(initiator: self, target: nextShape!, color: UIColor.black)
        }
    }
    
    func lineForPanning(to point: CGPoint) -> LineForConnecting? {
        return nextShape == nil ? LineForConnecting(initiator: self, point: point, color: .black) : nil
    }
    
    func related(to shape: Shape?) -> Bool {
        if shape == nil {
            return true
        }
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
    
}
//
//extension Shape: UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return instructions.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
//        cell.textLabel?.font = cell.textLabel?.font.withSize(tableView.rowHeight)
//        cell.textLabel?.adjustsFontSizeToFitWidth = true
//        cell.textLabel?.textAlignment = .center
//        cell.textLabel?.baselineAdjustment = .alignCenters
//        cell.textLabel?.text = instructions[indexPath.row].description
//        cell.backgroundColor = .clear
//        return cell
//    }
//    
//    override func didMoveToWindow() {
//        super.didMoveToWindow()
//        clipsToBounds = false
//        backgroundColor = UIColor.clear
//        tableView.separatorStyle = .none
//        tableView.separatorInset = .zero
//        tableView.isScrollEnabled = false
//        tableView.backgroundColor = UIColor.clear
//        tableView.dataSource = self
//        tableView.delegate = self
//        tableView.allowsSelection = false
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
//        tableView.rowHeight = tableView.bounds.height
//        addSubview(tableView)
//    }
//    
//}

