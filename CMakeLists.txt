cmake_minimum_required(VERSION 3.15.2)
# 设置cxx编译器
# 如果你使用别的编译器，请在这里修改
set(CMAKE_CXX_COMPILER /usr/local/bin/g++-9)
# 设置工程名称和语言
project(LIBLCG VERSION 1.0.0 LANGUAGES CXX)
# 添加源文件地址
add_subdirectory(src/)
# 设置安装地址
set(CMAKE_INSTALL_PREFIX /usr/local)