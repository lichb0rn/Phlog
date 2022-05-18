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
    private var cancellable = Set<AnyCancellable>()

    @Published private(set) var isMenuActive: Bool = false
    @Published private(set) var image: UIImage? {
        didSet {
            if image != nil {
                isMenuActive = true
            }
        }
    }

    @Published private(set) var error: Error?
    @Published private(set) var address: String?
    @Published var body: String?
    var date: String {
        return phlog.dateCreated.formatted(date: .long, time: .omitted)
    }
    var headerViewHeight: CGFloat {
        return UIScreen.main.bounds.height / 2
    }
    
    private(set) var phlog: PhlogPost
    private let imageProvider: ImageService
    private let phlogProvider: PhlogService
    
    private var locationProvider: LocationService
    private var location: CLLocation?
    private var placemark: CLPlacemark?

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
        address = phlog.location?.placemark?.string()
    }
    
    func updatePhoto(with photoIdentifier: String) {
        let imageData = ImageData(identifier: photoIdentifier)
        let targetSize = CGSize(width: UIScreen.main.bounds.width, height: headerViewHeight)
        imageProvider.requestImage(for: imageData, targetSize: targetSize) { [weak self] imgData in
            guard let self = self else { return }
            self.image = imgData?.image
            self.phlog.picture = self.phlogProvider.newPicture(withID: imageData.identifier, context: self.context)
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

extension DetailViewModel {

    func addLocation() {
        if locationProvider.isAuthorized {
            subscribeForPlacemark()
            subscribeForLocation()
        } else {
            error = PhlogLocationError.locationDenied
        }
    }

    private func subscribeForLocation() {
        locationProvider.location
            .sink { [weak self] result in
                switch result {
                case .finished:
                    break
                case .failure(let err):
                    self?.error = err
                }
            } receiveValue: { location in
                self.location = location
                self.newPhlogLocation()
            }
            .store(in: &cancellable)
        locationProvider.startLocationTracking(waitFor: 60)
    }

    private func subscribeForPlacemark() {
        locationProvider.placemark
            .sink { [weak self] result in
                switch result {
                case .finished:
                    break
                case .failure(let err):
                    self?.error = err
                }
            } receiveValue: { placemark in
                self.placemark = placemark
                self.newPhlogPlacemark()
                
            }
            .store(in: &cancellable)
    }

    private func newPhlogLocation() {
        guard let location = location else { return }
        locationProvider.startGeocoding(location)
        let newPhlogLocation = phlogProvider.newLocation(latitude: location.coordinate.latitude,
                                                         longitude: location.coordinate.longitude,
                                                         placemark: nil,
                                                         context: context)
        phlog.location = newPhlogLocation
    }

    private func newPhlogPlacemark() {
        guard let location = phlog.location, let placemark = placemark else { return }
        location.placemark = placemark
        address = placemark.string()
    }
}

enum PhlogLocationError {
    case locationDenied
    case invalidLocation
}

extension PhlogLocationError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .locationDenied: return "Unfortunately the app does not have permissions for this"
        case .invalidLocation: return "Could not determine your current location"
        }
    }
}
