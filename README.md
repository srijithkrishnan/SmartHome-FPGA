# Smart Home

> Srijith Krishnan (22107597)

## Overview

Smart Home is a FPGA project designed on a Boolean Board (Spartan 7) for automated control over lights and fans within a room. Here a DC motor would be used in place of a fan.

This is acheived with the help of few low powered low powered and inexpensive components. Few motion sensors are used in order to detect the direction of motion by which it can be determined whether the person is entering the room or exiting. Once if the person enters the room then the lights get switched ON automatically. Also if the person is inside the room then depending on the room temperature, speed of the fan can be controlled. Later when the person is exiting the room the direction is detected and the appliances that were switched ON for usage would be switched OFF.

## Requirements

This project is implemented on the the AMD Spartan-7 FPGA, called the Boolean Board. Along with the board this requires: 

- 3 PIR Motion Sensors (HC-SR501)
- 1 Single wire digital temperature sensor (DS18B20)
- 1 H-Bridge Motor Driver (L298N)
- 1 DC Motor
- few jumper wires

### Pre-requisites

- Basic level understanding about verilog coding
- requires to understand on how to configure the sensors (reference provided at the end)


## Instructions

The source code of the project is located within 'source_code/'. To build and execute this project, look into the following instructions:

```
cd smart-home-fpga/source_code
```

### Generate Bitsream (Build)

In order to generate the bitsream, initially clone or download the project. After which, within the directory execute the 'source_code/syn.tcl' script.

```
vivado -mode batch -source syn.tcl
```

### Program Hardware 

Similar as generating bitsream, by executing the 'source_code/program.tcl' script it is possible to program the hardware.

```
vivado -mode batch -source program.tcl
```

## References

### PIR Sensor

- [https://cdn-learn.adafruit.com/downloads/pdf/pir-passive-infrared-proximity-motion-sensor.pdf](https://cdn-learn.adafruit.com/downloads/pdf/pir-passive-infrared-proximity-motion-sensor.pdf)
- [https://components101.com/sensors/hc-sr501-pir-sensor](https://components101.com/sensors/hc-sr501-pir-sensor)

### DS18B20

- [https://datasheets.maximintegrated.com/en/ds/DS18B20.pdf](https://datasheets.maximintegrated.com/en/ds/DS18B20.pdf)

### H-Bridge Motor Driver

- [https://www.sparkfun.com/datasheets/Robotics/L298_H_Bridge.pdf](https://www.sparkfun.com/datasheets/Robotics/L298_H_Bridge.pdf)
- [https://components101.com/modules/l293n-motor-driver-module](https://components101.com/modules/l293n-motor-driver-module)

## Additional

[FPGA Lab Projects](https://mygit.th-deg.de/sk09597/fpga-labs) are linked here.
