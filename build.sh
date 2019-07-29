#!/bin/sh

# ----

echoerr() {
	echo "$@" 1>&2
}

usage() {
	echoerr "Usage: ./build.sh [-b|-c]"
	echoerr "" 1>&2
	echoerr "-b: Build the dictionary"
	echoerr "-c: Cleanup"

	exit 1
}

# ----

build() {
	echo "==> BUILD"

	# We need a `vim` binary in PATH
	command -v vim >/dev/null 2>&1

	if [ $? -ne 0 ] ; then
		echoerr "No vim binary in PATH"
		exit 2
	fi

	# Create and populate build dir
	if [ -e build/ ] ; then
		if [ ! -d build/ ] ; then
			echoerr "build/ exists and isn't a directory"
			exit 2
		fi
	else
		mkdir -p build/

		if [ $? -ne 0 ] ; then
			echoerr "Couldn't create build/"
			exit 2
		fi
	fi

	cp src/de_AT_frami.aff build/de_AT.aff
	cp src/de_AT_frami.dic build/de_AT.dic
	cp src/de_CH_frami.aff build/de_CH.aff
	cp src/de_CH_frami.dic build/de_CH.dic
	cp src/de_DE_frami.aff build/de_DE.aff
	cp src/de_DE_frami.dic build/de_DE.dic

	# Make sure that we've got the right locale...
	export LANG=de_DE.UTF-8

	# ...and are at the right place.
	cd build

	# Mkay, let's build the dictionaries.
	vim -u NONE -e -c "mkspell! de de_AT de_CH de_DE" -c q

	if [ $? -eq 0 ] ; then
		echo "Dictionaries build: build/de.utf-8.spl build/de.utf-8.sug"
	else
		echo "Vim return code not 0, something went wrong"
	fi
}

clean() {
	echo "==> CLEAN"

	if [ -d build/ ] ; then
		rm -Rf build
	fi
}

# ----

BASEDIR=$(realpath $(dirname $0))
cd $BASEDIR


ARGS=$(getopt bc $*)

if [ $? -ne 0 ]; then
	usage
fi

for ARG in $ARGS; do
	case $ARG in
		-b)
			clean
			build
			break
			;;
		-c)
			clean
			break
			;;
		*)
			usage
			break
			;;
	esac
done
