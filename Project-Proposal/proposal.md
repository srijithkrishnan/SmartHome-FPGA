# Smart Home

> Srijith Krishnan (22107597)

## Overview

Smart Home is a FPGA project designed on a Boolean Board (Spartan 7) for automated control over lights and fans within a room. Here a DC motor would be used in place of a fan.

## Background

Smart Home, as the name suggests the project would be based on automation of certain home appliances in a home. Currently, the project would be controlling an LED and a DC motor (representing a real world room fan) based on motion detection and room temperature respectively.

In this project, 8 PIR Motion sensors would be used in order to detect motion, a temperature sensor to mesaure the room temperature, one of the on board seven segment display, an on board LED, a DC Motor and a H bridge motor driver.

Motion sensors would be arranged in a sequential manner in order to detect the direction of motion. Therefore if the motion of the user is into the room then the lights will be switched ON while if the motion is detected outwards then the lights would be switched OFF. At the same time if the motion sensors detect the motion into the room then the temperature of the room would be taken into consideration. If the room temperature is greater than a limit then the motor will be switched ON. 

As additional features I would also want to control the speed of the motor using PWM signals (increase or descrease the speed). Along with which the current temperature measured could be displayed on the seven segment display.

The project idea is illustrated in the below diagram: 

![FPGA Project Idea](/Project-Proposal/images/FPGA_Idea.png)

## Implementation Strategy

This project would be implemented in 3 stages - Handling and reading data from the sensors, controlling PWM signals and displaying temperature value on the seven segement display.

Initially, I would start with a single PIR sensor and try to illuminate an LED on motion detection. Later the 8 sensors would be used to detect the direction of motion. The last part of this stage would be by using the temperature sensor, where I would use the sensor to switch ON an LED if the temperature crosses the provided limit.

As the second stage I would be trying to control the PWM signals. Here I would start off using an LED to control the intensity of the light using the PWM signals. As the last part of the second stage the LED would be switched by a DC motor, controlling its speed using the PWM signals which is passed through a H bridge motor driver.

As the final stage, the temperature obtained from the temperature sensor would be dispayed on the seven segment display. After this stage the project would be developed fully.

## Tasks

All the tasks are noted down here and as each task is completed the check box would be ticked.

### Technical Tasks

- [ ] Connect a motion sensor to the board and read data
    - [ ] Use the data from motion sensors to illuminate a LED.
- [ ] Connect all the motion sensors to the board and detect direction.
- [ ] Connect temperature sensor and read data
    - [ ] Use the data from the temperature sensor and compare with the provided limit to illuminate a LED.
- [ ] Controlling PWM signals
    - [ ] using the PWM signals controlling a LED light intensity
    - [ ] using the PWM signals controlling the speed of a DC motor
- [ ] displaying the obtained temperature value on the seven segment dispaly
- [ ] write the test bench for the code and verify

### Documentation Tasks

- [ ] verify git repo is upto date
- [ ] creation of report on the project.

## Resources

The sensors required for the project (PIR motion and temperature) are yet to be obtained. They would be either provided by the professor if available or would be purchased online. 

The DC motor is available with me, while the H-bridge motor driver circuit would be purchased online. 

Further references required (for example datasheets) for the project would be surfed online and details required regarding the Boolean Board would be obtained from [Real Digital](http://realdigital.org/). 

Previously completed [FPGA Lab Projects](https://mygit.th-deg.de/sk09597/fpga-labs) are linked here, which can be used for references if required.

Currently no other resources link are available, but would be updated as the project work is started.