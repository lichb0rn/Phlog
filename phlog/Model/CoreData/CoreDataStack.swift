//
//  CoreDataStack.swift
//  phlog
//
//  Created by Miroslav Taleiko on 04.12.2021.
//

import Foundation
import CoreData

public class CoreDataStack {
    public init() { }
    
    public var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "phlog")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    public func saveMainContext () {
        if mainContext.hasChanges {
            do {
                try mainContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }


    // Brutal reset for testing purposes
    public func reset() {
        let storeContainer = persistentContainer.persistentStoreCoordinator
        
        for store in storeContainer.persistentStores {
            try! storeContainer.destroyPersistentStore(
                at: store.url!,
                ofType: store.type,
                options: nil
            )
        }
    
        persistentContainer = NSPersistentContainer(name: "phlog")
        
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
}
