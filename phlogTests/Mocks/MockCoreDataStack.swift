//
//  MockCoreDataStack.swift
//  phlogTests
//
//  Created by Miroslav Taleiko on 01.04.2022.
//

import CoreData
@testable import phlog

class MockCoreDataStack: CoreDataStack {
    
    var fatalErrored: Bool = false
    var error: Error? = nil
    var saved: Bool = false
    
    override init() {
        super.init()
        
        let storeDescription = NSPersistentStoreDescription()
        storeDescription.type = NSInMemoryStoreType
        
        let container = NSPersistentContainer(name: CoreDataStack.modelName)
        container.persistentStoreDescriptions = [storeDescription]
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        persistentContainer = container
    }
    
    override func saveMainContext() {
        if mainContext.hasChanges {
            do {
                try mainContext.save()
                saved = true
            } catch {
                self.error = error
                fatalErrored = true
            }
        }
    }
}
