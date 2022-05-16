//
//  FeedCell.swift
//  phlog
//
//  Created by Miroslav Taleiko on 15.12.2021.
//

import UIKit


public class FeedCell: UICollectionViewCell {

    public static let identifier = "FeedCell"
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    public override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        stopPreviosActivity()
    }
    
    private func showImage(_ image: UIImage?) {
        stopPreviosActivity()
        imageView.image = image
    }
    
    private func stopPreviosActivity() {
        activityIndicator.stopAnimating()
        imageView.image = nil
    }
}

extension UICollectionViewCell {
    class var storyboardID : String {
        return "\(self)"
    }
    
    static func registerCellXib(with collectionView: UICollectionView){
        let nib = UINib(nibName: self.storyboardID, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: self.storyboardID)
    }
}
