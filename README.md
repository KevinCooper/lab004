# Lab 3 #
## Table of Contents ##
- [Introduction](#introduction)
- [Approach](#approach)
- [Implementation](#implementation)
    - [Top Shell Diagram](#top-shell-diagram)
    - [](#character-generator-diagram)
    - [](#character-generator)
    - [](#nes-controller)
- [Testing and Debugging](#testing-and-debugging)
    - [](#character-positioning)
    - [(#math)
    - [](#scrolling)
- [Conclusion](#conclusion)
- [Documentation](#documentation)


## Introduction ##
The purpose of this lab was to use the picoblaze process in VHDL to instatiate a USB-to-UART bridge.  I created a program to take input over my computers serial port and read/write to any one of my input or output peripherals: LED's or switches.  In the second part, the same logic was implemented, but using the MicroBlaze processor instead:

 1. Get characters to echo the terminal using the PicoBlaze
 2. Get the PicoBlaze program to correctly process LED and SWT commands 
 3. Get characters to echo the terminal using the MicroBlaze
 4. Get the MicroBlaze program to correctly process LED and SWT commands 
z
## Approach ##
The most important part to the lab was to get the characters to echo correctly to the screen.  This demonstrates that the processor had been instantiated correctly and only the code needed to be significantly modified from that point on.

 - The basic approach to getting the echo:
![echo](images/basic_ex.png)
graphic 1
 - Implement the LED command
 - Implement the SWT command

![commands](images/command_ex.jpg)
graphic 2

## Implementation ##
There were four components to get the basic functionality working.  The RX and TX module needed to be included in order to echo the character correctly on the screen.  After, the PicoBlaze needed to be included, along with the ROM containing our code to run the program.  The following lab4a top shell can be seen below.
### Top Shell Diagram ###
![Block Diagram](images/BlockDiagram.png)
graphic 3

## Conclusion ##
The amount of time needed to implement required funcitonality was less than most labs, however there were some hiccups.  Too much time was spent on problems with the toolset, like understanding custom VHDL needed to be added to the pao file for the microblaze.  This cause extreme amounts of time to be spent on problems that weren't even really part of the lab.
## Documentation ##
None