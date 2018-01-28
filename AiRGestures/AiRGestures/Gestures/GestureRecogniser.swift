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
    
    private enum SwipeLocation: String {
        case left = "left"
        case center = "center"
        case right = "right"
        case empty = "empty"
    }
    
    var delegate: GestureDelegate?
    private var previousSwipeLocation: SwipeLocation?
    
    public func detectGestures(in image: CMSampleBuffer) {
        guard let cvPixelBuffer = CMSampleBufferGetImageBuffer(image) else {
            return
        }
        do {
            //CoreML Detection of Gestures
            //let handlers = afterAll(fns: [didGetGestureResults, didGetSwipeResults], finalizer: didGetBothResults)
            
            let gestureModel = try VNCoreMLModel(for: GestureModel().model)
            let gestureRequest = VNCoreMLRequest(model: gestureModel, completionHandler: didGetGestureResults)
            let handler = VNImageRequestHandler(cvPixelBuffer: cvPixelBuffer, options: [:])
            try handler.perform([gestureRequest])
            
            let swipeModel = try VNCoreMLModel(for: SwipeRecogniser().model)
            let swipeRequest = VNCoreMLRequest(model: swipeModel, completionHandler: didGetSwipeResults)
            let otherHandler = VNImageRequestHandler(cvPixelBuffer: cvPixelBuffer, options: [:])
            try otherHandler.perform([swipeRequest])
            
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
        let filteredResults = results.filter({$0.confidence > 0.1})
        let probableObservation = filteredResults.sorted { (observationA, observationB) -> Bool in
            return observationA.confidence > observationB.confidence
            }.first
        // return (probableObservation.identifier, probableObservation.confidence)
        if case nil = probableObservation {
            return
        }
        delegate?.didGetGesture(Gesture(rawValue: probableObservation!.identifier)!)
    }
    
    private func didGetSwipeResults(request: VNRequest, error: Error?) {
        

        
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
        
        let swipeLocation = SwipeLocation(rawValue: probableObservation.identifier)!
        
        switch swipeLocation {
        case .left:
            if previousSwipeLocation == .center {
                delegate?.didGetSwipe(.right)
            }
        case .right:
            if previousSwipeLocation == .center {
                delegate?.didGetSwipe(.left)
            }
        default:
            break
        }
        
        previousSwipeLocation = swipeLocation
        
        
        // return (probableObservation.identifier, probableObservation.confidence)
    }
    
//    func didGetBothResults(_ results: [(String, Int)?]) {
//        results.sorted { (a, b) -> Bool in
//            return a?.1 ?? 0  > b?.1 ?? 0
//        }.first
//
//    }
//
//    func afterAll<T,U,V>(fns: [(_ arg1: T, _ arg2: U) -> V], finalizer: @escaping ([V]) -> Void) {
//        var responses = [V?](repeating: nil, count: fns.count)
//        var boundFns = [(_: T, _: U) -> Void]()
//        for (i,fn) in fns.enumerated() {
//            boundFns.append({ (arg1, arg2) in
//                responses[i] = fn(arg1, arg2)
//                if !responses.contains(where: {$0 == nil}) {
//                    finalizer(responses.map({$0!}))
//                }
//            })
//        }
//    }
    
}
