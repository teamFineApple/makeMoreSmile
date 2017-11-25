//
//  CameraViewController.swift
//  PineApple
//
//  Created by KimDuho on 2017. 11. 25..
//  Copyright © 2017년 PineApple. All rights reserved.
//

import UIKit
import AVFoundation


class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet weak var CameraView: UIView!
    
    var captureSesssion: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        captureSesssion = AVCaptureSession()
        stillImageOutput = AVCapturePhotoOutput()
        
        captureSesssion.sessionPreset = AVCaptureSession.Preset.hd1920x1080 // 해상도설정
        
        let frontCamera =  AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front)
        
        

        do {
            let input = try AVCaptureDeviceInput(device: frontCamera!)
            
            // 입력
            if (captureSesssion.canAddInput(input)) {
                captureSesssion.addInput(input)
                
                // 출력
                if (captureSesssion.canAddOutput(stillImageOutput!)) {
                    captureSesssion.addOutput(stillImageOutput!)
                    captureSesssion.startRunning() // 카메라 시작
                    
                    previewLayer = AVCaptureVideoPreviewLayer(session: captureSesssion)
                    previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspect //화면 조절
                    previewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait // 카메라 방향
                    
                    CameraView.layer.addSublayer(previewLayer!)
                    
                    // 뷰 크기 조절
                    previewLayer?.position = CGPoint(x: self.CameraView.frame.width / 2, y: self.CameraView.frame.height / 2)
                    previewLayer?.bounds = CameraView.frame
                    
                    
                    let dataOutput = AVCaptureVideoDataOutput()
                    dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
                    captureSesssion.addOutput(dataOutput)
                    
                }
            }
        }
        catch {
            print(error)
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        let imageBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        
        let ciImage : CIImage = CIImage(cvPixelBuffer: imageBuffer)
        
        
        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh, CIDetectorSmile: true ])
        
        
        let faces = faceDetector?.features(in: ciImage, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh, CIDetectorSmile: true ])
        
    
        
        print(faces?.count)
        
        for face in faces as! [CIFaceFeature] {
            
            print("Found bounds are \(face.bounds)")
            
            let faceBox = UIView(frame: face.bounds)
            
            faceBox.layer.borderWidth = 3
            faceBox.layer.borderColor = UIColor.red.cgColor
            faceBox.backgroundColor = UIColor.clear
            //ciImage.addSubview(faceBox)
            print(face.hasSmile)
            if face.hasSmile {
                print("웃는다")
            }
        }
        
        
        
    }
    
    func convert(cmage:CIImage) -> UIImage
    {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        CameraView.frame = CGRect(x: CGFloat(0.0), y: CGFloat(0.0), width: self.view.frame.width, height: self.view.frame.height)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
