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
        
        // supposed height ang width of the input image of the MobileNet
        let width : CGFloat = 224.0
        let height : CGFloat = 224.0
        let width_Int : Int = Int(width)
        let height_Int : Int = Int(height)
        
        // a black imahe used to do the padding
        let pada : MultiArray = MultiArray<Double>(shape : [3, height_Int, width_Int])
        for i in 0 ..< 3 * width_Int * height_Int
        {
            pada.pointer[i] = 0.0
        }
        let pad = pada.image(offset: 0, scale: 1)
        
        // the original image to do HumanSeg
        let image = UIImage(named: "pic_hd.jpg")
        
        // resize and padding
        let newImage = resize_padding2(image: image!, dstshape: [height_Int, width_Int], pad : pad!)
        
        // show the image after resizing and padding
        let uv = UIView(frame: CGRect(x: 50, y: 50, width: width_Int, height: height_Int))
        let color = UIColor(patternImage: newImage)
        uv.backgroundColor = color
        self.view.addSubview(uv)
        
        // convert the resized and padded image to CVImageBuffer( which is the input format for CoreML MobileNet )
        let input = newImage.pixelBuffer(width: Int(width), height: Int(height))

        // MobileNet runs here
        if #available(iOS 11.0, *)
        {
            // CoreML Net init
            let mobileNet = MobileNet()
            
            // Net RUNS in prediction() and return the answer to output
            guard
                let output = try? mobileNet.prediction(data: input!)
            else
            {
                fatalError("Unexpected Error.")
            }
            
            // turn the output MLMultiArray into a gray image
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
            
            // show the gray image on the screen
            let uv = UIView(frame: CGRect(x: 50, y: 300, width: width_Int, height: height_Int))
            let color = UIColor(patternImage: outputImage)
            uv.backgroundColor = color
            self.view.addSubview(uv)
        }
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
        
        // a black background padding
        UIGraphicsBeginImageContext(CGSize(width: dst_width, height: dst_height))
        image.draw(in:CGRect(x: 0, y: 0, width: dst_width, height: dst_height))
        let tmpImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // draw the resize image in the center
        UIGraphicsBeginImageContext(CGSize(width: dstshape[1], height: dstshape[0]))
        pad.draw(in:CGRect(x: 0, y: 0, width: dstshape[1], height: dstshape[0]))
        tmpImage?.draw(at: CGPoint(x: origin[1], y: origin[0]))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

