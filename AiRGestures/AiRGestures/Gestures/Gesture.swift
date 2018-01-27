//
//  Gesture.swift
//  AiRGestures
//
//  Created by Jay Lees on 27/01/2018.
//  Copyright © 2018 Lewis Bell. All rights reserved.
//

import Foundation


public enum Gesture: String {
    case thumb = "THUMB"
    case oneFinger = "ONE"
    case twoFingers = "TWO"
    case threeFingers = "THREE"
    case fourFingers = "FOUR"
    case fiveFingers = "FIVE"
    case fist = "FIST"
}

func getEmoji(gesture: Gesture) -> String{
    switch gesture {
    case .thumb:
        return "👍"
    case .oneFinger:
        return "☝️"
    case .twoFingers:
        return "✌️"
    case .threeFingers:
        return "👆👆👆"
    case .fourFingers:
        return "✌️✌️"
    case .fiveFingers:
        return "🖐"
    case .fist:
        return "✊"
    }
}
