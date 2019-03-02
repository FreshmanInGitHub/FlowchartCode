//
//  InputInstruction.swift
//  Drawing
//
//  Created by Young on 2019/1/16.
//  Copyright © 2019 Young. All rights reserved.
//

import Foundation

class InOutInstruction: Instruction {
    
    var variable = ""
    
    override var description: String {
        return ""
    }
    
    override var isFinished: Bool {
        return !variable.isEmpty
    }
    
    override init() {
        super.init()
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(variable, forKey: "variable")
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init()
        variable = aDecoder.decodeObject(forKey: "variable") as! String
    }

}
