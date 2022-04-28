//
//  Location.swift
//  phlog
//
//  Created by Miroslav Taleiko on 28.04.2022.
//


import Foundation
import CoreData
import CoreLocation

public class Location: NSManagedObject {
    
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var placemark: CLPlacemark?
    @NSManaged public var phlog: PhlogPost?
    
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
    }
    
}

extension Location {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }
}
extension Location: Identifiable { }
