//
//  TrippleTextFieldCell.swift
//  Drawing
//
//  Created by Young on 2019/1/11.
//  Copyright © 2019 Young. All rights reserved.
//

import UIKit

class DoubleTextFieldCell: SingleTextFieldCell {
    
    override var frame: CGRect {
        didSet {
            let width = bounds.width
            let height = bounds.height-5
            firstTextField.frame = CGRect(x: 0, y: 5, width: width*0.4, height: height)
            secondTextField.frame = CGRect(x: width*0.6, y: 5, width: width*0.4, height: height)
            firstLabel.frame = CGRect(x: width*0.4, y: 5, width: width*0.2, height: height)
        }
    }
    
    var secondTextField = UITextField(frame: CGRect())
    
    override var instruction: Instruction {
        didSet {
            initialization()
        }
    }
    
    override func saveToInstruction() {
        if let instruction = instruction as? AssignmentInstruction {
            instruction.variable = firstTextField.text ?? ""
            instruction.operand1 = secondTextField.text ?? ""
        } else if let instruction = instruction as? IfInstruction {
            instruction.operand1 = firstTextField.text ?? ""
            instruction.operand2 = secondTextField.text ?? ""
        }
    }
    
    override func initialization() {
        super.initialization()
        
        secondTextField.textAlignment = .center
        
        secondTextField.adjustsFontSizeToFitWidth = true
        
        secondTextField.delegate = self
        
        addSubview(secondTextField)
        
        var font = textLabel?.font.withSize(20)
        
        if let instruction = instruction as? AssignmentInstruction {
            firstTextField.placeholder = "var"
            secondTextField.placeholder = "opr"
            firstLabel.text = "="
            firstTextField.text = instruction.variable
            secondTextField.text = instruction.operand1
        } else if let instruction = instruction as? IfInstruction {
            font = textLabel?.font.withSize(25)
            firstTextField.placeholder = "opr1"
            secondTextField.placeholder = "opr2"
            firstLabel.text = instruction.operator.rawValue
            firstTextField.text = instruction.operand1
            secondTextField.text = instruction.operand2
        }
        
        firstTextField.font = font
        secondTextField.font = font
        firstLabel.font = font
    }

}
