//
//  FeedViewModel.swift
//  phlog
//
//  Created by Miroslav Taleiko on 05.02.2022.
//

import UIKit
import CoreData

public class FeedViewModel: NSObject {
    
    private let phlogManager: PhlogManager
    private var dataSource: UICollectionViewDiffableDataSource<Section, NSManagedObjectID>!
    
    private lazy var fetchedResultController: NSFetchedResultsController<PhlogPost> = {
        let fetchRequest: NSFetchRequest = PhlogPost.fetchRequest()
        fetchRequest.fetchBatchSize = 20
        let sortDescriptor = NSSortDescriptor(key: #keyPath(PhlogPost.dateCreated), ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let fetchedResultController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: phlogManager.mainContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        fetchedResultController.delegate = self
        return fetchedResultController
    }()
    
    
    public init(collectionView: UICollectionView, phlogManager: PhlogManager) {
        self.phlogManager = phlogManager
        super.init()
        dataSource = makeDataSource(with: collectionView)
    }
    
    public func fetch() {
        do {
            try fetchedResultController.performFetch()
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }

    
    private func configureCell(_ cell: FeedCell, with phlog: PhlogPost) {
        
        guard let thumbnailData = phlog.pictureThumbnail,
              let thumbnail = UIImage(data: thumbnailData) else {
                  return
              }
        
        cell.imageView.image = thumbnail
    }
    
    public func phlog(for indexPath: IndexPath) -> PhlogPost {
        let phlog = fetchedResultController.object(at: indexPath)
        return phlog
    }
}


// --------------------------------------
// MARK: - DataSource
// --------------------------------------
extension FeedViewModel {
    private enum Section: Int {
        case main = 0
    }
    
    private func makeDataSource(with collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<Section, NSManagedObjectID> {
        return UICollectionViewDiffableDataSource(collectionView: collectionView) {
            [unowned self] collectionView, indexPath, managedObjectID in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeedCell.identifier, for: indexPath) as! FeedCell
            if let phlog = try? fetchedResultController.managedObjectContext.existingObject(with: managedObjectID) as? PhlogPost {
                self.configureCell(cell, with: phlog)
            }
            return cell
        }
    }
}


extension FeedViewModel: NSFetchedResultsControllerDelegate {
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                           didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        
        var snapshot = snapshot as NSDiffableDataSourceSnapshot<Section, NSManagedObjectID>
        
        let existingSnapshot = dataSource.snapshot() as NSDiffableDataSourceSnapshot<Section, NSManagedObjectID>
        let reloadIDs: [NSManagedObjectID] = existingSnapshot.itemIdentifiers.compactMap { objectID in
            guard let currentIndex = existingSnapshot.indexOfItem(objectID),
                  let index = snapshot.indexOfItem(objectID),
                  index == currentIndex
            else {
                return nil
            }

            guard let existingObject = try? fetchedResultController.managedObjectContext.existingObject(with: objectID),
                    existingObject.isUpdated else { return nil }
            
            return objectID
        }
        snapshot.appendSections([Section.main])
        snapshot.reloadItems(reloadIDs)
        
        let shouldAnimate:Bool = !snapshot.itemIdentifiers.isEmpty
        dataSource.apply(snapshot, animatingDifferences: shouldAnimate)
    }
}


