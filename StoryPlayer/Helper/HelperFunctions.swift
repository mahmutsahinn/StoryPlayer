
//
//  HelperFunctions.swift
//  StoryPlayer
//
//  Created by Mahmut  Şahin on 22.04.2020.
//  Copyright © 2020 Mahmut  Şahin. All rights reserved.
//

import UIKit

var deviceHasTopNotch: Bool {
    if #available(iOS 11.0, tvOS 11.0, *) {
        return keyWindow?.safeAreaInsets.top ?? 0 > 20
    }
    return false
}

var keyWindow: UIWindow? {
    return UIApplication.shared.windows.first(where: { $0.isKeyWindow })
}

func mainThread(_ time: Double = 0, _ completion: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + time) {
        completion()
    }
}

typealias CompletionBlock = () -> Void
