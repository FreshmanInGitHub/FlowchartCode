//
//  DataBase.swift
//  Drawing
//
//  Created by Young on 2019/2/20.
//  Copyright © 2019 Young. All rights reserved.
//

import Foundation
import UIKit

class DataBase {
    static let archivePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("programs").path
    
    static var programs = DataBase.loadPrograms() {
        didSet {
            DataBase.savePrograms()
        }
    }
    
    static func savePrograms() {
        print("saving")
        do {
            FileManager.default.createFile(atPath: DataBase.archivePath, contents: try NSKeyedArchiver.archivedData(withRootObject: programs, requiringSecureCoding: false), attributes: nil)
        } catch {
            print(error)
        }
    }
    
    static func loadPrograms() -> [Program] {
        print("loading")
        if let data = FileManager.default.contents(atPath: DataBase.archivePath) {
            do {
                if let programs = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [Program] {
                    return programs
                }
            } catch {
                print(error)
            }
        }
        return [Program]()
    }
    
}
