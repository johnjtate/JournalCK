//
//  EntryTableViewController.swift
//  JournalCK
//
//  Created by John Tate on 9/24/18.
//  Copyright © 2018 John Tate. All rights reserved.
//

import UIKit

class EntryTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        EntryController.shared.fetchEntries { (success) in
            if success {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return EntryController.shared.entries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "entryCell", for: indexPath)
        let entry = EntryController.shared.entries[indexPath.row]
        cell.textLabel?.text = entry.title
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {

            let entry = EntryController.shared.entries[indexPath.row]
            EntryController.shared.deleteEntry(entryToDelete: entry) { (success) in
                if success {
                    DispatchQueue.main.async {
                        self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                }
            }
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showEntry" {
            guard let indexPath = tableView.indexPathForSelectedRow, let destinationVC = segue.destination as? EntryDetailViewController else { return }
            let entryBeingPassed = EntryController.shared.entries[indexPath.row]
            destinationVC.entry = entryBeingPassed
        }
    }
}
