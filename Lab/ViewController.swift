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
        
        let image = UIImage(named: "pic_hd.jpg")
        
        // gear the image to meet the request of the MobileNet
        let width : CGFloat = 112.0
        let height : CGFloat = 112.0
        let width_Int : Int = Int(width)
        let height_Int : Int = Int(height)
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        image?.draw(in:CGRect(x: 0, y: 0, width: width, height: height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()/**/
        
        //let newImage = resize_padding2(image: image!, dstshape: [width_Int, height_Int])
        //MultiArray
        //let newImage =
        
        /*let uv = UIView(frame: CGRect(x: 50, y: 50, width: 400, height: 400))
        let color = UIColor(patternImage: newImage)
        uv.backgroundColor = color
        self.view.addSubview(uv)*/
        
        //let input = pixelBufferFromImage(image: newImage!)!
        let input = newImage?.pixelBuffer(width: Int(width), height: Int(height))

        // MobileNet runs here
        if #available(iOS 11.0, *)
        {
            let mobileNet = MobileNet()
            
            guard
                let output = try? mobileNet.prediction(data: input!)
            else
            {
                fatalError("Unexpected Error.")
            }
            
            //var pointer = UnsafeMutablePointer<Double>(OpaquePointer(output.prob.dataPointer))
            // prob : Double 1 x 1 x 2 x 112 x 112 array
            //               0   0   1    i     j
            //pointer += MemoryLayout<Double>.stride * width_Int * height_Int

            let ma = MultiArray<Double>(output.prob)
            var mm = MultiArray<Double>(shape: [height_Int, width_Int], initial: 0.0)
            
            for i in 0 ..< height_Int
            {
                for j in 0 ..< width_Int
                {
                    mm[i, j] = ma[0, 0, 0, i, j]
                }
            }
            
            let outputImage : UIImage = mm.image(offset: 0, scale: 225)!
            
            
            /*let ci : CIImage = CIImage(bitmapData: Data(bytes: pointer, count: Int(width) * Int(height)),
                                       bytesPerRow: MemoryLayout<Double>.stride * Int(width),
                                       size: CGSize(width: width, height: height),
                                       format: CIFormat(kCVPixelFormatType_OneComponent8),
                                       colorSpace: (CGColorSpace.linearGray as! CGColorSpace))
            let outputImage : UIImage = UIImage(ciImage: ci)*/
            
            //let d = NSData(bytesNoCopy: pointer, length: MemoryLayout<Double>.stride * Int(width) * Int(height))
            //let e = Data(bytes: pointer, count: Int(width) * Int(height))
            //print(pointer[index(row: i, col: j)])
            
            let uv = UIView(frame: CGRect(x: 60, y: 60, width: width_Int, height: height_Int))
            let color = UIColor(patternImage: outputImage)
            uv.backgroundColor = color
            self.view.addSubview(uv)/**/
        }/**/
    }
    
    func resize_padding2(image : UIImage, dstshape : [Int]) -> UIImage
    {
        let s = NSDate()
        print("s@\(s)")
        
        let height = image.size.height
        let width = image.size.width
        let ratio = width / height
        let dst_width = Int(min(CGFloat(dstshape[1]) * ratio, CGFloat(dstshape[0])))
        let dst_height = Int(min(CGFloat(dstshape[0]) / ratio, CGFloat(dstshape[1])))
        let origin = [Int((dstshape[1] - dst_height) / 2), Int((dstshape[0] - dst_width) / 2)]
        
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        image.draw(in:CGRect(x: 0, y: 0, width: dst_width, height: dst_height))
        let tmpImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        let blackImage = UIImage(ciImage: CIImage(color: CIColor.black))
        blackImage.draw(in:CGRect(x: 0, y: 0, width: width, height: height))
        //tmpImage?.draw(at: CGPoint(x: origin[0], y: origin[1]))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        print("e")
        print("cost\(NSDate().timeIntervalSince(s as Date))")
        
        return newImage!
    }

    
    /*func runMobileNet()
    {
        let image = UIImage(named: "timg.jpeg")
        
        // gear the image to meet the request of the MobileNet
        let width : CGFloat = 112.0
        let height : CGFloat = 112.0
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
            
            for _ in 0 ..< 1000
            {
                guard
                    let _ = try? mobileNet.prediction(data: input)
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
        print("\(endTimeStamp.timeIntervalSince(startTimeStamp as Date) * 1) ms / per pic")
    }*/
    
    /*func pixelBufferFromImage(image: UIImage) -> CVPixelBuffer?
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
    }*/
    
    /*func pixelBufferFromImage(image: UIImage) -> CVPixelBuffer?
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
     }*/

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

