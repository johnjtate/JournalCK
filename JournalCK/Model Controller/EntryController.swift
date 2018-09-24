//
//  EntryController.swift
//  JournalCK
//
//  Created by John Tate on 9/24/18.
//  Copyright © 2018 John Tate. All rights reserved.
//

import Foundation
import CloudKit

class EntryController {
    
    // shared instance
    static let shared = EntryController()
    
    // source of truth
    var entries: [Entry] = []
    
    // CRUD functions
    func saveEntry(_ entry: Entry, completion: @escaping (Bool) -> ()) {
        
        // call computed property to turn entry into a CKRecord
        let record = entry.cloudKitRecord
        
        CKContainer.default().privateCloudDatabase.save(record) { (record, error) in
            if let error = error {
                print("There was an error in \(#function); \(error); \(error.localizedDescription)")
                completion(false); return
            }
    
            if let record = record {
                // create an entry from the record to ensure that CloudKit matches what the user sees locally; failure to save means the record will not show up on the user's phone
                guard let entry = Entry(ckRecord: record) else { return }
                self.entries.append(entry)
                completion(true); return
            }
        }
    }
    
    func addEntryWith(title: String, body: String, completion: @escaping (Bool) -> Void) {
        let entry = Entry(title: title, bodytext: body)
        saveEntry(entry) { (success) in
            if success {
                completion(true)
                return
            } else {
                completion(false)
            }
        }
    }
    
    func deleteEntry(entryToDelete: Entry) {
        
        // need recordID to delete from CloudKit
        let recordID = entryToDelete.ckRecordID
        
        CKContainer.default().privateCloudDatabase.delete(withRecordID: recordID) { (record, error) in
            if let error = error {
                print("There was an error in \(#function); \(error); \(error.localizedDescription)")
                return
            }
            
            if record != nil {
                guard let index = self.entries.index(of: entryToDelete) else { return }
                self.entries.remove(at: index)
            }
        }
    }
    
    func fetchEntries(completion: @escaping (Bool) -> ()) {
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: Constants.recordKey, predicate: predicate)
        
        CKContainer.default().privateCloudDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("There was an error in \(#function); \(error); \(error.localizedDescription)")
                completion(false)
                return
            }
            guard let records = records else { completion(false); return }
            let entries = records.compactMap{ Entry(ckRecord: $0) }
            self.entries = entries
            completion(true)
        }
    }
    
    func update(entryToUpdate: Entry, newTitle: String, newBodyText: String) {
        
        let recordsOperation = CKModifyRecordsOperation()
        
        // initialize new entry with updated values
        let updatedEntry = Entry(title: newTitle, bodytext: newBodyText)
        let recordsToSave = [updatedEntry.cloudKitRecord]
        
        recordsOperation.savePolicy = .changedKeys
        recordsOperation.recordsToSave = recordsToSave
        recordsOperation.qualityOfService = .userInteractive
    }
}
