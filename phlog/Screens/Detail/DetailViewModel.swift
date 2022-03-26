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
    
    public var imageViewSize: CGSize = .zero
    
    @Published public private(set) var image: UIImage? = nil
    @Published public var body: String? = nil
    public var date: String {
        return phlog.dateCreated.formatted(date: .long, time: .omitted)
    }
    
    private let imageManager: PHImageManager = PHImageManager.default()
    private let phlogManager: PhlogManager
    private var phlog: PhlogPost
    
    // Something has to retain child context because NSManagedObject doesn't
    private var context: NSManagedObjectContext!

    
    public init(phlogManager: PhlogManager, phlog: PhlogPost? = nil) {
        self.phlogManager = phlogManager
        self.context = phlogManager.childContext()
        
        if let phlog = phlog {
            let objectId = phlog.objectID
            self.phlog = context.object(with: objectId) as! PhlogPost
            self.body = phlog.body
        } else {
            self.phlog = phlogManager.newPhlog(context: context)
        }
    }
    
}

// --------------------------------------
// MARK: - Data operations
// --------------------------------------
extension DetailViewModel {
    
    public func fetchImage() {
        if let pictureData = phlog.picture?.pictureData {
            image = UIImage(data: pictureData)
        } else {
            fetchImageFromGallery(with: imageViewSize)
        }
    }
    
    private func fetchImageFromGallery(with size: CGSize) {
        if let localIdentifier = phlog.picture?.pictureIdentifier,
           let asset = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil).lastObject {
            
            
            
            let requestOptions = PHImageRequestOptions()
            requestOptions.deliveryMode = .opportunistic
            requestOptions.isNetworkAccessAllowed = true
            requestOptions.resizeMode = .exact
            requestOptions.version = .current
            
            imageManager.requestImage(for: asset,
                                         targetSize: size,
                                         contentMode: .aspectFill,
                                         options: requestOptions) { image, _ in
                
                self.image = image
            }
        }
    }
    
    public func save() {
        phlog.picture?.pictureData = self.image?.pngData()
        
        // This view model doesn't know a particular cell size
        // So, we consider it's about 1/3 of the screen width
        // And calculation thumbnail for the feed accordingly
        // Not the best idea
        let thumbSize = thumbnailSize(from: image?.size ?? CGSize.zero)
        phlog.pictureThumbnail = self.image?.resizeTo(size: thumbSize)?.jpegData(compressionQuality: 0.8)
        
        phlog.body = body
        phlogManager.saveChanges(context)
    }
    
    private func thumbnailSize(from imageSize: CGSize) -> CGSize {
        let approximateCellWidth = UIScreen.main.bounds.width / 3
        let desiredSize = CGSize(width: approximateCellWidth, height: approximateCellWidth)
        
        let widthScale = desiredSize.width / imageSize.width
        let heightScale = desiredSize.height / imageSize.height
        
        let scaleFactor = min(widthScale, heightScale)
        let scaledSize = CGSize(width: imageSize.width * scaleFactor, 
                                height: imageSize.height * scaleFactor)
        
        return scaledSize
    }
    
    public func remove() {
        image = nil
        body = nil
        phlogManager.remove(phlog)
    }
    
    public func updatePhoto(with photoIdentifier: String) {
        if let picture = phlog.picture {
            picture.pictureIdentifier = photoIdentifier
        } else {
            let newPicture = phlogManager.newPicture(with: photoIdentifier, context: context)
            phlog.picture = newPicture
        }
        fetchImageFromGallery(with: imageViewSize)
    }
}
