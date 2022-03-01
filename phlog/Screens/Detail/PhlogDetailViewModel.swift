//
//  DetailPhlogViewModel.swift
//  phlog
//
//  Created by Miroslav Taleiko on 16.01.2022.
//

import UIKit
import Photos
import Combine

public class PhlogDetailViewModel: ObservableObject {
    
    public var imageViewSize: CGSize = .zero
    
    @Published public private(set) var image: UIImage? = nil
    @Published public var body: String? = nil
    public var date: String {
        return phlog.dateCreated.formatted(date: .long, time: .omitted)
    }
    
    private let imageManager: PHImageManager = PHImageManager.default()
    private let phlog: PhlogPost
    private let phlogManager: PhlogManager
    
    public init(phlog: PhlogPost, phlogManager: PhlogManager) {
        self.phlog = phlog
        self.body = phlog.body
        self.phlogManager = phlogManager
    }
    
}

// --------------------------------------
// MARK: - Data operations
// --------------------------------------
extension PhlogDetailViewModel {
    
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
        
        let thumbSize = thumbnailSize(from: image?.size ?? CGSize.zero)
        phlog.pictureThumbnail = self.image?.resizeTo(size: thumbSize)?.jpegData(compressionQuality: 0.8)
        
        phlog.body = body
        phlogManager.saveChanges()
    }
    
    private func thumbnailSize(from imageSize: CGSize) -> CGSize {
        let availableWidth = UIScreen.main.bounds.width
        // We don't know the exact feed cell size, so we approximate it
        let approximateCellWidth = availableWidth / 3
        let thumbSize = CGSize(width: approximateCellWidth, height: approximateCellWidth)
        return thumbSize
    }
    
    public func remove() {
        image = nil
        body = nil
        phlogManager.remove(phlog)
    }
    
    public func updatePhoto(with localIdentifier: String) {
        // Here we just updating the view model, we are not saving until "save" button is pressed
        phlog.picture?.pictureIdentifier = localIdentifier
        fetchImageFromGallery(with: imageViewSize)
    }
}
