//
//  ViewController.swift
//  Lab
//
//  Created by hxc on 2017/9/21.
//  Copyright © 2017年 Han Xi. All rights reserved.
//

import UIKit
import CoreML

class ViewController: UIViewController
{

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let image = UIImage(named: "timg.jpeg")
        
        // gear the image to meet the request of the MobileNet
        let width : CGFloat = 224.0
        let height : CGFloat = 224.0
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        image?.draw(in:CGRect(x: 0, y: 0, width: width, height: height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let input = pixelBufferFromImage(image: newImage!)!
        
        // get the timestamp before the net runs
        let startTimeStamp = NSDate()
        print("MobileNet Starts Running @ \(startTimeStamp)")
        
        // MobileNet runs here
        if #available(iOS 11.0, *)
        {
            let mobileNet = MobileNet()
            
            for _ in 0 ..< 100
            {
                guard
                    let _ = try? mobileNet.prediction(image: input)
                    else
                {
                    fatalError("Unexpected Error.")
                }
                
                //print("Prediction: " + output.classLabel)
                //print(output.classLabel)
                //print(output.classLabelProbs)
            }
        }
        
        // get the timestamp after the net runs
        let endTimeStamp = NSDate()
        print("MobileNet Ends Running @ \(endTimeStamp)")
        print("MobileNet Runs for 1000 times, costing ")
        print("\(endTimeStamp.timeIntervalSince(startTimeStamp as Date)) s")
        print("Averange Time cost is ")
        print("\(endTimeStamp.timeIntervalSince(startTimeStamp as Date)) ms / per pic")
    }
    
    func pixelBufferFromImage(image: UIImage) -> CVPixelBuffer?
    {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        
        guard
            (status == kCVReturnSuccess)
        else
        {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        
        let context = CGContext(data: pixelData,
                                width: Int(image.size.width),
                                height: Int(image.size.height),
                                bitsPerComponent: 8,
                                bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!),
                                space: rgbColorSpace,
                                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: image.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

