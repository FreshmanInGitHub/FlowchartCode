//
//  TrippleTextFieldCell.swift
//  Drawing
//
//  Created by Young on 2019/1/11.
//  Copyright © 2019 Young. All rights reserved.
//

import UIKit

class DoubleTextFieldCell: SingleTextFieldCell {
    
    @IBOutlet weak var secondTextField: UITextField!
    
    override func saveToInstruction() {
        if let instruction = instruction as? AssignmentInstruction {
            instruction.variable = firstTextField.text ?? ""
            instruction.operand1 = secondTextField.text ?? ""
        } else if let instruction = instruction as? IfInstruction {
            instruction.operand1 = firstTextField.text ?? ""
            instruction.operand2 = secondTextField.text ?? ""
        }
    }
    
    override func didSetInstruction() {
        if let instruction = instruction as? IfInstruction {
            firstLabel?.text = instruction.operator.rawValue
            firstTextField?.text = instruction.operand1
            secondTextField?.text = instruction.operand2
        } else if let instruction = instruction as? AssignmentInstruction {
            firstTextField?.text = instruction.variable
            secondTextField?.text = instruction.operand1
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        secondTextField.delegate = self
    }
    
}
