//
//  JumpInstruction.swift
//  BigProject
//
//  Created by Young on 2018/9/28.
//  Copyright © 2018 Young. All rights reserved.
//

import Foundation

class IfInstruction: Instruction {
    
    override var description: String {
        return isFinished ? "\(operand1) \(`operator`.rawValue) \(operand2)" : ""
    }
    
    override var isFinished: Bool {
        return !operand1.isEmpty && !operand2.isEmpty
    }
    
    var operand1 = ""
    var operand2 = ""
    var `operator` = Operator.equalTo
    
    override init() {
        super.init()
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(operand1, forKey: "operand1")
        aCoder.encode(operand2, forKey: "operand2")
        aCoder.encode(`operator`.rawValue, forKey: "operator")
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init()
        operand1 = aDecoder.decodeString(forKey: "operand1")!
        operand2 = aDecoder.decodeString(forKey: "operand2")!
        `operator` = Operator(rawValue: aDecoder.decodeString(forKey: "operator")!)!
    }
    
    enum Operator: String{
        case equalTo = "=="
        case notEqualTo = "!="
        case greaterThan = ">"
        case lessThan = "<"
        case greaterThanOrEqualTo = ">="
        case lessThanOrEqualTo = "<="
    }
}
