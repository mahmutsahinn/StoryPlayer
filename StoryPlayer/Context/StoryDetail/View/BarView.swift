//
//  BarView.swift
//  StoryPlayer
//
//  Created by Mahmut  Şahin on 22.04.2020.
//  Copyright © 2020 Mahmut  Şahin. All rights reserved.
//

import UIKit

class BarView: UIView {

    var passiveColor = UIColor.lightGray

    var percentage: CGFloat = 0 {
        didSet {
            let totalWidth = self.frame.size.width
            let newMargin = (totalWidth / 100.0) * percentage
            
            UIView.animate(withDuration: 0.1) {
                self.passiveViewLeadingConstraint.constant = newMargin
                self.layoutIfNeeded()
            }
        }
    }
    
    private var passiveView = UIView()
    private var passiveViewLeadingConstraint: NSLayoutConstraint!
    private var activeView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        layer.cornerRadius = 1.5
        clipsToBounds = true
        activeView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activeView)
        activeView.heightAnchor.constraint(equalToConstant: 10.0).isActive = true
        activeView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        activeView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        activeView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        activeView.backgroundColor = .white
        passiveView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(passiveView)
        passiveView.heightAnchor.constraint(equalToConstant: 10.0).isActive = true
        passiveViewLeadingConstraint = passiveView.leftAnchor.constraint(equalTo: self.leftAnchor)
        passiveViewLeadingConstraint.isActive = true
        passiveView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        passiveView.centerYAnchor.constraint(equalTo: activeView.centerYAnchor).isActive = true
        passiveView.backgroundColor = passiveColor
    }
}
