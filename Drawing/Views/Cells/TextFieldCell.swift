//
//  TextFieldCell.swift
//  Drawing
//
//  Created by Young on 2019/4/11.
//  Copyright © 2019 Young. All rights reserved.
//

import UIKit

class TextFieldCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var textFieldOne: UITextField!
    @IBOutlet weak var textFieldTwo: UITextField!
    @IBOutlet weak var textFieldThree: UITextField!
    @IBOutlet weak var labelOne: UILabel!
    @IBOutlet weak var labelTwo: UILabel!
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        textFieldOne?.delegate = self
        textFieldTwo?.delegate = self
        textFieldThree?.delegate = self
    }
    
    var instruction = Instruction() {
        didSet {
            if let instruction = self.instruction as? AssignmentInstruction {
                textFieldOne.text = instruction.variable
                textFieldTwo.text = instruction.operand1
                textFieldThree?.text = instruction.operand2
                labelOne.text = "="
                labelTwo?.text = instruction.operator.rawValue
            } else if let instruction = self.instruction as? IfInstruction {
                textFieldOne.text = instruction.operand1
                textFieldTwo.text = instruction.operand2
                labelOne.text = instruction.operator.rawValue
            } else if let instruction = self.instruction as? InteractionInstruction {
                labelOne.text = instruction.operator.rawValue+": "
                textFieldOne.text = instruction.content
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, !text.isEmpty {
            if textField == textFieldOne, text.isDouble {
                if instruction is AssignmentInstruction {
                    textField.shiver()
                    return false
                } else if let instruction = instruction as? InteractionInstruction, instruction.operator != .print {
                    textField.shiver()
                    return false
                }
            }
            textField.endEditing(true)
            return true
        }
        textField.shiver()
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let instruction = self.instruction as? AssignmentInstruction {
            instruction.variable = textFieldOne.text ?? ""
            instruction.operand1 = textFieldTwo.text ?? ""
            if instruction.operator != .none {
                instruction.operand2 = textFieldThree.text ?? ""
            }
        } else if let instruction = self.instruction as? IfInstruction {
            instruction.operand1 = textFieldOne.text ?? ""
            instruction.operand2 = textFieldTwo.text ?? ""
        } else if let instruction = self.instruction as? InteractionInstruction {
            instruction.content = textFieldOne.text ?? ""
        }
    }
    
    
}
