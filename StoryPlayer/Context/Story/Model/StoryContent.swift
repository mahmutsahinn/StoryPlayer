//
//  StoryContent.swift
//  StoryPlayer
//
//  Created by Mahmut  Şahin on 21.04.2020.
//  Copyright © 2020 Mahmut  Şahin. All rights reserved.
//

struct StoryContent: Codable {
    
    var storyGroups: [StoryGroup]
    
    init() {
        self.storyGroups = [StoryGroup]()
    }
}
