# This file is part of the OpenADK project. OpenADK is copyrighted
# material, please see the LICENCE file in the top-level directory.

CP=			cp -fpR
INSTALL_DIR=		install -d -m0755
INSTALL_DATA=		install -m0644
INSTALL_BIN=		install -m0755
INSTALL_SCRIPT=		install -m0755
MAKEFLAGS=		$(EXTRA_MAKEFLAGS)
BUILD_USER=		$(shell id -un)
BUILD_GROUP=		$(shell id -gn)

BASE_DIR:=		$(TOPDIR)
DISTDIR?=		${BASE_DIR}/dl
BUILD_DIR:=		${BASE_DIR}/build_${ADK_TARGET_SYSTEM}_${CPU_ARCH}_${ADK_TARGET_LIBC}
BUILD_DIR_PFX:=		$(BASE_DIR)/build_*
STAGING_PKG_DIR:=	${BASE_DIR}/pkg_${ADK_TARGET_SYSTEM}_${CPU_ARCH}_${ADK_TARGET_LIBC}
STAGING_PKG_DIR_PFX:=	${BASE_DIR}/pkg_*
STAGING_HOST_DIR:=	${BASE_DIR}/host_${CPU_ARCH}_${ADK_TARGET_SUFFIX}_${ADK_TARGET_LIBC}
STAGING_HOST_DIR_PFX:=	${BASE_DIR}/host_*
# use headers and foo-config from system
ifeq ($(ADK_NATIVE),y)
STAGING_TARGET_DIR:=
SCRIPT_TARGET_DIR:=	/usr/bin
else
STAGING_TARGET_DIR:=	${BASE_DIR}/target_${CPU_ARCH}_${ADK_TARGET_SUFFIX}_${ADK_TARGET_LIBC}
SCRIPT_TARGET_DIR:=	${STAGING_TARGET_DIR}/scripts
endif
STAGING_DIR:=		${BASE_DIR}/target_${CPU_ARCH}_${ADK_TARGET_SUFFIX}_${ADK_TARGET_LIBC}
STAGING_TARGET_DIR_PFX:=${BASE_DIR}/target_*
# relation from STAGING_HOST_DIR to STAGING_TARGET_DIR (for gcc to find
# its sysroot while staying relocatable)
STAGING_HOST2TARGET:=	../target_${CPU_ARCH}_${ADK_TARGET_SUFFIX}_${ADK_TARGET_LIBC}
TOOLCHAIN_BUILD_DIR=	$(BASE_DIR)/toolchain_build_${CPU_ARCH}_${ADK_TARGET_SUFFIX}_${ADK_TARGET_LIBC}
TOOLCHAIN_BUILD_DIR_PFX=$(BASE_DIR)/toolchain_build_*
TOOLS_BUILD_DIR=	$(BASE_DIR)/tools_build
BIN_DIR:=		$(BASE_DIR)/bin
SCRIPT_DIR:=		$(BASE_DIR)/scripts
FW_DIR:=		$(BASE_DIR)/firmware/${ADK_TARGET_SYSTEM}_${CPU_ARCH}_${ADK_TARGET_LIBC}
FW_DIR_PFX:=		$(BASE_DIR)/firmware
PACKAGE_DIR:=		$(FW_DIR)/packages
TARGET_DIR:=		$(BASE_DIR)/root_${ADK_TARGET_SYSTEM}_${CPU_ARCH}_${ADK_TARGET_LIBC}
TARGET_DIR_PFX:=	$(BASE_DIR)/root_*
TARGET_PATH=		${SCRIPT_DIR}:${BIN_DIR}:${STAGING_TARGET_DIR}/scripts:${STAGING_HOST_DIR}/bin:${STAGING_HOST_DIR}/usr/bin:${_PATH}
HOST_PATH=		${SCRIPT_DIR}:${BIN_DIR}:${STAGING_HOST_DIR}/bin:${STAGING_HOST_DIR}/usr/bin:${_PATH}
AUTOTOOL_PATH=		${BIN_DIR}:${STAGING_HOST_DIR}/bin:${STAGING_HOST_DIR}/usr/bin:${STAGING_TARGET_DIR}/scripts:${_PATH}
REAL_GNU_TARGET_NAME=	$(CPU_ARCH)-$(ADK_VENDOR)-linux-$(ADK_TARGET_SUFFIX)
GNU_TARGET_NAME=	$(CPU_ARCH)-$(ADK_VENDOR)-linux

ifeq ($(ADK_DISABLE_HONOUR_CFLAGS),)
GCC_CHECK:=		GCC_HONOUR_COPTS=2
else
GCC_CHECK:=
endif

ifeq ($(ADK_NATIVE),y) 
TARGET_CROSS:=
TARGET_COMPILER_PREFIX?=
CONFIGURE_TRIPLE:=	
else
TARGET_CROSS:=		$(STAGING_HOST_DIR)/bin/$(REAL_GNU_TARGET_NAME)-
TARGET_COMPILER_PREFIX?=${TARGET_CROSS}
CONFIGURE_TRIPLE:=	--build=${GNU_HOST_NAME} --host=${GNU_TARGET_NAME} --target=${GNU_TARGET_NAME}
endif

ifneq ($(strip ${ADK_USE_CCACHE}),)
TARGET_COMPILER_PREFIX=ccache ${TARGET_CROSS}
endif

# target compiler flags
TARGET_CC:=		${TARGET_COMPILER_PREFIX}gcc
TARGET_CXX:=		${TARGET_COMPILER_PREFIX}g++
TARGET_LD:=		${TARGET_COMPILER_PREFIX}ld

MODE_FLAGS:=
ifeq ($(ADK_LINUX_ARM),y)
ifeq ($(ADK_LINUX_ARM_WITH_THUMB),y)
MODE_FLAGS:=		-mthumb
else
MODE_FLAGS:=		-marm
endif
endif

TARGET_CPPFLAGS:=	
TARGET_CFLAGS:=		$(TARGET_CFLAGS_ARCH) -fwrapv -fno-ident -fhonour-copts $(ADK_TARGET_ABI_CFLAGS) $(MODE_FLAGS)
TARGET_CFLAGS_LIBC:=	$(TARGET_CFLAGS_ARCH) -fwrapv -fno-ident -fhonour-copts $(TARGET_OPTIMIZATION) $(MODE_FLAGS)
TARGET_CXXFLAGS:=	$(TARGET_CFLAGS_ARCH) -fwrapv -fno-ident $(MODE_FLAGS)
TARGET_LDFLAGS:=	-L$(STAGING_TARGET_DIR)/lib -L$(STAGING_TARGET_DIR)/usr/lib \
			-Wl,-O1 -Wl,-rpath -Wl,/usr/lib \
			-Wl,-rpath-link -Wl,${STAGING_TARGET_DIR}/usr/lib \
			$(ADK_TARGET_ABI_LDFLAGS)
# security optimization, see http://www.akkadia.org/drepper/dsohowto.pdf
TARGET_LDFLAGS+=	-Wl,-z,relro,-z,now
# needed for musl ppc 
ifeq ($(ADK_LINUX_PPC),y)
ifeq ($(ADK_TARGET_LIB_MUSL),y)
TARGET_LDFLAGS+=	-Wl,--secure-plt
endif
endif

ifneq ($(ADK_NATIVE),)
TARGET_CPPFLAGS:=
TARGET_CFLAGS:=		$(TARGET_CFLAGS_ARCH) -fwrapv -fno-ident -fhonour-copts
TARGET_LDFLAGS:=
endif

ifneq ($(ADK_TOOLCHAIN_GCC_USE_SSP),)
TARGET_CFLAGS+=		-fstack-protector
TARGET_CXXFLAGS+=	-fstack-protector
TARGET_LDFLAGS+=	-fstack-protector
endif

ifneq ($(ADK_TOOLCHAIN_GCC_USE_LTO),)
TARGET_CFLAGS+=		-flto
TARGET_CXXFLAGS+=	-flto
TARGET_LDFLAGS+=	-flto
endif

ifneq ($(ADK_DEBUG),)
TARGET_CFLAGS+=		-g3 -fno-omit-frame-pointer
else
TARGET_CPPFLAGS+=	-DNDEBUG
TARGET_CFLAGS+=		-fomit-frame-pointer $(TARGET_OPTIMIZATION)
# stop generating eh_frame stuff
TARGET_CFLAGS+=		-fno-unwind-tables -fno-asynchronous-unwind-tables
# always add debug information
TARGET_CFLAGS+=		-g3
endif


# A nifty macro to make testing gcc features easier (from uClibc project)
check_gcc=$(shell \
        if $(CC_FOR_BUILD) $(1) -Werror -S -o /dev/null -xc /dev/null > /dev/null 2>&1; \
        then echo "$(1)"; else echo "$(2)"; fi)

CF_FOR_BUILD=$(call check_gcc,-fhonour-copts,)

# host compiler flags
CXX_FOR_BUILD?=		g++
CPPFLAGS_FOR_BUILD?=	-I$(STAGING_HOST_DIR)/usr/include
CFLAGS_FOR_BUILD=	-O2 -Wall $(CF_FOR_BUILD)
CXXFLAGS_FOR_BUILD?=    -O2 -Wall
LDFLAGS_FOR_BUILD?= 	-L$(STAGING_HOST_DIR)/usr/lib
FLAGS_FOR_BUILD=	${CPPFLAGS_FOR_BUILD} ${CFLAGS_FOR_BUILD} ${LDFLAGS_FOR_BUILD}

PATCH=			${BASH} $(SCRIPT_DIR)/patch.sh
SED:=			sed -i -e
LINUX_DIR:=		$(BUILD_DIR)/linux
KERNEL_MODULE_FLAGS:=	ARCH=${ARCH} KERNELVERSION="2.6" \
			KERNEL_PATH=${LINUX_DIR} KERNELDIR=${LINUX_DIR} KERNEL_DIR=${LINUX_DIR} \
			PREFIX=/usr CROSS_COMPILE="${TARGET_CROSS}" \
			LDFLAGS="$(ADK_TARGET_KERNEL_LDFLAGS)" CFLAGS_MODULE="-fhonour-copts" V=1

TARGET_CONFIGURE_OPTS=	PATH='${TARGET_PATH}' \
			AR='$(TARGET_CROSS)ar' \
			AS='$(TARGET_CROSS)as' \
			LD='$(TARGET_CROSS)ld' \
			NM='$(TARGET_CROSS)nm' \
			RANLIB='$(TARGET_CROSS)ranlib' \
			STRIP='${TARGET_CROSS}strip' \
			OBJCOPY='${TARGET_CROSS}objcopy' \
			CC='$(TARGET_CC)' \
			GCC='$(TARGET_CC)' \
			CXX='$(TARGET_CXX)' \
			CROSS='$(TARGET_CROSS)' \
			CROSS_COMPILE='$(TARGET_CROSS)'

HOST_CONFIGURE_OPTS=	CC_FOR_BUILD='${CC_FOR_BUILD}' \
			CPPFLAGS_FOR_BUILD='${CPPFLAGS_FOR_BUILD}' \
			CXX_FOR_BUILD='${CXX_FOR_BUILD}' \
			CFLAGS_FOR_BUILD='${CFLAGS_FOR_BUILD}' \
			LDFLAGS_FOR_BUILD='${LDFLAGS_FOR_BUILD}'

PKG_SUFFIX:=		$(strip $(subst ",, $(ADK_PACKAGE_SUFFIX)))

ifeq ($(ADK_TARGET_PACKAGE_IPKG),y)
PKG_BUILD:=		PATH='${TARGET_PATH}' \
			${BASH} ${SCRIPT_DIR}/ipkg-build
PKG_INSTALL:=		IPKG_TMP=$(BUILD_DIR)/tmp \
			IPKG_INSTROOT=$(TARGET_DIR) \
			IPKG_CONF_DIR=$(STAGING_TARGET_DIR)/etc \
			IPKG_OFFLINE_ROOT=$(TARGET_DIR) \
			BIN_DIR=$(BIN_DIR) \
			${BASH} ${SCRIPT_DIR}/ipkg \
			-force-defaults -force-depends install
PKG_STATE_DIR:=		$(TARGET_DIR)/usr/lib/ipkg
else
PKG_BUILD:=		${BASH} ${SCRIPT_DIR}/tarpkg build
PKG_INSTALL:=		PKG_INSTROOT=$(TARGET_DIR) \
			${BASH} ${SCRIPT_DIR}/tarpkg install
PKG_STATE_DIR:=		$(TARGET_DIR)/usr/lib/pkg
endif

ifeq ($(ADK_NATIVE),y)
RSTRIP:=		prefix=' ' ${BASH} ${SCRIPT_DIR}/rstrip.sh
else
RSTRIP:=		PATH="$(TARGET_PATH)" prefix='${TARGET_CROSS}' ${BASH} ${SCRIPT_DIR}/rstrip.sh
endif

STATCMD:=$(shell if stat -qs .>/dev/null 2>&1; then echo 'stat -f %z';else echo 'stat -c %s';fi)
	
EXTRACT_CMD=		mkdir -p ${WRKDIR}; \
			cd ${WRKDIR} && \
			for file in ${FULLDISTFILES}; do case $$file in \
			*.cpio) \
				cat $$file | $(BIN_DIR)/cpio -i -d ;; \
			*.tar) \
				tar -xf $$file ;; \
			*.cpio.Z | *.cpio.gz | *.cgz | *.mcz) \
				gzip -dc $$file | $(BIN_DIR)/cpio -i -d ;; \
			*.tar.xz | *.txz) \
				xz -dc $$file | tar -xf - ;; \
			*.tar.Z | *.tar.gz | *.taz | *.tgz) \
				gzip -dc $$file | tar -xf - ;; \
			*.cpio.bz2 | *.cbz) \
				bzip2 -dc $$file | $(BIN_DIR)/cpio -i -d ;; \
			*.tar.bz2 | *.tbz | *.tbz2) \
				bzip2 -dc $$file | tar -xf - ;; \
			*.zip) \
				cat $$file | $(BIN_DIR)/cpio -ivd -H zip ;; \
			*.arm) \
				cp $$file ${WRKDIR} ;; \
			*) \
				echo "Cannot extract '$$file'" >&2; \
				false ;; \
			esac; done

ifeq ($(VERBOSE),1)
QUIET:=
else
QUIET:=			--quiet
endif
FETCH_CMD?=		wget --timeout=$(ADK_WGET_TIMEOUT) -t 3 --no-check-certificate $(QUIET)

ifeq ($(ADK_HOST_CYGWIN),y)
EXEEXT:=		.exe
endif

include $(TOPDIR)/mk/mirrors.mk
