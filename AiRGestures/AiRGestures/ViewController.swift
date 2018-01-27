//
//  ViewController.swift
//  AiRGestures
//
//  Created by Lewis Bell on 27/01/2018.
//  Copyright © 2018 Lewis Bell. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var session: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var gestureRecogniser: GestureRecogniser!
    
    override func viewDidLoad() {
        gestureRecogniser = GestureRecogniser()
        gestureRecogniser.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Camera Setup
        session = AVCaptureSession()
        session!.sessionPreset = AVCaptureSession.Preset.high
        var defaultVideoDevice : AVCaptureDevice?
        if let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front) {
            defaultVideoDevice = frontCameraDevice
        }else{
            print("What the fuck")
        }
        var videoDeviceInput : AVCaptureDeviceInput?
        var videoDeviceOutput : AVCaptureVideoDataOutput?
        do{
            videoDeviceInput = try AVCaptureDeviceInput(device: defaultVideoDevice!)
            if session!.canAddInput(videoDeviceInput!){
                session!.addInput(videoDeviceInput!)
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
                videoPreviewLayer!.videoGravity = AVLayerVideoGravity.resizeAspect
                videoPreviewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                self.view.layer.addSublayer(videoPreviewLayer!)
                session!.startRunning()
            }
            videoDeviceOutput = AVCaptureVideoDataOutput()
            let thread = DispatchQueue(label: "VideoSampleThread")
            videoDeviceOutput?.setSampleBufferDelegate(self, queue: thread)
            session!.addOutput(videoDeviceOutput!)
        } catch let error1{
            print("Even more what the fuck \(error1)")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        videoPreviewLayer!.frame = self.view.bounds
    }

}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate{
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let cvBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        gestureRecogniser.detectGestures(in: cvBuffer!)
    }
    
}


extension ViewController: GestureDelegate {
    func didGetError(_ error: Error) {
        print("Error! \(error)")
    }
    
    func didGetGesture(_ gesture: Gesture) {
        print("Got gesture \(gesture)")
    }
}
