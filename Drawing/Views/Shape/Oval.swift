//
//  Oval.swift
//  Drawing
//
//  Created by Young on 2018/12/14.
//  Copyright © 2018 Young. All rights reserved.
//

import Foundation
import UIKit

class Oval: Shape {
    
    init(center: CGPoint, scale: CGFloat) {
        super.init(frame: CGRect(x: center.x-60*scale-1, y: center.y-35*scale-1, width: 120*scale+2, height: 70*scale+2))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init(block: Block) {
        self.init(center: block.center, scale: 1)
        instructions = block.instructions
    }
    
    override var path: UIBezierPath {
        return UIBezierPath(ovalIn: CGRect(x: 1, y: 1, width: bounds.maxX-2, height: bounds.maxY-2))
    }
    
    override func extendedEntry(for positionInCanvas: CGPoint) -> CGPoint? {
        if positionInCanvas != center {
            let squareA = (frame.minX-center.x).square
            let squareB = (frame.minY-center.y).square
            let targetInView = positionInCanvas - center
            let squareX = targetInView.x.square
            let line = LinearFunction(start: targetInView, end: CGPoint())!
            if line.b == 0 {
                let dY = sqrt(squareB*(1-squareX/squareA))
                return targetInView.y>0 ? CGPoint(x: targetInView.x+center.x, y: dY+center.y):CGPoint(x: targetInView.x+center.x, y: center.y-dY)
            } else {
                let a = squareB+squareA*line.a*line.a/(line.b*line.b)
                let b = squareA*line.a*line.c*2/(line.b*line.b)
                let c = squareA*line.c*line.c/(line.b*line.b)-squareA*squareB
                let x = targetInView.x >= 0 ? (-b+sqrt(b*b-4*a*c))/(2*a):(-b-sqrt(b*b-4*a*c))/(2*a)
                let y = -(line.a*x+line.c)/line.b
                return CGPoint(x: x+center.x, y: y+center.y)
            }
        }
        return nil
    }
    
    override func append(text: String) {
        if instructions.isEmpty {
            instructions.append(PrintInstruction())
        }
        switch text {
        case "Input": instructions[0] = InputInstruction()
        case "Output": instructions[0] = OutputInstruction()
        default: instructions[0] = PrintInstruction()
        }
        tableView.reloadData()
    }
    
}

extension Oval {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: InstructionCell
        if formerCenter == nil {
            cell = tableView.dequeueReusableCell(withIdentifier: "InstructionCell", for: indexPath) as! InstructionCell
            cell.textLabel?.font = cell.textLabel?.font.withSize(tableView.rowHeight)
            cell.textLabel?.adjustsFontSizeToFitWidth = true
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "SingleTextFieldCell", for: indexPath) as! SingleTextFieldCell
        }
        cell.instruction = instructions[0]
        return cell
    }
}
