include $(TOPDIR)/mk/kernel-ver.mk
ARCH:=			microblaze
CPU_ARCH:=		$(ADK_TARGET_CPU_ARCH)
TARGET_OPTIMIZATION:=	-Os -pipe
TARGET_CFLAGS_ARCH:=    $(ADK_TARGET_CFLAGS)
