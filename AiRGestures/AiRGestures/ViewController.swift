//
//  ViewController.swift
//  AiRGestures
//
//  Created by Lewis Bell on 27/01/2018.
//  Copyright © 2018 Lewis Bell. All rights reserved.
//

import UIKit
import SceneKit
import AVFoundation
import MultipeerConnectivity

enum PTType: UInt32 {
    case number = 100
    case image = 101
}
class ViewController: UIViewController {
    
    
    @IBOutlet weak var sceneView: SCNView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var emojiView: UITextView!
    var session: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var gestureRecogniser: GestureRecogniser!
    var orb: SCNSphere!
    var orbNode: SCNNode?
    var previousGesture : Gesture?
    var layer = true
    var forward  = true
    
    override func viewDidLoad() {
        gestureRecogniser = GestureRecogniser()
        //vision = Vision()
        gestureRecogniser.delegate = self
        PTManager.instance.delegate = self
        PTManager.instance.connect(portNumber: 4986)
        print("PT Connected")
        let scene = SCNScene()
        sceneView.scene = scene
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerForPreviewing(with: self, sourceView: view)
        orb = SCNSphere(radius: 1)
        let material  = orb.firstMaterial!
        let scene = sceneView.scene
        material.lightingModel = SCNMaterial.LightingModel.physicallyBased
        material.diffuse.contents = UIImage(named: "scuffed-plastic-albedo")
        material.roughness.contents = UIImage(named: "scuffed-plastic-roughness")
        material.metalness.contents = UIImage(named: "scuffed-plastic-metal")
        material.normal.contents = UIImage(named: "scuffed-plastic-normal")
        let env = UIImage(named: "spherical")
        scene!.lightingEnvironment.contents = env
        scene!.lightingEnvironment.intensity = 2.0
        orbNode = SCNNode(geometry: orb)
        orbNode?.position = SCNVector3Make(0, 0, 0)
        scene!.rootNode.addChildNode(orbNode!)
        scene?.rootNode.position = SCNVector3Make(0, 0, -2)
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
                videoPreviewLayer!.videoGravity = AVLayerVideoGravity.resizeAspect
                videoPreviewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
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
    }

}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        gestureRecogniser.detectGestures(in: sampleBuffer)
    }
}

extension ViewController: GestureDelegate {
    
    func didGetError(_ error: Error) {
        print("Error! \(error)")
        emojiView.text = "💔"
    }
    
    func didGetGesture(_ gesture: Gesture) {
        DispatchQueue.main.sync {
            if gesture != previousGesture{
                emojiView.text = getEmoji(gesture: gesture)
                PTManager.instance.sendObject(object:"\(gesture),\(layer)")
            }
        }
        if gesture != Gesture.none{
            orb.firstMaterial?.emission.contents = UIColor.purple
            let light = SCNLight()
            light.type = SCNLight.LightType.omni
            light.color = UIColor.purple
            orbNode?.light = light
        }else{
            orb.firstMaterial?.emission.contents = UIColor.black
            orbNode?.light = nil
        }
        switch gesture {
        case Gesture.fist:
            layer = false
            forward = true
        case Gesture.twoFingers:
            forward = false
        case Gesture.ok:
            orb.firstMaterial?.emission.contents = UIColor.green
        default:
            layer = true
            forward = true
        }
        var z: Float = 0
        var y: Float = 0
        if !layer{
            z = -2
        }
        if !forward{
            y = 1
        }
        SCNTransaction.animationDuration = 0.1
        orbNode?.position = SCNVector3Make(0, y, z)
        previousGesture = gesture
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

extension ViewController: UIViewControllerPreviewingDelegate{
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        print("here")
        guard let viewController = storyboard?.instantiateViewController(withIdentifier: "mkl") as? ViewController else { return nil }
        viewController.preferredContentSize = CGSize(width: 0, height: 500)
        return viewController
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {return}
    
    
}



