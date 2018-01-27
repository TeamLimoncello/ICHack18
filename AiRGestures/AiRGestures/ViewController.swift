//
//  ViewController.swift
//  AiRGestures
//
//  Created by Lewis Bell on 27/01/2018.
//  Copyright © 2018 Lewis Bell. All rights reserved.
//

import UIKit
import AVFoundation
import MultipeerConnectivity

enum PTType: UInt32 {
    case number = 100
    case image = 101
}
class ViewController: UIViewController {
    
    
    @IBOutlet weak var emojiView: UITextView!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    var gestureRecogniser: GestureRecogniser!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    //var vision: Vision!
    
    override func viewDidLoad() {
        gestureRecogniser = GestureRecogniser()
        //vision = Vision()
        gestureRecogniser.delegate = self
        PTManager.instance.delegate = self
        PTManager.instance.connect(portNumber: 4986)
        print("PT Connected")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Camera Setup
        let session = AVCaptureSession()
        session.sessionPreset = AVCaptureSession.Preset.high
        guard let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front) else{
            print("Front camera not available")
            return
        }
        
        do{
            let videoDeviceInput = try AVCaptureDeviceInput(device: frontCameraDevice)
            if session.canAddInput(videoDeviceInput){
                session.addInput(videoDeviceInput)
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
                videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspect
                videoPreviewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                cameraView.layer.addSublayer(videoPreviewLayer)
                session.startRunning()
            }
            let videoDeviceOutput = AVCaptureVideoDataOutput()
            let thread = DispatchQueue(label: "VideoSampleThread")
            videoDeviceOutput.setSampleBufferDelegate(self, queue: thread)
            session.addOutput(videoDeviceOutput)
        } catch let error{
            print("Error whilst setting up camera \(error)")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.videoPreviewLayer!.frame = self.cameraView.bounds
    }

}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        if vision.requiresRefresh() {
//            vision.setBackgroundImage(sampleBuffer)
//        }
        
        
        gestureRecogniser.detectGestures(in: sampleBuffer)
//        let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
//        let width = CVPixelBufferGetHeight(pixelBuffer)
//        let height = CVPixelBufferGetWidth(pixelBuffer)
//
//        let ciImage = CIImage(cvPixelBuffer: pixelBuffer).oriented(.leftMirrored)
//        let videoImage = Vision.context.createCGImage(ciImage, from: CGRect(x: 0, y: 0, width: width, height: height))
//
//        let result = vision.processPixels(in: UIImage(cgImage: videoImage!))
//        DispatchQueue.main.sync {
//            imageView.image = result
//        }
    }
}

extension ViewController: GestureDelegate {
    
    func didGetError(_ error: Error) {
        print("Error! \(error)")
        emojiView.text = "💔"
    }
    
    func didGetGesture(_ gesture: Gesture) {
        DispatchQueue.main.sync {
            emojiView.text = getEmoji(gesture: gesture)
            PTManager.instance.sendObject(object:gesture.rawValue, type: PTType.number.rawValue)
        }
    }
    
    func didGetSwipe(_ swipe: Swipe) {
        print(swipe)
    }
    
}

extension ViewController: PTManagerDelegate {
    
    func peertalk(shouldAcceptDataOfType type: UInt32) -> Bool {
        return true
    }
    
    func peertalk(didReceiveData data: Data, ofType type: UInt32) {
    }
    
    func peertalk(didChangeConnection connected: Bool) {
    }
    
    
}
