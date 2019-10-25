cmake_minimum_required(VERSION 3.15.2)
# 设置cxx编译器
# 如果你使用别的编译器，请在这里修改
set(CMAKE_CXX_COMPILER /usr/local/bin/g++-9)
# 设置工程名称和语言
project(LIBLCG VERSION 1.1.0 LANGUAGES CXX)
# 设置安装地址
set(CMAKE_INSTALL_PREFIX /usr/local)
# 添加编译选项
option(LCG_FABS "use lcg's fabs" ON)
option(LCG_OPENMP "use openmp" ON)
# 加入一个头文件配置，让cmake对源码进行操作
configure_file(
	"${PROJECT_SOURCE_DIR}/config.h.in"
	"${PROJECT_SOURCE_DIR}/src/lib/config.h"
	)
# 添加openmp的编译命令
find_package(OpenMP)
if (OPENMP_FOUND)
	set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OpenMP_CXX_FLAGS}")
	set (CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${OpenMP_EXE_LINKER_FLAGS}")
endif()
# 添加源文件地址
add_subdirectory(src/)