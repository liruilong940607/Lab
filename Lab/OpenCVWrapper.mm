//
//  OpenCVWrapper.m
//  Lab
//
//  Created by hxc on 2017/9/30.
//  Copyright © 2017年 Han Xi. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "OpenCVWrapper.h"
#import "UIImage+OpenCV.h"

using namespace std;
using namespace cv;

static Mat imageCache;

@implementation OpenCVWrapper : NSObject

+ (UIImage *)processImageWithOpenCV:(UIImage *)inputImage
                     withPrediction:(MLMultiArray *)prob
                          andBounds:(CGRect *)bounds
{
    // generate the prediction Mat using the MLMultiArray
    int xx = bounds->origin.x, yy = bounds->origin.y;
    int wid = bounds->size.width, hei = bounds->size.height;
    
    Mat mat2 = Mat(hei, wid, CV_64FC1);
    
    double *pointer = (double *)[prob dataPointer];
    
    if (bounds->origin.x == 0.0)
    {
        pointer += 224 * (yy + 224);
        
        for (int r = 0; r < hei; r++)
        {
            for (int c = 0; c < wid; c++)
            {
                double tag = pointer[r * 224 + c];
                mat2.at<double>(r, c) = tag;
            }
        }
    }
    else
    {
        pointer += 224 * 224;
        
        for (int r = 0; r < hei; r++)
        {
            for (int c = 0; c < wid; c++)
            {
                double tag = pointer[224 * r + xx + c];
                mat2.at<double>(r, c) = tag;
            }
        }
    }
    
    // resize the prediction Mat to size 640 * 360
    Mat prediction = Mat(640, 360, CV_64FC1);
    resize(mat2, prediction, cv::Size(360, 640));
    
    // resize the input image Mat to size 640 * 360
    Mat mat = [inputImage CVMat3], ans = Mat(640, 360, CV_8UC3);
    resize(mat, ans, cv::Size(360, 640));
    
    // edit the image Mat using the prediction Mat
    for (int r = 0; r < 640; r++)
    {
        for (int c = 0; c < 360; c++)
        {
            double tag = prediction.at<double>(r, c);
            ans.at<Vec3b>(r, c)[0] *= tag;
            ans.at<Vec3b>(r, c)[1] *= tag;
            ans.at<Vec3b>(r, c)[2] *= tag;
        }
    }
    
    return [UIImage imageWithCVMat:ans];
}

+ (UIImage *)Mat8UC4Debug:(CVPixelBufferRef)pixelBuffer
{
    // Convert the CVPixelBuffer to cv::Mat for preprocessing
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    int bufferWidth = (int) CVPixelBufferGetWidth(pixelBuffer);
    int bufferHeight = (int) CVPixelBufferGetHeight(pixelBuffer);
    int bytePerRow = (int) CVPixelBufferGetBytesPerRow(pixelBuffer);
    unsigned char *pixel = (unsigned char *) CVPixelBufferGetBaseAddress(pixelBuffer);
    Mat image = Mat(bufferHeight, bufferWidth, CV_8UC4, pixel, bytePerRow);
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    // CV_8UC4: RGBA CV_8UC3: BGR pixelBuffer: BGRA
    for (int i = 0; i < bufferHeight; i++)
    {
        for (int j = 0; j < bufferWidth; j++)
        {
            swap(image.at<Vec4b>(i, j)[0], image.at<Vec4b>(i, j)[2]);
        }
    }
    
    return [UIImage imageWithCVMat:image];
}

+ (void)setImageCache:(CVPixelBufferRef)pixelBuffer
{
    // Convert the CVPixelBuffer to cv::Mat for preprocessing
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    int bufferWidth = (int) CVPixelBufferGetWidth(pixelBuffer);
    int bufferHeight = (int) CVPixelBufferGetHeight(pixelBuffer);
    int bytePerRow = (int) CVPixelBufferGetBytesPerRow(pixelBuffer);
    unsigned char *pixel = (unsigned char *) CVPixelBufferGetBaseAddress(pixelBuffer);
    imageCache = Mat(bufferHeight, bufferWidth, CV_8UC4, pixel, bytePerRow).clone();
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
}

+ (UIImage *)convGray:(MLMultiArray *)prob
{
    Mat mat = Mat(224, 224, CV_8UC1);
    
    double *pointer = (double *)[prob dataPointer];
    
    for (int r = 0; r < 224; r++)
    {
        for (int c = 0; c < 224; c++)
        {
            mat.at<int>(r, c) = 225 - pointer[r * 224 + c] * 255;
        }
    }
    
    //Mat mat2 = Mat(224, 224, CV_8UC4);
    //cvtColor(mat, mat2, CV_8UC4);
    UIImage *image = [UIImage imageWithCVMat:mat];

    return image;
}

/*+ (Mat)resize_padding2:(Mat &)image
{
    int height = image.size[0];
    int width = image.size[1];
    float ratio = float(width) / height;                      // ratio = (width:height)
    dst_width = int(min(dstshape[1]  * ratio, dstshape[0] ))
    dst_height = int(min(dstshape[0]  / ratio, dstshape[1] ))
    origin = [int((dstshape[1] - dst_height)/2), int((dstshape[0] - dst_width)/2)]
    
    if len(image.shape)==3:
        image_resize = cv2.resize(image, (dst_width, dst_height))
        newimage = np.zeros(shape = (dstshape[1], dstshape[0], image.shape[2]), dtype = np.uint8)
        newimage[origin[0]:origin[0]+dst_height, origin[1]:origin[1]+dst_width, :] = image_resize
        bbx = [origin[1], origin[0], origin[1]+dst_width, origin[0]+dst_height] # x1,y1,x2,y2
        else:
            image_resize = cv2.resize(image, (dst_width, dst_height),  interpolation = cv2.INTER_NEAREST)
            newimage = np.zeros(shape = (dstshape[1], dstshape[0]), dtype = np.uint8)
            newimage[origin[0]:origin[0]+height, origin[1]:origin[1]+width] = image
            bbx = [origin[1], origin[0], origin[1]+dst_width, origin[0]+dst_height] # x1,y1,x2,y2
            return newimage, bbx
}*/

@end

