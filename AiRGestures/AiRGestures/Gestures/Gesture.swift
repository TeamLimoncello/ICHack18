//
//  Gesture.swift
//  AiRGestures
//
//  Created by Jay Lees on 27/01/2018.
//  Copyright © 2018 Lewis Bell. All rights reserved.
//

import Foundation


public enum Gesture: String {
    case ok = "OK"
    case twoFingers = "TWO"
    case fiveFingers = "FIVE"
    case fist = "FIST"
    case none = "NONE"
}

func getEmoji(gesture: Gesture) -> String{
    switch gesture {
    case .ok:
        return "👌"
    case .twoFingers:
        return "☝️"
    case .fiveFingers:
        return "🖐"
    case .fist:
        return "✊"
    case .none:
        return ""
    }
}
