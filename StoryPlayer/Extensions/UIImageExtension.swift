//
//  UIImageExtension.swift
//  StoryPlayer
//
//  Created by Mahmut  Şahin on 22.04.2020.
//  Copyright © 2020 Mahmut  Şahin. All rights reserved.
//

import UIKit
import AlamofireImage

extension UIImageView {
    
    func setImageURL(_ urlString: String,_ completion: CompletionBlock? = nil) {
        self.af_cancelImageRequest()
        guard let url = URL(string: urlString) else {
            return
        }
        self.af_setImage(withURL: url, placeholderImage: nil, filter: nil, progress: nil,
                         runImageTransitionIfCached: false) { (response) in
                            completion?()
        }
    }
}
