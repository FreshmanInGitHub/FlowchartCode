//
//  InteractionInstruction.swift
//  Drawing
//
//  Created by Young on 2019/2/28.
//  Copyright © 2019 Young. All rights reserved.
//

import Foundation

class InteractionInstruction: Instruction {
    
    var content = ""
    var `operator` = Operator.print
    
    override var description: String {
        if !isFinished { return "" }
        switch `operator` {
        case .print: return "Print(\"\(content)\")"
        case .input: return "Input: \(content)"
        case .output: return "Output: \(content)"
        }
    }
    
    override var isFinished: Bool {
        return !content.isEmpty && (`operator` == .print || !content.isDouble)
    }
    
    override init() {
        super.init()
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(content, forKey: "content")
        aCoder.encode(`operator`.rawValue, forKey: "operator")
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init()
        content = aDecoder.decodeString(forKey: "content")!
        `operator` = Operator(rawValue: aDecoder.decodeString(forKey: "operator") ?? "print")!
    }
    
    enum Operator: String {
        case print = "Print"
        case input = "Input"
        case output = "Output"
    }
    
    static var operatorSequence: [String] {
        return ["Print", "Input", "Output"]
    }
}
