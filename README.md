# ESP_TF
1. run create.sf to update source this library just restructures the espressif tensorflow repo (https://github.com/espressif/tflite-micro-esp-examples) to be arduino compatible

## Examples
https://github.com/Nickjgniklu/esp_mnist
## Notes

The optimizations below are selected with preprocessor defines. These defines
must reach **every source file in this library**, not just your sketch - putting
`#define ESP_NN` at the top of your `.ino` will not work, because the library is
compiled as a separate set of translation units.

### ESP_NN support

Building with `ESP_NN` will enable espressif ansi layer implementations

Example for PlatformIO (`platformio.ini`):
```ini
build_flags = 
	-std=gnu++17
	-DCORE_DEBUG_LEVEL=5
	-DESP_NN
```

Example for Arduino IDE (`build_opt.h`, see below):
```
-DESP_NN
```

### ESP32_S3
Building with `ESP_NN`, `CONFIG_NN_OPTIMIZED`, and `ARCH_ESP32_S3` will enable ESP32-S3 specific optimizations.

`ARCH_ESP32_S3` must be passed on the command line rather than relying on the
`CONFIG_IDF_TARGET_ESP32S3` auto-detection in `esp_nn.h`: the hand written
assembly kernels never include that header, so they are only assembled when
`ARCH_ESP32_S3` is defined by the build system itself.

Example for PlatformIO (`platformio.ini`):
```ini
build_flags = 
	-std=gnu++17
	-DCORE_DEBUG_LEVEL=5
	-DESP_NN
	-DCONFIG_NN_OPTIMIZED
	-DARCH_ESP32_S3
```

Example for Arduino IDE (`build_opt.h`, see below):
```
-DESP_NN
-DCONFIG_NN_OPTIMIZED
-DARCH_ESP32_S3
```

### Setting build flags in the Arduino IDE

The Arduino IDE has no equivalent of PlatformIO's `build_flags`. Instead, the
arduino-esp32 core (2.0.0 and newer) reads a file named `build_opt.h` from your
**sketch folder** and passes it to the compiler as a response file, which means
it applies to the core, your sketch, and libraries alike - including the `.S`
assembly kernels this library needs for the ESP32-S3 path.

Create `build_opt.h` next to your `.ino`:

```
YourSketch/
  YourSketch.ino
  build_opt.h
```

`build_opt.h` holds **compiler flags, one per line** - not C `#define`
directives:

```
-DESP_NN
-DCONFIG_NN_OPTIMIZED
-DARCH_ESP32_S3
```

Notes:
- `-std=gnu++17` is not needed here; the arduino-esp32 core already selects a
  suitable C++ standard.
- After creating or editing `build_opt.h`, do a clean rebuild so cached objects
  are recompiled with the new flags.

## TODO
# Revalidate arduino versions
# mark versions 1.0.2 1.0.3 as bad releases
