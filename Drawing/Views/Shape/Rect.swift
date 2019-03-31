//
//  Rect.swift
//  Drawing
//
//  Created by Young on 2018/12/14.
//  Copyright © 2018 Young. All rights reserved.
//

import Foundation
import UIKit

class Rect: Shape {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    convenience init(block: Block) {
        self.init(center: block.center)
        instructions = block.instructions
    }
    
    init(center: CGPoint) {
        super.init(frame: CGRect(x: center.x-60, y: center.y-35, width: 120, height: 70))
    }
    
    
    override var path: UIBezierPath {
        return Rect.path(within: bounds)
    }
    
    override func extendedEntry(for positionInShapeView: CGPoint) -> CGPoint? {
        if positionInShapeView != center {
            let lineOne = LinearFunction(start: frame.upperLeft, end: frame.bottomRight)!
            let lineTwo = LinearFunction(start: frame.upperRight, end: frame.bottomLeft)!
            let line = LinearFunction(start: center, end: positionInShapeView)!
            switch (lineOne.isBelow(positionInShapeView), lineTwo.isBelow(positionInShapeView)) {
            case (true, true): return line.intersection(with: LinearFunction(start: frame.upperLeft, end: frame.upperRight)!)
            case (true, false): return line.intersection(with: LinearFunction(start: frame.bottomRight, end: frame.upperRight)!)
            case (false, true): return line.intersection(with: LinearFunction(start: frame.upperLeft, end: frame.bottomLeft)!)
            default: return line.intersection(with: LinearFunction(start: frame.bottomLeft, end: frame.bottomRight)!)
            }
        }
        return frame.leftCenter
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.textAlignment = .left
        return cell
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        tableView.frame = CGRect(x: 0, y: 1, width: bounds.width, height: bounds.height-2)
        tableView.rowHeight = tableView.bounds.height/5
    }
    
    
    static func path(within bounds: CGRect) -> UIBezierPath {
        return UIBezierPath(rect: CGRect(x: bounds.minX+1, y: bounds.minY+1, width: bounds.width-2, height: bounds.height-2))
    }
}
