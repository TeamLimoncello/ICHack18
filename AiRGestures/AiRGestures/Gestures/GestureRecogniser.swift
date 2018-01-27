//
//  GestureRecogniser.swift
//  AiRGestures
//
//  Created by Jay Lees on 27/01/2018.
//  Copyright © 2018 Lewis Bell. All rights reserved.
//

import Vision
import CoreML
import AVFoundation

public class GestureRecogniser {
    
    var delegate: GestureDelegate?
    
    public func detectGestures(in image: CMSampleBuffer) {
        guard let cvPixelBuffer = CMSampleBufferGetImageBuffer(image) else {
            return
        }
        do {
            //CoreML Detection of Gestures
            let gestureModel = try VNCoreMLModel(for: GestureModel().model)
            let gestureRequest = VNCoreMLRequest(model: gestureModel, completionHandler: didGetGestureResults)
            let handler = VNImageRequestHandler(cvPixelBuffer: cvPixelBuffer, options: [:])
            try handler.perform([gestureRequest])
        } catch let error {
            delegate?.didGetError(error)
        }
    }

    private func didGetGestureResults(request: VNRequest, error: Error?) {
        guard error == nil else {
            delegate?.didGetError(error!)
            return
        }
        
        guard let results = request.results as? [VNClassificationObservation] else {
            print("Error whilst parsing results")
            return
        }
        let probableObservation = results.sorted { (observationA, observationB) -> Bool in
            return observationA.confidence > observationB.confidence
        }.first!
        delegate?.didGetGesture(Gesture(rawValue: probableObservation.identifier)!)
    }
    
}
