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
        
        // total time
        let st : NSDate = NSDate()
        
        // the original image to do HumanSeg
        let image = UIImage(named: "pic_hd.jpg")
        
        // PREPROCESS VER 1
        // resize and padding
        //let newImage = resize_padding2(image: image!, dstshape: [height_Int, width_Int], pad : pad)
        // convert the resized and padded image to CVImageBuffer( which is the input format for CoreML MobileNet )
        //let input = newImage.pixelBuffer(width: width_Int, height: height_Int)
        
        // show image after proprocess
        
        // PREPROCESS VER 2
        dealRawImage(image: image!, dstshape: [height_Int, width_Int], pad: pad, pixelBuffer: pixelBuffer)
        
        let penis = UIImage(pixelBuffer: pixelBuffer!)
        let uv1 = UIView(frame: CGRect(x: 50, y: 50, width: width_Int, height: height_Int))
        let color1 = UIColor(patternImage: penis!)
        uv1.backgroundColor = color1
        self.view.addSubview(uv1)
        
        // MobileNet runs here
        // Net RUNS in prediction() and return the answer to output
        let output = try? mobileNet.prediction(data: pixelBuffer!)
        
        // net output generation timestamp
        let nst : NSDate = NSDate()
        
        // turn the output MLMultiArray into a gray image
        let ma = MultiArray<Double>((output?.prob)!, true)
        
        // show the gray image on the screen
        let outputImage : UIImage = ma.image(offset: 0, scale: 225)!
        /*let uv2 = UIView(frame: CGRect(x: 50, y: 300, width: width_Int, height: height_Int))
        let color2 = UIColor(patternImage: outputImage)
        uv2.backgroundColor = color2
        self.view.addSubview(uv2)*/
        
        // time
        let et : NSDate = NSDate()
        print("net time : \(et.timeIntervalSince(nst as Date) * 1000) ms")
        print("tot time : \(et.timeIntervalSince(st as Date) * 1000) ms")
    }
    
    func resize_padding2(image : UIImage, dstshape : [Int], pad : UIImage) -> UIImage
    {
        // decide whether to shrink in height or width
        let height = image.size.height
        let width = image.size.width
        let ratio = width / height
        let dst_width = Int(min(CGFloat(dstshape[1]) * ratio, CGFloat(dstshape[0])))
        let dst_height = Int(min(CGFloat(dstshape[0]) / ratio, CGFloat(dstshape[1])))
        let origin = [Int((dstshape[0] - dst_height) / 2), Int((dstshape[1] - dst_width) / 2)]
        
        // draw the padding in the context and the resized image in the center
        UIGraphicsBeginImageContext(CGSize(width: dstshape[1], height: dstshape[0]))
        pad.draw(in:CGRect(x: 0, y: 0, width: dstshape[1], height: dstshape[0]))
        image.draw(in: CGRect(x: origin[1], y: origin[0], width: dst_width, height: dst_height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func dealRawImage(image : UIImage, dstshape : [Int], pad : UIImage, pixelBuffer : CVPixelBuffer?)
    {
        // time
        let st = NSDate()
        
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
        
        // push context
        UIGraphicsPushContext(context)
        context.translateBy(x: 0, y: CGFloat(dstshape[0]))
        context.scaleBy(x: 1, y: -1)
        
        //print("context creation finish time : \(NSDate().timeIntervalSince(st as Date) * 1000) ms")
        
        //print("padding draw start time : \(NSDate().timeIntervalSince(st as Date) * 1000) ms")
        pad.draw(in:CGRect(x: 0, y: 0, width: dstshape[1], height: dstshape[0]))
        //print("padding draw finish time : \(NSDate().timeIntervalSince(st as Date) * 1000) ms")
        
        //print("image draw start time : \(NSDate().timeIntervalSince(st as Date) * 1000) ms")
        image.draw(in: CGRect(x: origin[1], y: origin[0], width: dst_width, height: dst_height))
        //print("image draw finish time : \(NSDate().timeIntervalSince(st as Date) * 1000) ms")
        
        UIGraphicsPopContext()
        
        // unlock
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        print("raw image deal takes : \(NSDate().timeIntervalSince(st as Date) * 1000) ms")
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

