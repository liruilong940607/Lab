//
//  ViewController.swift
//  Lab
//
//  Created by hxc on 2017/9/21.
//  Copyright © 2017年 Han Xi. All rights reserved.
//


import UIKit
import Vision
import CoreMedia

class ViewController: UIViewController
{
    @IBOutlet weak var videoPreview: UIView!
    @IBOutlet weak var predictionLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    let model = MobileNet()
    
    var videoCapture: VideoCapture!
    var request: VNCoreMLRequest!
    var startTimes: [CFTimeInterval] = []
    
    var framesDone = 0
    var frameCapturingStartTime = CACurrentMediaTime()
    let semaphore = DispatchSemaphore(value: 2)
    
    //let uiView = UIView(frame: CGRect(x: 0, y: 100, width: 360, height: 480))
    let uiView = UIView(frame: CGRect(x: 0, y: 100, width: 224, height: 224))
    
    var cachePrediction: MLMultiArray!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.view.addSubview(uiView)
        
        predictionLabel.text = ""
        timeLabel.text = ""
        
        setUpVision()
        setUpCamera()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        print(#function)
    }
    
    // MARK: - Initialization
    
    func setUpCamera()
    {
        videoCapture = VideoCapture()
        videoCapture.delegate = self
        videoCapture.fps = 50
        
        videoCapture.setUp
        {
            success in
            
            if success
            {
                // Add the video preview into the UI.
                if let previewLayer = self.videoCapture.previewLayer
                {
                    self.videoPreview.layer.addSublayer(previewLayer)
                    self.resizePreviewLayer()
                }
                
                self.videoCapture.start()
            }
        }
    }
    
    func setUpVision()
    {
        guard let visionModel = try? VNCoreMLModel(for: model.model) else
        {
            print("Error: could not create Vision model")
            return
        }
        
        request = VNCoreMLRequest(model: visionModel, completionHandler: requestDidComplete)
        request.imageCropAndScaleOption = .scaleFit
    }
    
    // MARK: - UI stuff
    
    override func viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews()
        resizePreviewLayer()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
    
    func resizePreviewLayer()
    {
        videoCapture.previewLayer?.frame = videoPreview.bounds
    }
    
    // MARK: - Doing inference
    
    typealias Prediction = (String, Double)
    
    func predict(pixelBuffer: CVPixelBuffer)
    {
        // Measure how long it takes to predict a single video frame. Note that
        // predict() can be called on the next frame while the previous one is
        // still being processed. Hence the need to queue up the start times.
        startTimes.append(CACurrentMediaTime())
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
        try? handler.perform([request])
    }
    
    func requestDidComplete(request: VNRequest, error: Error?)
    {
        if let results = request.results
        {
            DispatchQueue.main.async
            {
                let pp = results[0] as! VNCoreMLFeatureValueObservation
                
                //let srcImage = MultiArray<Double>(pp.featureValue.multiArrayValue!).reshaped([2, 224, 224]).image(channel: 1, offset: 0, scale: 255)!
                //let srcImage = OpenCVWrapper.mat8UC4Debug(self.cacheBuffer)!
                //self.uiView.backgroundColor = UIColor(patternImage: srcImage)
                
                self.cachePrediction = pp.featureValue.multiArrayValue!
                self.showFPS()
                self.semaphore.signal()
            }
        }
    }
    
    func showFPS()
    {
        let latency = CACurrentMediaTime() - startTimes.remove(at: 0)
        let fps = self.measureFPS()
        timeLabel.text = String(format: "%.2f FPS (latency %.5f seconds)", fps, latency)
    }
    
    func show(results: [Prediction])
    {
        /*var s: [String] = []
        
        for (i, pred) in results.enumerated()
        {
            s.append(String(format: "%d: %@ (%3.2f%%)", i + 1, pred.0, pred.1 * 100))
        }
        
        predictionLabel.text = s.joined(separator: "\n\n")*/
        
        let latency = CACurrentMediaTime() - startTimes.remove(at: 0)
        let fps = self.measureFPS()
        timeLabel.text = String(format: "%.2f FPS (latency %.5f seconds)", fps, latency)
    }
    
    func measureFPS() -> Double
    {
        // Measure how many frames were actually delivered per second.
        framesDone += 1
        let frameCapturingElapsed = CACurrentMediaTime() - frameCapturingStartTime
        let currentFPSDelivered = Double(framesDone) / frameCapturingElapsed
        
        if frameCapturingElapsed > 1
        {
            framesDone = 0
            frameCapturingStartTime = CACurrentMediaTime()
        }
        
        return currentFPSDelivered
    }
}

extension ViewController: VideoCaptureDelegate
{
    func videoCapture(_ capture: VideoCapture, didCaptureVideoFrame pixelBuffer: CVPixelBuffer?, timestamp: CMTime)
    {
        if let pixelBuffer = pixelBuffer
        {
            // For better throughput, perform the prediction on a background queue
            // instead of on the VideoCapture queue. We use the semaphore to block
            // the capture queue and drop frames when Core ML can't keep up.
            semaphore.wait()
            
            DispatchQueue.global().async
            {
                self.predict(pixelBuffer: pixelBuffer)
            }
            
            DispatchQueue.main.async
            {
                self.uiView.backgroundColor = UIColor(patternImage: OpenCVWrapper.convGray(self.cachePrediction!))
            }
        }
    }
}



/*import UIKit
import AVKit
import CoreML
import AVFoundation
import AssetsLibrary
import MobileCoreServices


class ViewController: UIViewController
{
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // INIT : supposed height ang width of the input image of the MobileNet
        let width : CGFloat = 224.0
        let height : CGFloat = 224.0
        let width_Int : Int = Int(width)
        let height_Int : Int = Int(height)
         
        // INIT : a black imahe used to do the padding
        let pad : UIImage = MultiArray<Double>(shape : [3, height_Int, width_Int]).image(offset: 0, scale: 1)!
         
        // INIT : a pixelBuffer to store the resized & padded image
        var pixelBuffer: CVPixelBuffer?
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue]
        CVPixelBufferCreate(kCFAllocatorDefault,
                            width_Int,
                            height_Int,
                            kCVPixelFormatType_32ARGB,
                            attrs as CFDictionary,
                            &pixelBuffer)
         
        // INIT : CoreML Net init
        let mobileNet = MobileNet()
         
        // INIT : the UIView to show the preserved image
        let uv2 = UIView(frame: CGRect(x: 0, y: 50, width: 360, height: 640))
        self.view.addSubview(uv2)
        
        let image = UIImage(named: "720-1280.jpeg")!
         
        // resize & padding
        var bounds = dealRawImage(image: image,
                                  dstshape: [height_Int, width_Int],
                                  pad: pad,
                                  pixelBuffer: pixelBuffer)
         
        // net preprocess time start
        let nst : NSDate = NSDate()
         
        //for _ in 0 ..< 1000
        //{
         
        // MobileNet runs here
        let output = try? mobileNet.prediction(data: pixelBuffer!)
        //}
        // turn the output MLMultiArray into a gray image
        //let pi = (OpenCVWrapper.processImage(withOpenCV: image, withPrediction: (output?.prob)!, andBounds: &bounds))!
         
        // show the gray image on the screen
        //let color2 = UIColor(patternImage: pi)
        //uv2.backgroundColor = color2
         
        // total time
        print("total time: \(NSDate().timeIntervalSince(nst as Date) * 1000) ms")
        
    }
    
    func dealRawImage(image: UIImage, dstshape: [Int], pad: UIImage, pixelBuffer: CVPixelBuffer?) -> CGRect
    {
        // decide whether to shrink in height or width
        let height = image.size.height
        let width = image.size.width
        let ratio = width / height
        let dst_width = Int(min(CGFloat(dstshape[1]) * ratio, CGFloat(dstshape[0])))
        let dst_height = Int(min(CGFloat(dstshape[0]) / ratio, CGFloat(dstshape[1])))
        let origin = [Int((dstshape[0] - dst_height) / 2), Int((dstshape[1] - dst_width) / 2)]
        
        // get the pointer of this pixelBuffer
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        // init a context that contains this pixelBuffer to draw in
        let context = CGContext(data: pixelData,
                                width: dstshape[1],
                                height: dstshape[0],
                                bitsPerComponent: 8,
                                bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!),
                                space: CGColorSpaceCreateDeviceRGB(),
                                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)!
        
        // draw in this context
        UIGraphicsPushContext(context)
        context.translateBy(x: 0, y: CGFloat(dstshape[0]))
        context.scaleBy(x: 1, y: -1)
        pad.draw(in:CGRect(x: 0, y: 0, width: dstshape[1], height: dstshape[0]))
        image.draw(in: CGRect(x: origin[1], y: origin[0], width: dst_width, height: dst_height))
        UIGraphicsPopContext()
        
        // unlock
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return CGRect(x: origin[1], y: origin[0], width: dst_width, height: dst_height)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}*/

