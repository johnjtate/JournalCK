//
//  Entry.swift
//  JournalCK
//
//  Created by John Tate on 9/24/18.
//  Copyright © 2018 John Tate. All rights reserved.
//

import Foundation
import CloudKit

class Entry: Equatable {
    
    static func == (lhs: Entry, rhs: Entry) -> Bool {
        if lhs.ckRecordID != rhs.ckRecordID { return false }
        return true
    }
    
    var title: String
    var bodytext: String = ""
    var ckRecordID: CKRecord.ID
    
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
}

extension CKRecord {
    
    convenience init(entry: Entry) {
        
        self.init(recordType: Constants.recordKey, recordID: entry.ckRecordID)
        
        self.setValue(entry.title, forKey: Constants.titleKey)
        self.setValue(entry.bodytext, forKey: Constants.bodyKey)
    }
}
