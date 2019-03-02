//
//  BasicInstruction.swift
//  BigProject
//
//  Created by Young on 2018/9/28.
//  Copyright © 2018 Young. All rights reserved.
//

import Foundation

class AssignmentInstruction: Instruction {
    
    override var description: String {
        if `operator` == .none {
            return "\(variable) = \(operand1)"
        } else {
            return "\(variable) = \(operand1) \(`operator`.rawValue) \(operand2)"
        }
    }
    
    override var isFinished: Bool {
        if variable.isEmpty || operand1.isEmpty {
            return false
        } else if `operator` != .none, operand2.isEmpty {
            return false
        }
        return true
    }
    
    var variable = ""
    var operand1 = ""
    var operand2 = ""
    var `operator` = Operator.none
    
    override init() {
        super.init()
    }
    
    init(`operator`: Operator) {
        super.init()
        self.operator = `operator`
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(variable, forKey: "variable")
        aCoder.encode(operand1, forKey: "operand1")
        aCoder.encode(operand2, forKey: "operand2")
        aCoder.encode(`operator`.rawValue, forKey: "operator")
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init()
        variable = aDecoder.decodeString(forKey: "variable")!
        operand1 = aDecoder.decodeString(forKey: "operand1")!
        operand2 = aDecoder.decodeString(forKey: "operand2")!
        `operator` = Operator(rawValue: aDecoder.decodeString(forKey: "operator")!)!
    }
}
