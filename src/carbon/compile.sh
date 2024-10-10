#!/bin/bash

# Script to compile cassio
#
# usage : compile-cassio.sh

# change directory to the path of the script
SCRIPTPATH=${0%/*}
cd "$SCRIPTPATH"

# compile cassio with the Free Pascal Compiler
# fpc -Mobjfpc -Sh -ocassio.exe cassio.pas 2>&-
fpc -Mobjfpc -Sh -k"-macosx_version_min 10.13" -ocassio.exe cassio.pas


