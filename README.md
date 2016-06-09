RpiSoft-UART
============

This driver will create a software-based serial port/UART using any GPIO pin, similiar to `/dev/tty*` devices, with some unique features.

### Features
* Works with <a href="http://en.wikipedia.org/wiki/Minicom">Minicom</a>
* Works with `cat` and `echo` commands
* 256 bytes RX buffer (read the data whenever you want, no data lost!)
* 256 bytes TX buffer (no need to send each byte separately, send the whole array once!)
* RX buffer cleared automatically after a read operation (Ex: `cat`)
* TX buffer cleared automatically after a write operation (Ex: `echo`)
* No pooling needed
* Loopback mode
* Runtime changeable parameters (GPIO pins, baudrate and loopback mode)

## Compiling
Export the path location of your toolchain/GCC, Ex:
```
export PATH=$PATH:/root/raspberry/tools/arm-bcm2708/arm-bcm2708-linux-gnueabi/bin
```
Edit `Makefile` to match your kernel source directory and GCC prefix:
```
KERNEL_SRC_DIR := /root/raspberry/linux
GCC_PREFIX := arm-bcm2708-linux-gnueabi-
```
Now type `make` and you have the `softuart.ko` driver.

## Structure
The driver will be created at `/sys/class/softuart/softuart/`:
```
root@raspberrypi:/home/pi# cat /sys/class/softuart/softuart/
baudrate   data       gpio_rx    gpio_tx    loopback   power/     subsystem/ uevent
```
Where:
* baudrate - Selected baudrate
* data - Used to send and receive data, is the `/dev/tty*` like file
* gpio_rx - Selected GPIO pin to receive data
* gpio_tx - Selected GPIO pin to transmit data
* loopback - Loopback mode, 1 - on / 0 - off (default) 

## Usage
Driver parameters:
```
root@raspberrypi:/home/pi# modinfo softuart.ko 
...
parm:           BAUDRATE: Baudrate value [default = 4800] (min=1200, max=19200) (int)
parm:           GPIO_TX: GPIO TX pin [default = 4] (int)
parm:           GPIO_RX: GPIO RX pin [default = 2] (int)
```
Loading module with default parameters:
```
insmod softuart.ko
```
Loading module specifying all possible parameters:
```
insmod softuart.ko GPIO_TX=4 GPIO_RX=2 BAUDRATE=4800
```

### Examples
Minicom:
```
minicom -b 4800 -D /sys/class/softuart/softuart/data
```
Send data with `echo`:
```
echo abc > /sys/class/softuart/softuart/data
```
Receive data with `cat`:
```
cat /sys/class/softuart/softuart/data
```
Loopback mode:
```
echo 1 > /sys/class/softuart/softuart/loopback
echo abc > /sys/class/softuart/softuart/data
cat /sys/class/softuart/softuart/data
abc
```
Change baudrate to 9600 kbps:
```
echo 9600 > /sys/class/softuart/softuart/baudrate
```
## Advanced
Just don't send more than 256 bytes at once and all must be ok, 256 is enough for most applications, but if you need more just change in the source code.

### Understanding the RX buffer
The driver have a 256 bytes RX buffer. This mean you can receive up to 256 bytes at once and they will be stored, without loss, if more bytes are received the buffer will be cleared and start store again. Any read operation at 'data' entry, will clear the buffer (Ex: `cat`). The buffer have only effect without the use of a software like `minicom` (because have it's own buffer, and due the pooling, keep the buffer clear).

### Understanding the TX buffer
The driver have a 256 bytes TX buffer. This mean you can send up to 256 bytes at once and they will be stored and transmitted until the last byte, clearing the buffer automatically. If more bytes than the buffer capacity is written, the buffer will clear and start store again. Any write operation at 'data' entry, will start the transmission (Ex: `echo`). The buffer have only effect without the use of a software like `minicom` (because transmit each byte separately, using just one byte of the TX buffer at time).

Remember, this is a <b>software</b>-based UART, subject to preemption, not a piece of <b>dedicated hardware</b>. Details, limitations and a user-space version can be found <a href="http://www.l3oc.com/2015/05/software-based-uart.html">HERE</a>.

## License
GPLv2 License, details <a href="https://github.com/themrleon/RpiSoft-UART/blob/master/LICENSE">HERE</a>.

## Updated (june 2016)
Tag 1.0 released and a pull request was accept on the Master branch, seems to be that the new raspberry pi toolchain can't understand some of the old symbols, so they were hardcoded
