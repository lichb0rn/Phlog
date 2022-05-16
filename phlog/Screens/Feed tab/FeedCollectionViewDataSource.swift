//
//  FeedCollectionViewDataSource.swift
//  phlog
//
//  Created by Miroslav Taleiko on 13.03.2022.
//

import UIKit
import CoreData

public typealias FeedDataSource = UICollectionViewDiffableDataSource<String, NSManagedObjectID>

public class FeedCollectionViewDataSource: FeedDataSource {
    
    public init(collectionView: UICollectionView,
                controller: NSFetchedResultsController<PhlogPost>,
                configure: @escaping (FeedCell, PhlogPost) -> Void) {
        
        super.init(collectionView: collectionView) {
            (collectionView, indexPath, managedObjectID) -> UICollectionViewCell? in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeedCell.identifier, for: indexPath) as! FeedCell
            if let phlog = try? controller.managedObjectContext.existingObject(with: managedObjectID) as? PhlogPost {
                configure(cell, phlog)
            }
            return cell
        }
    }
}
