#!/bin/sh
#set -x
current=`pwd`
rm -rf cscope
mkdir cscope
find $current/* -name '*.m' > $current/cscope/cscope.files
find $current/* -name '*.mm' >> $current/cscope/cscope.files
find $current/* -name '*.cpp' >> $current/cscope/cscope.files
find $current/* -name '*.h' >> $current/cscope/cscope.files
