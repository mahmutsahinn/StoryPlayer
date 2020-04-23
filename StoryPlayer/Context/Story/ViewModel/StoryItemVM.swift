//
//  StoryItemVM.swift
//  StoryPlayer
//
//  Created by Mahmut  Şahin on 21.04.2020.
//  Copyright © 2020 Mahmut  Şahin. All rights reserved.
//

import UIKit

class StoryItemVM {

    var storyItem: StoryItem!
    
    init(_ storyItem: StoryItem) {
        self.storyItem = storyItem
    }
    
    var mediaUrl: String {
        return storyItem.mediaUrl
    }
    
    var duration: Int {
        return storyItem.duration
    }
    
    
    var isVideo: Bool {
        return storyItem.isVideo
    }
}
