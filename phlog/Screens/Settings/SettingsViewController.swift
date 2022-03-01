//
//  SettingsViewController.swift
//  phlog
//
//  Created by Miroslav Taleiko on 04.12.2021.
//

import UIKit

public protocol SettingsViewControllerDelegate: AnyObject {
    func changedLayout(to layoutIndex: Int)
    func removeRequested()
}

public class SettingsViewController: UITableViewController {
    
    public weak var delegate: SettingsViewControllerDelegate?
    @IBOutlet weak var layoutControl: UISegmentedControl!
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    @IBAction func layoutControlTapped(_ sender: UISegmentedControl) {
        delegate?.changedLayout(to: sender.selectedSegmentIndex)
    }
    
    @IBAction func removeButtonTapped(_ sender: UIButton) {
        delegate?.removeRequested()
    }
    
}

extension SettingsViewController: Storyboarded {
    static var name: String {
        return "SettingsViewController"
    }
}
