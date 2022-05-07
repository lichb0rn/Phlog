//
//  Location.swift
//  phlog
//
//  Created by Miroslav Taleiko on 28.04.2022.
//


import Foundation
import CoreData
import CoreLocation

public class PhlogLocation: NSManagedObject {
    
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var placemark: CLPlacemark?
    @NSManaged public var phlog: PhlogPost?
    
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
    }
    
}

extension PhlogLocation {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PhlogLocation> {
        return NSFetchRequest<PhlogLocation>(entityName: "PhlogLocation")
    }
}
extension PhlogLocation: Identifiable { }
