//
//  PhotoManager.swift
//  phlog
//
//  Created by Miroslav Taleiko on 08.01.2022.
//

import Foundation
import Combine
import CoreData

public class PhlogManager {
    
    private let dbStack: CoreDataStack
    
    public var mainContext: NSManagedObjectContext {
        return dbStack.managedContext
    }
    
    public init(db: CoreDataStack) {
        self.dbStack = db
    }
    
    public func newPhlog() -> PhlogPost {
        let newPhlog = PhlogPost(context: mainContext)
        return newPhlog
    }
    
    public func newPhlog(_ pictureIdetnifier: String) -> PhlogPost {
        let phlog = newPhlog()
        let phlogPicture = PhlogPicture(context: mainContext)
        phlogPicture.pictureIdentifier = pictureIdetnifier
        phlog.picture = phlogPicture
        return phlog
    }
    
    public func saveChanges() {
        dbStack.saveContext()
    }

    
    public func remove(_ phlog: PhlogPost) {
        mainContext.delete(phlog)
        saveChanges()
    }

    public func removeAll() {
        dbStack.reset()
    }
}
