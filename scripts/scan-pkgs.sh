# $Id: scan-pkgs.sh 431 2009-05-09 01:01:40Z wbx $
#-
# This file is part of the OpenADK project. OpenADK is copyrighted
# material, please see the LICENCE file in the top-level directory.
#-
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

#-- start adding dependencies here --
if [[ -n $ADK_PACKAGE_ALSA_UTILS ]]; then
	NEED_XMLTO="$NEED_XMLTO alsa-utils"
fi

if [[ -n $ADK_COMPILE_AVAHI ]]; then
	NEED_PKGCONFIG="$NEED_PKGCONFIG avahi"
fi

#if [[ -n $ADK_PACKAGE_RUBY ]]; then
#	NEED_RUBY="$NEED_RUBY ruby"
#fi

if [[ -n $ADK_PACKAGE_GLIB2 ]]; then
	NEED_GLIBZWO="$NEED_GLIBZWO glib2"
	NEED_GETTEXT="$NEED_GETTEXT glib2"
	NEED_PKGCONFIG="$NEED_PKGCONFIG glib2"
fi

#-- start checking dependencies here --

if [[ -n $NEED_GETTEXT ]]; then
	if ! which xgettext >/dev/null 2>&1; then
		echo >&2 You need gettext to build $NEED_GETTEXT
		out=1
	elif ! which msgfmt >/dev/null 2>&1; then
		echo >&2 You need gettext to build $NEED_GETTEXT
		out=1
	fi
fi

if [[ -n $NEED_RUBY ]]; then
	if ! which ruby >/dev/null 2>&1; then
		echo >&2 You need ruby to build $NEED_RUBY
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

#if [[ -n $ADK_COMPILE_MYSQL && $OStype != Linux ]]; then
#	echo >&2 mySQL does not build on non-GNU/Linux.
#	out=1
#fi

#-- end of dependency checks
exit $out
