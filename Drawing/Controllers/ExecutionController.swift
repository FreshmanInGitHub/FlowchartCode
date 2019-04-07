//
//  ExecutionController.swift
//  Drawing
//
//  Created by Young on 2019/1/22.
//  Copyright © 2019 Young. All rights reserved.
//

import UIKit

class ExecutionController: UITableViewController {
    var program = Program()
    var current: Block?
    var register = [String: Double]()
    var cells = [UITableViewCell]()
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let startIndex = program.entrance.index {
            process(program.blocks[startIndex])
        } else {
            programEnded()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cells[indexPath.row]
    }
    
    func process(_ block: Block?) {
        var block = block
        while block != nil {
            var next: Block?
            switch block!.type {
            case .rect: next = processRect(block!)
            case .diamond: next = processDiamond(block!)
            case .oval: next = processOval(block!)
            }
            block = next
        }
        if self.current == nil {
            programEnded()
        }
    }
    
    func processRect(_ block: Block) -> Block? {
        let instructions = block.instructions as! [AssignmentInstruction]
        for instruction in instructions {
            let variable = instruction.variable
            let operand1 = value(with: instruction.operand1)
            let operand2 = value(with: instruction.operand2)
            switch instruction.operator {
            case .plus: register[variable] = operand1 + operand2
            case .minus: register[variable] = operand1 - operand2
            case .multiply: register[variable] = operand1 * operand2
            case .divide: register[variable] = operand1 / operand2
            default: register[variable] = operand1
            }
        }
        return block.next
    }
    
    func processDiamond(_ block: Block) -> Block? {
        var result = true
        if let instruction = block.instructions.first as? IfInstruction {
            let operand1 = value(with: instruction.operand1)
            let operand2 = value(with: instruction.operand2)
            switch instruction.operator {
            case .greaterThanOrEqualTo: result = operand1 >= operand2
            case .lessThanOrEqualTo: result = operand1 <= operand2
            case .greaterThan: result = operand1 > operand2
            case .lessThan: result = operand1 < operand2
            default: result = operand1 == operand2
            }
        }
        return result ? block.next : block.nextWhenFalse
    }
    
    func processOval(_ block: Block) -> Block? {
        var cell: UITableViewCell?
        if let instruction = block.instructions.first as? InteractionInstruction {
            let indexPath = IndexPath(row: cells.count, section: 0)
            switch instruction.operator {
            case .input:
                let inputCell = tableView.dequeueReusableCell(withIdentifier: "InputCell", for: indexPath) as! InputCell
                inputCell.textField.delegate = self
                inputCell.label.text = instruction.content + " = "
                self.current = block
                cell = inputCell
            case .output:
                cell = tableView.dequeueReusableCell(withIdentifier: "OutputCell", for: indexPath)
                cell!.textLabel?.text = instruction.content + " = " + value(with: instruction.content).description
            case .print:
                cell = tableView.dequeueReusableCell(withIdentifier: "OutputCell", for: indexPath)
                cell!.textLabel?.text = instruction.content
            }
            cells.append(cell!)
            tableView.insertRows(at: [indexPath], with: .automatic)
        }
        return cell is InputCell ? nil : block.next
    }
    
    func programEnded() {
        let indexPath = IndexPath(row: cells.count, section: 0)
        let cell = tableView.dequeueReusableCell(withIdentifier: "OutputCell", for: indexPath)
        cell.textLabel?.text = "End"
        cells.append(cell)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    func value(with operand: String) -> Double {
        return Double(operand) ?? register[operand] ?? 0
    }
    
}

extension  ExecutionController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if reason == .committed, let block = current {
            if let value = Double(textField.text!), let instruction = block.instructions[0] as? InteractionInstruction {
                register[instruction.content] = value
                let indexPath = IndexPath(row: cells.count-1, section: 0)
                let cell = tableView.dequeueReusableCell(withIdentifier: "OutputCell", for: indexPath)
                cell.textLabel?.text = instruction.content + " = " + value.description
                cells[indexPath.row] = cell
                tableView.reloadRows(at: [indexPath], with: .automatic)
                let next = block.next
                current = nil
                textField.text = nil
                process(next)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let _ = Double(textField.text ?? "") {
            textField.endEditing(true)
            return true
        }
        textField.shiver()
        return false
    }
}
