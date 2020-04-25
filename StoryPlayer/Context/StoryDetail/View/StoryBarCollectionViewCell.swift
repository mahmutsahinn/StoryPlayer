//
//  StoryBarCollectionViewCell.swift
//  StoryPlayer
//
//  Created by Mahmut  Şahin on 22.04.2020.
//  Copyright © 2020 Mahmut  Şahin. All rights reserved.
//

import UIKit

class StoryBarCollectionViewCell: UICollectionViewCell {

    static let identifier = "StoryBarCollectionViewCell"

    @IBOutlet private var viewBar: BarView!
    
    var timer = Timer()
    
    var percentage: CGFloat = 0 {
        didSet {
            viewBar.percentage = percentage
        }
    }
    
    var barWidth: Int = 0 {
        didSet {
            viewBar.barWidth = CGFloat(barWidth - 10)
        }
    }

}
