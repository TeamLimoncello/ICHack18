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
    var session: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var gestureRecogniser: GestureRecogniser!
    
    override func viewDidLoad() {
        gestureRecogniser = GestureRecogniser()
        gestureRecogniser.delegate = self
        PTManager.instance.delegate = self
        PTManager.instance.connect(portNumber: 4986)
        print("PT Connected")
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
                cameraView.layer.addSublayer(videoPreviewLayer!)
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
        self.videoPreviewLayer!.frame = self.cameraView.bounds
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
        emojiView.text = "💔"
    }
    
    func didGetGesture(_ gesture: Gesture) {
        //print("Got gesture \(gesture)")
        DispatchQueue.main.sync {
            emojiView.text = getEmoji(gesture: gesture)
            PTManager.instance.sendObject(object:gesture.rawValue, type: PTType.number.rawValue)
        }
        
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
