# This file is part of the OpenADK project. OpenADK is copyrighted
# material, please see the LICENCE file in the top-level directory.

shopt -s extglob
topdir=$(pwd)
opath=$PATH
out=0
if [ -z $(which gmake) ];then
	makecmd=$(which make)
else
	makecmd=$(which gmake)
fi

if [[ $NO_ERROR != @(0|1) ]]; then
	echo Please do not invoke this script directly!
	exit 1
fi

set -e
rm -rf $topdir/tmp
mkdir -p $topdir/tmp
cd $topdir/tmp

rm -f foo
echo >FOO
if [[ -e foo ]]; then
	cat >&2 <<-EOF
		ERROR: OpenADK cannot be built in a case-insensitive file system. 
	EOF
	exit 1
fi
rm -f FOO

os=$(uname)
case $os in
Linux)
	# supported with no extra quirks at the moment
	;;
FreeBSD)
	# supported with no extra quirks at the moment
	;;
MirBSD)
	# supported with no extra quirks at the moment
	;;
CYG*)
	# mkdir /openadk 
	# mount -b -s -o managed "C:/openadk" "/openadk"
	# cd /
	# git clone git+ssh://openadk.org/git/openadk.git
	echo "Building OpenADK on $os is needs a managed mount point."
	echo '"mount -b -s -o managed "C:/openadk" "/openadk"'
	;;
NetBSD)
	echo "Building OpenADK on $os is currently unsupported."
	echo "Sorry."
	echo
	echo There are unresolved issues relating to ncurses not
	echo being included in NetBSD®, and these provided by pkgsrc®
	echo lack important header files.
	;;
OpenBSD)
	# supported with no extra quirks at the moment
	# although some packages' autoconf scripts may
	# not properly recognise OpenBSD
	;;
*)
	# unsupported
	echo "Building OpenADK on $os is currently unsupported."
	echo "Sorry."
	exit 1
	;;
esac

set +e

cat >Makefile <<'EOF'
include ${TOPDIR}/prereq.mk
HOSTCFLAGS+=	-O2
all: run-test

test: test.c
	${HOSTCC} ${HOSTCFLAGS} -o $@ $^ ${LDADD}

run-test: test
	./test
EOF
cat >test.c <<-'EOF'
	#include <stdio.h>
	int
	main()
	{
		printf("Yay! Native compiler works.\n");
		return (0);
	}
EOF
X=$($makecmd TOPDIR=$topdir 2>&1)
if [[ $X != *@(Native compiler works)* ]]; then
	echo "$X" | sed 's/^/| /'
	echo Cannot compile a simple test programme.
	echo You must install a host make and C compiler,
	echo usually GCC, to proceed.
	echo
	out=1
fi
rm test 2>/dev/null

#if ! which cpp >/dev/null 2>&1; then
#	echo You must install a C preprocessor to continue.
#	echo
#	out=1
#fi

if ! which tar >/dev/null 2>&1; then
	echo You must install GNU tar to continue.
	echo
	out=1
fi

if ! tar --version|grep GNU >/dev/null 2>&1;then
	if ! which gtar >/dev/null 2>&1; then
		echo You must install GNU tar to continue.
		echo
		out=1
	fi
fi

if ! which gzip >/dev/null 2>&1; then
	echo You must install gzip to continue.
	echo
	out=1
fi

if ! which lzma >/dev/null 2>&1; then
	echo You must install lzma to continue.
	echo
	out=1
fi

if ! which bzip2 >/dev/null 2>&1; then
	echo You must install bzip2 to continue.
	echo
	out=1
fi

if ! which cpio >/dev/null 2>&1; then
	echo You must install cpio to continue.
	echo
	out=1
fi

if ! which unzip >/dev/null 2>&1; then
	echo You must install unzip to continue.
	echo
	out=1
fi

if ! which patch >/dev/null 2>&1; then
	echo You must install patch to continue.
	echo
	out=1
fi

cat >test.c <<-'EOF'
	#include <stdio.h>
	#include <zlib.h>

	#ifndef STDIN_FILENO
	#define STDIN_FILENO 0
	#endif

	int
	main()
	{
		gzFile zstdin;
		char buf[1024];
		int i;

		zstdin = gzdopen(STDIN_FILENO, "rb");
		i = gzread(zstdin, buf, sizeof (buf));
		if ((i > 0) && (i < sizeof (buf)))
			buf[i] = '\0';
		buf[sizeof (buf) - 1] = '\0';
		printf("%s\n", buf);
		return (0);
	}
EOF
X=$(echo 'Yay! Native compiler works.' | gzip | \
    $makecmd TOPDIR=$topdir LDADD=-lz 2>&1)
if [[ $X != *@(Native compiler works)* ]]; then
	echo "$X" | sed 's/^/| /'
	echo Cannot compile a libz test programm.
	echo You must install the zlib development package,
	echo usually called libz-dev, and the run-time library.
	echo
	out=1
fi

[[ -s /usr/include/ncurses.h ]] || if [[ -s /usr/pkg/include/ncurses.h ]]; then
	echo 'HOSTCFLAGS+= -isystem /usr/pkg/include' >>$topdir/prereq.mk
	echo 'HOSTLDFLAGS+=-L/usr/pkg/lib -Wl,-rpath -Wl,/usr/pkg/lib' >>$topdir/prereq.mk
else
	echo Install ncurses header files, please.
	echo
	out=1
fi

if ! which gawk >/dev/null 2>&1; then
	echo You must install GNU awk to continue.
	echo
	out=1
fi

if ! which sed >/dev/null 2>&1; then
	echo You must install GNU sed to continue.
	echo
	out=1
fi

if ! sed --version 2>/dev/null|grep GNU >/dev/null;then
	if ! which gsed >/dev/null 2>&1; then
		echo You must install GNU sed to continue.
		echo
		out=1
	fi
fi

if ! which wget >/dev/null 2>&1; then
	echo You must install wget to continue.
	echo
	out=1
fi

if ! which autoconf >/dev/null 2>&1; then
	echo You must install autoconf to continue.
	echo
	out=1
fi

if ! which automake >/dev/null 2>&1; then
	echo You must install automake to continue.
	echo
	out=1
fi

if ! which libtool >/dev/null 2>&1; then
	echo You must install libtool to continue.
	echo
	out=1
fi

if ! which file >/dev/null 2>&1; then
	echo You must install \"file\" to continue.
	echo
	out=1
fi

if ! which perl >/dev/null 2>&1; then
	echo You must install perl to continue.
	echo
	out=1
fi

cd $topdir
rm -rf tmp

exit $out
