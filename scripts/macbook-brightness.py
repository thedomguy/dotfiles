#!/usr/bin/env python3
"""Get or set MacBook built-in display brightness via DisplayServices."""
import ctypes, sys

_lib = ctypes.CDLL('/System/Library/PrivateFrameworks/DisplayServices.framework/DisplayServices')
_lib.DisplayServicesGetBrightness.restype = ctypes.c_int
_lib.DisplayServicesGetBrightness.argtypes = [ctypes.c_uint32, ctypes.POINTER(ctypes.c_float)]
_lib.DisplayServicesSetBrightness.restype = ctypes.c_int
_lib.DisplayServicesSetBrightness.argtypes = [ctypes.c_uint32, ctypes.c_float]

BUILTIN_DISPLAY_ID = 0x1

def get():
    val = ctypes.c_float(0)
    _lib.DisplayServicesGetBrightness(BUILTIN_DISPLAY_ID, ctypes.byref(val))
    print(f"{val.value:.4f}")

def set_brightness(level: float):
    level = max(0.0, min(1.0, level))
    _lib.DisplayServicesSetBrightness(BUILTIN_DISPLAY_ID, ctypes.c_float(level))

if __name__ == '__main__':
    if len(sys.argv) < 2 or sys.argv[1] == 'get':
        get()
    elif sys.argv[1] == 'set' and len(sys.argv) == 3:
        set_brightness(float(sys.argv[2]))
    else:
        print(f"Usage: {sys.argv[0]} get | set <0.0-1.0>", file=sys.stderr)
        sys.exit(1)
