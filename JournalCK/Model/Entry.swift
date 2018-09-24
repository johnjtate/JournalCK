//
//  Entry.swift
//  JournalCK
//
//  Created by John Tate on 9/24/18.
//  Copyright © 2018 John Tate. All rights reserved.
//

import Foundation
import CloudKit

class Entry {
    
    let title: String
    var bodytext: String = ""
    let ckRecordID: CKRecord.ID
    
    // MARK: - CloudKit
    var cloudKitRecord: CKRecord {
        
        let record = CKRecord(recordType: Constants.recordKey)
        record.setValue(title, forKey: Constants.titleKey)
        record.setValue(bodytext, forKey: Constants.bodyKey)
        record.setValue(ckRecordID, forKey: Constants.recordIdKey)
        return record
    }
    
    init(title: String, bodytext: String, ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        
        self.title = title
        self.bodytext = bodytext
        self.ckRecordID = ckRecordID
    }
 
    convenience init?(ckRecord: CKRecord) {
        
        guard let title = ckRecord[Constants.titleKey] as? String, let bodytext = ckRecord[Constants.bodyKey] as? String else { return nil }
        
        self.init(title: title, bodytext: bodytext, ckRecordID: ckRecord.recordID)
    }
}

struct Constants {
    static let recordKey = "Entry"
    static let titleKey = "Title"
    static let bodyKey = "Body"
    static let recordIdKey = "Record ID"
}
