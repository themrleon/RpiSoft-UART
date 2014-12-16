obj-m := softuart.o
PWD := $(shell pwd)

KERNEL_SRC_DIR := /root/raspberry/linux
GCC_PREFIX := arm-bcm2708-linux-gnueabi-

all:
	$(MAKE) -C $(KERNEL_SRC_DIR) M=$(PWD) modules ARCH=arm CROSS_COMPILE=$(GCC_PREFIX)
