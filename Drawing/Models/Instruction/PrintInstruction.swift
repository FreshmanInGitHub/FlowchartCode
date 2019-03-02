//
//  PrintInstruction.swift
//  Drawing
//
//  Created by Young on 2019/1/16.
//  Copyright © 2019 Young. All rights reserved.
//

import Foundation

class PrintInstruction: Instruction {
    
    var text = ""
    
    override var description: String {
        return isFinished ? "Print(\"\(text)\")" : ""
    }
    
    override var isFinished: Bool {
        return !text.isEmpty
    }
    
    override init() {
        super.init()
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(text, forKey: "text")
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init()
        text = aDecoder.decodeString(forKey: "text")!
    }
}
