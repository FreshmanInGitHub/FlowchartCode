//
//  SingleTextFieldCell.swift
//  Drawing
//
//  Created by Young on 2019/1/16.
//  Copyright © 2019 Young. All rights reserved.
//

import UIKit

class SingleTextFieldCell: InstructionCell, UITextFieldDelegate {
    
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var firstTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        firstTextField.delegate = self
    }
    
    override func didSetInstruction() {
        if let instruction = instruction as? InteractionInstruction {
            firstLabel?.text = instruction.type.rawValue
            firstTextField?.text = instruction.content
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
        if let instruction = instruction as? InteractionInstruction {
            instruction.content = firstTextField.text ?? ""
        }
    }
    


}
