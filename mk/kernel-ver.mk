ifeq ($(ADK_KERNEL_VERSION_TOOLCHAIN),y)
KERNEL_VERSION:=	3.5.6
KERNEL_MOD_VERSION:=	$(KERNEL_VERSION)
KERNEL_RELEASE:=	1
KERNEL_MD5SUM:=		95d5c7271ad448bc965bdb29339b6923
endif
ifeq ($(ADK_KERNEL_VERSION_3_6_1),y)
KERNEL_VERSION:=	3.6.1
KERNEL_MOD_VERSION:=	$(KERNEL_VERSION)
KERNEL_RELEASE:=	1
KERNEL_MD5SUM:=		63bdd7d325afae1ac525586d24eb5399
endif
ifeq ($(ADK_KERNEL_VERSION_3_5_6),y)
KERNEL_VERSION:=	3.5.6
KERNEL_MOD_VERSION:=	$(KERNEL_VERSION)
KERNEL_RELEASE:=	1
KERNEL_MD5SUM:=		95d5c7271ad448bc965bdb29339b6923
endif
ifeq ($(ADK_KERNEL_VERSION_3_4_13),y)
KERNEL_VERSION:=	3.4.13
KERNEL_MOD_VERSION:=	$(KERNEL_VERSION)
KERNEL_RELEASE:=	1
KERNEL_MD5SUM:=		f9cd4fe763396bf814f3a71de42fde9b
endif
