//
//  GestureRecogniser.swift
//  AiRGestures
//
//  Created by Jay Lees on 27/01/2018.
//  Copyright © 2018 Lewis Bell. All rights reserved.
//

import Vision
import CoreML

public class GestureRecogniser {
    
    var delegate: GestureDelegate?
    
    public func detectGestures(in image: CVPixelBuffer) {
        do {
            let model = try VNCoreMLModel(for: GestureModel().model)
            let request = VNCoreMLRequest(model: model, completionHandler: didGetResults)
            let handler = VNImageRequestHandler(cvPixelBuffer: image, options: [:])
            try handler.perform([request])
        } catch let error {
            delegate?.didGetError(error)
        }
    }
    
    func didGetResults(request: VNRequest, error: Error?) {
        guard error == nil else {
            delegate?.didGetError(error!)
            return
        }
        
        guard let results = request.results as? [VNClassificationObservation] else {
            print("What")
            return
        }
        let probableObservation = results.sorted { (observationA, observationB) -> Bool in
            return observationA.confidence > observationB.confidence
        }.first!
        
        delegate?.didGetGesture(Gesture(rawValue: probableObservation.identifier)!)
        
    }
}
