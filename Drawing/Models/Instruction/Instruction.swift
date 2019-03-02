//
//  Instruction.swift
//  BigProject
//
//  Created by Young on 2018/9/24.
//  Copyright © 2018 Young. All rights reserved.
//

import Foundation

class Instruction: NSObject, NSCoding {
    
    override var description: String { return "" }
    
    var isFinished: Bool { return true }
    
    override init() { }
    
    enum Operator: String{
        case plus = "+"
        case minus = "-"
        case multiply = "*"
        case divide = "/"
        case equalTo = "=="
        case notEqualTo = "!="
        case greaterThan = ">"
        case lessThan = "<"
        case greaterThanOrEqualTo = ">="
        case lessThanOrEqualTo = "<="
        case none = ""
    }
    
    func encode(with aCoder: NSCoder) { }
    
    required init?(coder aDecoder: NSCoder) { }
    
}
