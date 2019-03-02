//
//  ProgramTableViewController.swift
//  Drawing
//
//  Created by Young on 2019/2/19.
//  Copyright © 2019 Young. All rights reserved.
//

import UIKit

class ProgramTableViewController: UITableViewController {

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataBase.programs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = DataBase.programs[indexPath.row].title
        return cell
    }

    @IBAction func addProgram(_ sender: UIBarButtonItem) {
        DataBase.programs.append(Program())
        tableView.insertRows(at: [IndexPath(row: DataBase.programs.count-1, section: 0)], with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            DataBase.programs.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? ProgramController, let cell = sender as? UITableViewCell, let index = tableView.indexPath(for: cell)?.row {
            controller.program = DataBase.programs[index]
        }
    }

}
