# HumanSeg IOS APP

Demo project applying the coreML code MobileNet in the lab.

## Things Done
- Calculate the efficiency of this net
- Make a demo to make this net run correctly and give proper predicition

## TODO
- Recover the original size of the prediction picture
- Do proper padding for the input picture with less time complexity
- Read pictutures from the memory of the iphone rather than the project lib

## Input and Output
- Input: A picture size 112*112
- Output: The prediction humanseg picture (gray)

## Usage of .mmodel File
- Open Xcode
- Right click "Lab" subfile (the one that directly contains "ViewController.swift") in the root "Lab" file in the nevagator panel on the left
- Choose "Add Files to Lab" tab
- Select your "MobileNet.mlmodel" model
- Check "Add"

## Dependence
Xcode Version 9.0(9A235)
