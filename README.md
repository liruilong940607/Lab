# HumanSeg IOS APP

Demo project applying HumanSeg MobileNet in the CoreML frame in the lab.

## Things Done
- Calculate the efficiency of this net
- Make a demo to make this net run correctly and give proper predicition

## TODO
- Make this app run faster (At present, it takes too much time outside the Net for resizing, padding, and formt conversion)
- Read pictutures from the memory of the iphone rather than the project lib

## Input and Output
- Input: A picture size 224*224
- Output: The prediction humanseg picture (gray)

## Usage of .mmodel File
- Open Xcode
- Right click "Lab" subfile (the one that directly contains "ViewController.swift") in the root "Lab" file in the nevagator panel on the left
- Choose "Add Files to Lab" tab
- Select your "MobileNet.mlmodel" model
- Check "Add"

## Dependence
Xcode Version 9.0(9A235)
