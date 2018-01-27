//
//  GestureRecogniser.swift
//  AiRGestures
//
//  Created by Jay Lees on 27/01/2018.
//  Copyright © 2018 Lewis Bell. All rights reserved.
//

import Foundation
import CoreImage

public class GestureRecogniser {
    var model: GestureModel
    
    
    init(){
        self.model = GestureModel()
    }
    
    public func detectGestures(in image: CVPixelBuffer) -> Gesture? {
        print("here")
        do {
            let prediction = try model.prediction(data: image)
            print(prediction.classLabel)
        } catch let error {
            print(error)
        }
        return nil
    }
}
