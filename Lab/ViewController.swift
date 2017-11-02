//
//  ViewController.swift
//  Lab
//
//  Created by hxc on 2017/9/21.
//  Copyright © 2017年 Han Xi. All rights reserved.
//

import UIKit
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
         let attrs =
         [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
         ]
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
         
         // preprocess time start
         let st : NSDate = NSDate()
         
         let image = UIImage(named: "720-1280.jpeg")!
         
         // resize & padding
         var bounds = dealRawImage(image: image,
         dstshape: [height_Int, width_Int],
         pad: pad,
         pixelBuffer: pixelBuffer)
         
         // MobileNet runs here
         let output = try? mobileNet.prediction(data: pixelBuffer!)
         // turn the output MLMultiArray into a gray image
         let pi = (OpenCVWrapper.processImage(withOpenCV: image, withPrediction: (output?.prob)!, andBounds: &bounds))!
         
         // show the gray image on the screen
         let color2 = UIColor(patternImage: pi)
         uv2.backgroundColor = color2
         
         // total time
         print("total time: \(NSDate().timeIntervalSince(st as Date) * 1000) ms")
        
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
}


