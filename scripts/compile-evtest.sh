#!/usr/bin/env sh
# Download and cross compile evtest
#
# Adapted from https://duckpond.ch/evkill/bash/2020/08/10/disable-reMarkable-touchscreen-with-evkill.html

git clone https://github.com/freedesktop-unofficial-mirror/evtest.git

cd evtest

docker \
  run --rm \
  dockcross/linux-armv7a > dockercross

chmod +x dockercross

./dockercross bash -c "autoreconf -iv && ./configure --host=arm-linux-gnueabi && make"

mv evtest ../bin/
