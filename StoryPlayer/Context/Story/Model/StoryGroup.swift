//
//  StoryGroup.swift
//  StoryPlayer
//
//  Created by Mahmut  Şahin on 21.04.2020.
//  Copyright © 2020 Mahmut  Şahin. All rights reserved.
//

struct StoryGroup: Codable {

    var groupName: String
    var thumbUrl: String
    var stories: [StoryItem]
}
