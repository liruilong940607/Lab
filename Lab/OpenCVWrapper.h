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

@interface OpenCVWrapper : NSObject

+ (UIImage *)processImageWithOpenCV:(UIImage *)inputImage
                     withPrediction:(MLMultiArray *)prob
                          andBounds:(CGRect *)bounds;

@end

#endif /* OpenCVWrapper_h */
