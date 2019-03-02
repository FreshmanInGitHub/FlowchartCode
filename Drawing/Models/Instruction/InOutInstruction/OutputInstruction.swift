//
//  OutputInstruction.swift
//  Drawing
//
//  Created by Young on 2019/1/16.
//  Copyright © 2019 Young. All rights reserved.
//

import Foundation

class OutputInstruction: InOutInstruction {
    override var description: String {
        return "Output: \(variable)"
    }
}
