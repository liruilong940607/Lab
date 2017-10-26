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

#include <opencv2/opencv.hpp>

using namespace std;
using namespace cv;

@implementation OpenCVWrapper : NSObject

/*+ (UIImage *)processImageWithOpenCV:(UIImage *)inputImage
                     withPrediction:(MLMultiArray *)prob
                          andBounds:(CGRect *)bounds
{
    int xx = bounds->origin.x, yy = bounds->origin.y;
    int wid = bounds->size.width, hei = bounds->size.height;
    
    Mat mat = [inputImage CVMat3], mat2 = Mat(hei, wid, CV_8UC3);
    resize(mat, mat2, cv::Size(wid, hei));
    
    double *pointer = (double *)[prob dataPointer];
    
    if (bounds->origin.x == 0.0)
    {
        pointer += 224 * (yy + 224);
        
        for (int r = 0; r < hei; r++)
        {
            for (int c = 0; c < wid; c++)
            {
                double tag = pointer[r * 224 + c];
                mat2.at<Vec3b>(r, c)[0] *= tag;
                mat2.at<Vec3b>(r, c)[1] *= tag;
                mat2.at<Vec3b>(r, c)[2] *= tag;
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
                mat2.at<Vec3b>(r, c)[0] *= tag;
                mat2.at<Vec3b>(r, c)[1] *= tag;
                mat2.at<Vec3b>(r, c)[2] *= tag;
            }
        }
    }
 
    Mat ans = Mat(640, 480, CV_8UC3);
    resize(mat2, ans, cv::Size(480, 640));
    
    return [UIImage imageWithCVMat:ans];
}*/

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
}/**/

@end

