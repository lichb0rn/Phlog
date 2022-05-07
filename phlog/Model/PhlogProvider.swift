//
//  PhotoManager.swift
//  phlog
//
//  Created by Miroslav Taleiko on 08.01.2022.
//

import Foundation
import CoreData
import CoreLocation

protocol PhlogService {
    var mainContext: NSManagedObjectContext { get }
    
    func newPhlog(context: NSManagedObjectContext) -> PhlogPost
    func newPicture(withID id: String, context: NSManagedObjectContext) -> PhlogPicture
    func newLocation(latitude: Double, longitude: Double, placemark: CLPlacemark?, context: NSManagedObjectContext) -> PhlogLocation
    func remove(_ phlog: PhlogPost)
    
    func saveChanges(context: NSManagedObjectContext)
    func makeChildContext() -> NSManagedObjectContext
}

class PhlogProvider {
    
    private let dbStack: CoreDataStack
    
    var mainContext: NSManagedObjectContext {
        return dbStack.mainContext
    }
    
    init(db: CoreDataStack) {
        self.dbStack = db
    }
    
    func newPhlog(context: NSManagedObjectContext) -> PhlogPost {
        let newPhlog = PhlogPost(context: context)
        return newPhlog
    }
    
    func newPicture(withID id: String, context: NSManagedObjectContext) -> PhlogPicture {
        let picture = PhlogPicture(context: context)
        picture.pictureIdentifier = id
        return picture
    }

    func newLocation(latitude: Double, longitude: Double, placemark: CLPlacemark? = nil, context: NSManagedObjectContext) -> PhlogLocation {
        let newLocation = PhlogLocation(context: context)
        newLocation.latitude = latitude
        newLocation.longitude = longitude
        newLocation.placemark = placemark
        return newLocation
    }
    
    func remove(_ phlog: PhlogPost) {
        guard let entityToRemove = try? mainContext.existingObject(with: phlog.objectID) else {
            return
        }
        
        mainContext.delete(entityToRemove)
        dbStack.saveMainContext()
    }
    
    func removeAll() {
        dbStack.reset()
    }
}

// MARK: - Context Operations
extension PhlogProvider {
    func saveChanges(context: NSManagedObjectContext) {
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
    
    func makeChildContext() -> NSManagedObjectContext {
        let childMOC = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        childMOC.parent = mainContext
        return childMOC
    }
    
    func makeChildContext(for parent: NSManagedObjectContext) -> NSManagedObjectContext {
        let childMOC = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        childMOC.parent = parent
        return childMOC
    }
}

extension PhlogProvider: PhlogService {}
