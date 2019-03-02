//
//  Rect.swift
//  Drawing
//
//  Created by Young on 2018/12/14.
//  Copyright © 2018 Young. All rights reserved.
//

import Foundation
import UIKit

class Rect: Shape {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var editing = false {
        didSet { tableView.reloadData() }
    }
    
    convenience init(block: Block) {
        self.init(center: block.center, scale: 1)
        instructions = block.instructions
    }
    
    init(center: CGPoint, scale: CGFloat) {
        super.init(frame: CGRect(x: center.x-60*scale-1, y: center.y-35*scale-1, width: scale*120+2, height: scale*70+2))
    }
    
    override func append(text: String) {
        instructions.append(AssignmentInstruction(operator: Instruction.Operator(rawValue: text)!))
        tableView.insertRows(at: [IndexPath(row: instructions.count-1, section: 0)], with: .automatic)
    }
    
    override var path: UIBezierPath {
        return UIBezierPath(rect: CGRect(x: 1, y: 1, width: bounds.maxX-2, height: bounds.maxY-2))
    }
    
    override func extendedEntry(for positionInCanvas: CGPoint) -> CGPoint? {
        if positionInCanvas != centerInSuperview {
            let lineOne = LinearFunction(start: frame.upperLeft, end: frame.bottomRight)!
            let lineTwo = LinearFunction(start: frame.upperRight, end: frame.bottomLeft)!
            let line = LinearFunction(start: centerInSuperview!, end: positionInCanvas)!
            switch (lineOne.isBelow(positionInCanvas), lineTwo.isBelow(positionInCanvas)) {
            case (true, true): return line.intersection(with: LinearFunction(start: frame.upperLeft, end: frame.upperRight)!)
            case (true, false): return line.intersection(with: LinearFunction(start: frame.bottomRight, end: frame.upperRight)!)
            case (false, true): return line.intersection(with: LinearFunction(start: frame.upperLeft, end: frame.bottomLeft)!)
            default: return line.intersection(with: LinearFunction(start: frame.bottomLeft, end: frame.bottomRight)!)
            }
        }
        return nil
    }
    
    override var formerCenter: CGPoint? {
        didSet {
            tableView.isScrollEnabled = formerCenter != nil
            tableView.isEditing = tableView.isScrollEnabled
            editing = false
            if let canvas = canvas {
                if formerCenter != nil {
                    tableView.separatorStyle = .singleLine
                    frame = CGRect(x: 5, y: 64, width: canvas.bounds.width-10, height: canvas.bottomBar.frame.minY-64)
                    tableView.rowHeight = 50
                } else if let center = oldValue {
                    tableView.separatorStyle = .none
                    let scale = canvas.scale
                    frame = CGRect(x: center.x-60*scale-1, y: center.y-35*scale-1, width: scale*120+2, height: scale*70+2)
                }
            }
        }
    }
    
    override var frame: CGRect {
        didSet {
            tableView.frame = bounds
            tableView.rowHeight = bounds.height/5
            tableView.reloadData()
            setNeedsDisplay()
            canvas?.resetLines()
        }
    }
    
}

extension Rect {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let instruction = instructions[indexPath.row] as! AssignmentInstruction
        let cell: InstructionCell
        if !editing {
            cell = tableView.dequeueReusableCell(withIdentifier: "InstructionCell", for: indexPath) as! InstructionCell
            cell.textLabel?.font = cell.textLabel?.font.withSize(tableView.rowHeight*0.9>20 ? 20 : tableView.rowHeight*0.9)
        } else if instruction.operator == .none {
            cell = tableView.dequeueReusableCell(withIdentifier: "DoubleTextFieldCell", for: indexPath) as! DoubleTextFieldCell
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "TrippleTextFieldCell", for: indexPath) as! TrippleTextFieldCell
        }
        cell.instruction = instruction
        return cell
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return tableView.isEditing
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            instructions.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        instructions.swapAt(sourceIndexPath.row, destinationIndexPath.row)
    }
}
