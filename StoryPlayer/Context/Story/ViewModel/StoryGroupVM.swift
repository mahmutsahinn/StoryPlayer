//
//  StoryGroupVM.swift
//  StoryPlayer
//
//  Created by Mahmut  Şahin on 21.04.2020.
//  Copyright © 2020 Mahmut  Şahin. All rights reserved.
//

import UIKit

class StoryGroupVM {

    var storyGroup: StoryGroup!
    
    init(_ storyGroup: StoryGroup) {
        self.storyGroup = storyGroup
        self.currentIndex = storyGroup.groupIndex
    }
    
    var groupName: String {
        return storyGroup.groupName
    }
    
    var thumbUrl: String {
        return storyGroup.thumbUrl
    }
    
    var numberOfStories: Int {
        return storyGroup.stories.count
    }
    
    func getStoryItemVM(_ index: Int) -> StoryItemVM {
        return StoryItemVM(storyGroup.stories[index])
    }
    
    var currentIndex = 0
}
