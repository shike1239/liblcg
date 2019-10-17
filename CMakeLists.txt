cmake_minimum_required(VERSION 3.15.2)
# 设置cxx编译器
set(CMAKE_CXX_COMPILER /usr/local/bin/g++-9)
# 设置工程名称和语言
project(LCG VERSION 0.1.0 LANGUAGES CXX)
# 添加源文件地址
add_subdirectory(src/)
# 设置安装地址
set(CMAKE_INSTALL_PREFIX /Users/zhangyi/Desktop/lcg/tmp_install)
#set(CMAKE_INSTALL_PREFIX /usr/local)