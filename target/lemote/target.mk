include $(TOPDIR)/mk/kernel-ver.mk
ARCH:=			mips
CPU_ARCH:=		mips64el
TARGET_OPTIMIZATION:=	-Os -pipe
TARGET_CFLAGS_ARCH:=    -march=loongson2f -mabi=64
