ARCH:=			arm
CPU_ARCH:=		arm
KERNEL_VERSION:=	2.6.29.1
KERNEL_RELEASE:=	1
KERNEL_MD5SUM:=		4ada43caecb08fe2af71b416b6f586d8
TARGET_OPTIMIZATION:=	-Os -pipe
TARGET_CFLAGS_ARCH:=    -march=armv5te -msoft-float
GCC_EXTRA_CONFOPTS:=	--with-float=soft
