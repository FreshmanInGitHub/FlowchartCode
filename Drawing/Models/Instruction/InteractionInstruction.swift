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
    var type: InteractionType = .print
    
    override var description: String {
        if !isFinished { return "" }
        switch type {
        case .print: return "Print(\"\(content)\")"
        case .input: return "Input: \(content)"
        case .output: return "Output: \(content)"
        }
    }
    
    override var isFinished: Bool {
        if content.isEmpty { return false }
        else if type != .print { return !content.isDouble }
        return true
    }
    
    override init() {
        super.init()
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(content, forKey: "content")
        aCoder.encode(type.rawValue, forKey: "type")
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init()
        content = aDecoder.decodeString(forKey: "content")!
        type = InteractionType(rawValue: aDecoder.decodeString(forKey: "type") ?? "print")!
    }
    
    enum InteractionType: String {
        case print
        case input
        case output
    }
}
