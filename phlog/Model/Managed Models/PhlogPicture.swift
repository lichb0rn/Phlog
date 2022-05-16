//
//  PhlogPicture.swift
//  phlog
//
//  Created by Miroslav Taleiko on 24.02.2022.
//

import UIKit
import CoreData

public class PhlogPicture: NSManagedObject {
    
    @NSManaged public var pictureData: Data?
    @NSManaged public var pictureIdentifier: String?

}

extension PhlogPicture {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PhlogPicture> {
        return NSFetchRequest<PhlogPicture>(entityName: "PhlogPicture")
    }
}
