//
//  ViewController.swift
//  SmartCamera
//
//  Created by Hsiao Ai LEE on 03/12/2017.
//  Copyright © 2017 Hsiao Ai LEE. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController {
    
    @IBOutlet weak var resultLabel: UILabel!
    
    @IBOutlet weak var cameraView: UIView!
    
    @IBAction func tapStart(_ sender: UIButton) {
        captureSession.startRunning()
    }
    
    
    @IBAction func tapStop(_ sender: UIButton) {
        captureSession.stopRunning()
    }
    
    let captureSession = AVCaptureSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultLabel.setNeedsDisplay()
       
        // Start up the camera
        
        captureSession.sessionPreset = .photo

        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        
        captureSession.addInput(input)
        
        // Show camera view
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        previewLayer.videoGravity = .resizeAspectFill
        
        previewLayer.frame = cameraView.frame
        
        cameraView.layer.addSublayer(previewLayer)
        
        // Output
        let dataOutput = AVCaptureVideoDataOutput()
        
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        
        captureSession.addOutput(dataOutput)
        
    }
}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        //print("Camera was able to capture a frame:", Date())
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else {
            fatalError("Someone did a baddie")
        }
        
        let request = VNCoreMLRequest(model: model)
        {
            (finishedRequest, error) in
                        
            guard let observations = finishedRequest.results as? [VNClassificationObservation] else { return }
            guard let firstObservation = observations.first else { return }
            var objectName = firstObservation.identifier.components(separatedBy: ",")[0]
            DispatchQueue.main.async {
                self.resultLabel.text = "\(objectName), \(firstObservation.confidence)"
            }
            
        }
        
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        
    }
}

