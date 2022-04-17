//
//  DetailPhlogViewModel.swift
//  phlog
//
//  Created by Miroslav Taleiko on 16.01.2022.
//

import UIKit
import Photos
import Combine
import CoreData

public class DetailViewModel {
    
    private var targetSize: CGSize = .zero
    
    @Published public var image: UIImage? = nil
    @Published public var body: String? = nil
    public var date: String {
        return phlog.dateCreated.formatted(date: .long, time: .omitted)
    }
    
    private let imageProvider: ImageService
    private let phlogProvider: PhlogService
    private var phlog: PhlogPost
    
    // Something has to retain child context because NSManagedObject doesn't
    private var context: NSManagedObjectContext!
    
    
    public init(phlogProvider: PhlogService, phlog: PhlogPost? = nil, imageProvider: ImageService = ImageProvider()) {
        self.phlogProvider = phlogProvider
        self.imageProvider = imageProvider
        self.context = phlogProvider.makeChildContext()
        
        if let phlog = phlog {
            let objectId = phlog.objectID
            self.phlog = context.object(with: objectId) as! PhlogPost
            self.body = phlog.body
        } else {
            self.phlog = phlogProvider.newPhlog(context: context)
        }
    }
    
}

// --------------------------------------
// MARK: - Data operations
// --------------------------------------
extension DetailViewModel {
    
    func fetchImage(targetSize: CGSize) {
        self.targetSize = targetSize
        if let pictureData = phlog.picture?.pictureData {
            image = UIImage(data: pictureData)
        } else {
            fetchFromLibrary(targetSize: targetSize)
        }
    }
    
    private func fetchFromLibrary(targetSize: CGSize) {
        guard let id = phlog.picture?.pictureIdentifier else { return }
        let imageData = ImageData(identitifier: id)
        imageProvider.requestImage(for: imageData, targetSize: targetSize) { [weak self] imgData in
            self?.image = imgData?.image
        }
    }

    
    public func updatePhoto(with photoIdentifier: String) {
        if let picture = phlog.picture {
            picture.pictureIdentifier = photoIdentifier
        } else {
            let newPicture = phlogProvider.newPicture(withID: photoIdentifier, context: context)
            phlog.picture = newPicture
        }
        fetchFromLibrary(targetSize: self.targetSize)
    }
    
    public func save() {
        phlog.picture?.pictureData = image?.pngData()
        
        // This view model doesn't know a particular cell size
        // So, we consider it's about 1/3 of the screen width
        // And calculation thumbnail for the feed accordingly
        // Not the best idea
        
        let approximateCellWidth = UIScreen.main.bounds.width / 3
        let desiredSize = CGSize(width: approximateCellWidth, height: approximateCellWidth)
        let thumbnailData = image?.thumbnail(for: desiredSize)?.jpegData(compressionQuality: 0.8)
        
        phlog.pictureThumbnail = thumbnailData
        phlog.body = body
        phlogProvider.saveChanges(context: context)
    }
    
    public func remove() {
        phlogProvider.remove(phlog)
    }
}
