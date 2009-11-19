# This file is part of the OpenADK project. OpenADK is copyrighted
# material, please see the LICENCE file in the top-level directory.
#
# Scan host-tool prerequisites of certain packages before building.

if test -z "$BASH_VERSION"; then
	foo=`$BASH -c 'echo "$BASH_VERSION"'`
else
	foo=$BASH_VERSION
fi

if test -z "$foo"; then
	echo OpenADK requires GNU bash to be installed.
	exit 1
fi

test -z "$BASH_VERSION$KSH_VERSION" && exec $BASH $0 "$@"

[[ -n $BASH_VERSION ]] && shopt -s extglob
topdir=$(readlink -nf $(dirname $0)/.. 2>/dev/null || (cd $(dirname $0)/..; pwd -P))
OStype=$(env NOFAKE=yes uname)
out=0

. $topdir/.config

if [[ -n $ADK_NATIVE ]];then
	if [[ -n $ADK_PACKAGE_GIT ]];then
		NEED_CURLDEV="$NEED_CURLDEV git"
		NEED_SSLDEV="$NEED_SSLDEV git"
	fi
	if [[ -n $ADK_TARGET_PACKAGE_RPM ]]; then
		NEED_RPM="$NEED_RPM rpm"
	fi
fi

if [[ -n $ADK_NATIVE ]];then
	if [[ -n $ADK_PACKAGE_SQUID ]]; then
		NEED_GXX="$NEED_GXX squid"
	fi
fi

if [[ -n $ADK_COMPILE_HEIMDAL ]]; then
	NEED_BISON="$NEED_BISON heimdal-server"
fi

if [[ -n $ADK_PACKAGE_ALSA_UTILS ]]; then
	NEED_XMLTO="$NEED_XMLTO alsa-utils"
fi

if [[ -n $ADK_PACKAGE_XKEYBOARD_CONFIG ]]; then
	NEED_XKBCOMP="$NEED_XKBCOMP xkeyboard-config"
fi

if [[ -n $ADK_COMPILE_AVAHI ]]; then
	NEED_PKGCONFIG="$NEED_PKGCONFIG avahi"
fi

if [[ -n $ADK_PACKAGE_SQUID ]]; then
	NEED_SSLDEV="$NEED_SSLDEV squid"
fi

if [[ -n $ADK_PACKAGE_DANSGUARDIAN ]]; then
	NEED_PKGCONFIG="$NEED_PKGCONFIG dansguardian"
fi

if [[ -n $ADK_PACKAGE_GLIB ]]; then
	NEED_GLIBZWO="$NEED_GLIBZWO glib"
	NEED_GETTEXT="$NEED_GETTEXT glib"
	NEED_PKGCONFIG="$NEED_PKGCONFIG glib"
fi


if [[ -n $NEED_GETTEXT ]]; then
	if ! which xgettext >/dev/null 2>&1; then
		echo >&2 You need gettext to build $NEED_GETTEXT
		out=1
	elif ! which msgfmt >/dev/null 2>&1; then
		echo >&2 You need gettext to build $NEED_GETTEXT
		out=1
	fi
fi

if [[ -n $NEED_CURLDEV ]];then
	if ! test -f /usr/include/curl/curl.h >/dev/null; then
		echo >&2 You need curl headers to build $NEED_CURLDEV
		out=1
	fi
fi

if [[ -n $NEED_SSLDEV ]]; then
	if ! test -f /usr/lib/pkgconfig/openssl.pc >/dev/null; then
		if ! test -f /usr/include/openssl/ssl.h >/dev/null; then
			echo >&2 You need openssl headers to build $NEED_SQUID
			out=1
		fi
	fi
fi

if [[ -n $NEED_BISON ]]; then
	if ! which bison >/dev/null 2>&1; then
		echo >&2 You need bison to build $NEED_BISON
		out=1
	fi
fi

if [[ -n $NEED_GXX ]]; then
	if ! which g++ >/dev/null 2>&1; then
		echo >&2 You need GNU c++ compiler to build $NEED_GXX
		out=1
	fi
fi

if [[ -n $NEED_RUBY ]]; then
	if ! which ruby >/dev/null 2>&1; then
		echo >&2 You need ruby to build $NEED_RUBY
		out=1
	fi
fi

if [[ -n $NEED_XKBCOMP ]]; then
	if ! which xkbcomp >/dev/null 2>&1; then
		echo >&2 You need xkbcomp to build $NEED_XKBCOMP
		out=1
	fi
fi

if [[ -n $NEED_XMLTO ]]; then
	if ! which xmlto >/dev/null 2>&1; then
		echo >&2 You need xmlto to build $NEED_XMLTO
		out=1
	fi
fi

if [[ -n $NEED_PKGCONFIG ]]; then
	if ! which pkg-config >/dev/null 2>&1; then
		echo >&2 You need pkg-config to build $NEED_PKGCONFIG
		out=1
	fi
fi

if [[ -n $NEED_GLIBZWO ]]; then
	if ! which glib-genmarshal >/dev/null 2>&1; then
		echo >&2 You need libglib2.0-dev to build $NEED_GLIBZWO
		out=1
	fi
fi

if [[ -n $ADK_USE_CCACHE ]]; then
        if ! which ccache >/dev/null 2>&1; then
                echo >&2 You have selected to build with ccache, but ccache could not be found.
                out=1
        fi
fi

if [[ -n $NEED_RPM ]]; then
	if ! which rpmbuild >/dev/null 2>&1; then
		echo >&2 You need rpmbuild to to use $NEED_RPM package backend
		out=1
	fi
fi

#if [[ -n $ADK_COMPILE_MYSQL && $OStype != Linux ]]; then
#	echo >&2 mySQL does not build on non-GNU/Linux.
#	out=1
#fi

exit $out
