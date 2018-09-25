//
//  EntryDetailViewController.swift
//  JournalCK
//
//  Created by John Tate on 9/24/18.
//  Copyright © 2018 John Tate. All rights reserved.
//

import UIKit

class EntryDetailViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var bodyTextView: UITextView!
    
    // MARK: - Properties
    var entry: Entry? {
        didSet{
            loadViewIfNeeded()
            updateViews()
        }
    }
    
    // MARK: - Update Views Function
    func updateViews() {
        guard let entry = entry else { return }
        titleTextField.text = entry.title
        bodyTextView.text = entry.bodytext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - IBActions
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        // exit function if title field is blank
        guard let title = titleTextField.text, let body = bodyTextView.text else { return }
        
        // Case 1: Arrived by segue to detail view
        if let entry = entry {
            
            EntryController.shared.updateEntry(entryToUpdate: entry, newTitle: title, newBodyText: body) { (success) in
                
                if success {
                    print("success updating entry")
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    print("failure updatng entry")
                }
            }
            
        } else {
        // Case 2: Arrived by add button
            
            EntryController.shared.addEntryWith(title: title, body: body) { (success) in
                
                if success {
                    print("success creating new entry")
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    print("failue creating new entry")
                }
            }
        }
    }

    @IBAction func clearButtonTapped(_ sender: Any) {
        
        titleTextField.text = ""
        bodyTextView.text = ""
    }

}
