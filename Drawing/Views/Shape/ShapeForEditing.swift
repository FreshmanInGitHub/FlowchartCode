//
//  ShapeForEditing.swift
//  Drawing
//
//  Created by Young on 2019/3/21.
//  Copyright © 2019 Young. All rights reserved.
//

import Foundation
import UIKit

class ShapeForEditing: UIView {
    var tableView = UITableView(frame: CGRect())
    
    var shape: Shape = Rect(center: CGPoint()) {
        didSet {
            setTableView()
            switch shape {
            case is Rect: path = rectPath
            case is Diamond: path = diamondPath
            case is Oval: path = ovalPath
            default: break
            }
            tableView.reloadData()
            self.isHidden = false
            setNeedsDisplay()
        }
    }
    
    var path = UIBezierPath()
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        UIColor.black.setStroke()
        path.stroke()
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if let tableView = subviews.first as? UITableView {
            self.tableView = tableView
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
    func append(_ text: String) {
        switch shape {
        case is Rect: appendForRect(text)
        case is Oval: appendForOval(text)
        case is Diamond: appendForDiamond(text)
        default: break
        }
        tableView.reloadData()
    }
}

// Rect
extension ShapeForEditing {
    var rectPath: UIBezierPath {
        return Rect.path(within: CGRect(x: 5, y: 5, width: bounds.maxX-10, height: bounds.maxY-10))
    }
    func appendForRect(_ text: String) {
        let opt = Instruction.Operator(rawValue: text) ?? .none
        shape.instructions.append(AssignmentInstruction(operator: opt))
    }
    func cellForRect(_ indexPath: IndexPath) -> InstructionCell {
        let instruction = shape.instructions[indexPath.row] as! AssignmentInstruction
        if tableView.isEditing {
            let cell = tableView.dequeueReusableCell(withIdentifier: "InstructionCell", for: indexPath) as! InstructionCell
            cell.textLabel?.text = instruction.description
            return cell
        } else {
            switch instruction.operator {
            case .plus, .minus, .multiply, .divide:
                return tableView.dequeueReusableCell(withIdentifier: "TrippleTextFieldCell", for: indexPath) as! TrippleTextFieldCell
            default:
                return tableView.dequeueReusableCell(withIdentifier: "DoubleTextFieldCell", for: indexPath) as! DoubleTextFieldCell
            }
        }
    }
}

// Diamond
extension ShapeForEditing {
    var diamondPath: UIBezierPath {
        let width = bounds.width+80
        let height = width/13*8
        return Diamond.path(within: CGRect(x: -40, y: bounds.midY-height/2, width: width, height: height))
    }
    func appendForDiamond(_ text: String) {
        let opt = Instruction.Operator(rawValue: text)!
        if shape.instructions.isEmpty {
            shape.instructions.append(IfInstruction())
        }
        let instruction = shape.instructions.first as! IfInstruction
        instruction.operator = opt
    }
    func cellForDiamond(_ indexPath: IndexPath) -> InstructionCell {
        return tableView.dequeueReusableCell(withIdentifier: "DoubleTextFieldCell", for: indexPath) as! DoubleTextFieldCell
    }
}

// Oval
extension ShapeForEditing {
    var ovalPath: UIBezierPath {
        let width = bounds.width+40
        let height = width/12*7
        return Oval.path(within: CGRect(x: -20, y: bounds.midY-height/2, width: width, height: height))
    }
    func appendForOval(_ text: String) {
        if shape.instructions.isEmpty {
            shape.instructions.append(InteractionInstruction())
        }
        let instruction = shape.instructions.first as! InteractionInstruction
        switch text {
        case "Input": instruction.type = .input
        case "Output": instruction.type = .input
        default: instruction.type = .print
        }
    }
    func cellForOval(_ indexPath: IndexPath) -> InstructionCell {
        return tableView.dequeueReusableCell(withIdentifier: "SingleTextFieldCell", for: indexPath) as! SingleTextFieldCell
    }
}

// tableView
extension ShapeForEditing: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shape.instructions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: InstructionCell
        switch shape {
        case is Diamond: cell = cellForDiamond(indexPath)
        case is Oval: cell = cellForOval(indexPath)
        default: cell = cellForRect(indexPath)
        }
        cell.instruction = shape.instructions[indexPath.row]
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return shape is Rect
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        shape.instructions.swapAt(sourceIndexPath.row, destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            shape.instructions.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    
    func setTableView() {
        if shape is Rect {
            tableView.frame = CGRect(x: 10, y: 10, width: bounds.maxX-20, height: bounds.maxY-20)
            tableView.isScrollEnabled = true
            tableView.separatorStyle = .singleLine
        } else {
            tableView.frame = CGRect(x: 5, y: bounds.midY-25, width: bounds.width-10, height: 50)
            tableView.isScrollEnabled = false
            tableView.separatorStyle = .none
        }
    }
    
}
