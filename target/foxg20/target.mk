# arm default is little endian, this target uses EABI
ARCH:=			arm
CPU_ARCH:=		arm
KERNEL_VERSION:=	2.6.34
KERNEL_RELEASE:=	1
KERNEL_MD5SUM:=		10eebcb0178fb4540e2165bfd7efc7ad
TARGET_OPTIMIZATION:=	-Os -pipe
TARGET_CFLAGS_ARCH:=    -march=armv5te -mtune=arm926ej-s
