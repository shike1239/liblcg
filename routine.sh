#!/bin/bash

if [[ ${1} == "configure" ]]; then
	cd build && rm -rf * && cmake ..
elif [[ ${1} == "build" ]]; then
	cd build && make
elif [[ ${1} == "install" ]]; then
	cd build && make install
elif [[ ${1} == "package" ]]; then
	cd build && cpack -C CPackConfig.cmake
fi