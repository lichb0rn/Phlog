//
//  SettingsViewController.swift
//  phlog
//
//  Created by Miroslav Taleiko on 04.12.2021.
//

import UIKit
import MapKit

public protocol JournalDetailDelegate: AnyObject {
    func changedLayout(to layoutIndex: Int)
    func removeRequested()
}

public class JournalDetailViewController: UIViewController {
    
    public weak var delegate: JournalDetailDelegate?

    @IBOutlet weak var journalImage: UIImageView!
    @IBOutlet weak var journalNameLabel: UILabel!
    @IBOutlet weak var totalPhlogsLabel: UILabel!
    @IBOutlet weak var photoMapView: MKMapView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }


    
}

extension JournalDetailViewController: Storyboarded {
    static var name: String {
        return "JournalDetailViewController"
    }
}
