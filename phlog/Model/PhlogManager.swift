//
//  PhotoManager.swift
//  phlog
//
//  Created by Miroslav Taleiko on 08.01.2022.
//

import Foundation
import CoreData

public class PhlogManager {
    
    private let dbStack: CoreDataStack
    
    public var mainContext: NSManagedObjectContext {
        return dbStack.mainContext
    }
    
    public init(db: CoreDataStack) {
        self.dbStack = db
    }
    
    public func newPhlog(context: NSManagedObjectContext) -> PhlogPost {
        let newPhlog = PhlogPost(context: context)
        return newPhlog
    }

    public func newPicture(with pictureIdentifier: String, context: NSManagedObjectContext) -> PhlogPicture {
        let picture = PhlogPicture(context: context)
        picture.pictureIdentifier = pictureIdentifier
        return picture
    }
    
    public func saveChanges(_ context: NSManagedObjectContext? = nil) {
        if let context = context, context.hasChanges {
            context.perform {
                do {
                    try context.save()
                } catch let error as NSError {
                    fatalError("Could not save context: \(error), \(error.userInfo)")
                }
                self.dbStack.saveMainContext()
            }
        }
    }
    
    
    public func remove(_ phlog: PhlogPost) {
        let entityToRemove = mainContext.object(with: phlog.objectID)
        mainContext.delete(entityToRemove)
        dbStack.saveMainContext()
    }
    
    public func removeAll() {
        dbStack.reset()
    }
}


extension PhlogManager {
    
    public func childContext() -> NSManagedObjectContext {
        let childMOC = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        childMOC.parent = mainContext
        return childMOC
    }
    
    public func childContext(for parent: NSManagedObjectContext) -> NSManagedObjectContext {
        let childMOC = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        childMOC.parent = parent
        return childMOC
    }
}
