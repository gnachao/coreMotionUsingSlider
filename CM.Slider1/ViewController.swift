//
//  ViewController.swift
//  CM.Slider1
//
//  Created by MacBKPro on 6/30/15.
//  Copyright (c) 2015 GNA CHAO. All rights reserved.
//

/*
    - App lock in portrait mode
    - aliders interval: [-1, 1], which means 0 is neutral
    - label: set line field to 0
    - behaviour of the slider; how you want it to slide
    - Design: CMDeviceMotion
    - Testing: smallest time you to find the boundary
    - study min/max for the gap: if >max we add interval, if <min, we minus interval
**/

import UIKit
import CoreMotion

class ViewController: UIViewController {
   
    // intervals setting
    @IBOutlet var timerIntervalSlider: UISlider!
    @IBOutlet var slideIntervalSlider: UISlider!
    @IBOutlet var timerInervalDisplay: UILabel!
    @IBOutlet var slideIntervalDisplay: UILabel!
    
    // statistic output labels
    @IBOutlet var rotationRateCMGyroDataDisplay: UILabel!
    @IBOutlet var rotationRateCMDeviceMotionDisplay: UILabel!
    @IBOutlet var attitudeCMDeviceMotionDisplay: UILabel!
    @IBOutlet var userStudyDataDisplay: UILabel!
   
    

    // sliders for testing
    @IBOutlet var gyroscopeSlider: UISlider!
    @IBOutlet var deviceMotionSlider: UISlider!
    @IBOutlet var attitudeSlider: UISlider!
    
    // buttons
    @IBOutlet var startStopButton: UIButton!
    
    // open gateway to use CMMotionManager
    private let motionManager = CMMotionManager()
    private let motionQueue = NSOperationQueue()
    private let gyroDataQueue = NSOperationQueue()
    private var useRawData = true
    
    
    // maximum and minimum rotationRate
    var initialRecordCMDeviceMotion = 0
    var maxRotationRateXCMDeviceMotion = 0.0
    var maxRotationRateYCMDeviceMotion = 0.0
    var maxRotationRateZCMDeviceMotion = 0.0
    var minRotationRateXCMDeviceMotion = 0.0
    var minRotationRateYCMDeviceMotion = 0.0
    var minRotationRateZCMDeviceMotion = 0.0
    
    var initialRecordGyroData = 0
    var maxRotationRateXCMGyroData:Double = 0.0
    var maxRotationRateYCMGyroData = 0.0
    var maxRotationRateZCMGyroData = 0.0
    var minRotationRateXCMGyroData = 0.0
    var minRotationRateYCMGyroData = 0.0
    var minRotationRateZCMGyroData = 0.0
    
    // user holding hand behavior
    private var userStudy = true
    var userMaxRotationRateYCMDeviceMotion = 0.0
    var userMinRotationRateYCMDeviceMotion = 0.0
    var userMaxRotationRateYCMGyroData = 0.0
    var userMinRotationRateYCMGyroData = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if startStopButton.currentTitle == "START" {startMotionManager()}
        setTimeIntervalDsiplay(timerIntervalSlider)
        setSlideIntervalDisplays(slideIntervalSlider)
        
        // default setting after application is load
        startStopButton.setTitle("START", forState: UIControlState.Normal)
    }
    
    
    func startMotionManager(){
        if motionManager.deviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = NSTimeInterval(timerIntervalSlider.value)
            
            // Use CMDeviceMotion
            motionManager.startDeviceMotionUpdatesToQueue(motionQueue){
                (motion, error) in
                
                let rotationRateX = motion.rotationRate.x
                let rotationRateY = motion.rotationRate.y
                let rotationRateZ = motion.rotationRate.z
                
                // Study min and max rotation rate
                if self.initialRecordCMDeviceMotion == 0 {
                    self.maxRotationRateXCMDeviceMotion = rotationRateX
                    self.maxRotationRateYCMDeviceMotion = rotationRateY
                    self.maxRotationRateZCMDeviceMotion = rotationRateZ
                    
                    self.minRotationRateXCMDeviceMotion = rotationRateX
                    self.minRotationRateYCMDeviceMotion = rotationRateY
                    self.minRotationRateZCMDeviceMotion = rotationRateZ
                    self.initialRecordCMDeviceMotion += 1
                }
                
                if self.maxRotationRateXCMDeviceMotion < rotationRateX {self.maxRotationRateXCMDeviceMotion = rotationRateX}
                if self.maxRotationRateYCMDeviceMotion < rotationRateY {self.maxRotationRateYCMDeviceMotion = rotationRateY}
                if self.maxRotationRateZCMDeviceMotion < rotationRateZ {self.maxRotationRateZCMDeviceMotion = rotationRateZ}
                
                if self.minRotationRateXCMDeviceMotion > rotationRateX {self.minRotationRateXCMDeviceMotion = rotationRateX}
                if self.minRotationRateYCMDeviceMotion > rotationRateY {self.minRotationRateYCMDeviceMotion = rotationRateY}
                if self.minRotationRateZCMDeviceMotion > rotationRateZ {self.minRotationRateZCMDeviceMotion = rotationRateZ}
                
                // set user behavior min/max
                if self.userStudy == true {
                    self.userMaxRotationRateYCMDeviceMotion = self.maxRotationRateYCMDeviceMotion
                    self.userMinRotationRateYCMDeviceMotion = self.minRotationRateYCMDeviceMotion
                }
                
                // format string for output
                let rotationRateText = String(format: "CMDeviceMotion Rotation Rate:\n---------------------\nX: %+.4f\nY: %+.4f\nZ: %+.4f\nmaxX: %+.4f\nmaxY: %+.4f\nmaxZ: %+.4f\nminX: %+.4f\nminY: %+.4f\nminZ: %+.4f",rotationRateX, rotationRateY, rotationRateZ, self.maxRotationRateXCMDeviceMotion, self.maxRotationRateYCMDeviceMotion, self.maxRotationRateZCMDeviceMotion, self.minRotationRateXCMDeviceMotion, self.minRotationRateYCMDeviceMotion, self.minRotationRateZCMDeviceMotion)
                let attitudeText = String(format: "CMDeviceMotion Attitude:\n---------------------\n" +
                    "Roll: %+.4f\nPitch: %+.4f\nYaw: %+.4f\n", motion.attitude.roll, motion.attitude.pitch, motion.attitude.yaw)
                
                // use queue data to display and move slider
                dispatch_async(dispatch_get_main_queue()){
                    self.moveSlider(self.deviceMotionSlider, value: motion.rotationRate.y)
                    self.moveSlider(self.attitudeSlider, value: motion.attitude.roll)
                    
                    self.rotationRateCMDeviceMotionDisplay.text = rotationRateText
                    self.attitudeCMDeviceMotionDisplay.text = attitudeText
                }
            }
            
            // Use CMGyroData
            motionManager.startGyroUpdatesToQueue(gyroDataQueue){
                (motion, error) in
                
                let rotationRateX = motion.rotationRate.x
                let rotationRateY = motion.rotationRate.y
                let rotationRateZ = motion.rotationRate.z

                // Study min and max rotation rate
                if self.initialRecordGyroData == 0 {
                    self.maxRotationRateXCMGyroData = rotationRateX
                    self.maxRotationRateYCMGyroData = rotationRateY
                    self.maxRotationRateZCMGyroData = rotationRateZ
                    
                    self.minRotationRateXCMGyroData = rotationRateX
                    self.minRotationRateYCMGyroData = rotationRateY
                    self.minRotationRateZCMGyroData = rotationRateZ
                    
                    self.initialRecordGyroData += 1
                }
                
                if self.maxRotationRateXCMGyroData < rotationRateX {self.maxRotationRateXCMGyroData = rotationRateX}
                if self.maxRotationRateYCMGyroData < rotationRateY {self.maxRotationRateYCMGyroData = rotationRateY}
                if self.maxRotationRateZCMGyroData < rotationRateZ {self.maxRotationRateZCMGyroData = rotationRateZ}
                
                if self.minRotationRateXCMGyroData > rotationRateX {self.minRotationRateXCMGyroData = rotationRateX}
                if self.minRotationRateYCMGyroData > rotationRateY {self.minRotationRateYCMGyroData = rotationRateY}
                if self.minRotationRateZCMGyroData > rotationRateZ {self.minRotationRateZCMGyroData = rotationRateZ}
                
                // set user behavior min/max
                if self.userStudy == true {
                    self.userMaxRotationRateYCMGyroData = self.maxRotationRateYCMGyroData
                    self.userMinRotationRateYCMGyroData = self.minRotationRateYCMGyroData
                }
                
                // format string for output
                let rotationRateText = String(format: "CMGyroData Rotation Rate:\n---------------------\nX: %+.4f\nY: %+.4f\nZ: %+.4f\nmaxX: %+.4f\nmaxY: %+.4f\nmaxZ: %+.4f\nminX: %+.4f\nminY: %+.4f\nminZ: %+.4f",rotationRateX, rotationRateY, rotationRateZ, self.maxRotationRateXCMGyroData, self.maxRotationRateYCMGyroData, self.maxRotationRateZCMGyroData, self.minRotationRateXCMGyroData, self.minRotationRateYCMGyroData, self.minRotationRateZCMGyroData)
                
                // use queue data to display and move slider
                dispatch_async(dispatch_get_main_queue()){
                    self.moveSlider(self.gyroscopeSlider, value: motion.rotationRate.y)
                    self.rotationRateCMGyroDataDisplay.text = rotationRateText
                }
            }
        }
    }
    
    // to move slider
    func moveSlider(slider: UISlider, value: Double){
        if useRawData == false {
            if slider.isEqual(gyroscopeSlider) {
                if value > userMaxRotationRateYCMGyroData {//0.0198, 0.0234, 3.34
                    slider.value += slideIntervalSlider.value
                }else if value < userMinRotationRateYCMGyroData { //0.012. 0.0075, -4.29
                    slider.value -= slideIntervalSlider.value
                }else {
                    slider.value += 0
                }
            }
            
            if slider.isEqual(deviceMotionSlider){
                if value > userMaxRotationRateYCMDeviceMotion { //0.008
                    slider.value += slideIntervalSlider.value
                }else if value < userMinRotationRateYCMDeviceMotion { //-0.008
                    slider.value -= slideIntervalSlider.value
                }else {
                    slider.value += 0
                }
            }
            
            if slider.isEqual(attitudeSlider){
                if value < -0.4 {
                    slider.value -= slideIntervalSlider.value
                }else if value > 0.4 {
                    slider.value += slideIntervalSlider.value
                }else{
                    slider.value += 0
                }
            }
        } else {
            slider.value = Float(value)
        }
    }
    
    @IBAction func startStop(sender: UIButton) {
        if sender.currentTitle == "START" {
            sender.setTitle("STOP", forState: UIControlState.Normal)
            startMotionManager()
        }else {
            sender.setTitle("START", forState: UIControlState.Normal)
            motionManager.stopGyroUpdates()
            motionManager.stopDeviceMotionUpdates()
        }
    }

    @IBAction func adustIntervalSlider(sender: UISlider) {
        if sender.isEqual(self.timerIntervalSlider) {
            setTimeIntervalDsiplay(sender)
        } else if sender.isEqual(self.slideIntervalSlider){
            setSlideIntervalDisplays(sender)
        }
    }
    
    func setTimeIntervalDsiplay(sender: UISlider){
        timerInervalDisplay.text = String(format: "%.4f",sender.value)
    }
    
    func setSlideIntervalDisplays(sender: UISlider){
        slideIntervalDisplay.text = String(format: "%.3f",sender.value)
    }
    
    @IBAction func setSmoothStateCMDeviceRotationRateY(sender: UIButton) {
        if sender.currentTitle == "Study Your Hand" {
            useRawData = false
            userStudy = true;
            sender.setTitle("Study Finished", forState: UIControlState.Normal)
            startStopButton.setTitle("STOP", forState: UIControlState.Normal)
            timerIntervalSlider.setValue(0.0001, animated: true)//smallest for better study
            startMotionManager()
            let userStudyText = String(format: "CMGyroData: minY = %+.4f, maxY = %+.4f\nCMDeviceMotion: minY = %+.4f, maxY = %+.4f",userMinRotationRateYCMGyroData, userMaxRotationRateYCMGyroData, userMinRotationRateYCMDeviceMotion, userMaxRotationRateYCMDeviceMotion)
            userStudyDataDisplay.text = userStudyText
        }else if sender.currentTitle == "Study Finished"{
            sender.setTitle("Study Your Hand", forState: UIControlState.Normal)
            useRawData = false
            userStudy = false;
            startStopButton.setTitle("START", forState: UIControlState.Normal)
            motionManager.stopGyroUpdates()
            motionManager.stopDeviceMotionUpdates()
        }else if sender.currentTitle == "Use Raw Data"{
            sender.setTitle("Use Your Hand", forState: UIControlState.Normal)
            useRawData = true
        }else if sender.currentTitle == "Use Your Hand"{
            sender.setTitle("Use Raw Data", forState: UIControlState.Normal)
            useRawData = false
        }
        
        setTimeIntervalDsiplay(timerIntervalSlider)
        setSlideIntervalDisplays(slideIntervalSlider)
    }
    
    
   
}

