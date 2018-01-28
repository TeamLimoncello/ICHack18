//
//  GestureDelegate.swift
//  AiRGestures
//
//  Created by Jay Lees on 27/01/2018.
//  Copyright © 2018 Lewis Bell. All rights reserved.
//

import Foundation
import CoreGraphics

public protocol GestureDelegate {
    func didGetGesture(_ gesture: Gesture)
    func didGetError(_ error: Error)
    func didGetSwipe(_ swipe: Swipe)
}
