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


class DetailViewModel: NSObject {
    
    @Published private(set) var isMenuActive: Bool = false
    @Published private(set) var image: UIImage? {
        didSet {
            if image != nil {
                isMenuActive = true
            }
        }
    }
    @Published var address: String?
    @Published var body: String?
    var date: String {
        return phlog.dateCreated.formatted(date: .long, time: .omitted)
    }
    
    private var phlog: PhlogPost
    private let imageProvider: ImageService
    private let phlogProvider: PhlogService
    
    private var locationProvider: LocationService   
    
    // Something has to retain child context because NSManagedObject doesn't
    private var context: NSManagedObjectContext!
    
    
    init(phlogProvider: PhlogService,
         phlog: PhlogPost? = nil,
         imageProvider: ImageService = PHImageManager.default(),
         locationProvider: LocationService) {
        
        self.phlogProvider = phlogProvider
        self.imageProvider = imageProvider
        self.locationProvider = locationProvider
        
        self.context = phlogProvider.makeChildContext()
        
        if let phlog = phlog {
            let objectId = phlog.objectID
            self.phlog = context.object(with: objectId) as! PhlogPost
            self.body = phlog.body
        } else {
            self.phlog = phlogProvider.newPhlog(context: context)
        }
        
        super.init()
    }
}

extension DetailViewModel {
    func didAppear() {        
        guard let pictureData = phlog.picture?.pictureData,
              let picture = UIImage(data: pictureData)  else {
            return
        }
        image = picture
    }
    
    func updatePhoto(with photoIdentifier: String, size: CGSize) {
        let imageData = ImageData(identifier: photoIdentifier)
        imageProvider.requestImage(for: imageData, targetSize: size) { [weak self] imgData in
            self?.image = imgData?.image
        }
    }
    
    func save() {
        phlog.picture?.pictureData = image?.pngData()
        
        // This view model doesn't know the cell size from the FeedView
        // So, we consider it's about 1/3 of the screen width
        // Since most of time there are 3 cells in a row
        // And calculating a thumbnail for the feed accordingly
        // Not the best idea
        let approximateCellWidth = UIScreen.main.bounds.width / 3
        let desiredSize = CGSize(width: approximateCellWidth, height: approximateCellWidth)
        let thumbnailData = image?.thumbnail(for: desiredSize)?.jpegData(compressionQuality: 0.8)
        
        phlog.pictureThumbnail = thumbnailData
        phlog.body = body
        phlogProvider.saveChanges(context: context)
    }
    
    func remove() {
        phlogProvider.remove(phlog)
    }
}

extension DetailViewModel: CLLocationManagerDelegate {


    private func addLocation(location: CLLocation, placemark: CLPlacemark? = nil) {
        let newLocation = phlogProvider.newLocation(latitude: location.coordinate.latitude,
                                                    longitude: location.coordinate.longitude,
                                                    placemark: placemark,
                                                    context: self.context)
        phlog.location = newLocation
    }
}
