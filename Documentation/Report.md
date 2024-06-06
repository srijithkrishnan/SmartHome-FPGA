## Abstract

Considering the current situations, there is a lot of electricity and energy wastage happening all around the world. When we consider a scenario happening inside a house, such as, a person entering into his house or a room will switch ON the lights, fans and also maybe other appliances but while exiting the room they might forget to switch them OFF. This is an example of electricity wastage. What is a solution for this? 

Here, I have implemented one of the solutions for this problem, which is by making the house or room smart. This means that the room would be able to switch off the lights even if the person forgets. This is done with the help of low powered and inexpensive components such as sensors. A small portion of a big concept is being implemented here.

Few motion sensors are used in order to detect the direction of motion by which it can be determined whether the person is entering the room or exiting. Once if the person enters the room then the lights get switched ON automatically. Also if the person is inside the room then depending on the room temperature, speed of the fan can be controlled. Later when the person is exiting the room the direction is detected and the appliances that were switched ON for usage would be switched OFF, preventing wastage of electricity.

This is a project designed and implemented on the AMD Spartan-7 FPGA, the Boolean Board, also using PIR motion sensors, a digital temperature sensor, a motor driver and a DC motor. In this project the lights are represented using the on-board LED and the real world fan is represented by a DC Motor. The verilog code for the FPGA is implemented in the free Vivado CAD tool from AMD.

## Relavant Concepts

To design and implement this project, it is required to understand the working as well as how to configure each components. The components required are 3 PIR motions sensors, 1 DS18B20 single wire temperature sensor, a H-Bridge motor driver, a DC motor and few jumper wires.

### PIR Motion Sensor - HC-SR501

Passive Infrared or PIR motion sensors are mostly used to detect human motion within a specific range. These sensors are small, inexpensive, requires low power and detects motion efficiently due to which they are preferred and used widely in home security devices or automatic lighting systems.

The PIR sensors are having two modes, Repeatable mode and Non-Repeatable mode. In the repetable mode, the sensor will stay on a logic one if the motion detected body is still in the range of detection, while in the Non-Repeatable mode once the sensor detect motion it returns to a logic zero after a particular delay. Both the control parameters can be controlled by adjusting the knobs. 

These sensors are having two control parameters in addition. One is called the 'sensitivity control', which determines the range of detection and the second is 'Off time control', which controls the delay time for the sensor to stay logic one after detecting motion.

The motion sensor used for this project is HC-SR501

![HC-SR501](/Documentation/images/HC-SR501.png)

|  | MIN | MAX | USED |
| ------ | ------ | ------ | ------ |
| VCC | 4.5V | 12V | 5V |
| sensitivity | 3 | 7 | 3 |
| off time | 3s | 5min | 3s |

Reference :
- [https://cdn-learn.adafruit.com/downloads/pdf/pir-passive-infrared-proximity-motion-sensor.pdf](https://cdn-learn.adafruit.com/downloads/pdf/pir-passive-infrared-proximity-motion-sensor.pdf)
- [https://components101.com/sensors/hc-sr501-pir-sensor](https://components101.com/sensors/hc-sr501-pir-sensor)

### Temperature Sensor - DS18B20

DS18B20 is a single wire digital temperature sensor providing a 9-bit to 12-bit Celcius temperature measurements. This sensor communicates on a single wire bus, which means it requires only one port for communication. Each of this sensor is having a unique 64 bit code which allows multiple DS18B20's to communicate using the same single bus. The sensor is having two powering options, either using an external supply or directly from the data line, known as the 'parasite power'. 

The sensor is having an 64 bit ROM, storing the unique serial code of the sensor. There is also a scratchpad memory, whos 1st 2-bytes store digital temperature output of the sensor. The scratchpad also provides access to the Alarm trigger registers (TH and TL) and 1 byte configuration register.

The 2-byte alarm registers and the configuration register are nonvolatile (EPROM) memory as even after the sensor is powered off these stored values can be retained and they can be accessed from the scratchpad memory.

The communication between the sensor and the FPGA board is done with the help of certain commands like ConverT(44H), Read Scratchpad (BEH), etc through the one wire bus.

![KY-001](/Documentation/images/KY-001.png)

![DS18B20-Supply](/Documentation/images/DS18B20-Supply.png)

| Name | MIN | MAX | Description |
| ------ | ------ | ------ | ------ |
| VCC | +3V | +5.5V | here an external supply of 3.3V is being used. If sensor opertaing in parasite mode then this should be grounded |
| DQ |  |  | Data I/O pin |
| GND |  |  | Ground |

References : 
- [https://datasheets.maximintegrated.com/en/ds/DS18B20.pdf](https://datasheets.maximintegrated.com/en/ds/DS18B20.pdf)

### H-Bridge Motor Driver - L298N

L298N is a high power motor driver module for driving both DC motors and Stepper Motors. Depending on the value provided to the IN1, IN2, IN3 and IN4 a user can control the direction of rotation of the motor.

| Pin | Description |
| ------ | ------ |
| IN1 & IN2 | Motor A input pins. Used to control the spinning direction of Motor A |
| IN3 & IN4 | Motor B input pins. Used to control the spinning direction of Motor B |
| ENA | Enables PWM signal for Motor A |
| ENB | Enables PWM signal for Motor B |
| OUT1 & OUT2 | Output pins of Motor A |
| OUT3 & OUT4 | Output pins of Motor B |
| 12V | 12V input from DC power Source |
| 5V | Supplies power for the switching logic circuitry inside L298N IC |
| GND | Ground pin |

References : 

- [https://www.sparkfun.com/datasheets/Robotics/L298_H_Bridge.pdf](https://www.sparkfun.com/datasheets/Robotics/L298_H_Bridge.pdf)
- [https://components101.com/modules/l293n-motor-driver-module](https://components101.com/modules/l293n-motor-driver-module)

## Design

As the whole project is based on three different components, the design is created using the Divide and Conquer theory, the main design is split into three small designs and then combined later. Initially a circuit was created for the PIR motion configuration after which the temperature sensor circuit was configured. Then the motor driver circuit was created, later integrated with the temperature sensor ciruit. Once each component circuits were complete all of them were integrated together into a single circuit design.

For connecting all the components to the Boolean board, the PmodC from the soldered PMOD was used.

### Motion Sensor

Each motion sensor data output is passed to T5, R5, T4 PMOD ports and the sensor was driven with on board 5V and GND

![PIR-Circuit](/Documentation/images/PIR-Circuit.png)

### Temperature Sensor

The temperature sensor's data I/O pin is connected to the T6 PMOD port and the sensor was driven by 3.3V from the board.

![DS18B20-Circuit](/Documentation/images/DS18B20-Circuit.png)

### Motor Driver

The pwm signal generated from the board is passed on to the motor driver through the PMOD port R6 and the motor is driven using an external 4.5V power supply.

![PWM-Circuit](/Documentation/images/PWM-Circuit.png)



## Implementation

As the design was created, the verilog code for this implementation was split into three modules, each module for the three components and wrapped into a single module.

## pir_sensor

As known the motion sensors detects motion but the task here is to detect the direction of motion, for which multiple PIR sensors are being used. Therefore this implementation requires a proper structure, which is created with the help of a Finite State Machine (FSM). 

Initially a FSM was created to understand the flow of control to detect the direction using the sensors. As a person is entering into a room the sensors placed/arranged in a sequence, where each sensor would be detecting motion one after the other. So by determining the motion sequence of detection we would be able to determine the direction.

A simple FSM is created where the state changes in the sequence of detection and at the last state the light/LED is illuminated.

![PIR-FSM](/Documentation/images/PIR-FSM.png)

After the FSM being created, the next task is to implement the same in verilog.


Problems Faced

- Due to space restrictions the sensors were kept close due to which sometimes multiple sensors detect at the same time.
- The sensors stay on logic 1 for an approximate time of 3 seconds, therefore there sometimes the delay might be 3 seconds, maybe a little less or maybe little more than 3 seconds.

### ds18b20

The temperature sensor works on a strict flow, where each command should be passed on to the sensor and read from the sensor in respective time interval. As we are using a single port for both input and output it is required to create a flow so that there would not be any collisions in data passage. For this purpose referring to the flow diagram from the [datasheet](https://datasheets.maximintegrated.com/en/ds/DS18B20.pdf), a required flow diagram was created.

![DS18B20-Flow](/Documentation/images/DS18B20-Flow.png)

To implement this flow we require a proper structure for which a state flow diagram was designed, where the control will be passing from each state and within each state the specific task would be implemented within the required time period for the sensor.

![DS18B20-FSM](/Documentation/images/DS18B20-FSM.png)

After implementing the FSM the temperature was delivered from the sensor and the next task is to display this value on the on-board seven segment display. The binary output from the sensor read was 72 bits, of which the first 2 bytes were having the read temperature. This 16 bits represents the signed temperature value with deimal points in binary. The least significiant 4 bits comes after the decimal point, which is displayed directly on the display and the rest 12 bits is converted binary into BCD and displyed.

Problems Faced

- While writing each command to the sensor through the single bus only one bit was passed at a time and it required to provide delays of 15 us or 65 us. This was resoolved by reducing the 100MHz clock to 1MHz which is 1 us. 


### motor_driver

The motor driver requires a PWM signal as an input which will be passed on to the motor, which will be controlling the speed of the motor. So the initial task is to generate a PWM signal. As PWM meand controlling the width of a signal, that is, defining how much time should the singal be on logic one and zero. 

For the motor driving 100MHz from the board is too much to handle therefore the frequncy is to be reduced. So the 100 MHz is reduced to 20KHz by dividing the 100MHz by 5000. After which the decision on how much time the signal was to be on logic one and zero was determined.

Now as a pwm signal was generated, the next task is to make it dynamic depending on a dynamic variable, which here would be the temperature. So a variable is created which would be provided with different values between 0 to 3 and based on this value the pwm signal is generated. This variable value will be assigned based on the temperature coming from the sensor.


### smart_wrapper

The last part of the implementation is to integrate or wrap up all the individual modules under one roof. This top module will be calling the individual component modules, the important task here is to provide a check and assign the appropriate value to variable present in the motor_driver module to generate the respective PWM signal.

This check can be carried out by taking the LED value from the motion_sensor module which determines if the person is inside the room or outisde. So only if the person is inside the room we require the fan to be switched ON, otherwise the fan would be provided with a logic 0. If the person is inside the room then the temperature from the module ds18b20 is considered and checked whether the temperature is more than 27 degree Celcius or between 23 - 26 degree Celcius excl. or less than that. 


## Test and Results

The developed code was tested before moving into the hardware, by creating a simulation file for the wrapper module.

After verifying the implementation using simulation, the code was moved into hardware. The final result observed was recorded. 

# Experience

The design and execution of this project was a complete knowledge gaining experience. Working with an FPGA gave the freedom to design a digital circuit with ease. This project included the incorporation of different components like PIR sensors, digital temperature sensor, motor driver and more. It was also required to generate pwm signals based on the use case, which was just a theoretical based knowledge initially. Similarly the project provided with an oppurtunity to convert all the theoretical knowledge into practical experience. The exitment to know the working of each design made the complete project more interesting.

## Things that can be improved

The PIR sensors were not really efficient for finding the direction of motion at all times. This can be improved by using image processing with FPGA to find the direction of motion effectively. Xillinx is having dedicated template library for such applications called '[xfopencv](https://github.com/Xilinx/xfopencv)'.







