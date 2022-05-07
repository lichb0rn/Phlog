//
//  FeedViewModel.swift
//  phlog
//
//  Created by Miroslav Taleiko on 05.02.2022.
//

import UIKit
import CoreData

class FeedViewModel: NSObject {
    
    private let phlogProvider: PhlogService
    private var dataSource: FeedDataSource!
    
    private lazy var fetchedResultController: NSFetchedResultsController<PhlogPost> = {
        let fetchRequest: NSFetchRequest = PhlogPost.fetchRequest()
        fetchRequest.fetchBatchSize = 20
        let sortDescriptor = NSSortDescriptor(key: #keyPath(PhlogPost.dateCreated), ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let fetchedResultController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: phlogProvider.mainContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        fetchedResultController.delegate = self
        return fetchedResultController
    }()
    
    
    init(collectionView: UICollectionView, phlogProvider: PhlogService) {
        self.phlogProvider = phlogProvider
        super.init()
        dataSource = FeedCollectionViewDataSource(collectionView: collectionView,
                                                  controller: fetchedResultController,
                                                  configure: configureCell(_:with:))
    }
    
    func fetch() {
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
    
    func phlog(for indexPath: IndexPath) -> PhlogPost {
        let phlog = fetchedResultController.object(at: indexPath)
        return phlog
    }
}

extension FeedViewModel: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                           didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        
        var snapshot = snapshot as NSDiffableDataSourceSnapshot<String, NSManagedObjectID>
        
        let existingSnapshot = dataSource.snapshot() as NSDiffableDataSourceSnapshot<String, NSManagedObjectID>
        let reloadIDs: [NSManagedObjectID] = existingSnapshot.itemIdentifiers.compactMap { objectID in
            guard let currentIndex = existingSnapshot.indexOfItem(objectID),
                  let index = snapshot.indexOfItem(objectID),
                  index == currentIndex
            else {
                return nil
            }
            
            guard let existingObject = try? controller.managedObjectContext.existingObject(with: objectID),
                  existingObject.isUpdated else { return nil }
            
            return objectID
        }
        
        snapshot.reloadItems(reloadIDs)
        
        let shouldAnimate:Bool = !snapshot.itemIdentifiers.isEmpty
        dataSource.apply(snapshot, animatingDifferences: shouldAnimate)
    }
}
