# This file is part of the OpenADK project. OpenADK is copyrighted
# material, please see the LICENCE file in the top-level directory.

include ${ADK_TOPDIR}/rules.mk

PKG_NAME:=		bluez-firmware
PKG_VERSION:=		1.2
PKG_RELEASE:=		1
PKG_HASH:=		b6119e118fabc6bd34584afcbe6fff00a44caeb64152b02ed57c6fba9fd99eec
PKG_DESCR:=		firmware for bcm2033 bluetooth dongle
PKG_SECTION:=		sys/firmware
PKG_DEPENDS:=		bluez
PKG_URL:=		http://www.bluez.org/
PKG_SITES:=		http://bluez.sourceforge.net/download/

DISTFILES:=		${PKG_NAME}-${PKG_VERSION}.tar.gz

include ${ADK_TOPDIR}/mk/package.mk

$(eval $(call PKG_template,BLUEZ_FIRMWARE,bluez-firmware,${PKG_VERSION}-${PKG_RELEASE},${PKG_DEPENDS},${PKG_DESCR},${PKG_SECTION}))

CONFIGURE_ARGS+=	--libdir=/lib

bluez-firmware-install:
	${INSTALL_DIR} ${IDIR_BLUEZ_FIRMWARE}/lib/firmware
	${CP} ${WRKINST}/lib/firmware/BCM* \
		${IDIR_BLUEZ_FIRMWARE}/lib/firmware

include ${ADK_TOPDIR}/mk/pkg-bottom.mk
