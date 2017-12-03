//
//  ViewController.swift
//  SmartCamera
//
//  Created by Hsiao Ai LEE on 03/12/2017.
//  Copyright © 2017 Hsiao Ai LEE. All rights reserved.
//

import UIKit
import AVKit

class ViewController: UIViewController {

    @IBOutlet weak var cameraView: UIView!
    
    @IBAction func tapStart(_ sender: UIButton) {
        captureSession.startRunning()
    }
    
    @IBAction func tapEnd(_ sender: UIButton) {
        captureSession.stopRunning()
    }
    
    
    var captureSession = AVCaptureSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Start up the camera

        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        
        captureSession.addInput(input)
                
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        cameraView.layer.addSublayer(previewLayer)
        
        previewLayer.frame = cameraView.frame
    }




}

