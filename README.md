# DMA Prototype
Simple DMA module prototype

### Objective
The goal is to create simple DMA system in VHDL language, consisting of:
* DMA Memory Block
* Network Controller
* Specificated system bus

Еhe entire text of the task is presented in a task.pdf file

### MYBUS Specification

MYBUS Interface (Master/Slave): writing to block memory devices
* ADDRESS[19:0] - memory address
* DATA[63:0] - 8 bytes of data
* WRITE - write command pulse
* READY - ready signal of Slave 

MYBUS LITE Inteface (Master/Slave): writing Slave device internal registers
* ADDRESS[4:0] - address of register
* DATA_IN[31:0] - value to be written to register
* DATA_OUT[31:0] - value to be read from register
* WRITE - write command pulse

MYBUS STREAM Interface (Master/Slave): transfering stream of data to devices
* DATA[31:0] - 4 bytes of streaming data
* FLAGS[3:0] - different flags, each one for each byte in DATA: End Of Packet, Error, etc
* VALID - request of starting to stream data
* READY - ready to receive stream signal of Slave

