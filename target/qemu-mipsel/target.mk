include $(TOPDIR)/mk/kernel-ver.mk
ARCH:=			mips
CPU_ARCH:=		mipsel
TARGET_OPTIMIZATION:=	-Os -pipe
TARGET_CFLAGS_ARCH:=    -march=mips32 -mabi=32
