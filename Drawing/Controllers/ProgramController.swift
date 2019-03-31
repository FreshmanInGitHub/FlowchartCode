//
//  ProgramController.swift
//  Drawing
//
//  Created by Young on 2019/2/25.
//  Copyright © 2019 Young. All rights reserved.
//

import UIKit

class ProgramController: UITableViewController, UITextFieldDelegate {
    @IBOutlet weak var textField: UITextField!
    
    var program = Program()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        textField.text = program.title
        title = program.title
    }
    
    @IBAction func editingDidEnd(_ sender: UITextField) {
        program.title = textField.text ?? "Program"
        title = program.title
        DataBase.savePrograms()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? DrawingController {
            controller.program = program
        } else if let controller = segue.destination as? ExecutionController {
            controller.program = program
        }
    }

}
