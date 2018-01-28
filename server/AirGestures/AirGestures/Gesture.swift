//
//  Gesture.swift
//  AiRGestures
//
//  Created by Jay Lees on 27/01/2018.
//  Copyright © 2018 Lewis Bell. All rights reserved.
//

import Foundation

public enum Gesture: String {
    case ok = "ok"
    case twoFingers = "twoFingers"
    case fiveFingers = "fiveFingers"
    case fist = "fist"
    case none = "none"
}

public enum Layer: String {
    case Up = "true"
    case Down = "false"
}

func getEmoji(gesture: Gesture) -> String {
    switch gesture {
    case .ok:
        return "👌"
    case .twoFingers:
        return "✌️"
    case .fiveFingers:
        return "🖐"
    case .fist:
        return "✊"
    case .none:
        return ""
    }
}
