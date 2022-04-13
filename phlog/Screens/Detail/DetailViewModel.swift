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
    
    var imageView: UIImageView?
    
    //    public private(set) var image: UIImage? = nil
    @Published public var body: String? = nil
    public var date: String {
        return phlog.dateCreated.formatted(date: .long, time: .omitted)
    }
    
    private let phlogManager: PhlogManager
    private var phlog: PhlogPost
    
    // Something has to retain child context because NSManagedObject doesn't
    private var context: NSManagedObjectContext!
    
    
    public init(phlogManager: PhlogManager, phlog: PhlogPost? = nil) {
        self.phlogManager = phlogManager
        self.context = phlogManager.makeChildContext()
        
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
            imageView?.image = UIImage(data: pictureData)
        } else {
            fetchImageFromGallery()
        }
    }
    
    private func fetchImageFromGallery() {
        if let localIdentifier = phlog.picture?.pictureIdentifier,
           let asset = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil).firstObject {
            
            self.imageView?.fetchImageAsset(asset, targetSize: self.imageView!.frame.size, completion: { [weak self] _ in
                guard let self = self else { return }
                self.imageView?.contentMode = .scaleAspectFill
            })
        }
    }
    
    public func updatePhoto(with photoIdentifier: String) {
        if let picture = phlog.picture {
            picture.pictureIdentifier = photoIdentifier
        } else {
            let newPicture = phlogManager.newPicture(withID: photoIdentifier, context: context)
            phlog.picture = newPicture
        }
        fetchImageFromGallery()
    }
    
    public func save() {
        phlog.picture?.pictureData = self.imageView?.image?.pngData()
        
        // This view model doesn't know a particular cell size
        // So, we consider it's about 1/3 of the screen width
        // And calculation thumbnail for the feed accordingly
        // Not the best idea
        let thumbSize = thumbnailSize(from: self.imageView?.image?.size ?? CGSize.zero)
        print(thumbSize)
//        phlog.pictureThumbnail = self.imageView?.image?.resizeTo(size: thumbSize)?.jpegData(compressionQuality: 0.8)
        phlog.pictureThumbnail = imageView?.image?.preparingThumbnail(of: thumbSize)?.pngData()
        
        phlog.body = body
        phlogManager.saveChanges(context: context)
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
        phlogManager.remove(phlog)
    }
    
    
}
