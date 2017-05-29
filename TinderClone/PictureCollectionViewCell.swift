//
//  PictureCollectionViewCell.swift
//  TinderClone
//
//  Created by Max Jala on 28/05/2017.
//  Copyright © 2017 Max Jala. All rights reserved.
//

import UIKit

class PictureCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var pictureImageView: UIImageView!

    static let cellIdentifier = "PictureCollectionViewCell"
    static let cellNib = UINib(nibName: PictureCollectionViewCell.cellIdentifier, bundle: Bundle.main)
    
    
    var pictureURL: String? {
        didSet {
            self.updateUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    private func updateUI() {
        if let pictureURL = pictureURL {
            pictureImageView.loadImageUsingCacheWithUrlString(urlString: pictureURL)
        }
    }
    /*
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = 3.0
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize(width: 5, height: 10)
        
        self.clipsToBounds = false
    }
 */
}
