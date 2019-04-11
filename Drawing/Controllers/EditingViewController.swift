//
//  EditingViewController.swift
//  Drawing
//
//  Created by Young on 2019/4/6.
//  Copyright © 2019 Young. All rights reserved.
//

import UIKit

class EditingViewController: UIViewController {
    @IBOutlet var editingView: EditingView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var shape: Shape?
    
    var label: UILabel? {
        didSet {
            if let label = label {
                editingView.addSubview(label)
            } else if let label = oldValue {
                label.removeFromSuperview()
            }
        }
    }
    
    var formerPosition = CGPoint()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editingView.tableView.delegate = self
        editingView.tableView.dataSource = self
        collectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        switch shape {
        case is Diamond: editingView.shapeType = .diamond
        case is Oval: editingView.shapeType = .oval
        default: editingView.shapeType = .rect
        }
        navigationItem.rightBarButtonItem = shape is Rect ? editButtonItem : nil
        editingView.tableView.reloadData()
        collectionView.reloadData()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        editingView.tableView.setEditing(editing, animated: animated)
    }
    
    @IBAction func dragLabel(_ sender: UILongPressGestureRecognizer) {
        if let cell = sender.view as? UICollectionViewCell {
            let position = sender.location(in: view)
            switch sender.state {
            case .began:
                if let label = cell.backgroundView as? UILabel {
                    label.textColor = .lightGray
                    label.font = label.font.withSize(30)
                    UIView.animate(withDuration: 0.1) {
                        label.translate(with: -CGPoint(x: label.frame.width, y: 80))
                    }
                    label.removeFromSuperview()
                    label.frame.origin = position-CGPoint(x: label.frame.width, y: 80)
                    self.label = label
                }
            case .changed:
                label?.translate(with: position - formerPosition)
            default:
                if editingView.path.contains(sender.location(in: editingView)), let text = label?.text {
                    append(text)
                }
                label = nil
                collectionView.reloadData()
            }
            formerPosition = position
        }
    }
    
    // appending
    func append(_ text: String) {
        switch editingView.shapeType {
        case .rect: appendForRect(text)
        case .diamond: appendForDiamond(text)
        case .oval: appendForOval(text)
        }
        editingView.tableView.reloadData()
    }
    
    func appendForRect(_ text: String) {
        if let opt = AssignmentInstruction.Operator(rawValue: text) {
            shape.instructions.append(AssignmentInstruction(operator: opt))
        }
    }
    
    func appendForDiamond(_ text: String) {
        if let opt = IfInstruction.Operator(rawValue: text) {
            if shape.instructions.isEmpty {
                shape.instructions.append(IfInstruction())
            }
            let instruction = shape.instructions.first as! IfInstruction
            instruction.operator = opt
        }
    }
    
    func appendForOval(_ text: String) {
        if let opt = InteractionInstruction.Operator(rawValue: text) {
            if shape.instructions.isEmpty {
                shape.instructions.append(InteractionInstruction())
            }
            let instruction = shape.instructions.first as! InteractionInstruction
            instruction.operator = opt
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        for instruction in shape.instructions {
            if !instruction.isFinished {
                shape.instructions.remove(at: shape.instructions.firstIndex(of: instruction)!)
            }
        }
        shape.tableView.reloadData()
        super.viewWillDisappear(animated)
    }
    
}


// tableView
extension EditingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shape.instructions.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        shape.instructions.swapAt(sourceIndexPath.row, destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            shape.instructions.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: InstructionCell
        switch editingView.shapeType {
        case .rect:
            let instruction = shape.instructions[indexPath.row] as! AssignmentInstruction
            if instruction.operator == .none {
                cell = editingView.tableView.dequeueReusableCell(withIdentifier: "DoubleTextFieldCell", for: indexPath) as! DoubleTextFieldCell
            } else {
                cell = editingView.tableView.dequeueReusableCell(withIdentifier: "TrippleTextFieldCell", for: indexPath) as! TrippleTextFieldCell
            }
        case .diamond: cell = editingView.tableView.dequeueReusableCell(withIdentifier: "DoubleTextFieldCell", for: indexPath) as! DoubleTextFieldCell
        case .oval: cell = editingView.tableView.dequeueReusableCell(withIdentifier: "SingleTextFieldCell", for: indexPath) as! SingleTextFieldCell
        }
        cell.instruction = shape.instructions[indexPath.row]
        return cell
    }
    
}



// CollectionView
extension EditingViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        flowLayout.itemSize = CGSize(width: shape is Oval ? 65 : 50, height: 50)
        switch shape {
        case is Diamond: return IfInstruction.operatorSequence.count
        case is Oval: return InteractionInstruction.operatorSequence.count
        default: return AssignmentInstruction.operatorSequence.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        let label = UILabel(frame: cell.frame)
        label.textColor = .darkGray
        label.adjustsFontSizeToFitWidth = true
        //label.font = UIFont(descriptor: .preferredFontDescriptor(withTextStyle: .body), size: shape is Oval ? 20 : 25)
        label.textAlignment = .center
        label.baselineAdjustment = .alignCenters
        switch shape {
        case is Diamond: label.text = IfInstruction.operatorSequence[indexPath.row]
        case is Oval: label.text = InteractionInstruction.operatorSequence[indexPath.row]
        default: label.text = AssignmentInstruction.operatorSequence[indexPath.row]
        }
        cell.backgroundView = label
        cell.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(dragLabel(_:))))
        return cell
    }
    
}
