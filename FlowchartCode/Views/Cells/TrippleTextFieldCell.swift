//
//  ArithmeticCell.swift
//  Drawing
//
//  Created by Young on 2019/1/9.
//  Copyright © 2019 Young. All rights reserved.
//

import UIKit

class TrippleTextFieldCell: DoubleTextFieldCell {
    
    @IBOutlet weak var thirdTextField: UITextField!
    @IBOutlet weak var secondLabel: UILabel!
    
    
    override func saveToInstruction() {
        super.saveToInstruction()
        if let instruction = instruction as? AssignmentInstruction {
            instruction.operand2 = thirdTextField.text ?? ""
        }
    }
    
    override func didSetInstruction() {
        if let instruction = instruction as? AssignmentInstruction {
            secondLabel?.text = instruction.operator.rawValue
            firstTextField?.text = instruction.variable
            secondTextField?.text = instruction.operand1
            thirdTextField?.text = instruction.operand2
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        thirdTextField.delegate = self
    }
    
}
