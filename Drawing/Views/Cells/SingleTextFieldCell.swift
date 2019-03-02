//
//  SingleTextFieldCell.swift
//  Drawing
//
//  Created by Young on 2019/1/16.
//  Copyright © 2019 Young. All rights reserved.
//

import UIKit

class SingleTextFieldCell: InstructionCell, UITextFieldDelegate {

    override var frame: CGRect {
        didSet {
            let width = bounds.width
            let height = bounds.height-5
            firstLabel.frame = CGRect(x: 0, y: 5, width: width*0.3, height: height)
            firstTextField.frame = CGRect(x: width*0.3, y: 5, width: width*0.7, height: height)
        }
    }
    
    var firstLabel = UILabel(frame: CGRect())
    var firstTextField = UITextField(frame: CGRect())
    
    override var instruction: Instruction {
        didSet {
            initialization()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        saveToInstruction()
    }
    
    func saveToInstruction() {
        if let instruction = instruction as? PrintInstruction {
            instruction.text = firstTextField.text ?? ""
        } else if let instruction = instruction as? InOutInstruction {
            instruction.variable = firstTextField.text ?? ""
        }
    }
    
    func initialization() {
        textLabel?.text = nil
        
        firstTextField.textAlignment = .center
        firstLabel.textAlignment = .center
        
        firstTextField.adjustsFontSizeToFitWidth = true
        
        firstTextField.delegate = self
        
        addSubview(firstTextField)
        addSubview(firstLabel)
        
        let font = textLabel?.font.withSize(19)
        firstTextField.font = font
        firstLabel.font = font
        
        if let instruction = instruction as? PrintInstruction {
            firstTextField.placeholder = "text"
            firstLabel.text = "Print:"
            firstTextField.text = instruction.text
        } else if let instruction = instruction as? InOutInstruction {
            firstTextField.placeholder = "var"
            firstLabel.text = instruction is InputInstruction ? "Input:" : "Output:"
            firstTextField.text = instruction.variable
        }
    }


}
