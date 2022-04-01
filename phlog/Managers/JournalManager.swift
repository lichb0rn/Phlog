//
//  JournalManager.swift
//  phlog
//
//  Created by Miroslav Taleiko on 27.03.2022.
//

import UIKit
import CoreLocation

public struct Journal {
    var image: UIImage? = nil
    var title: String
    var count: Int = 0
    let locations: [CLLocation]
}

fileprivate var testJournal = Journal(title: "My supa journal",
                                  locations: [CLLocation(latitude: 55.752121, longitude: 37.617664),
                                             CLLocation(latitude: 55.754663648, longitude: 37.609830894)])

public class JournalManager {
    
    private let dbStack: CoreDataStack
    
    public init(db: CoreDataStack) {
        self.dbStack = db
    }
    
    public func fetchCount() -> Int {
        return 100
    }
    
    public func fetchJournal() -> Journal {
        testJournal.count = fetchCount()
        return testJournal
    }
    
}
