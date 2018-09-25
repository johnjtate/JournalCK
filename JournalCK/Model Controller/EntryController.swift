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
    
    let privateDB = CKContainer.default().privateCloudDatabase
    
    // CRUD functions
    func saveEntry(_ entry: Entry, completion: @escaping (Bool) -> ()) {
        
        // call convenience initializer to turn entry into a CKRecord
        let record = CKRecord(entry: entry)
        
        privateDB.save(record) { (record, error) in
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
    
    func deleteEntry(entryToDelete: Entry, completion: @escaping (Bool) ->()) {
        
        // delete locally
        guard let index = self.entries.index(of: entryToDelete) else { return }
        self.entries.remove(at: index)
        
        // delete from CloudKit using recordID
        privateDB.delete(withRecordID: entryToDelete.ckRecordID) { (_, error) in
            if let error = error {
                print("There was an error in \(#function); \(error); \(error.localizedDescription)")
                completion(false)
                return
            } else {
                print("record deleted from CloudKit")
                completion(true)
            }
        }
    }
    
    func fetchEntries(completion: @escaping (Bool) -> ()) {
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: Constants.recordKey, predicate: predicate)
        
        privateDB.perform(query, inZoneWith: nil) { (records, error) in
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
    
    func updateEntry(entryToUpdate: Entry, newTitle: String, newBodyText: String, completion: @escaping (Bool) -> Void) {
        
        // update local entry
        entryToUpdate.title = newTitle
        entryToUpdate.bodytext = newBodyText
        
        // update entry's remote record
        privateDB.fetch(withRecordID: entryToUpdate.ckRecordID) { (record, error) in
            
            if let error = error{
                print("\(error.localizedDescription) \(error) in function: \(#function)")
                completion(false)
                return
            }
            
            guard let record = record else { completion(false) ; return }
            
            record[Constants.titleKey] = newTitle
            record[Constants.bodyKey] = newBodyText
            
            let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
            operation.savePolicy = .changedKeys
            operation.queuePriority = .high
            operation.qualityOfService = .userInitiated
            operation.modifyRecordsCompletionBlock = { (records, recordIDs, error) in
                completion(true)
            }
            self.privateDB.add(operation)
        }
    
    }
}
