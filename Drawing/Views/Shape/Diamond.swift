//
//  Diamond.swift
//  Drawing
//
//  Created by Young on 2018/12/14.
//  Copyright © 2018 Young. All rights reserved.
//

import Foundation
import UIKit

class Diamond: Shape {
    
    override func append(text: String) {
        if instructions.isEmpty {
            instructions.append(IfInstruction())
        }
        let instruction = instructions[0] as! IfInstruction
        instruction.operator = Instruction.Operator(rawValue: text)!
        tableView.reloadData()
    }
    
    init(center: CGPoint, scale: CGFloat) {
        super.init(frame: CGRect(x: center.x-65*scale-1, y: center.y-40*scale-1, width: scale*130+2, height: scale*80+2))
    }
    
    convenience init(block: Block) {
        self.init(center: block.center, scale: 1)
        instructions = block.instructions
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override var path: UIBezierPath {
        let path = UIBezierPath()
        path.move(to: bounds.leftCenter)
        path.addLine(to: bounds.upperCenter)
        path.addLine(to: bounds.rightCenter)
        path.addLine(to: bounds.bottomCenter)
        path.addLine(to: bounds.leftCenter)
        return path
    }
    
    var nextShapeWhenFalse: Shape? {
        didSet {
            canvas?.resetLines()
        }
    }
    
    override var line: Line? {
        if let line = super.line {
            line.color = UIColor.green
            return line
        }
        return nil
    }
    
    var lineWhenFalse: Line? {
        return nextShapeWhenFalse == nil ? nil : Line(initiator: self, target: nextShapeWhenFalse!, color: UIColor.red)
    }
    
    override func extendedEntry(for positionInCanvas: CGPoint) -> CGPoint? {
        if positionInCanvas != center {
            let line = LinearFunction(start: center, end: positionInCanvas)!
            let lineOfFrame: LinearFunction
            switch (positionInCanvas.x>center.x, positionInCanvas.y>center.y) {
            case (true, true): lineOfFrame = LinearFunction(start: frame.rightCenter, end: frame.bottomCenter)!
            case (true, false): lineOfFrame = LinearFunction(start: frame.rightCenter, end: frame.upperCenter)!
            case (false, true): lineOfFrame = LinearFunction(start: frame.leftCenter, end: frame.bottomCenter)!
            default: lineOfFrame = LinearFunction(start: frame.leftCenter, end: frame.upperCenter)!
            }
            return line.intersection(with: lineOfFrame)!
        }
        return nil
    }
    
    override func deleteConnection(to shape: Shape) {
        super.deleteConnection(to: shape)
        if nextShapeWhenFalse == shape {
            nextShapeWhenFalse = nil
        }
    }
    
    override func canConnect(to target: Shape) -> Bool {
        return super.canConnect(to: target) && target != nextShapeWhenFalse
    }
    
}

extension Diamond {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: InstructionCell
        if formerCenter == nil {
            cell = tableView.dequeueReusableCell(withIdentifier: "InstructionCell", for: indexPath) as! InstructionCell
            cell.textLabel?.font = cell.textLabel?.font.withSize(tableView.rowHeight)
            cell.textLabel?.adjustsFontSizeToFitWidth = true
            cell.textLabel?.textAlignment = .center
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "DoubleTextFieldCell", for: indexPath) as! DoubleTextFieldCell
        }
        cell.instruction = instructions[0]
        return cell
    }
}
