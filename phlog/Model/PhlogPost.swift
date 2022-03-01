//
//  PhlogPost+CoreDataClass.swift
//  phlog
//
//  Created by Miroslav Taleiko on 22.02.2022.
//
//

import Foundation
import CoreData


public class PhlogPost: NSManagedObject {
    
    @NSManaged public var body: String?
    @NSManaged public var dateCreated: Date
    @NSManaged public var id: UUID
    @NSManaged public var pictureThumbnail: Data?
    @NSManaged public var picture: PhlogPicture?

    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        dateCreated = Date()
        id = UUID()
    }
    
}

extension PhlogPost {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PhlogPost> {
        return NSFetchRequest<PhlogPost>(entityName: "PhlogPost")
    }
}

extension PhlogPost: Identifiable { }