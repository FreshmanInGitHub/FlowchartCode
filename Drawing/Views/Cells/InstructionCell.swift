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
            textLabel?.text = instruction.description
            textLabel?.baselineAdjustment = .alignCenters
            backgroundColor = .clear
        }
    }
    
    var isFinished: Bool {
        if !instruction.isFinished { flash() }
        return instruction.isFinished
    }

}

extension UITableViewCell {
    func flash() {
        UIView.animate(withDuration: 0.1, animations: {self.backgroundColor = UIColor(white: 0.9, alpha: 1)}, completion: {_ in
            UIView.animate(withDuration: 0.1, animations: {self.backgroundColor = .clear}, completion: {_ in
                UIView.animate(withDuration: 0.1, animations: {self.backgroundColor = UIColor(white: 0.9, alpha: 1)}, completion: {_ in
                    UIView.animate(withDuration: 0.1, animations: {self.backgroundColor = .clear})
                })
            })
        })
    }
}
