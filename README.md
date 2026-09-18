# ESP_TF
1. run create.sf to update source this library just restructures the espressif tensorflow repo (https://github.com/espressif/tflite-micro-esp-examples) to be arduino compatible

## Examples

`examples/HelloESP_TF` loads a real, trained MNIST digit-classifier model and
runs inference on five real MNIST test images bundled in the sketch (no
camera or network required), printing a PASS/FAIL and timing per image. It
builds and runs unmodified under both the Arduino IDE and PlatformIO, with or
without the `ESP_NN` optimization flags below.

For a full camera + WiFi based demo, see
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
- `-std=gnu++17` is not needed; the library builds under the arduino-esp32
  core's own `-std=gnu++2b`.
- After creating or editing `build_opt.h`, do a clean rebuild so cached objects
  are recompiled with the new flags.

### Verified builds

Both configurations are built for `esp32:esp32:esp32s3` with arduino-cli and
core `esp32:esp32@3.3.11` (xtensa-esp-elf gcc 14.2.0):

| Flags | Result |
|---|---|
| none | builds |
| `ESP_NN` + `CONFIG_NN_OPTIMIZED` + `ARCH_ESP32_S3` | builds, 18 ESP32-S3 assembly kernels linked in |

Both configurations were also flashed to a real ESP32-S3 (8MB PSRAM) and run
under both the Arduino IDE and PlatformIO, using `examples/HelloESP_TF`'s
real MNIST model against 5 real, labeled test images:

| Flags | Toolchain | Result | Time/inference |
|---|---|---|---|
| none | Arduino IDE | 5/5 correct | ~1325 ms |
| none | PlatformIO | 5/5 correct | ~1325 ms |
| `ESP_NN` + `CONFIG_NN_OPTIMIZED` + `ARCH_ESP32_S3` | Arduino IDE | 5/5 correct | ~21 ms |
| `ESP_NN` + `CONFIG_NN_OPTIMIZED` + `ARCH_ESP32_S3` | PlatformIO | 5/5 correct | ~21 ms |

The optimized and unoptimized builds produce byte-identical output scores -
the ~60x speedup comes from the ESP32-S3 assembly kernels, not a change in
behavior.

### Known bad releases

**Every release before 2.1.0 fails to build for ESP32-S3 under the Arduino
IDE** with `ESP_NN` enabled: the ESP_NN kernels were copied on top of the
standard kernels without removing the originals, so the Arduino toolchain
(which links every library object directly, unlike PlatformIO's archived
linking) hits "multiple definition" / undefined-reference errors - this is
what [issue #3](https://github.com/Nickjgniklu/ESP_TF/issues/3) is hitting.
`1.0.2` is additionally known bad for unrelated reasons. Fixed in `2.1.0` -
if you hit build errors like these on an older version, upgrade.

## TODO
# Revalidate arduino versions
