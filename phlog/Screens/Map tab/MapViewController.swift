//
//  SettingsViewController.swift
//  phlog
//
//  Created by Miroslav Taleiko on 04.12.2021.
//

import UIKit
import MapKit


public class MapViewController: UIViewController {


    @IBOutlet weak var mapView: MKMapView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }


    
}

extension MapViewController: Storyboarded {
    static var name: String {
        return "MapViewController"
    }
}
