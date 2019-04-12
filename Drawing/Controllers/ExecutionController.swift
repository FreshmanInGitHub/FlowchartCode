//
//  ExecutionController.swift
//  Drawing
//
//  Created by Young on 2019/1/22.
//  Copyright © 2019 Young. All rights reserved.
//

import UIKit

class ExecutionController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var textField: UITextField!
    
    var program = Program()
    var variable: String?
    var register = [String: Double]()
    var solidRange: NSRange?
    var stoppingReason: stoppingReasons? {
        didSet {
            if let text = stoppingReason?.rawValue {
                setText(text)
            }
        }
    }
    var current: Block? {
        didSet {
            backgoundQueue.async {
                self.process()
            }
        }
    }
    
    let backgoundQueue = DispatchQueue.global(qos: .background)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        textField.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reset()
        if let startIndex = program.entrance.index {
            current = program.blocks[startIndex]
        } else {
            current = nil
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        if current != nil {
            stoppingReason = stoppingReasons.exiting
        }
    }
    
    private func reset() {
        variable = nil
        register = [String: Double]()
        solidRange = nil
        stoppingReason = nil
    }
    
    func process() {
        if stoppingReason == nil {
            if let block = current {
                switch block.style {
                case .rect: processRect(block)
                case .diamond: processDiamond(block)
                case .oval: processOval(block)
                }
            } else {
                DispatchQueue.main.async {
                    self.navigationItem.rightBarButtonItem = nil
                }
                stoppingReason = .finished
                enableScrolling(true)
            }
        }
    }
    
    func processRect(_ block: Block) {
        let instructions = block.instructions as! [AssignmentInstruction]
        for instruction in instructions {
            let variable = instruction.variable
            let operand1 = value(with: instruction.operand1)
            let operand2 = value(with: instruction.operand2)
            switch instruction.operator {
            case .plus: register[variable] = operand1 + operand2
            case .minus: register[variable] = operand1 - operand2
            case .multiply: register[variable] = operand1 * operand2
            case .divide:
                if operand2 == 0 {
                    stoppingReason = stoppingReasons.dividendError
                }
                register[variable] = operand1 / operand2
            case .none: register[variable] = operand1
            }
        }
        current = block.next
    }
    
    func processDiamond(_ block: Block) {
        var result = true
        if let instruction = block.instructions.first as? IfInstruction {
            let operand1 = value(with: instruction.operand1)
            let operand2 = value(with: instruction.operand2)
            switch instruction.operator {
            case .greaterThanOrEqualTo: result = operand1 >= operand2
            case .lessThanOrEqualTo: result = operand1 <= operand2
            case .greaterThan: result = operand1 > operand2
            case .lessThan: result = operand1 < operand2
            case .equalTo: result = operand1 == operand2
            case .notEqualTo: result = operand1 != operand2
            }
        }
        current = result == true ? block.next : block.nextWhenFalse
    }
    
    func processOval(_ block: Block) {
        if let instruction = block.instructions.first as? InteractionInstruction {
            switch instruction.operator {
            case .output:
                let value = self.value(with: instruction.content)
                setText("\n\n  " + instruction.content + " = " + value.simpleDescription)
            case .input:
                variable = instruction.content
                setText("\n\n  " + instruction.content + " = ")
                DispatchQueue.main.async {
                    self.textView.isEditable = true
                    self.enableScrolling(true)
                }
            case .print:
                setText("\n\n  " + instruction.content)
            }
        }
        if variable == nil {
            // Must be in mainQueue or UI will not be able to respond.
            DispatchQueue.main.async {
                self.current = block.next
            }
        }
    }
    
    
    func value(with operand: String) -> Double {
        return Double(operand) ?? register[operand] ?? 0
    }
    
    func setText(_ newText: String) {
        DispatchQueue.main.async {
            if var text = self.textView.text {
                if text.count > 1000 {
                    text.removeSubrange(...text.firstIndex(of: "\n")!)
                    text.removeFirst()
                }
                text.append(newText)
                self.textView.text = text
                self.textView.scrollToBottom()
            }
        }
    }
    
    func enableScrolling(_ enabled: Bool) {
        DispatchQueue.main.async {
            self.textView.isUserInteractionEnabled = enabled
            if enabled {
                self.textView.scrollToBottom()
            }
        }
    }
    
    @IBAction func rightBarButtonPressed(_ sender: UIBarButtonItem) {
        toolBar.isHidden = !toolBar.isHidden
        var height = toolBar.frame.height
        if toolBar.isHidden {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .pause, target: self, action: #selector(rightBarButtonPressed(_:)))
            height = textView.frame.height+height
            stoppingReason = nil
            let current = self.current
            self.current = current
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(rightBarButtonPressed(_:)))
            stoppingReason = .paused
            height = textView.frame.height-height
            enableScrolling(true)
        }
        textView.frame = CGRect(origin: textView.frame.origin, size: CGSize(width: textView.frame.width, height: height))
        textView.scrollToBottom()
    }
    
    enum stoppingReasons: String {
        case dividendError = "\n\nERROR: Dividend can't be 0!"
        case exiting = "\n\nERROR: Commit exiting."
        case finished = "\n\nEND"
        case paused = "\n\nPaused"
    }
    
}

extension ExecutionController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        solidRange = NSRange(location: 0, length: textView.text.count)
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.isEditable = false
        enableScrolling(false)
        variable = nil
        solidRange = nil
        current = current?.next
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if solidRange == nil { return true }
        
        if solidRange!.intersection(range) != nil { return false }
        
        if text != "\n" { return true }
        
        if var subString = textView.text {
            subString.removeSubrange(Range(solidRange!, in: subString)!)
            if let value = Double(subString), let variable = variable {
                register[variable] = value
                textView.endEditing(true)
            }
        }
        
        return false
    }
}

extension ExecutionController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, text.isDouble {
            textField.shiver()
            return false
        }
        textField.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if reason == .committed, let text = textField.text, !text.isEmpty {
            setText("\n\n  \(text) = \(value(with: text).simpleDescription)")
        }
    }
    
}
