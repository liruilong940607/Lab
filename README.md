# IOS HumanSeg Demo APP

Demo project applying HumanSeg MobileNet in the CoreML frame in the lab.

## Things Done
- Calculate the efficiency of this net
- Make a demo to make this net run correctly and give proper predicition
- Change the background using the seg output with opencv2
- Read raw video from the camera and do the complete video process
- Make this app run faster (Done by integrating Vision framework)

## TODO
- Integrate the seg prediction with the original data input (At present due to the framework of Vision I can't get original image together with prediction seg)
- Complete the whole framework of thsi demo (including interacting with users etc.)

## Net Input and Output
- Input: A picture (CVPixelBuffer) size 224*224
- Output: The image with background changed

## Usage of .mmodel File
- Open Xcode
- Right click "Lab" subfile (the one that directly contains "ViewController.swift") in the root "Lab" file in the nevagator panel on the left
- Choose "Add Files to Lab" tab
- Select your "MobileNet.mlmodel" model
- Check "Add"

## Usage of opencv2.framework File
- Just drag it into the navigation bar on the left

## Dependence
- Xcode Version 9.1 (9B55)
- iPhone 7 (ios Version 11.1(15B93))
