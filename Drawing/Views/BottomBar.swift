//
//  BottomBar.swift
//  Drawing
//
//  Created by Young on 2019/2/27.
//  Copyright © 2019 Young. All rights reserved.
//

import UIKit

class BottomBar: UICollectionView {
    lazy var deleteLabel = backgroundView as! UILabel
    
    var state = State.hidden {
        didSet {
            backgroundView?.isHidden = !(state == .deleteLabel)
            isHidden = state == .hidden
            backgroundColor = state == .editing ? .white : .clear
            reloadData()
        }
    }
    
    enum State {
        case deleteLabel
        case hidden
        case editing
    }
    
    func labelCellForRect(forItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableCell(withReuseIdentifier: "LabelCell", for: indexPath) as! CollectionViewCellWithLabel
        cell.label.font = cell.label.font.withSize(25)
        switch indexPath.row {
        case 0: cell.label.text = "+"
        case 1: cell.label.text = "-"
        case 2: cell.label.text = "*"
        case 3: cell.label.text = "/"
        default: cell.label.text = "="
        }
        return cell
    }
    
    func labelCellForDiamond(forItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableCell(withReuseIdentifier: "LabelCell", for: indexPath) as! CollectionViewCellWithLabel
        cell.label.font = cell.label.font.withSize(25)
        switch indexPath.row {
        case 0: cell.label.text = "=="
        case 1: cell.label.text = ">"
        case 2: cell.label.text = "<"
        case 3: cell.label.text = ">="
        default: cell.label.text = "<="
        }
        return cell
    }
    
    func labelCellForOval(forItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableCell(withReuseIdentifier: "LabelCell", for: indexPath) as! CollectionViewCellWithLabel
        cell.label.font = cell.label.font.withSize(20)
        switch indexPath.row {
        case 0: cell.label.text = "Input"
        case 1: cell.label.text = "Output"
        default: cell.label.text = "Print"
        }
        return cell
    }
    
//    func sourceCell(forItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
//        let shape: Shape
//        switch indexPath.row {
//        case 0: shape = Rect(center: cell.bounds.center, scale: 0.4)
//        case 1: shape = Diamond(center: cell.bounds.center, scale: 0.4)
//        default: shape = Oval(center: cell.bounds.center, scale: 0.4)
//        }
//        shape.tableView.isHidden = true
//        let backgroundView = UIView(frame: cell.bounds)
//        backgroundView.addSubview(shape)
//        cell.backgroundView = backgroundView
//        return cell
//    }
}
