//
//  Location.swift
//  phlog
//
//  Created by Miroslav Taleiko on 28.04.2022.
//


import Foundation
import CoreData
import CoreLocation
import MapKit

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

extension PhlogLocation: MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(latitude, longitude)
    }

    public var title: String? {
        return placemark?.string()
    }

    public var subtitle: String? {
        return self.phlog?.dateCreated.formatted(date: .abbreviated, time: .omitted)
    }
}



extension PhlogLocation: Identifiable { }
