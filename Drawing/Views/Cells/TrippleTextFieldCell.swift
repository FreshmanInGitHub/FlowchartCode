//
//  ArithmeticCell.swift
//  Drawing
//
//  Created by Young on 2019/1/9.
//  Copyright © 2019 Young. All rights reserved.
//

import UIKit

class TrippleTextFieldCell: DoubleTextFieldCell {
    override var frame: CGRect {
        didSet {
            let width = bounds.width
            let height = bounds.height-5
            firstTextField.frame = CGRect(x: 0, y: 5, width: width*0.3, height: height)
            secondTextField.frame = CGRect(x: width*0.35, y: 5, width: width*0.3, height: height)
            thirdTextField.frame = CGRect(x: width*0.7, y: 5, width: width*0.3, height: height)
            firstLabel.frame = CGRect(x: width*0.3, y: 5, width: width*0.05, height: height)
            secondLabel.frame = CGRect(x: bounds.width*0.65, y: 5, width: width*0.05, height: height)
        }
    }
    
    var thirdTextField = UITextField(frame: CGRect())
    var secondLabel = UILabel(frame: CGRect())
    
    override var instruction: Instruction {
        didSet {
            initialization()
        }
    }
    
    
    override func saveToInstruction() {
        super.saveToInstruction()
        if let instruction = instruction as? AssignmentInstruction {
            instruction.operand2 = thirdTextField.text ?? ""
        }
    }
    
    override func initialization() {
        super.initialization()
        
        let font = textLabel?.font.withSize(20)
        thirdTextField.font = font
        secondLabel.font = font
        
        thirdTextField.textAlignment = .center
        secondLabel.textAlignment = .center
        
        thirdTextField.adjustsFontSizeToFitWidth = true
        
        thirdTextField.delegate = self
        
        addSubview(thirdTextField)
        addSubview(secondLabel)
        
        if let instruction = instruction as? AssignmentInstruction {
            secondTextField.placeholder = "opr1"
            thirdTextField.placeholder = "opr2"
            thirdTextField.text = instruction.operand2
            secondLabel.text = instruction.operator.rawValue
        }
    }
}
