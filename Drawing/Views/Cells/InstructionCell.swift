//
//  InstructionCell.swift
//  Drawing
//
//  Created by Young on 2019/1/11.
//  Copyright © 2019 Young. All rights reserved.
//

import UIKit

class InstructionCell: UITableViewCell {

    var instruction = Instruction() {
        didSet {
            didSetInstruction()
        }
    }
    
    func didSetInstruction() {
        textLabel?.text = instruction.description
        
    }
    
    var isFinished: Bool {
        if !instruction.isFinished { shiver() }
        return instruction.isFinished
    }

}
