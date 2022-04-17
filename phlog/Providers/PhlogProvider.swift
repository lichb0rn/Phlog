//
//  PhotoManager.swift
//  phlog
//
//  Created by Miroslav Taleiko on 08.01.2022.
//

import Foundation
import CoreData

public protocol PhlogService {
    var mainContext: NSManagedObjectContext { get }
    
    func newPhlog(context: NSManagedObjectContext) -> PhlogPost
    func newPicture(withID id: String, context: NSManagedObjectContext) -> PhlogPicture
    func remove(_ phlog: PhlogPost)
    
    func saveChanges(context: NSManagedObjectContext)
    func makeChildContext() -> NSManagedObjectContext
}

public class PhlogProvider {
    
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
    
    public func newPicture(withID id: String, context: NSManagedObjectContext) -> PhlogPicture {
        let picture = PhlogPicture(context: context)
        picture.pictureIdentifier = id
        return picture
    }
    
    public func remove(_ phlog: PhlogPost) {
        guard let entityToRemove = try? mainContext.existingObject(with: phlog.objectID) else {
            return
        }
        
        mainContext.delete(entityToRemove)
        dbStack.saveMainContext()
    }
    
    public func removeAll() {
        dbStack.reset()
    }
}


extension PhlogProvider {
    public func saveChanges(context: NSManagedObjectContext) {
        guard context.hasChanges else { return }
        
        context.perform {
            do {
                try context.save()
            } catch let error as NSError {
                fatalError("Could not save context: \(error), \(error.userInfo)")
            }
            self.dbStack.saveMainContext()
        }
    }
    
    public func makeChildContext() -> NSManagedObjectContext {
        let childMOC = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        childMOC.parent = mainContext
        return childMOC
    }
    
    public func makeChildContext(for parent: NSManagedObjectContext) -> NSManagedObjectContext {
        let childMOC = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        childMOC.parent = parent
        return childMOC
    }
}

extension PhlogProvider: PhlogService {}
