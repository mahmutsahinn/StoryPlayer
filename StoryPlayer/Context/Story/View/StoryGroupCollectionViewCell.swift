//
//  StoryGroupCollectionViewCell.swift
//  StoryPlayer
//
//  Created by Mahmut  Şahin on 21.04.2020.
//  Copyright © 2020 Mahmut  Şahin. All rights reserved.
//

import UIKit

class StoryGroupCollectionViewCell: UICollectionViewCell {

    static let identifier = "StoryGroupCollectionViewCell"
    
    @IBOutlet private var imageViewThumb: UIImageView!
    @IBOutlet private var labelGroupName: UILabel!

    var viewModel: StoryGroupVM! {
        didSet {
            updateUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageViewThumb.layer.cornerRadius = 30
        imageViewThumb.layer.borderWidth = 2
        imageViewThumb.layer.borderColor = UIColor.blue.cgColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageViewThumb.image = nil
    }
    
    private func updateUI() {
        imageViewThumb.setImageURL(viewModel.thumbUrl)
        labelGroupName.text = viewModel.groupName
    }
}
