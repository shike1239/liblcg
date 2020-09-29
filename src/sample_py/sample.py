#!/usr/bin/env python3
# -*- coding:utf-8 -*-

import numpy as np
from ctypes import *

# 加载
lib = cdll.LoadLibrary("../../build/lib/liblcg.so")

lib.lcg_error_str.restype = c_char_p
lib.lcg_error_str.argtype = c_int

print("%s" % lib.lcg_error_str(-1023))