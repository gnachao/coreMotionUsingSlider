# Swift Core Motion Using Slider
(this app is built to understand how rotation data work)

This is an iOS app that is built for understanding swift Core Motion. I built this app for an experiment to display out the rotational data as I rotate my phone. 

For those who want to try out the app, it has to be installed on your phone to see how the app works. It won't work in simulator because it has no rotation sensor.

Study: 
* study rotation rate from CMGyroData and CMDeviceMotion class.
* compare rotion rate with attitude from CMDeviceMotion class.

Feature:
* [x] User can hold device to see the raw data of rotation rate and attitude with effect on slider.
* [x] User can rotate device to see the raw data of rotation rate and attitude with the effect on slider.
* [x] The app can study user's hand and define the behavior to move the slider.
* [x] The app contain a diagram of rotation rules.

Conclution after study:
* Rotation rate from CMGyroData and CMDeviceMotion are bias and hard to implement. To move the slider using rotation rate, user need to rotate with speed.
* Attitude is more pratical and accurate when implementing to move the slider. It move the slider base on the angel we rotate. 

![alt tag](https://github.com/gnachao/coreMotionUsingSlider/blob/master/coreMotionSlider.gif)
