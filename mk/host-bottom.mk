# This file is part of the OpenADK project. OpenADK is copyrighted
# material, please see the LICENCE file in the top-level directory.

host-extract: ${_HOST_PATCH_COOKIE}

host-configure:
${_HOST_CONFIGURE_COOKIE}: ${_HOST_PATCH_COOKIE}
	@mkdir -p ${WRKBUILD}
	@$(CMD_TRACE) "host configuring... "
ifneq (,$(filter autoreconf,${AUTOTOOL_STYLE}))
	cd ${WRKSRC}; env ${AUTOTOOL_ENV} autoreconf -if $(MAKE_TRACE)
	@rm -rf ${WRKSRC}/autom4te.cache
	@touch ${WRKDIR}/.autoreconf_done
endif
	@cd ${WRKBUILD}; \
	    for i in $$(find . -name config.sub);do \
		if [ -f $$i ]; then \
			${CP} $$i $$i.bak; \
			${CP} ${SCRIPT_DIR}/config.sub $$i; \
		fi; \
	    done; \
	    for i in $$(find . -name config.guess);do \
		if [ -f $$i ]; then \
			${CP} $$i $$i.bak; \
			${CP} ${SCRIPT_DIR}/config.guess $$i; \
	        fi; \
	    done;
ifneq (${HOST_STYLE},manual)
ifeq ($(strip ${HOST_STYLE}),)
	cd ${WRKBUILD}; rm -f config.{cache,status}; \
	    env ${HOST_CONFIGURE_ENV} \
	    ${BASH} ${WRKSRC}/${CONFIGURE_PROG} \
	    --program-prefix= \
	    --program-suffix= \
	    --prefix=/usr \
	    --bindir=/usr/bin \
	    --datadir=/usr/share \
	    --mandir=/usr/share/man \
	    --libexecdir=/usr/libexec \
	    --localstatedir=/var \
	    --sysconfdir=/etc \
	    --disable-dependency-tracking \
	    --disable-libtool-lock \
	    --disable-nls \
	    ${HOST_CONFIGURE_ARGS} $(MAKE_TRACE)
else
	cd ${WRKBUILD}; rm -f config.{cache,status}; \
	    env ${HOST_CONFIGURE_ENV} \
	    ${BASH} ${WRKSRC}/${CONFIGURE_PROG} \
	    --program-prefix= \
	    --program-suffix= \
	    --prefix=${STAGING_HOST_DIR}/usr \
	    --bindir=${STAGING_HOST_DIR}/usr/bin \
	    --datadir=${STAGING_HOST_DIR}/usr/share \
	    --mandir=${STAGING_HOST_DIR}/usr/share/man \
	    --libexecdir=${STAGING_HOST_DIR}/usr/libexec \
	    --sysconfdir=${STAGING_HOST_DIR}/etc \
	    --disable-dependency-tracking \
	    --disable-libtool-lock \
	    --disable-nls \
	    ${HOST_CONFIGURE_ARGS} $(MAKE_TRACE)
endif
endif
	${MAKE} host-configure $(MAKE_TRACE)
	touch $@

host-build:
${_HOST_BUILD_COOKIE}: ${_HOST_CONFIGURE_COOKIE}
ifneq (${HOST_STYLE},manual)
	@$(CMD_TRACE) "host compiling... "
	cd ${WRKBUILD} && env ${HOST_MAKE_ENV} ${MAKE} -f ${MAKE_FILE} \
	    ${HOST_MAKE_FLAGS} ${HOST_ALL_TARGET} $(MAKE_TRACE)
endif
	${MAKE} host-build $(MAKE_TRACE)
	touch $@

hostpost-install:
hpkg-install: ${ALL_HOSTINST}
host-install:
${_HOST_FAKE_COOKIE}: ${_HOST_BUILD_COOKIE}
	@$(CMD_TRACE) "host installing... "
	@mkdir -p ${HOST_WRKINST}
ifneq (${HOST_STYLE},manual)
ifeq ($(strip ${HOST_STYLE}),)
	cd ${WRKBUILD} && env ${HOST_MAKE_ENV} ${MAKE} -f ${MAKE_FILE} \
	    DESTDIR='${HOST_WRKINST}' ${HOST_FAKE_FLAGS} ${HOST_INSTALL_TARGET} $(MAKE_TRACE)
	env ${HOST_MAKE_ENV} ${MAKE} hpkg-install $(MAKE_TRACE)
else
	cd ${WRKBUILD} && env ${HOST_MAKE_ENV} ${MAKE} -f ${MAKE_FILE} \
	    DESTDIR='' ${HOST_FAKE_FLAGS} ${HOST_INSTALL_TARGET} $(MAKE_TRACE)
endif
else
	env ${HOST_MAKE_ENV} ${MAKE} hpkg-install $(MAKE_TRACE)
endif
	env ${HOST_MAKE_ENV} ${MAKE} hostpost-install $(MAKE_TRACE)
	@touch $@

${_HOST_COOKIE}:
	exec ${MAKE} hostpackage

ifeq ($(HOST_LINUX_ONLY),)
hostpackage: ${ALL_HOSTDIRS}
	@touch ${_HOST_COOKIE}
endif
