//
//  OpenCVWrapper.h
//  Lab
//
//  Created by hxc on 2017/9/30.
//  Copyright © 2017年 Han Xi. All rights reserved.
//

#ifndef OpenCVWrapper_h
#define OpenCVWrapper_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreML/CoreML.h>
#import <CoreVideo/CoreVideo.h>

#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#endif

@interface OpenCVWrapper : NSObject

+ (UIImage *)processImageWithOpenCV:(UIImage *)inputImage
                     withPrediction:(MLMultiArray *)prob
                          andBounds:(CGRect *)bounds;

+ (UIImage *)Mat8UC4Debug:(CVPixelBufferRef)pixelBuffer;

+ (void)setImageCache:(CVPixelBufferRef)pixelBuffer;

+ (UIImage *)convGray:(MLMultiArray *)prob;

@end

#endif /* OpenCVWrapper_h */
