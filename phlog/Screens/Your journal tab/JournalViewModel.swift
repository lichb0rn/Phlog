//
//  JournalViewModel.swift
//  phlog
//
//  Created by Miroslav Taleiko on 27.03.2022.
//

import UIKit
import MapKit


public class JournalViewModel: NSObject {
    
    private let journalManager: JournalManager
    private let journal: Journal?
    
    public init(manager: JournalManager) {
        self.journalManager = manager
        self.journal = journalManager.fetchJournal()
    }
    
    
    public func configureView(imageView: UIImageView, nameLabel: UILabel, countLabel: UILabel, mapView: MKMapView) {
        if let image = journal?.image {
            imageView.image = image
        } else {
            imageView.image = UIImage(systemName: "book.closed")
        }
        
        nameLabel.text = journal?.title
        countLabel.text = "Total phlogs: \(journal?.count ?? 0)"
        
    }
    
}

// --------------------------------------
// MARK: - MapView Delegate
// --------------------------------------
extension JournalViewModel: MKMapViewDelegate {
    
//    private func annotation() -> MKAnnotation {
//        
//    }
    
    
//    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        let identifier = "phlog"
//        let annotationView = MKAnnotationView(annotation: <#T##MKAnnotation?#>, reuseIdentifier: identifier)
//    }
}
