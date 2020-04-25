//
//  StoryContentVM.swift
//  StoryPlayer
//
//  Created by Mahmut  Şahin on 21.04.2020.
//  Copyright © 2020 Mahmut  Şahin. All rights reserved.
//

import UIKit
import Observable

class StoryContentVM: NSObject {

    var storyContent = MutableObservable(StoryContent())
    
    func fetchStories() {
        if let path = Bundle.main.path(forResource: "stories", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let content = try JSONDecoder().decode(StoryContent.self, from: data)
                storyContent.wrappedValue = content
              } catch {}
        }
    }
    
    var numberOfGroups: Int {
        return storyContent.wrappedValue.storyGroups.count
    }
    
    func getStoryGroupVM(_ index: Int) -> StoryGroupVM {
        return StoryGroupVM(storyContent.wrappedValue.storyGroups[index])
    }
    
    var currentGroupIndex = 0
    
    func setGroupCurrentIndex(_ index: Int,_ groupIndex: Int) {
        storyContent.wrappedValue.storyGroups[groupIndex].groupIndex = index
    }
}
